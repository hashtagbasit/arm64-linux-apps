Heroic Games Launcher 2.22.3, unofficial ARM64 (aarch64) Linux build
=====================================================================

This is an unofficial build, made by the arm64-linux-apps project
(https://github.com/steamos-arm-port/arm64-linux-apps). It is not made or
supported by the Heroic team. Please report problems with this build there,
not to Heroic.

What's different from the official release:
- built for arm64 Linux from Heroic's v2.22.3 source
- the store helpers (legendary for Epic, gogdl for GOG, nile for Amazon) are
  their Python packages in resources/app.asar.unpacked/build/bin/arm64/linux/py,
  run with the system Python 3.12 instead of x86 binaries
- one source change (heroic/patches/0001-no-x86-tool-downloads-on-arm64-linux.patch
  in the project): on arm64 Linux Heroic doesn't download x86 DXVK, VKD3D,
  Winetricks or a default Wine at start, since none of them can run there

Licences: Heroic, legendary, gogdl and nile are GPL-3.0; their source, with
the patch, is attached to the same release this file came from. Electron and
Chromium licences are in LICENSE.electron.txt and LICENSES.chromium.html; the
Python libraries' licences are in their .dist-info folders; nile's is in
LICENSES/nile-LICENSE.md.
