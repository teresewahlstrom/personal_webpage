param(
  [string]$PythonTwinUrl = 'http://127.0.0.1:8000',
  [switch]$Install
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$gatewayRoot = Join-Path $workspaceRoot 'backend\gateway'

try {
  $Host.UI.RawUI.WindowTitle = 'Gateway Service'
} catch {
}

Set-Location $gatewayRoot

if ($Install -or -not (Test-Path (Join-Path $gatewayRoot 'node_modules'))) {
  npm install
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

$env:PYTHON_TWIN_URL = $PythonTwinUrl
npm run dev
exit $LASTEXITCODE