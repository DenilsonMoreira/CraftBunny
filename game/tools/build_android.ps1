param([switch]$Configure, [string]$GodotPath = $env:GODOT_BIN)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$cache = Join-Path $env:LOCALAPPDATA 'CraftBunnyAndroid'
$jdk = Get-ChildItem $cache -Directory -Filter 'jdk-17*' | Select-Object -First 1
if ($null -eq $jdk) { throw 'Run tools/setup_android.ps1 and install the Android SDK first.' }
$env:JAVA_HOME = $jdk.FullName
if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -ne $godotCommand) { $GodotPath = $godotCommand.Source }
}
if ([string]::IsNullOrWhiteSpace($GodotPath) -or -not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Set GODOT_BIN or pass -GodotPath with the Godot 4.7.2 console executable.'
}
$godot = $GodotPath
$output = Join-Path $projectRoot 'builds/CraftBunny-Android-Test.apk'
New-Item -ItemType Directory -Force -Path (Split-Path $output) | Out-Null
if ($Configure) {
    & $godot --headless --editor --path $projectRoot --script res://tools/configure_android.gd
    if ($LASTEXITCODE -ne 0) { throw 'Android configuration failed' }
}
& $godot --headless --path $projectRoot --export-debug Android $output
if ($LASTEXITCODE -ne 0) { throw 'APK export failed' }
& (Join-Path $cache 'android-sdk/build-tools/35.0.1/apksigner.bat') verify --verbose $output
if ($LASTEXITCODE -ne 0) { throw 'APK signature verification failed' }
Get-Item -LiteralPath $output | Select-Object FullName,Length
Get-FileHash -LiteralPath $output -Algorithm SHA256
