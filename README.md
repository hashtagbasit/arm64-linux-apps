<h1 align="center">arm64-linux-apps</h1>

<p align="center"><strong>ARM64 builds of Linux apps that don't ship one</strong></p>

<p align="center">
  Unofficial aarch64 builds of desktop and gaming apps for ARM Linux handhelds, laptops and boards.
</p>

<p align="center">
  <a href="https://github.com/hashtagbasit/arm64-linux-apps/releases"><img alt="Releases" src="https://img.shields.io/github/v/release/hashtagbasit/arm64-linux-apps?style=flat&color=18181a"></a>
  <a href="LICENSE"><img alt="GPL-3.0 license" src="https://img.shields.io/badge/license-GPL--3.0-18181a?style=flat"></a>
</p>

<p align="center">
  <a href="https://github.com/hashtagbasit/arm64-linux-apps/releases"><strong>Downloads</strong></a>
  ·
  <a href="#apps">Apps</a>
  ·
  <a href="#building">Building</a>
  ·
  <a href="https://github.com/hashtagbasit/SteamOS-ARM-Handhelds">SteamOS ARM</a>
</p>

> [!WARNING]
> These are unofficial builds. They are not made or supported by the projects
> they come from, so please report problems here and not upstream.

## About

Some apps only publish x86 Linux builds even though their code runs fine on
arm64. This repo builds them from their own release source for aarch64 Linux,
with as few changes as possible. Every change is a patch in the app's folder,
and every release carries the source it was built from.

The builds are used by [SteamOS ARM](https://github.com/hashtagbasit/SteamOS-ARM-Handhelds),
where Loadout installs them, but they work on any arm64 Linux that has what
each app needs.

## Apps

| App | Version | Needs | Notes |
|---|---|---|---|
| [Heroic Games Launcher](https://heroicgameslauncher.com) | 2.22.3 | Python 3.12, GTK 3 | Epic, GOG and Amazon. Doesn't download x86 Wine, DXVK or Winetricks on arm64. Start with `--no-sandbox` where Chromium's sandbox helper isn't setuid. |

## Installing

Download the `.tar.xz` from [Releases](https://github.com/hashtagbasit/arm64-linux-apps/releases),
check it against its `.sha256`, unpack it anywhere and run the app from the
folder:

```sh
sha256sum -c Heroic-2.22.3-linux-arm64.tar.xz.sha256
tar -xf Heroic-2.22.3-linux-arm64.tar.xz
./Heroic-2.22.3-linux-arm64/heroic --no-sandbox
```

## Building

Each app has its own folder with a `build.sh`. They run on an arm64 Linux
host with Docker:

```sh
heroic/build.sh out/
```

## License

The build scripts and patches here are GPL-3.0. Each app keeps its own
license; the licenses ship inside each build and the matching source is
attached to its release.
