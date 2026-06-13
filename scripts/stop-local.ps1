param(
  [switch]$WithFlutter
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$statePath = Join-Path $workspaceRoot '.dart_tool\local-dev-processes.json'
$scriptPathMap = @{
  twin = (Join-Path $workspaceRoot 'scripts\run-twin.ps1')
  gateway = (Join-Path $workspaceRoot 'scripts\run-gateway.ps1')
  flutter = (Join-Path $workspaceRoot 'scripts\run-flutter-web.ps1')
}

function Get-DescendantProcessIds {
  param(
    [int]$ParentProcessId
  )

  $allProcesses = Get-CimInstance Win32_Process
  $childrenByParent = @{}
  foreach ($process in $allProcesses) {
    if (-not $childrenByParent.ContainsKey($process.ParentProcessId)) {
      $childrenByParent[$process.ParentProcessId] = New-Object System.Collections.Generic.List[int]
    }
    $childrenByParent[$process.ParentProcessId].Add([int]$process.ProcessId)
  }

  $pending = New-Object System.Collections.Generic.Queue[int]
  $descendants = New-Object System.Collections.Generic.List[int]
  $pending.Enqueue($ParentProcessId)

  while ($pending.Count -gt 0) {
    $current = $pending.Dequeue()
    if (-not $childrenByParent.ContainsKey($current)) {
      continue
    }

    foreach ($childId in $childrenByParent[$current]) {
      $descendants.Add($childId)
      $pending.Enqueue($childId)
    }
  }

  return $descendants
}

function Stop-ProcessTree {
  param(
    [int]$RootPid
  )

  $descendants = @(Get-DescendantProcessIds -ParentProcessId $RootPid)
  foreach ($processId in $descendants | Sort-Object -Descending) {
    try {
      Stop-Process -Id $processId -Force -ErrorAction Stop
    } catch {
    }
  }

  try {
    Stop-Process -Id $RootPid -Force -ErrorAction Stop
  } catch {
  }
}

function Get-FallbackServices {
  $powershellProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match '^powershell(\.exe)?$|^pwsh(\.exe)?$'
  }

  $services = @()
  foreach ($name in $scriptPathMap.Keys) {
    $scriptPath = $scriptPathMap[$name]
    $matched = $powershellProcesses | Where-Object {
      $_.CommandLine -like "*$scriptPath*"
    }

    foreach ($process in $matched) {
      $services += [PSCustomObject]@{
        name = $name
        pid = [int]$process.ProcessId
      }
    }
  }

  return $services
}

$servicesToStop = @()
if (Test-Path $statePath) {
  $state = Get-Content -Path $statePath -Raw | ConvertFrom-Json
  $servicesToStop = @($state.services)
}

if (-not $servicesToStop -or $servicesToStop.Count -eq 0) {
  $servicesToStop = @(Get-FallbackServices)
}

if (-not $servicesToStop -or $servicesToStop.Count -eq 0) {
  Write-Host 'No tracked local services found.'
  exit 0
}

$serviceNames = @('twin', 'gateway')
if ($WithFlutter) {
  $serviceNames += 'flutter'
}

$selectedServices = @($servicesToStop | Where-Object { $serviceNames -contains $_.name })
if ($selectedServices.Count -eq 0) {
  Write-Host 'No matching tracked services found for the requested stop set.'
  exit 0
}

foreach ($service in $selectedServices) {
  Stop-ProcessTree -RootPid ([int]$service.pid)
  Write-Host "Stopped $($service.name) (PID $($service.pid))."
}

if (Test-Path $statePath) {
  $remainingServices = @($servicesToStop | Where-Object {
    $serviceNames -notcontains $_.name
  })

  if ($remainingServices.Count -eq 0) {
    Remove-Item -Path $statePath -Force
  } else {
    $updatedState = [PSCustomObject]@{
      workspaceRoot = $workspaceRoot
      launchedAt = (Get-Date).ToString('o')
      services = $remainingServices
    }
    $updatedState | ConvertTo-Json -Depth 4 | Set-Content -Path $statePath
  }
}