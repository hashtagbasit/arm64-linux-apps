#!/bin/bash
# Build Heroic Games Launcher for arm64 Linux.
#
#   heroic/build.sh [OUT_DIR]
#
# Runs on an arm64 Linux host with Docker. Heroic only ships x86 Linux
# builds, so this builds it from the release source:
#
#   helpers  legendary (Epic), gogdl (GOG) and nile (Amazon) are Python
#            packages. They go into a folder inside the app with their
#            dependencies for Python 3.12, and small wrappers start them
#            with the system python3, so nothing is installed system-wide.
#   app      the Electron app, packed with electron-builder for arm64.
#
# Output: Heroic-<version>-linux-arm64.tar.xz and its .sha256, plus the
# matching source archives, which the GPL needs next to the binary.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT=$(realpath -m "${1:-$HERE/../out}")
HEROIC=2.22.3
LEGENDARY=0.21.1
GOGDL=v1.3.0
NILE=v1.2.0
W=${WORK:-/tmp}/heroic-build
NAME="Heroic-$HEROIC-linux-arm64"
mkdir -p "$W" "$OUT"
rm -rf "$W/src" "$W/helpers" "$W/$NAME"

# source, with our patches on top
curl -fsSL "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/archive/refs/tags/v$HEROIC.tar.gz" \
  -o "$OUT/HeroicGamesLauncher-$HEROIC-source.tar.gz"
tar -xzf "$OUT/HeroicGamesLauncher-$HEROIC-source.tar.gz" -C "$W"
mv "$W/HeroicGamesLauncher-$HEROIC" "$W/src"
for p in "$HERE"/patches/*.patch; do
  patch -d "$W/src" -p1 --forward < "$p"
done

# store helpers for Python 3.12, and their source
docker run --rm -v "$W:/w" -v "$OUT:/out" python:3.12-bookworm bash -euc "
  apt-get -qq update >/dev/null && apt-get -qq install -y git xz-utils >/dev/null
  pip -q install --upgrade pip setuptools wheel
  mkdir -p /w/helpers/py /w/srcs
  cd /w/srcs
  git clone -q --depth 1 --branch $LEGENDARY https://github.com/legendary-gl/legendary legendary-$LEGENDARY
  git clone -q --depth 1 --branch $GOGDL --recurse-submodules --shallow-submodules \
    https://github.com/Heroic-Games-Launcher/heroic-gogdl heroic-gogdl-${GOGDL#v}
  git clone -q --depth 1 --branch $NILE https://github.com/imLinguin/nile nile-${NILE#v}
  pip -q install --no-compile --target /w/helpers/py ./legendary-$LEGENDARY ./heroic-gogdl-${GOGDL#v}
  # nile's folder layout has an assets/ dir setuptools won't package, so its
  # dependencies come from pip and the package itself is copied in
  pip -q install --no-compile --target /w/helpers/py -r nile-${NILE#v}/requirements.txt
  cp -a nile-${NILE#v}/nile /w/helpers/py/nile
  mkdir -p /w/helpers/licenses && cp nile-${NILE#v}/LICENSE.md /w/helpers/licenses/nile-LICENSE.md
  rm -rf /w/helpers/py/bin
  find /w/helpers/py -name __pycache__ -prune -exec rm -rf {} +
  find . -name .git -prune -exec rm -rf {} +
  tar -cJf /out/heroic-helpers-source.tar.xz legendary-$LEGENDARY heroic-gogdl-${GOGDL#v} nile-${NILE#v}
"

D="$W/src/public/bin/arm64/linux"
mkdir -p "$D"
cp -a "$W/helpers/py" "$D/py"
for tool in legendary gogdl nile; do
  cat > "$D/$tool" <<EOF
#!/bin/sh
# $tool, run from the Python package next to this file
here=\$(dirname "\$(readlink -f "\$0")")
PYTHONPATH="\$here/py\${PYTHONPATH:+:\$PYTHONPATH}" exec python3 -c 'import sys
from $tool.cli import main
sys.argv[0] = "$tool"
sys.exit(main())' "\$@"
EOF
  chmod 0755 "$D/$tool"
done

# the app
docker run --rm -v "$W/src:/src" -w /src node:22-bookworm bash -euc "
  corepack enable >/dev/null 2>&1 || npm i -g pnpm@10 >/dev/null
  pnpm install --frozen-lockfile --ignore-scripts
  pnpm run build
  pnpm exec electron-builder --linux dir --arm64 --publish never
"
APP="$W/src/dist/linux-arm64-unpacked"
[[ -x "$APP/heroic" ]] || { echo "no heroic binary" >&2; exit 1; }
# electron-builder drops the helpers' py folder from the package; the
# wrappers it kept look for it next to themselves
cp -a "$D/py" "$APP/resources/app.asar.unpacked/build/bin/arm64/linux/py"
mkdir -p "$APP/LICENSES"
cp "$W/helpers/licenses/"* "$APP/LICENSES/"
cp "$HERE/README-ARM64.txt" "$APP/README-ARM64.txt"

# the helpers have to start on Python 3.12
docker run --rm -v "$APP:/app:ro" python:3.12-slim-bookworm sh -euc '
  b=/app/resources/app.asar.unpacked/build/bin/arm64/linux
  $b/legendary --version; $b/gogdl --version; $b/nile --version'

cp -a "$APP" "$W/$NAME"
tar -C "$W" -cf - "$NAME" | xz -T0 -6 > "$OUT/$NAME.tar.xz"
(cd "$OUT" && sha256sum "$NAME.tar.xz" > "$NAME.tar.xz.sha256")
ls -la "$OUT"
