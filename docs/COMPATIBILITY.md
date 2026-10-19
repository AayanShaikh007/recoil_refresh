# Compatibility investigation and hardware test plan

## Original Recoil 1.4

Inspected on 2026-10-19. Download: https://recoil-game.de/mobile/apps/Recoil-Game_1.4.apk

SHA-256: `89941d960a807721cd20e803309a993b04d2d665ca829461ebb63c36af74b292`

| Property | Observed value |
| --- | --- |
| Package | `com.illfonic.recoil` |
| Version | 1.4, code 102 |
| Minimum / target API | 22 / 26 |
| Native ABIs | `armeabi-v7a` only |
| Engine | Unity with Mono and managed C# assemblies |
| Native dependencies | Unity, Mono, Auro, Wwise (`libAkSoundEngine.so`) |

The original clears Android 14's minimum target of 23 and Android 15's minimum of 24. A generic "not compatible" message is not sufficient to identify the actual failure. An older original APK may have a different target. Check the device ABI list and exact installation error before deciding to patch.

A 64-bit-only OS cannot load these 32-bit native libraries. Updating the manifest or adding an `arm64-v8a` directory does not convert them. Restoring the original there requires a reconstructed Unity project and compatible 64-bit versions/replacements of all native plugins. The APK's C# assemblies alone are not the full project. No such rebuild is claimed here.

Primary references:

- https://developer.android.com/about/versions/14/behavior-changes-all#minimum-target-api-level
- https://developer.android.com/about/versions/15/behavior-changes-all#minimum-target-api-level
- https://developer.android.com/guide/practices/page-sizes
- https://developer.android.com/develop/connectivity/bluetooth/bt-permissions

## Recoil Refresh baseline

Based on SimpleCoil `b39ab85b287b983a406c595efcbf8b5701579a5b`. Minimum API 23; compile/target API 37. This codebase has no bundled native `.so` dependency, avoiding the original's 32-bit architecture restriction and native 16 KB page-size problem. The built APK must be checked again after dependency changes.

| Device | Intended coverage | Status |
| --- | --- | --- |
| Nothing Phone (3a) | Installed Android version, BLE blaster pairing, offline Wi-Fi multiplayer | Needs physical testing |
| Samsung Galaxy S23 | Installed Android version, BLE blaster pairing, offline Wi-Fi multiplayer | Needs physical testing |
| Newer / 64-bit-only phones | Install and startup, permissions, BLE and network | Architecture-independent APK; not hardware verified |

### Build on this Windows PC

JDK 21 and Android SDK are local to `tools/`. No global PATH changes are needed.

```powershell
.\scripts\Build.ps1
```

On a fresh workstation, install JDK 21, Android platform 37.0 and build tools 37.0.0, set `JAVA_HOME` and `ANDROID_HOME`, then run the same script. The Gradle wrapper downloads Gradle. Debug builds are signed automatically with a development key and are for testing. Keep the signing key stable to allow updates; keys are not committed.

### Identify the installation failure

Enable Developer options and USB debugging on the phone, connect it over USB and approve this PC on the phone. Then:

```powershell
.\scripts\Device-Check.ps1
.\scripts\Device-Check.ps1 -InstallRefresh
```

The script saves model, Android API, supported ABIs, page size and (when requested) the exact Refresh install result to ignored `work/device-check.json`. It does not collect accounts, Bluetooth MAC addresses, device serials in the saved report, or general phone logs. With multiple phones, use `-Serial` to select one. It does not uninstall anything or override Android's old-target protection.

### Physical acceptance checks (run on each phone)

1. Install Refresh normally and launch it. Record model and Android version using the script.
2. Grant Nearby devices and precise Location access. On Android 13+, deny Notifications once: blaster pairing should still work. Grant notifications afterward if desired.
3. Connect to a powered blaster. Verify trigger, ammunition count, reload, recoil toggle and firing modes. Repeat with each blaster type available.
4. Use a second phone/blaster to verify hits, health, elimination and respawn. Power-cycle a blaster and verify reconnection.
5. Join the same Wi-Fi on both phones. Keep mobile data enabled. If using the Recoil hub, choose to stay connected when Android says it has no internet. Run Refresh's Dedicated Server on one phone, then join from the other. If discovery fails, try the displayed server IP to distinguish routing from broadcast failure.
6. Verify scoreboard updates, team rules, restart/end game, backgrounding, screen lock and reconnection. On Samsung, check that battery restrictions do not stop the connected-device service.
7. Repeat on an ordinary Wi-Fi router to isolate any hub client-isolation or routing problem. Never assume the old hub game server speaks SimpleCoil's protocol.

The hub can potentially provide Wi-Fi; Refresh hosts game rules in the app's dedicated server. Original-app multiplayer features and hub firmware integration are not restored by this fallback. Do not mix original Recoil and Refresh clients in one match.

Record actual results in a dated local report before changing any status above to supported. Unit tests and a successful build do not prove hardware interoperability.
