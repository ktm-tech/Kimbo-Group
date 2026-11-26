# Generates images/kimbo-group-logo.png — PNG replica of kimbo-group-logo.svg
# (transparent background, green K + white G monogram, KIMBO GROUP wordmark + green bar)
# Run from the KG_GROUP folder: powershell -NoProfile -ExecutionPolicy Bypass -File tools\make-logo-png.ps1
Add-Type -AssemblyName System.Drawing

$root = 'c:\Users\Mduva\Documents\KG_GROUP'
$out = Join-Path $root 'images\kimbo-group-logo.png'

$W = 2800
$H = 600
$bmp = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::Transparent)

# Slant everything like the SVG's skewX(-4deg); +45px keeps slanted tops inside the canvas
$skew = [Math]::Tan(4 * [Math]::PI / 180)
$g.Transform = New-Object System.Drawing.Drawing2D.Matrix(1, 0, -$skew, 1, 45, 0)

$green = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#00D72B'))
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$fmt = New-Object System.Drawing.StringFormat([System.Drawing.StringFormat]::GenericTypographic)

function Get-AscentPx($font) {
    $em = $font.FontFamily.GetEmHeight($font.Style)
    $asc = $font.FontFamily.GetCellAscent($font.Style)
    return $font.Size * $asc / $em
}

# --- KG monogram (baseline mirrors SVG y=118 @4x) ---
$fontKG = New-Object System.Drawing.Font('Arial Black', 470, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$baseKG = 472
$topKG = $baseKG - (Get-AscentPx $fontKG)
$g.DrawString('K', $fontKG, $green, 0, $topKG, $fmt)
$kw = $g.MeasureString('K', $fontKG, 3000, $fmt).Width
$g.DrawString('G', $fontKG, $white, ($kw - 55), $topKG, $fmt)
$gw = $g.MeasureString('G', $fontKG, 3000, $fmt).Width
$kgRight = $kw - 55 + $gw
$wx = $kgRight + 70

# --- Wordmark, auto-fit so it NEVER clips (the SVG's bug: text wider than its viewBox) ---
$probe = New-Object System.Drawing.Font('Arial Black', 200, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$probeW = $g.MeasureString('KIMBO GROUP', $probe, 6000, $fmt).Width
$probe.Dispose()
$avail = $W - 45 - $wx - 45
$sizeW = [Math]::Min(200, 200 * $avail / $probeW)

$fontW = New-Object System.Drawing.Font('Arial Black', $sizeW, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
$baseW = 372
$topW = $baseW - (Get-AscentPx $fontW)
$g.DrawString('KIMBO GROUP', $fontW, $white, $wx, $topW, $fmt)
$ww = $g.MeasureString('KIMBO GROUP', $fontW, 6000, $fmt).Width

# --- Underline bar (mirrors SVG y=96 h=8 @4x) ---
$g.FillRectangle($green, ($wx + 6), 388, ($ww - 12), 34)

$fontKG.Dispose()
$fontW.Dispose()
$green.Dispose()
$white.Dispose()
$fmt.Dispose()
$g.Dispose()
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$info = New-Object System.IO.FileInfo($out)
'Wrote ' + $out + ' (' + $info.Length + ' bytes)'
