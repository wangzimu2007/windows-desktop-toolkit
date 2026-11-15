param()
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $dir 'BlackOverlay.exe'
if (-not (Test-Path -LiteralPath $exe)) { $exe = Join-Path (Join-Path $dir 'dist') 'BlackOverlay.exe' }
$flag = Join-Path $dir '.movie-manual-off.flag'
if (Test-Path -LiteralPath $flag) { Remove-Item -LiteralPath $flag -Force -ErrorAction SilentlyContinue }
if (-not (Get-Process -Name 'BlackOverlay' -ErrorAction SilentlyContinue)) { Start-Process -FilePath $exe -WorkingDirectory $dir -ErrorAction SilentlyContinue }
Write-Host '主屏 OLED 遮罩已恢复'
exit 0