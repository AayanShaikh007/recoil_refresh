# First compatibility build — 2026-10-19

## Delivered build

- Recoil Refresh 0.1.0-dev, application ID `io.github.aayanshaikh007.recoilrefresh`.
- Based on SimpleCoil; this is not a rebuilt original Recoil app.
- Minimum Android API 23; target API 37.
- APK is signed for development testing and contains no native `.so` files.
- Source and build tools are under `C:\Users\shaik\coding\recoil_refresh`.

## Verification

- All 651 JVM tests pass, including network protocol fixtures and notification-denial regression coverage.
- GitHub Actions successfully runs unit tests, Android lint and APK assembly. The first SDK setup failure was corrected; subsequent runs pass.
- APK signature verified with Android's `apksigner`.
- APK metadata checked with Android's `aapt`.
- PowerShell scripts parse successfully; the device check gives a clear error if no authorized phone is connected.
- Windows network fixture checkouts use LF to preserve expected protocol bytes.
- No physical installation, radio connection, hub Wi-Fi, hit detection or multiplayer match has been tested here. The owner will test those separately.

## Local changes beyond upstream

- Separate app ID and visible name to allow installation beside original Recoil and SimpleCoil.
- Notification permission is optional for Bluetooth pairing; Android 13+ users can deny it without being trapped in a permission loop.
- Removed the JetBrains-specific daemon JDK restriction; a standard JDK 21 can build on Windows.
- Corrected the in-app multiplayer explanation to match the current dedicated-server architecture.
- Added local build/signature/ABI checks, a USB compatibility report and GitHub build artifacts.

For hardware acceptance steps and the original app investigation, see [COMPATIBILITY.md](COMPATIBILITY.md). The first milestone is a testable APK; support for a particular phone remains provisional until its physical tests pass.
