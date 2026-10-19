# Credits and third-party notices

Recoil Refresh is a derivative of [SimpleCoil](https://github.com/Dees-Troy/SimpleCoil), not an original implementation of its game and hardware code. The initial fork is revision `b39ab85b287b983a406c595efcbf8b5701579a5b`. Credit for upstream SimpleCoil belongs to Ethan Yonker, Brennan Yonker and its other contributors. Existing file-level notices and Git history are preserved.

Copyright 2026 Aayan Shaikh applies only to Recoil Refresh modifications and additions. Source code for this fork is provided under [Apache License 2.0](LICENSE), subject to the separate third-party terms below. See [NOTICE](NOTICE).

## Bundled software

| Component | Attribution | License |
| --- | --- | --- |
| SimpleCoil | Ethan Yonker, Brennan Yonker and upstream contributors | Apache-2.0 |
| AndroidX libraries, including view binding | The Android Open Source Project and the component authors | Apache-2.0 |
| Material Components for Android | Google LLC and contributors | Apache-2.0 |
| ZXing core | ZXing authors | Apache-2.0 |
| ZXing Android Embedded | ZXing authors, Journey Mobile and contributors | Apache-2.0 |
| Kotlin standard library | JetBrains and Kotlin contributors | Apache-2.0 |
| kotlinx.coroutines | JetBrains and contributors | Apache-2.0 |
| JetBrains annotations | JetBrains and contributors | Apache-2.0 |
| Guava listenablefuture and Error Prone annotations | Google and contributors | Apache-2.0 |
| JSpecify | JSpecify authors | Apache-2.0 |
| Android BluetoothLeGatt sample portions | Copyright 2013 The Android Open Source Project | Apache-2.0 |

The runtime dependency versions reviewed for the first build are recorded in [the dependency inventory](docs/security/dependency-audit.json). Individual component copyright and license notices remain applicable; this table does not replace them. Apache license text is included at the repository root and bundled in the app's assets and About section.

## Sound effects

Upstream credits the sound effects to GameBurp.com. The original [GameBurp Sound Effects EULA](app/src/main/res/raw/gameburp_sfx_license.pdf) is retained and packaged as an Android raw resource. The project Apache license does not relicense these sound assets or grant rights beyond their own terms.

## Original Recoil product

The original Recoil application, hardware and hub firmware are separate from SimpleCoil. This repository does not distribute the proprietary original APK or recovered proprietary source. RECOIL and other product names identify compatibility; no endorsement or ownership of those names is claimed.
