Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$rg = Get-Command rg -ErrorAction SilentlyContinue
if (-not $rg) {
  $fallback = 'C:\Users\teres\AppData\Local\Microsoft\WinGet\Links\rg.exe'
  if (Test-Path $fallback) {
    $rg = @{ Source = $fallback }
  }
}

if (-not $rg) {
  Write-Error "ripgrep (rg) was not found. Install rg or add it to PATH."
}

$pattern = 'Color\s*\(\s*0x[0-9A-Fa-f]+|Colors\.[A-Za-z_][A-Za-z0-9_]*'

$rgArgs = @(
  '--line-number',
  '--with-filename',
  '--glob', 'lib/**/*.dart',
  '--glob', 'packages/**/*.dart',
  # Only allow color definitions inside packages/tw_primitives/lib/src/colors by excluding that path from the search.
  '--glob', '!packages/tw_primitives/lib/src/colors/**',
  $pattern,
  $repoRoot
)

$rgMatches = & $rg.Source @rgArgs

if ($LASTEXITCODE -eq 0 -and $rgMatches) {
  Write-Host ''
  Write-Host 'Color centralization check failed.' -ForegroundColor Red
  Write-Host 'Found hardcoded color usage outside the approved theme source (packages/tw_primitives/lib/src/colors):' -ForegroundColor Yellow
  Write-Host ''
  $rgMatches | ForEach-Object { Write-Host $_ }
  Write-Host ''
  Write-Host 'Move these colors into packages/tw_primitives/lib/src/colors and reference semantic tokens from `tw_primitives`.' -ForegroundColor Yellow
  exit 1
}

if ($LASTEXITCODE -eq 1) {
  Write-Host 'Color centralization check passed.' -ForegroundColor Green
  exit 0
}

if ($LASTEXITCODE -ne 0) {
  Write-Error "ripgrep failed with exit code $LASTEXITCODE"
}

Write-Host 'Color centralization check passed.' -ForegroundColor Green
exit 0
