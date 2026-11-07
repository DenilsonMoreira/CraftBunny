Add-Type -AssemblyName System.Drawing

$root = Join-Path (Get-Location) 'assets/production/characters/bunny'
$sourceRoot = Join-Path $root 'cleaned-draft'
$states = @('idle','walk','run','jump','land','hurt','death','craft','attack')
$frameSize = 112
$columns = 7
$rows = $states.Count
$outputPath = Join-Path $root 'bunny_spritesheet_clean.png'

$sheet = [System.Drawing.Bitmap]::new($frameSize*$columns, $frameSize*$rows, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

for ($row = 0; $row -lt $states.Count; $row++) {
    $files = @(Get-ChildItem (Join-Path $sourceRoot $states[$row]) -Filter *.png | Sort-Object Name)
    for ($col = 0; $col -lt [Math]::Min($files.Count,$columns); $col++) {
        $frame = [System.Drawing.Image]::FromFile($files[$col].FullName)
        $graphics.DrawImage($frame, $col*$frameSize, $row*$frameSize, $frameSize, $frameSize)
        $frame.Dispose()
    }
}

$graphics.Dispose()
$sheet.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()

@"
# Bunny spritesheet clean

- Arquivo: `bunny_spritesheet_clean.png`
- Grade: 7 colunas x 9 linhas
- Célula: 112x112 px
- Filtro recomendado: Nearest

Linhas: idle, walk, run, jump, land, hurt, death, craft, attack.
"@ | Set-Content (Join-Path $root 'bunny_spritesheet_clean.md')
