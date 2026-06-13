param(
  [switch]$WithFlutter,
  [switch]$InstallGateway,
  [switch]$FlutterPubGet,
  [string]$TwinHost = '127.0.0.1',
  [int]$TwinPort = 8000,
  [string]$GatewayUrl = 'http://localhost:8787',
  [string]$Device = 'chrome',
  [ValidateSet('auto', 'html', 'canvaskit', 'skwasm')]
  [string]$WebRenderer = 'auto'
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$scriptRoot = Join-Path $workspaceRoot 'scripts'
$stateRoot = Join-Path $workspaceRoot '.dart_tool'
$statePath = Join-Path $stateRoot 'local-dev-processes.json'
$pythonTwinUrl = "http://$TwinHost`:$TwinPort"

function Start-DevWindow {
  param(
    [string]$ServiceName,
    [string]$ScriptPath,
    [string[]]$Arguments = @()
  )

  $processArguments = @(
    '-NoExit',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    $ScriptPath
  ) + $Arguments

  $process = Start-Process -FilePath 'powershell.exe' -WorkingDirectory $workspaceRoot -PassThru -ArgumentList $processArguments

  [PSCustomObject]@{
    name = $ServiceName
    pid = $process.Id
    script = $ScriptPath
  }
}

$startedServices = @(
  Start-DevWindow -ServiceName 'twin' -ScriptPath (Join-Path $scriptRoot 'run-twin.ps1') -Arguments @(
    '-BindHost',
    $TwinHost,
    '-Port',
    $TwinPort.ToString()
  )
)

$gatewayArguments = @(
  '-PythonTwinUrl',
  $pythonTwinUrl
)
if ($InstallGateway) {
  $gatewayArguments += '-Install'
}

$startedServices += Start-DevWindow -ServiceName 'gateway' -ScriptPath (Join-Path $scriptRoot 'run-gateway.ps1') -Arguments $gatewayArguments

if ($WithFlutter) {
  $flutterArguments = @(
    '-BackendUrl',
    $GatewayUrl,
    '-Device',
    $Device,
    '-WebRenderer',
    $WebRenderer
  )
  if ($FlutterPubGet) {
    $flutterArguments += '-PubGet'
  }

  $startedServices += Start-DevWindow -ServiceName 'flutter' -ScriptPath (Join-Path $scriptRoot 'run-flutter-web.ps1') -Arguments $flutterArguments
}

if (-not (Test-Path $stateRoot)) {
  New-Item -ItemType Directory -Path $stateRoot | Out-Null
}

$state = [PSCustomObject]@{
  workspaceRoot = $workspaceRoot
  launchedAt = (Get-Date).ToString('o')
  services = $startedServices
}
$state | ConvertTo-Json -Depth 4 | Set-Content -Path $statePath

Write-Host 'Started twin and gateway in new PowerShell windows.'
if ($WithFlutter) {
  Write-Host 'Started Flutter Web in a new PowerShell window.'
} else {
  Write-Host 'Use -WithFlutter if you also want to launch Flutter Web.'
}
Write-Host "State saved to $statePath"
