# Codex Startup Launcher

独立的 Codex 启动动画启动器：先播放动画，再打开已安装的 Codex。它不修改 Codex 安装文件、不读取账号或工作区，也不是 OpenAI 官方产品。

## 中文说明

### 下载与安装

从 GitHub **Releases → Assets** 下载 `Codex-Startup-Launcher.zip`，解压到本地文件夹，然后双击 `安装说明.cmd`。如果还没有 Release，可用 **Code → Download ZIP** 下载仓库。

安装后会在桌面和开始菜单创建 `Codex-Startup-Launcher`。旧的 Codex/ChatGPT 快捷方式会被移动到 `%LOCALAPPDATA%\\CodexStartupLauncher\\hidden-shortcuts`，可恢复，不会删除 Codex 应用。

### 使用与快捷键

双击启动器，按一次 Enter 或点击“开始体验”。动画自动播放，结束后打开 Codex 并关闭动画窗口。按 Esc 可跳过。声音在第一次点击或按键后播放，这是浏览器自动播放限制。

动画设置支持显示名称、深色/暖白主题、界面音效和系统中文语音。

### 卸载与还原

双击 `卸载说明.cmd`：它会删除启动器快捷方式、恢复原快捷方式、删除 `%LOCALAPPDATA%\\CodexStartupLauncher`，但保留 Codex 应用。

### 文件

`Codex-Startup-Launcher.zip` 是下载包；`安装说明.cmd` 安装；`启动 Codex.cmd` 直接运行；`卸载说明.cmd` 卸载并还原；`Launch-Codex.ps1` 负责本地页面和启动 Codex；`codex-startup-screen.html`、`startup.css`、`startup.js` 是页面；两个 SVG 是官方 OpenAI Blossom 资源。

### 发布到 GitHub

在 GitHub 新建空仓库，把 `YOUR_NAME` 换成用户名后执行：

```powershell
cd "C:\\Users\\jiakun\\Documents\\Codex\\2026-11-18\\github-dhh-startup-screen\\outputs"
git init
git add .
git commit -m "Add bilingual Codex startup launcher"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/codex-startup-launcher.git
git push -u origin main
```

然后创建 GitHub Release，把 `Codex-Startup-Launcher.zip` 上传到 **Assets**。

## English Instructions

### Download and Install

Download `Codex-Startup-Launcher.zip` from **GitHub → Releases → Assets**, extract it locally, and double-click `安装说明.cmd`. If no Release exists, use **Code → Download ZIP**.

The installer creates `Codex-Startup-Launcher` shortcuts on the Desktop and Start Menu. Existing Codex/ChatGPT shortcuts are moved to `%LOCALAPPDATA%\\CodexStartupLauncher\\hidden-shortcuts` so they can be restored. The Codex app is never deleted.

### Use and Shortcuts

Double-click the launcher and press Enter once or click “Start Experience”. The animation runs automatically, then Codex opens and the animation window closes. Press Esc to skip. Audio starts after the first click or key press because of browser autoplay rules.

Settings include display name, dark/warm-light theme, interface sounds, and system Chinese narration.

### Uninstall and Restore

Double-click `卸载说明.cmd`. It removes launcher shortcuts, restores the original shortcuts, removes `%LOCALAPPDATA%\\CodexStartupLauncher`, and keeps the Codex application installed.

### Publish on GitHub

Create an empty GitHub repository and run the following in PowerShell. Replace `YOUR_NAME` with your GitHub username:

```powershell
cd "C:\\Users\\jiakun\\Documents\\Codex\\2026-11-18\\github-dhh-startup-screen\\outputs"
git init
git add .
git commit -m "Add bilingual Codex startup launcher"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/codex-startup-launcher.git
git push -u origin main
```

Create a GitHub Release and upload `Codex-Startup-Launcher.zip` under **Assets** for direct downloads.
