Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$rg = Get-Command rg -ErrorAction SilentlyContinue
if (-not $rg) {
  $fallbacks = @(
    'C:\Users\teres\AppData\Local\Microsoft\WinGet\Links\rg.exe',
    'C:\Users\teres\AppData\Local\Programs\Antigravity IDE\resources\app\node_modules\@vscode\ripgrep\bin\rg.exe'
  )
  foreach ($fb in $fallbacks) {
    if (Test-Path $fb) {
      $rg = @{ Source = $fb }
      break
    }
  }
}

if (-not $rg) {
  Write-Error "ripgrep (rg) was not found. Install rg or add it to PATH."
}

$pattern = '\bColor\s*\(\s*0x[0-9A-Fa-f]+|\bColors\.[A-Za-z_][A-Za-z0-9_]*'

$rgArgs = @(
  '--line-number',
  '--with-filename',
  '--glob', 'lib/**/*.dart',
  '--glob', 'packages/**/*.dart',
  # Only allow color definitions inside packages/tw_primitives/lib/src/theme/colors by excluding that path from the search.
  '--glob', '!packages/tw_primitives/lib/src/theme/colors/**',
  # Exclude test files and packages/tw_primitives library internals that use native platform styling colors
  '--glob', '!**/test/**',
  '--glob', '!packages/tw_primitives/lib/src/text_field/**',
  '--glob', '!packages/tw_primitives/lib/src/scrollbar/**',
  '--glob', '!packages/tw_primitives/lib/src/theme/text_styles/**',
  '--glob', '!packages/tw_primitives/lib/src/selection/**',
  '--glob', '!packages/tw_primitives/lib/src/markdown/**',
  '--glob', '!packages/tw_primitives/lib/src/theme/container/**',
  $pattern,
  $repoRoot
)

$rgMatches = & $rg.Source @rgArgs | Where-Object { $_ -notmatch 'Colors\.transparent' }

if ($rgMatches) {
  Write-Host ''
  Write-Host 'Color centralization check failed.' -ForegroundColor Red
  Write-Host 'Found hardcoded color usage outside the approved theme source (packages/tw_primitives/lib/src/theme/colors):' -ForegroundColor Yellow
  Write-Host ''
  $rgMatches | ForEach-Object { Write-Host $_ }
  Write-Host ''
  Write-Host 'Move these colors into packages/tw_primitives/lib/src/theme/colors and reference semantic tokens from `tw_primitives`.' -ForegroundColor Yellow
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
