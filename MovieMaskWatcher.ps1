$ErrorActionPreference = 'SilentlyContinue'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $dir 'movie-mask-watch.log'
$pidFile = Join-Path $dir '.movie-mask-watch.pid'
$exe = Join-Path $dir 'BlackOverlay.exe'
if (-not (Test-Path -LiteralPath $exe)) { $exe = Join-Path (Join-Path $dir 'dist') 'BlackOverlay.exe' }
$graceSeconds = 300
$manualFlag = Join-Path $dir '.movie-manual-off.flag'
function Write-Log($msg) {
    Add-Content -LiteralPath $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $msg) -Encoding UTF8
}
$existing = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'powershell.exe' -and $_.CommandLine -like '*movie-mask-watch.ps1*' -and $_.ProcessId -ne $PID }
if ($existing) { exit 0 }
Set-Content -LiteralPath $pidFile -Value $PID -Encoding ASCII
function Mask-Off {
    Get-Process -Name 'BlackOverlay' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Log 'PotPlayer 播放：主屏 OLED 遮罩已关闭（BlackDisplay 未动）'
}
function Mask-On {
    if (-not (Get-Process -Name 'BlackOverlay' -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $exe -WorkingDirectory $dir -ErrorAction SilentlyContinue
    }
    Write-Log 'PotPlayer 退出满 5 分钟：主屏 OLED 遮罩已恢复'
}
Write-Log '主屏 OLED 遮罩自动检测启动（5 分钟延迟恢复）'
$wasPlaying = $false
$graceUntil = $null
while ($true) {
    $players = Get-Process -Name 'PotPlayerMini64','PotPlayer64' -ErrorAction SilentlyContinue | Where-Object {
        $_.MainWindowTitle -and $_.MainWindowTitle -notmatch '参数选项|设置|Preferences'
    }
    $isPlaying = [bool]$players
    if ($isPlaying) {
        if (-not $wasPlaying) { if (Test-Path -LiteralPath $manualFlag) { Remove-Item -LiteralPath $manualFlag -Force -ErrorAction SilentlyContinue }; Mask-Off }
        elseif (Get-Process -Name 'BlackOverlay' -ErrorAction SilentlyContinue) { Mask-Off }
        $graceUntil = $null
    } elseif ($wasPlaying) {
        if (Test-Path -LiteralPath $manualFlag) { Remove-Item -LiteralPath $manualFlag -Force -ErrorAction SilentlyContinue }
        $graceUntil = (Get-Date).AddSeconds($graceSeconds)
        Write-Log 'PotPlayer 已退出：5 分钟后恢复主屏遮罩'
    } elseif ($graceUntil -and (Get-Date) -ge $graceUntil) {
        if (Test-Path -LiteralPath $manualFlag) {
            Remove-Item -LiteralPath $manualFlag -Force -ErrorAction SilentlyContinue
            Write-Log '手动关闭仍有效：跳过本次自动恢复'
        } else {
            Mask-On
        }
        $graceUntil = $null
    }
    $wasPlaying = $isPlaying
    Start-Sleep -Seconds 2
}