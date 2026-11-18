$ErrorActionPreference = 'Stop'
$installRoot = Join-Path $env:LOCALAPPDATA 'CodexStartupLauncher'
$hiddenRoot = Join-Path $installRoot 'hidden-shortcuts'
$desktop = [Environment]::GetFolderPath('Desktop')
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
foreach ($linkPath in @((Join-Path $desktop 'Codex-Startup-Launcher.lnk'),(Join-Path $startMenu 'Codex-Startup-Launcher.lnk'))) {
  Remove-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
}
$recordFile = Join-Path $installRoot 'hidden-shortcuts.json'
if (Test-Path -LiteralPath $recordFile) {
  $items = @(Get-Content -LiteralPath $recordFile -Raw | ConvertFrom-Json)
  foreach ($item in $items) {
    if (Test-Path -LiteralPath $item.Hidden) {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $item.Original) | Out-Null
      Move-Item -LiteralPath $item.Hidden -Destination $item.Original -Force
    }
  }
}
if (Test-Path -LiteralPath $installRoot) {
  Remove-Item -LiteralPath $installRoot -Recurse -Force
}
Write-Host 'Codex launcher removed. Original shortcuts restored.'
