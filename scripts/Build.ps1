param([switch]$SkipChecks)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot
try {
    $localJdk = Get-ChildItem "$projectRoot/tools/jdk" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($localJdk) { $env:JAVA_HOME = $localJdk.FullName }
    if (Test-Path "$projectRoot/tools/android-sdk") { $env:ANDROID_HOME = "$projectRoot/tools/android-sdk" }
    if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME/bin/java.exe")) {
        throw 'Set JAVA_HOME to a JDK 21 installation, or unpack it under tools/jdk/.'
    }
    if (-not $env:ANDROID_HOME -or -not (Test-Path "$env:ANDROID_HOME/platforms")) {
        throw 'Set ANDROID_HOME to an Android SDK with platform 37.0 and build tools 37.0.0.'
    }
    $tasks = @('assembleDebug')
    if (-not $SkipChecks) { $tasks += @('testDebugUnitTest', 'lintDebug') }
    & ./gradlew.bat @tasks --console=plain
    if ($LASTEXITCODE -ne 0) { throw "Gradle failed ($LASTEXITCODE)." }
    New-Item -ItemType Directory -Force artifacts | Out-Null
    Copy-Item app/build/outputs/apk/debug/app-debug.apk artifacts/recoil-refresh-debug.apk
    Get-FileHash artifacts/recoil-refresh-debug.apk -Algorithm SHA256
    Write-Host 'Built artifacts/recoil-refresh-debug.apk. Physical phone/blaster testing is still required.'
} finally { Pop-Location }
