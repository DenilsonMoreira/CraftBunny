$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$toolRoot = Join-Path $env:LOCALAPPDATA 'CraftBunnyAndroid'
New-Item -ItemType Directory -Force -Path $toolRoot | Out-Null
function Download-File($url, $path) {
    if (Test-Path -LiteralPath $path) { return }
    Write-Output "Downloading: $([IO.Path]::GetFileName($path))"
    & curl.exe -L --fail --retry 2 --silent --show-error -o ($path + '.part') $url
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $url" }
    Move-Item -LiteralPath ($path + '.part') -Destination $path
}
$assets = Invoke-RestMethod -Uri 'https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&image_type=jdk&os=windows' -Headers @{'User-Agent'='CraftBunny-Android-Build'}
$package = @($assets)[0].binary.package
$jdkZip = Join-Path $toolRoot 'jdk17.zip'
Download-File $package.link $jdkZip
if ((Get-FileHash -LiteralPath $jdkZip -Algorithm SHA256).Hash.ToLower() -ne $package.checksum.ToLower()) { throw 'JDK checksum mismatch' }
if (-not (Get-ChildItem $toolRoot -Directory -Filter 'jdk-17*')) { Expand-Archive -LiteralPath $jdkZip -DestinationPath $toolRoot }
Write-Output 'JDK 17 ready'
$sdkZip = Join-Path $toolRoot 'android-commandline.zip'
Download-File 'https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip' $sdkZip
$sdkRoot = Join-Path $toolRoot 'android-sdk'
$cliRoot = Join-Path $sdkRoot 'cmdline-tools'
if (-not (Test-Path (Join-Path $cliRoot 'latest/bin/sdkmanager.bat'))) {
    New-Item -ItemType Directory -Force -Path $cliRoot | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $toolRoot 'android-cli') | Out-Null
    & tar.exe -xf $sdkZip -C (Join-Path $toolRoot 'android-cli')
    if ($LASTEXITCODE -ne 0) { throw 'Android tools extraction failed' }
    Move-Item -LiteralPath (Join-Path $toolRoot 'android-cli/cmdline-tools') -Destination (Join-Path $cliRoot 'latest')
}
Write-Output 'Android command line tools ready'
$templates = Join-Path $toolRoot 'export_templates.tpz'
Download-File 'https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz' $templates
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($templates)
try {
    foreach ($name in @('android_debug.apk','android_release.apk')) {
        $entry = $zip.GetEntry("templates/$name")
        if ($null -eq $entry) { throw "Missing template: $name" }
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $toolRoot $name), $true)
        Write-Output "Extracted $name"
    }
} finally { $zip.Dispose() }
Write-Output 'ANDROID_DOWNLOADS_READY'
