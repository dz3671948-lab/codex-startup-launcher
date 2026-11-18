$ErrorActionPreference = 'Stop'
$source = Split-Path -Parent $MyInvocation.MyCommand.Path
$installRoot = Join-Path $env:LOCALAPPDATA 'CodexStartupLauncher'
$hiddenRoot = Join-Path $installRoot 'hidden-shortcuts'
$desktop = [Environment]::GetFolderPath('Desktop')
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$shell = New-Object -ComObject WScript.Shell

New-Item -ItemType Directory -Force -Path $installRoot,$hiddenRoot | Out-Null
Copy-Item -LiteralPath (Join-Path $source '*') -Destination $installRoot -Recurse -Force

$records = @()
foreach ($folder in @($desktop,$startMenu)) {
  if (-not (Test-Path -LiteralPath $folder)) { continue }
  foreach ($lnk in Get-ChildItem -LiteralPath $folder -Filter '*.lnk' -File -ErrorAction SilentlyContinue) {
    try {
      $shortcut = $shell.CreateShortcut($lnk.FullName)
      $target = $shortcut.TargetPath
      if (($lnk.Name -match '(?i)codex|chatgpt') -or ($target -match '(?i)ChatGPT.exe|Codex.exe|OpenAI.Codex')) {
        $destination = Join-Path $hiddenRoot $lnk.Name
        Move-Item -LiteralPath $lnk.FullName -Destination $destination -Force
        $records += [pscustomobject]@{Original=$lnk.FullName;Hidden=$destination}
      }
    } catch {}
  }
}
$records | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $installRoot 'hidden-shortcuts.json') -Encoding UTF8

$launcher = Join-Path $installRoot '启动 Codex.cmd'
$desktopLink = Join-Path $desktop 'Codex-Startup-Launcher.lnk'
$startLink = Join-Path $startMenu 'Codex-Startup-Launcher.lnk'
foreach ($linkPath in @($desktopLink,$startLink)) {
  $shortcut = $shell.CreateShortcut($linkPath)
  $shortcut.TargetPath = $launcher
  $shortcut.WorkingDirectory = $installRoot
  $shortcut.Description = '播放启动动画后打开 Codex'
  $shortcut.Save()
}
Write-Host "Installed to $installRoot"
Write-Host "Launcher shortcuts created. Original Codex shortcuts were moved to the reversible backup folder."
