$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root 'src'
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$csc = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) { $csc = 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe' }
if (-not (Test-Path $csc)) { throw '找不到 csc.exe（需要 .NET Framework 4.x）' }
$common = @('/target:winexe','/optimize+','/codepage:65001','/r:System.Windows.Forms.dll','/r:System.Drawing.dll')
$tools = @(
    @{Name='ScreenshotHotkey'; Icon='screenshot.ico'},
    @{Name='WindowGuard'},
    @{Name='BlackDisplay'},
    @{Name='BlackOverlay'},
    @{Name='BlackHotkey'}
)
foreach ($t in $tools) {
    $args = @($common) + @('/out:' + (Join-Path $dist ($t.Name + '.exe')))
    if ($t.Icon -and (Test-Path (Join-Path $src $t.Icon))) { $args += '/win32icon:' + (Join-Path $src $t.Icon) }
    $args += (Join-Path $src ($t.Name + '.cs'))
    & $csc $args
    if ($LASTEXITCODE -ne 0) { throw "编译失败：$($t.Name)" }
    Write-Host "OK $($t.Name).exe"
}
Write-Host "输出目录：$dist"