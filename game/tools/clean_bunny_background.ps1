Add-Type -AssemblyName System.Drawing

$root = Join-Path (Get-Location) 'assets/production/characters/bunny'
$sourceRoot = Join-Path $root 'draft'
$outputRoot = Join-Path $root 'cleaned-draft'

foreach ($source in Get-ChildItem $sourceRoot -Recurse -Filter *.png) {
    $relative = $source.FullName.Substring($sourceRoot.Length).TrimStart('\')
    $target = Join-Path $outputRoot $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    $bitmap = [System.Drawing.Bitmap]::new($source.FullName)
    $w = $bitmap.Width; $h = $bitmap.Height
    $remove = New-Object 'bool[,]' $w,$h
    $queue = [System.Collections.Generic.Queue[System.Drawing.Point]]::new()

    for ($x = 0; $x -lt $w; $x++) { $queue.Enqueue([Drawing.Point]::new($x,0)); $queue.Enqueue([Drawing.Point]::new($x,$h-1)) }
    for ($y = 0; $y -lt $h; $y++) { $queue.Enqueue([Drawing.Point]::new(0,$y)); $queue.Enqueue([Drawing.Point]::new($w-1,$y)) }
    while ($queue.Count -gt 0) {
        $p = $queue.Dequeue()
        if ($p.X -lt 0 -or $p.X -ge $w -or $p.Y -lt 0 -or $p.Y -ge $h -or $remove[$p.X,$p.Y]) { continue }
        $c = $bitmap.GetPixel($p.X,$p.Y)
        if ([Math]::Max($c.R,[Math]::Max($c.G,$c.B)) -gt 175) { continue }
        $remove[$p.X,$p.Y] = $true
        $queue.Enqueue([Drawing.Point]::new($p.X+1,$p.Y)); $queue.Enqueue([Drawing.Point]::new($p.X-1,$p.Y))
        $queue.Enqueue([Drawing.Point]::new($p.X,$p.Y+1)); $queue.Enqueue([Drawing.Point]::new($p.X,$p.Y-1))
    }
    for ($x = 0; $x -lt $w; $x++) { for ($y = 0; $y -lt $h; $y++) { if ($remove[$x,$y]) { $bitmap.SetPixel($x,$y,[Drawing.Color]::Transparent) } } }
    $bitmap.Save($target, [Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}
