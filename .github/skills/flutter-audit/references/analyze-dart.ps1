param(
  [string[]]$Paths = @(),
  [switch]$ChangedOnly,
  [int]$TimeoutSeconds = 180,
  [string]$OutFile = 'docs\tmp\tmp-analyze.txt'
)

$ErrorActionPreference = 'Stop'

$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
Set-Location $workspaceRoot

function Get-DartPath {
  $candidates = @()
  if ($env:FLUTTER_ROOT) {
    $candidates += (Join-Path $env:FLUTTER_ROOT 'bin\dart.bat')
  }
  $candidates += 'D:\tools\flutter\flutter\bin\dart.bat'

  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) {
      return $candidate
    }
  }

  $cmd = Get-Command dart -ErrorAction SilentlyContinue
  if ($cmd) {
    return $cmd.Source
  }

  throw 'Could not find Dart executable. Set FLUTTER_ROOT or ensure dart is on PATH.'
}

function Get-ChangedDartFiles {
  $files = New-Object System.Collections.Generic.HashSet[string]

  $unstaged = git diff --name-only -- '*.dart'
  $staged = git diff --cached --name-only -- '*.dart'
  $untracked = git ls-files --others --exclude-standard -- '*.dart'

  foreach ($path in @($unstaged) + @($staged) + @($untracked)) {
    if ([string]::IsNullOrWhiteSpace($path)) {
      continue
    }
    $normalized = $path.Trim()
    if (Test-Path (Join-Path $workspaceRoot $normalized)) {
      [void]$files.Add($normalized)
    }
  }

  return @($files.ToArray() | Sort-Object)
}

if ($ChangedOnly -or $Paths.Count -eq 0) {
  $Paths = @(Get-ChangedDartFiles)
}

if ($Paths.Count -eq 0) {
  Write-Host 'No Dart files to analyze.'
  exit 0
}

$dartPath = Get-DartPath

$outPath = Join-Path $workspaceRoot $OutFile
$outDir = Split-Path -Parent $outPath
if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$stdoutFile = [System.IO.Path]::GetTempFileName()
$stderrFile = [System.IO.Path]::GetTempFileName()

try {
  $argumentList = @('analyze') + $Paths
  $commandLine = "$dartPath $($argumentList -join ' ')"

  $process = Start-Process `
    -FilePath $dartPath `
    -ArgumentList $argumentList `
    -WorkingDirectory $workspaceRoot `
    -RedirectStandardOutput $stdoutFile `
    -RedirectStandardError $stderrFile `
    -PassThru

  $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
  if ($timedOut) {
    try {
      $process.Kill()
    } catch {
    }
  }

  $stdout = ''
  $stderr = ''
  if (Test-Path $stdoutFile) {
    $stdout = [string](Get-Content -Path $stdoutFile -Raw)
  }
  if (Test-Path $stderrFile) {
    $stderr = [string](Get-Content -Path $stderrFile -Raw)
  }
  $stdoutSafe = if ($null -eq $stdout) { '' } else { $stdout }
  $stderrSafe = if ($null -eq $stderr) { '' } else { $stderr }

  $report = @()
  $report += "timestamp: $(Get-Date -Format o)"
  $report += "workspace: $workspaceRoot"
  $report += "timed_out: $timedOut"
  $report += "timeout_seconds: $TimeoutSeconds"
  if (-not $timedOut) {
    $report += "exit_code: $($process.ExitCode)"
  } else {
    $report += 'exit_code: timeout'
  }
  $report += "command: $commandLine"
  $report += 'files:'
  foreach ($path in $Paths) {
    $report += "  - $path"
  }
  $report += ''
  $report += 'stdout:'
  $report += ($stdoutSafe.TrimEnd())
  $report += ''
  if (-not [string]::IsNullOrWhiteSpace($stderrSafe)) {
    $report += 'stderr:'
    $report += ($stderrSafe.TrimEnd())
  }

  $report -join [Environment]::NewLine | Set-Content -Path $outPath -Encoding utf8
  Write-Host "Analyze report written to $outPath"

  if ($timedOut) {
    exit 124
  }
  exit $process.ExitCode
} finally {
  Remove-Item -LiteralPath $stdoutFile -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
}