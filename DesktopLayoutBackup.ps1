param(
    [ValidateSet('backup','restore','list')]
    [string]$Action = 'backup',
    [string]$File = ''
)
$ErrorActionPreference = 'Stop'
$dir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'layout-backups'
$key = 'HKCU\Software\Microsoft\Windows\Shell\Bags\1\Desktop'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

if ($Action -eq 'list') {
    Get-ChildItem $dir -Filter '*.reg' | Sort-Object LastWriteTime -Descending | Select-Object Name, Length, LastWriteTime
    exit 0
}

if ($Action -eq 'backup') {
    $name = 'desktop-layout-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.reg'
    $out = Join-Path $dir $name
    & reg.exe export $key $out /y | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "备份失败：$out" }
    Write-Host "已备份：$out"
    exit 0
}

if ($Action -eq 'restore') {
    if (-not $File) {
        $File = (Get-ChildItem $dir -Filter '*.reg' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
    }
    if (-not $File -or -not (Test-Path -LiteralPath $File)) { throw '找不到布局备份' }
    $before = Join-Path $dir ('before-restore-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.reg')
    & reg.exe export $key $before /y | Out-Null
    Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    & reg.exe import $File | Out-Null
    Start-Process explorer.exe
    Write-Host "已恢复：$File"
    Write-Host "恢复前备份：$before"
    exit 0
}