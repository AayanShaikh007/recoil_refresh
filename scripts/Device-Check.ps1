param(
    [string]$Serial,
    [switch]$InstallRefresh,
    [string]$Apk
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$adbPath = "$projectRoot/tools/android-sdk/platform-tools/adb.exe"
if (-not (Test-Path $adbPath)) {
    $adbCommand = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $adbCommand) { throw 'Android platform-tools are required. See docs/COMPATIBILITY.md.' }
    $adbPath = $adbCommand.Source
}
$deviceLines = & $adbPath devices
if ($LASTEXITCODE -ne 0) { throw 'Could not list Android devices.' }
$devices = @($deviceLines | Where-Object { $_ -match '^\S+\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] })
if (-not $Serial) {
    if ($devices.Count -ne 1) { throw 'Connect and authorize exactly one phone over USB, or specify -Serial. Enable USB debugging in Developer options.' }
    $Serial = $devices[0]
}
if ($Serial -notin $devices) { throw 'The selected phone is not connected and authorized.' }
function Read-DeviceProperty([string]$Name) {
    $value = & $adbPath -s $Serial shell getprop $Name
    if ($LASTEXITCODE -ne 0) { throw "Could not read $Name." }
    return ($value -join '').Trim()
}
$abis = Read-DeviceProperty 'ro.product.cpu.abilist'
$report = [ordered]@{
    manufacturer = Read-DeviceProperty 'ro.product.manufacturer'
    model = Read-DeviceProperty 'ro.product.model'
    android = Read-DeviceProperty 'ro.build.version.release'
    api = Read-DeviceProperty 'ro.build.version.sdk'
    supportedAbis = $abis
    original14ArchitectureCompatible = ('armeabi-v7a' -in ($abis -split ','))
    original14Note = 'ABI compatibility alone does not establish that the original app runs.'
    refreshPackage = 'io.github.aayanshaikh007.recoilrefresh'
}
$pageSize = & $adbPath -s $Serial shell getconf PAGE_SIZE
if ($LASTEXITCODE -eq 0) { $report.pageSize = ($pageSize -join '').Trim() }
if ($InstallRefresh) {
    if (-not $Apk) { $Apk = "$projectRoot/artifacts/recoil-refresh-debug.apk" }
    if (-not (Test-Path -LiteralPath $Apk)) { throw "APK not found: $Apk. Run scripts/Build.ps1 first." }
    $installOutput = & $adbPath -s $Serial install -r $Apk 2>&1
    $installExitCode = $LASTEXITCODE
    $report.installResult = ($installOutput -join "`n")
    $report.installSucceeded = ($installExitCode -eq 0)
}
New-Item -ItemType Directory -Force "$projectRoot/work" | Out-Null
$report | ConvertTo-Json | Set-Content "$projectRoot/work/device-check.json"
$report | ConvertTo-Json | Write-Output
if ($InstallRefresh -and -not $report.installSucceeded) { throw 'Installation failed. The exact installer response is saved in work/device-check.json.' }
