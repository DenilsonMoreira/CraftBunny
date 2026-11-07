Add-Type -AssemblyName System.Drawing

$sourcePath = Join-Path (Get-Location) 'assets/references/characters/bunny_animations_current.png'
$outputRoot = Join-Path (Get-Location) 'assets/production/characters/bunny/draft'
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$image = [System.Drawing.Bitmap]::new($sourcePath)
$states = @{
    idle = @(585, 0, 112, 96, 7)
    walk = @(585, 94, 112, 86, 7)
    run = @(585, 180, 112, 88, 7)
    jump = @(585, 270, 112, 112, 7)
    land = @(585, 382, 112, 96, 6)
    hurt = @(585, 472, 112, 86, 7)
    death = @(585, 552, 112, 88, 7)
    craft = @(585, 632, 112, 104, 6)
    attack = @(585, 730, 112, 104, 4)
}

foreach ($state in $states.Keys) {
    $spec = $states[$state]
    $stateDir = Join-Path $outputRoot $state
    New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
    $x0 = $spec[0]; $y = $spec[1]; $w = $spec[2]; $h = $spec[3]; $count = $spec[4]
    for ($i = 0; $i -lt $count; $i++) {
        $x = $x0 + ($i * 125)
        $rect = [System.Drawing.Rectangle]::new($x, $y, $w, $h)
        $frame = $image.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $frame.Save((Join-Path $stateDir ('frame_{0:D2}.png' -f $i)), [System.Drawing.Imaging.ImageFormat]::Png)
        $frame.Dispose()
    }
}

$image.Dispose()
