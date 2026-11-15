param(
    [ValidateSet('movie','old-film','hdr')]
    [string]$ProfileName = 'movie',
    [string]$PotPlayer = 'C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$reg = Join-Path (Join-Path $root 'profiles') ($ProfileName + '.reg')
if (-not (Test-Path -LiteralPath $reg)) { throw "找不到配置：$reg（把导出的 madVR profile .reg 放到 profiles/）" }
Get-Process -Name 'PotPlayerMini64','madHcCtrl' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 800
& reg.exe import $reg | Out-Null
Start-Sleep -Milliseconds 500
if (Test-Path -LiteralPath $PotPlayer) { Start-Process -FilePath $PotPlayer }
Write-Host "已切换 madVR：$ProfileName"