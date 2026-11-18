$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$edgePaths = @(
  'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
  'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
)
$edge = $edgePaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $edge) { throw 'Microsoft Edge was not found.' }
$codex = Get-AppxPackage -Name OpenAI.Codex | Select-Object -First 1
if (-not $codex) { throw 'Codex is not installed.' }
$appId = "$($codex.PackageFamilyName)!App"
Write-Host "Codex app ID: $appId"
$tcp = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,0)
$tcp.Start()
$port = $tcp.LocalEndpoint.Port
$tcp.Stop()
$server = [System.Net.HttpListener]::new()
$server.Prefixes.Add("http://127.0.0.1:$port/")
$server.Start()
$url = "http://127.0.0.1:$port/codex-startup-screen.html"
Write-Host "Startup page: $url"
$profileDir = Join-Path $env:TEMP "CodexStartup-$port"
$edgeProcess = Start-Process -FilePath $edge -ArgumentList @("--user-data-dir=`"$profileDir`"","--no-first-run","--no-default-browser-check","--app=$url","--window-size=980,720") -PassThru
$completed = $false
try {
  $deadline = [DateTime]::UtcNow.AddMinutes(10)
  $pending = $server.GetContextAsync()
  while ([DateTime]::UtcNow -lt $deadline) {
    if ($edgeProcess.HasExited) { break }
    if (-not $pending.Wait(1000)) { continue }
    $context = $pending.Result
    $path = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
    Write-Host "$($context.Request.HttpMethod) /$path"
    if ($path -eq '__launch_codex' -and $context.Request.HttpMethod -eq 'POST') {
      $context.Response.StatusCode = 204
      $context.Response.Close()
      Start-Process -FilePath 'explorer.exe' -ArgumentList "shell:AppsFolder\$appId"
      $completed = $true
      Write-Host 'Codex launch requested.'
      break
    }
    $allowed = @{
      'codex-startup-screen.html' = 'text/html; charset=utf-8'
      'startup.css' = 'text/css; charset=utf-8'
      'startup.js' = 'text/javascript; charset=utf-8'
      'codex-icon.svg' = 'image/svg+xml'
      'openai-blossom-black.svg' = 'image/svg+xml'
    }
    if (-not $allowed.ContainsKey($path)) {
      $context.Response.StatusCode = 404
      $context.Response.Close()
      $pending = $server.GetContextAsync()
      continue
    }
    $bytes = [System.IO.File]::ReadAllBytes((Join-Path $root $path))
    $context.Response.ContentType = $allowed[$path]
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes,0,$bytes.Length)
    $context.Response.Close()
    $pending = $server.GetContextAsync()
  }
} finally {
  $server.Stop()
  $server.Close()
  if ($completed -and -not $edgeProcess.HasExited) {
    Start-Sleep -Milliseconds 400
    Stop-Process -Id $edgeProcess.Id -ErrorAction SilentlyContinue
  }
  if ($completed) {
    Start-Sleep -Milliseconds 500
    $tempRoot = [System.IO.Path]::GetFullPath($env:TEMP).TrimEnd([char]'\') + '\'
    $resolvedProfile = [System.IO.Path]::GetFullPath($profileDir)
    if ($resolvedProfile.StartsWith($tempRoot,[System.StringComparison]::OrdinalIgnoreCase) -and
        [System.IO.Path]::GetFileName($resolvedProfile) -eq "CodexStartup-$port") {
      Remove-Item -LiteralPath $resolvedProfile -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}
