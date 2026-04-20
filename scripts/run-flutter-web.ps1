param(
  [string]$BackendUrl = 'http://localhost:8787',
  [string]$Device = 'chrome',
  [ValidateSet('auto', 'html', 'canvaskit', 'skwasm')]
  [string]$WebRenderer = 'auto',
  [switch]$PubGet
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

try {
  $Host.UI.RawUI.WindowTitle = 'Flutter Web'
} catch {
}

Set-Location $workspaceRoot

if ($PubGet -or -not (Test-Path (Join-Path $workspaceRoot '.dart_tool\package_config.json'))) {
  flutter pub get
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

$arguments = @(
  'run',
  '-d',
  $Device,
  "--dart-define=TWIN_BACKEND_URL=$BackendUrl"
)

if ($WebRenderer -ne 'auto') {
  $arguments += @('--web-renderer', $WebRenderer)
}

& flutter @arguments
exit $LASTEXITCODE