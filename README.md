# Windows Desktop Toolkit

一组无依赖的 Windows 桌面小工具（C# WinForms / PowerShell），适合多显示器、截图、OLED 护屏和 PotPlayer 自动遮罩场景。

## 包含

| 工具 | 说明 |
|---|---|
| `ScreenshotHotkey` | 全局截图：默认 Ctrl+Alt+Insert（4K）/ 加 Shift（2K），可通过 ini 改键 |
| `WindowGuard` | 新窗口/还原窗口跑到副屏时自动移到主屏；浏览器超屏自动最大化 |
| `BlackDisplay` | 在指定副屏盖纯黑窗口（适合小副屏/回音壁屏） |
| `BlackOverlay` | 主屏纯黑 OLED 护屏遮罩，Esc / Ctrl+Alt+B 退出 |
| `BlackHotkey` | `Ctrl+Alt+Shift+B` 启动 BlackOverlay |
| `MovieMaskWatcher` | PotPlayer 播放时自动关闭主屏遮罩，并临时阻止屏保/显示器休眠；退出 5 分钟后恢复 |
| `DesktopLayoutBackup` | 备份/恢复桌面图标布局 |
| `MadVRProfileSwitch` | 可选：按 profile 切换 madVR 配置（需自备 .reg） |

## 构建 C# 工具

需要 Windows + .NET Framework 4.x（系统自带 `csc.exe`）：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

输出：

```text
dist\ScreenshotHotkey.exe
dist\WindowGuard.exe
dist\BlackDisplay.exe
dist\BlackOverlay.exe
dist\BlackHotkey.exe
```

## 使用

### 截图

```text
Ctrl+Alt+Insert        4K 主屏截图
Ctrl+Alt+Shift+Insert  2K 主屏截图
```

保存到 `图片\Screenshots`，同时复制到剪贴板。

### 修改截图热键

把 `screenshot-hotkey.ini.example` 重命名为 `screenshot-hotkey.ini`，和 exe 放同目录：

```ini
[Hotkeys]
4K=Ctrl+Alt+Insert
2K=Ctrl+Alt+Shift+Insert
```

支持组合示例：

```text
Ctrl+Alt+F12
Ctrl+Alt+Shift+F12
Alt+PrintScreen
```

修改后重启 `ScreenshotHotkey.exe`。没有 Insert 的 75% 键盘可以改成 `Ctrl+Alt+F12`。

### 多屏窗口

运行 `WindowGuard.exe`。把不想被处理的进程名写进 `window-guard.ignore`（每行一个，不带 `.exe`）。

### 副屏黑屏

运行 `BlackDisplay.exe`，默认盖在非主屏上。

### 主屏 OLED 遮罩

```text
BlackHotkey.exe   常驻，Ctrl+Alt+Shift+B 启动遮罩
BlackOverlay.exe  直接启动遮罩
Esc / Ctrl+Alt+B  退出遮罩
```

### PotPlayer 自动遮罩与防黑屏

播放期间还会调用 `SetThreadExecutionState` 临时阻止屏保和显示器休眠；退出 PotPlayer 后自动释放，不改全局电源/屏保设置。

把 `MovieMaskWatcher.ps1` 设为开机启动：

```powershell
powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File .\MovieMaskWatcher.ps1
```

手动开关：

```text
MovieMaskOff.ps1
MovieMaskOn.ps1
```

### 桌面布局备份

```powershell
.\DesktopLayoutBackup.ps1 -Action backup
.\DesktopLayoutBackup.ps1 -Action list
.\DesktopLayoutBackup.ps1 -Action restore
```

恢复会重启 Explorer，并把恢复前布局另存一份。

### madVR 配置切换（可选）

1. 在 madVR 里导出配置为 `.reg`
2. 放到 `profiles\movie.reg` / `old-film.reg` / `hdr.reg`
3. 运行：

```powershell
.\MadVRProfileSwitch.ps1 -ProfileName movie
```

## 注意

- 工具默认把日志写在 exe 同目录；请放在有写权限的文件夹。
- `BlackDisplay` / `BlackOverlay` 会创建全屏黑窗，先确认快捷键和退出方式。
- `DesktopLayoutBackup` 恢复会强制重启 Explorer，先保存工作。
- 仓库不包含任何个人配置、日志或影片资源。

## License

MIT