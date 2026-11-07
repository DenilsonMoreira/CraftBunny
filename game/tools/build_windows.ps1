param([string]$GodotPath = $env:GODOT_BIN)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($null -ne $godotCommand) { $GodotPath = $godotCommand.Source }
}
if ([string]::IsNullOrWhiteSpace($GodotPath) -or -not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw 'Set GODOT_BIN or pass -GodotPath with the Godot console executable.'
}
$projectFile = [System.IO.File]::ReadAllText((Join-Path $projectRoot 'project.godot'))
$versionMatch = [regex]::Match($projectFile, 'config/version="([0-9]+\.[0-9]+\.[0-9]+)"')
if (-not $versionMatch.Success) { throw 'Project version is missing.' }
$version = $versionMatch.Groups[1].Value
$outputDirectory = Join-Path $projectRoot "builds/windows-$version"
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$output = Join-Path $outputDirectory "CraftBunny-$version.exe"
& $GodotPath --headless --editor --path $projectRoot --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
& $GodotPath --headless --path $projectRoot --export-release Windows $output
if ($LASTEXITCODE -ne 0) { throw 'Windows export failed.' }
Get-Item -LiteralPath $output | Select-Object FullName,Length
Get-FileHash -LiteralPath $output -Algorithm SHA256
