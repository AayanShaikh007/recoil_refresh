# Recoil Refresh

Restore playable Recoil laser tag on current Android phones, initially the Nothing Phone (3a) and Samsung Galaxy S23.

## Status

Work in progress. Installation, Bluetooth and multiplayer must be verified on physical hardware before either phone is declared supported.

Two paths are being investigated:

1. **Original Recoil 1.4:** inspect the archived APK and identify whether an installation/permission patch is viable. It ships only `armeabi-v7a` native libraries, so a manifest change cannot make it work on a 64-bit-only Android installation. Proprietary binaries and recovered source are kept out of this repository.
2. **Buildable fallback:** this repository preserves the source and history of [Dees-Troy/SimpleCoil](https://github.com/Dees-Troy/SimpleCoil), initially at `b39ab85b287b983a406c595efcbf8b5701579a5b`. Contrary to the archived download site's version listing, upstream has recent Android modernization work. Local changes are committed separately from that baseline.

SimpleCoil connects directly to a Recoil blaster over Bluetooth LE. Its multiplayer server runs on another phone; compatibility with the original hub's game-server protocol must not be assumed. The hub may be usable as the Wi-Fi access point, subject to testing.

## Local workspace

`C:\Users\shaik\coding\recoil_refresh`

Local toolchains belong in `tools/`, original downloads in `original/`, temporary analysis in `work/`, and test APKs in `artifacts/`. These directories are ignored. Do not commit signing keys, device logs containing personal information, or proprietary APK contents.

## Attribution

SimpleCoil is licensed under Apache-2.0; see [LICENSE](LICENSE). Upstream copyright and license notices are retained. Recoil Refresh is an independent compatibility effort, not an official Skyrocket release.
