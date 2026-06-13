param(
  [string]$BindHost = '127.0.0.1',
  [int]$Port = 8000
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pythonExe = Join-Path $workspaceRoot '.venv\Scripts\python.exe'

if (-not (Test-Path $pythonExe)) {
  throw "Expected Python interpreter at $pythonExe"
}

try {
  $Host.UI.RawUI.WindowTitle = 'Twin Service'
} catch {
}

Set-Location $workspaceRoot
& $pythonExe -m uvicorn backend.twin.app:app --host $BindHost --port $Port
exit $LASTEXITCODE