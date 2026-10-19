# Security review of Recoil Refresh 0.1.0-dev

Date: 2026-10-19. Reviewed application source: `bbcc131a682bace4e6e686eac8d1dd6cefd4dbab`.

## Assessment

No malware indicators were found in the inspected application code, packaged permissions or dependency inventory. That is not a guarantee that every dependency or runtime behavior is safe. **The current APK is a development build suitable only for controlled testing on a trusted network, not a security-hardened everyday release.** Multiplayer authentication and location-sharing weaknesses should be fixed before broader use.

This review does not replace the APK, and no application security fixes have been applied as part of it. The findings below remain in the previously delivered APK.

## Exact APK reviewed

- Application ID: `io.github.aayanshaikh007.recoilrefresh`
- Version: `0.1.0-dev`, code `1`
- APK SHA-256: `bd67dc253b335a64bb5a54d64d56c49d7808e557ae190c8241cdb1dca949612d`
- Signing certificate SHA-256: `3eedb2f2b4122581bb1e17e82d6a1cf95b9b9aea067487d9068093c8cba693f4`
- Android v2 APK signature verification passed. This confirms integrity under the development key, not official certification or malware clearance.
- The delivered copy and local build artifact have identical SHA-256 hashes. The APK was built locally from the reviewed project; an independent reproducible-build comparison was not performed.
- The merged manifest confirms `android:debuggable="true"`.
- No native `.so` libraries are packaged.

## Findings

### 1. High privacy concern: automatic server discovery plus server-controlled GPS sharing

After blaster communication begins, `ui/game/GameViewModel.kt:937` automatically searches Wi-Fi for a game server. `network/discovery/DiscoveryClient.kt:77` accepts matching UDP advertisements without authenticating their sender. `UDPListenerService.kt:91` selects the discovered server without a separate trust confirmation.

`network/client/ClientMessageHandler.kt:224` enables GPS whenever the server includes a GPS mode in game information. `MapFragment.java:148` responds by starting location tracking; its location callback sends coordinates through `NetworkSessionGateway.sendLocation` to the game server. If precise location permission was already granted for pairing/map use, there is no separate local approval for sharing with this server.

**Impact:** a rogue server reachable on the same network can potentially receive the phone's location after automatic joining. Android's location permission still applies; the app cannot bypass a permission denial. General location permission is not the same as informed consent to this specific server.

**Confirmed locally:** a test supplied server game information and observed `isUseGPS` change from false to true without a separate local sharing setting. GPS collection or transmission from a physical phone was not tested.

**Fix:** make joining explicit, authenticate/pin the game server, and require a per-phone location-sharing choice that the server cannot enable remotely. Bluetooth pairing on Android 12+ should not require precise GPS access when the player does not use the map.

### 2. Medium: claiming a blaster address can take over a player's game identity and admin role

`network/server/GameRoster.kt:289` treats a supplied blaster address as sufficient proof of reconnection during/after a game. `bindLocked` replaces the previous connection. The player's settings, including game-admin status, remain keyed to that identity. No secret, signature or challenge proves that the new connection is the original phone.

**Impact:** a reachable participant who learns an admin player's blaster address can impersonate that player, displace its connection and inherit game-admin privileges. Those are privileges inside this laser-tag game, not Android device administrator or phone control. Addresses are sent in unencrypted game hellos and may also appear on pairing labels/debug logs.

**Confirmed locally:** a second socket-less connection claiming the first player's address was accepted as a rejoin; the first connection was displaced and its admin flag remained available to the second.

**Fix:** issue an unpredictable reconnection token, authenticate it over a protected session, and bind admin authority to that authenticated session. A MAC address is an identifier, not a password.

### 3. Medium privacy concern: teammate-only GPS filtering happens after disclosure

`network/server/SnapshotBuilder.kt:132` builds one GPS list containing all teams. `network/server/GameServer.kt:661` broadcasts it to every connection. `hardware/location/MapLocationManager.java:232` filters which markers the normal UI displays.

**Impact:** choosing teammate-only GPS hides opponent markers in the standard screen, but it does not keep opponents' coordinates out of a modified client's network data. Because `sendToAll` iterates all accepted connections, a peer need not complete a normal hello before potentially receiving broadcasts while it remains connected.

**Confirmed locally:** with teammate-only mode selected, the snapshot still included positions from both teams. The source also directly shows the broadcast and display-side filtering. No real coordinates were used in this test.

**Fix:** filter positions on the server for each authenticated recipient before serialization, and exclude unauthenticated connections entirely.

### 4. Medium: game traffic and discovery lack cryptographic protection

`network/client/ClientConnection.kt:231` uses a normal `Socket`; `network/server/GameServer.kt:697` uses a normal `ServerSocket`. Messages use `writeUTF`, without TLS or a message authentication scheme. UDP discovery has no signature. No game password or server certificate check was found.

**Impact:** another game endpoint, a malicious access point, or a party able to observe network traffic can read game messages, including names, blaster identifiers and coordinates when GPS is active. Successful interception by a passive neighbor depends on the Wi-Fi's protection and network configuration; being on a Wi-Fi network does not automatically mean every peer can sniff every packet. The server listens on wildcard interfaces, rather than restricting its listener to the Wi-Fi address.

**Fix:** authenticate the lobby and reconnects, protect transport with TLS or an authenticated session protocol, and restrict server reachability to the intended network. Do not expose/forward the server port to the internet.

### 5. Medium/low depending on phone access: diagnostic logs expose identifiers and location

The supplied APK is debuggable. `network/NetTrace.kt:36` and `:42` log full TCP frames in debug builds. `MapFragment.java:68` logs exact coordinates without a debug-build guard. Other logs include player names and blaster addresses.

**Impact:** coordinates and game identifiers can be included in debugging captures or bug reports. Authorized ADB, privileged software and debugging access increase exposure; ordinary unrelated Android apps generally cannot read arbitrary application logs. No automatic upload of these logs was found. A debuggable build also permits debugging/run-as access through authorized development tools.

**Fix:** deliver a signed non-debuggable release and remove/redact coordinates, blaster identifiers and complete payloads in all build types. A release build alone does not remove the unconditional coordinate log.

### 6. Medium availability concern: insufficient limits for hostile network peers

`network/server/GameServer.kt:708` accepts connections without a connection cap or hello deadline and starts reader/writer threads per connection. Frames are queued through `Executors.newSingleThreadExecutor` (`:89`, `:756`), whose pending task queue is unbounded. A slow peer can keep the silence timer alive by sending occasional bytes. The 2-byte frame length bounds an individual frame to 65,535 bytes, and outbound connection queues are bounded, but these do not limit total inbound work/connections.

**Impact:** a reachable hostile peer can potentially exhaust threads, memory or CPU and freeze/crash the game process. This does not establish code execution or compromise of the whole phone.

**Evidence:** source review; no network flood or resource-exhaustion test was performed.

**Fix:** cap total and unauthenticated connections, impose an absolute hello/frame deadline, use bounded inbound queues and per-peer rate limits, and reject gameplay before authentication.

## Other privacy observations

- Android backup is enabled for the `SimpleCoil.xml` preference file. It includes the player name, saved blaster address and settings. This is ordinary platform backup, not covert transmission by the app. Decide whether cloud backup is desirable for these identifiers.
- `BLUETOOTH_ADVERTISE` is declared, although no advertising implementation was found. Remove it if unused.
- Camera access is used for QR scanning. QR export writes only to a location chosen through Android's document picker. No camera recording/upload feature or broad file-storage permission was found.
- Blaster writes use the fixed Recoil command/config characteristics for team IDs, reload, shot mode, cone and recoil. No firmware-flashing/DFU implementation was found in this fork. Hardware safety cannot be certified without the devices/firmware specifications and physical tests.

## Checks performed

- Repository-wide security-sensitive API/endpoint scans over 121 application Java/Kotlin files; targeted manual review of entry points, merged manifest, permissions, BLE command construction, GPS flow, QR handling, preferences/backups, WebView, discovery, TCP framing, client/server message handling and build configuration. This is a risk-based source review, not a line-by-line audit of every third-party library.
- No application implementation of contacts/SMS/call-log access, microphone capture, root/shell execution, installation of other apps, accessibility/device-admin control, dynamic downloaded-code loading, advertising trackers, analytics or credential collection was found. This statement is limited to the inspected code and manifest.
- The About WebView loads a bundled local HTML file. No JavaScript bridge or explicit JavaScript enablement was found. The placeholder map tile source has empty methods and does not implement tile fetching.
- 69 resolved runtime artifacts were compared with checksums from Google's Maven repository or Maven Central: **69 matched, 0 mismatched, 0 unverified**. Of these, 54 used SHA-256 and 15 SHA-1. These checks verify repository consistency, not the safety of an upstream library or reproducible provenance of its source.
- Queried [OSV's package/version API](https://google.github.io/osv.dev/post-v1-querybatch/) for 65 unique resolved Maven package versions: **no matching vulnerability records returned** on the review date, with no pagination indicated. Database coverage is incomplete; zero matches does not establish zero vulnerabilities. Build-only dependencies/tools were not included in this runtime lookup.
- Three local JVM audit probes passed by demonstrating findings 1–3. These probes confirm vulnerable behavior; they are not passing security regression tests. They ran in ignored `work/` scratch sources through a temporary Gradle configuration, with synthetic identities/coordinates and no external target.
- Previous functional baseline: 651 tests passed and Android lint reported 0 errors, 7 warnings. Those results are not a security certification.

## Limits and installation advice

No antivirus engine, independent sandbox, live packet capture, original firmware audit, physical phone/blaster test or full manual review of dependency source was performed. Source scans and the absence of known dependency advisories cannot guarantee safety.

I found no evidence that this APK is designed to compromise your phone. Nevertheless, I recommend fixing the findings before everyday use. For a limited hardware trial, use your own isolated/private Wi-Fi with trusted players, keep server GPS disabled, avoid public/shared networks and do not publish verbose logs. Disabling GPS on a trusted server reduces exposure; it does not fix the lack of a local GPS-sharing veto against a rogue server. A spare test phone is preferable if location privacy is important.

## Wi-Fi base functionality

This build potentially uses the Recoil base as an ordinary Wi-Fi access point, subject to hardware testing. It does **not** implement the original base's built-in game-server protocol or full original hub integration. Multiplayer is served by a phone running Refresh's Dedicated Server. The base's firmware, services and security were outside this review.
