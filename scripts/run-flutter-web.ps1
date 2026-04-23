param(
  [string]$BackendUrl = 'http://localhost:8787',
  [string]$Device = 'chrome',
  [ValidateSet('auto', 'html', 'canvaskit', 'skwasm')]
  [string]$WebRenderer = 'auto',
  [switch]$PubGet
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutterRoot = $env:FLUTTER_ROOT
if (-not $flutterRoot) {
  $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
  if ($flutterCommand -and $flutterCommand.Source) {
    $flutterBin = Split-Path -Parent $flutterCommand.Source
    $flutterRoot = Split-Path -Parent $flutterBin
  }
}

$dartExe = $null
$flutterSnapshot = $null
if ($flutterRoot) {
  $dartExeCandidate = Join-Path $flutterRoot 'bin\cache\dart-sdk\bin\dart.exe'
  $snapshotCandidate = Join-Path $flutterRoot 'bin\cache\flutter_tools.snapshot'
  if ((Test-Path $dartExeCandidate) -and (Test-Path $snapshotCandidate)) {
    $dartExe = $dartExeCandidate
    $flutterSnapshot = $snapshotCandidate
  }
}

function Invoke-FlutterTool {
  param(
    [string[]]$Arguments
  )

  if ($dartExe -and $flutterSnapshot) {
    & $dartExe $flutterSnapshot @Arguments
  } else {
    & flutter @Arguments
  }
}

try {
  $Host.UI.RawUI.WindowTitle = 'Flutter Web'
} catch {
}

Set-Location $workspaceRoot

if ($PubGet -or -not (Test-Path (Join-Path $workspaceRoot '.dart_tool\package_config.json'))) {
  Invoke-FlutterTool -Arguments @('pub', 'get')
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

Invoke-FlutterTool -Arguments $arguments
exit $LASTEXITCODE