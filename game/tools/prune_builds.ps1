param([ValidateRange(2,20)][int]$Keep = 2, [switch]$Apply)
$ErrorActionPreference = 'Stop'
$buildRoot = (Resolve-Path -LiteralPath (Join-Path (Split-Path $PSScriptRoot -Parent) 'builds')).Path.TrimEnd('\')
$entries = @(Get-ChildItem -LiteralPath $buildRoot)
$releaseEntries = @()
foreach ($entry in $entries) {
    $releaseVersion = $null
    if ($entry.PSIsContainer -and $entry.Name -match '^windows-(\d+\.\d+\.\d+)$') { $releaseVersion = $Matches[1] }
    elseif (-not $entry.PSIsContainer -and $entry.Name -match '^CraftBunny-(?:Android|Windows)-(\d+\.\d+\.\d+)\.(?:apk|zip)(?:\.idsig)?$') { $releaseVersion = $Matches[1] }
    elseif (-not $entry.PSIsContainer -and $entry.Name -match '^(?:android|windows)-(\d+\.\d+\.\d+)-(?:export|smoke)\.log$') { $releaseVersion = $Matches[1] }
    if ($null -ne $releaseVersion) { $releaseEntries += [pscustomobject]@{Entry=$entry; Version=[version]$releaseVersion} }
}
$versions = @($releaseEntries.Version | Sort-Object -Unique -Descending)
$retained = @($versions | Select-Object -First $Keep)
if ($retained.Count -lt $Keep) { throw "At least $Keep complete versions must exist before pruning." }
foreach ($releaseVersion in $retained) {
    foreach ($relative in @("windows-$releaseVersion/CraftBunny-$releaseVersion.exe","CraftBunny-Windows-$releaseVersion.zip","CraftBunny-Android-$releaseVersion.apk")) {
        if (-not (Test-Path -LiteralPath (Join-Path $buildRoot $relative) -PathType Leaf)) { throw "Retained release is incomplete: $relative" }
    }
}
$targets = @($releaseEntries | Where-Object {$_.Version -notin $retained})
# Validate all absolute paths before performing any recursive removal. Only
# recognized direct children of this project's builds directory are eligible.
foreach ($target in $targets) {
    $resolved = (Resolve-Path -LiteralPath $target.Entry.FullName).Path
    if (-not [string]::Equals((Split-Path $resolved -Parent),$buildRoot,[System.StringComparison]::OrdinalIgnoreCase)) { throw "Outside build root: $resolved" }
    if ($target.Entry.LinkType) { throw "Refusing link: $resolved" }
    if ($target.Entry.PSIsContainer) {
        $links = @(Get-ChildItem -LiteralPath $resolved -Recurse -Force | Where-Object {$_.LinkType})
        if ($links.Count -gt 0) { throw "Refusing directory containing links: $resolved" }
    }
}
Write-Output ('KEEP: '+($retained -join ', '))
foreach ($target in $targets) {
    Write-Output ($(if ($Apply) {'REMOVE: '} else {'WOULD REMOVE: '})+$target.Entry.Name)
    if ($Apply) { Remove-Item -LiteralPath $target.Entry.FullName -Recurse -Force }
}
Write-Output ('Pruned entries: '+$(if ($Apply) {$targets.Count} else {0}))
