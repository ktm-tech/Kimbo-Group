Add-Type -AssemblyName System.Drawing
$fs = [System.IO.File]::OpenRead('images\kimbo-group-logo.png')
$img = [System.Drawing.Bitmap]::FromStream($fs)
'Size: ' + $img.Width + 'x' + $img.Height
$minX = $img.Width; $minY = $img.Height; $maxX = -1; $maxY = -1; $count = 0; $green = 0; $white = 0
for ($y = 0; $y -lt $img.Height; $y += 2) {
  for ($x = 0; $x -lt $img.Width; $x += 2) {
    $p = $img.GetPixel($x, $y)
    if ($p.A -gt 16) {
      $count++
      if ($x -lt $minX) { $minX = $x }
      if ($x -gt $maxX) { $maxX = $x }
      if ($y -lt $minY) { $minY = $y }
      if ($y -gt $maxY) { $maxY = $y }
      if ($p.G -gt 150 -and $p.R -lt 150 -and $p.B -lt 150) { $green++ }
      elseif ($p.R -gt 180 -and $p.G -gt 180 -and $p.B -gt 180) { $white++ }
    }
  }
}
'Opaque samples: ' + $count + '  green: ' + $green + '  white: ' + $white
'Bounds x:[' + $minX + '-' + $maxX + '] y:[' + $minY + '-' + $maxY + ']'
$img.Dispose(); $fs.Close()
