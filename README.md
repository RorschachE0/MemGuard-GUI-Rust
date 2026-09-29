# MemGuard GUI

一个使用 **Rust + Win32 API** 编写的 Windows 内存管理工具，支持可视化进程选择、自动阈值触发、进程白名单、托盘常驻和开机自启。

当前版本：**v0.3.2**

## 功能

- Windows 原生 GUI，无需 .NET
- 实时显示物理内存使用率、已用/可用/总内存
- 进程列表按 Working Set 从高到低排序
- Ctrl / Shift 多选进程
- 手动“清理选中”
- “同名全选”，适合 Chrome、WPS、微信等多子进程程序
- 自动按内存阈值触发清理
- 连续高占用确认与冷却时间
- 白名单按**进程名**生效，而不是按 PID
- 支持前缀通配，例如 `chrome*`、`wps*`、`wechat*`
- 托盘常驻，关闭主窗口后继续运行
- 支持当前用户开机自启
- 本地日志与外部配置文件

## 工作原理

MemGuard 使用 Windows API：

- `GlobalMemoryStatusEx`：读取物理内存状态
- ToolHelp API：枚举进程
- `GetProcessMemoryInfo`：读取 Working Set
- `EmptyWorkingSet`：收缩目标进程 Working Set
- `Shell_NotifyIconW`：系统托盘
- Windows Registry：当前用户开机自启

> `EmptyWorkingSet` 主要减少进程当前驻留在物理内存中的 Working Set，并不会真正减少应用已经提交的虚拟内存（Commit/Private Bytes）。被移出的页面后续可能再次调入，因此不建议高频、低阈值地反复清理。

## 默认策略

首次运行后配置文件位于：

```text
%LOCALAPPDATA%\MemGuard\config.ini
```

默认配置：

```ini
threshold=88
interval_seconds=10
consecutive_checks=3
cooldown_seconds=900
min_working_set_mb=200
auto_clean=true
exclude=vmware-vmx
```

含义：

1. 每 10 秒检查一次物理内存；
2. 连续 3 次达到 88% 才触发；
3. 自动清理后进入 900 秒冷却；
4. 自动规则只处理 Working Set >= 200 MB 的普通用户进程；
5. 跳过 Windows 核心进程、Session 0 服务和白名单进程。

## 进程选择

进程列表支持：

- 单击：选择一个进程
- Ctrl + 单击：选择多个不连续进程
- Shift + 单击：选择连续区间
- **同名全选**：选中任意一个进程后，一次选中所有同名 PID

例如 Chrome 有十几个子进程时，只需要选中一个 `chrome`，点击“同名全选”，再执行“清理选中”。

## 白名单

白名单按**进程名**匹配。

例如只选中任意一个 Chrome 进程，点击“按名称加入白名单”，配置写入：

```ini
exclude=chrome
```

此后所有 `chrome.exe` PID 都会被自动规则跳过。

也支持前缀通配：

```ini
exclude=chrome*,msedge*,wps*,wechat*,vmware*
```

建议优先使用精确进程名；只有在确实需要覆盖整个进程族时使用 `*`。

## 编译

### 环境

- Windows 10 / Windows 11
- Rust stable
- MSVC toolchain

安装 Rust：

```powershell
winget install Rustlang.Rustup
```

重新打开 PowerShell：

```powershell
rustc --version
cargo --version
```

### 构建

```powershell
cargo build --release
```

或者：

```powershell
.\build.ps1
```

生成文件：

```text
target\release\memguard-gui.exe
```

## 日志

```text
%LOCALAPPDATA%\MemGuard\memguard.log
```

## 安全边界

- 自动清理跳过核心系统进程
- 自动清理跳过 Session 0
- 自动清理跳过白名单
- 手动清理仍禁止处理核心系统进程和 Session 0
- 默认将 `vmware-vmx` 加入白名单

## 版本

### v0.3.2

- 增加“同名全选”
- 白名单操作明确按进程名生效
- 增加前缀通配白名单
- 改进多子进程应用的操作体验

### v0.3.1

- 修复 `windows-sys 0.61.2` 下 Win32 控件样式常量的整数类型兼容问题
- 移除不可用的 `UpdateWindow` 导入

### v0.3.0

- 增加原生 Windows GUI
- 增加进程列表、多选清理和白名单管理
