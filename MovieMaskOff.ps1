param()
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$flag = Join-Path $dir '.movie-manual-off.flag'
Set-Content -LiteralPath $flag -Value (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -Encoding ASCII
Get-Process -Name 'BlackOverlay' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host '主屏 OLED 遮罩已关闭'
exit 0