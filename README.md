# Recoil Refresh

Restore playable Recoil laser tag on current Android phones, initially the Nothing Phone (3a) and Samsung Galaxy S23.

**Based on [SimpleCoil](https://github.com/Dees-Troy/SimpleCoil), by Ethan Yonker, Brennan Yonker and its contributors.** Recoil Refresh is an independent fork maintained by Aayan Shaikh. Credit for the upstream implementation remains with its authors.

## Status

Work in progress. Installation, Bluetooth and multiplayer must be verified on physical hardware before either phone is declared supported.

Two paths are being investigated:

1. **Original Recoil 1.4:** inspect the archived APK and identify whether an installation/permission patch is viable. It ships only `armeabi-v7a` native libraries, so a manifest change cannot make it work on a 64-bit-only Android installation. Proprietary binaries and recovered source are kept out of this repository.
2. **Buildable fallback:** this repository preserves the source and history of [Dees-Troy/SimpleCoil](https://github.com/Dees-Troy/SimpleCoil), initially at `b39ab85b287b983a406c595efcbf8b5701579a5b`. Contrary to the archived download site's version listing, upstream has recent Android modernization work. Local changes are committed separately from that baseline.

SimpleCoil connects directly to a Recoil blaster over Bluetooth LE. Its multiplayer server runs on another phone; compatibility with the original hub's game-server protocol must not be assumed. The hub may be usable as the Wi-Fi access point, subject to testing.

## Local workspace

`C:\Users\shaik\coding\recoil_refresh`

Local toolchains belong in `tools/`, original downloads in `original/`, temporary analysis in `work/`, and test APKs in `artifacts/`. These directories are ignored. Do not commit signing keys, device logs containing personal information, or proprietary APK contents.

Run `scripts/Build.ps1` to test, lint and build. The APK is copied to `artifacts/recoil-refresh-debug.apk`. Run `scripts/Device-Check.ps1 -InstallRefresh` with an authorized USB-connected phone to record its compatibility details and install the test build. See [the compatibility report and physical test plan](docs/COMPATIBILITY.md).

## Attribution

The source code is licensed under **Apache License 2.0**; see the complete [LICENSE](LICENSE), [NOTICE](NOTICE), and [third-party credits](THIRD_PARTY_NOTICES.md). Upstream copyright notices and history are retained. Modified upstream files identify the Recoil Refresh changes; Aayan Shaikh claims credit only for those changes and additions.

GameBurp sound effects retain their separate EULA. The Apache license does not relicense the proprietary original Recoil app, hub firmware, trademarks, or separately licensed assets. Recoil Refresh is independent and is not endorsed by Skyrocket, IllFonic, or the SimpleCoil authors. Credits, NOTICE and the full Apache license are also included inside the app.
