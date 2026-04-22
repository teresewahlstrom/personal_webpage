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
  '--glob', '!lib/config/app_color_theme.dart',
  '--glob', '!packages/tw_chat/**',
  '--glob', '!packages/tw_keywords/lib/src/config/keyword_color_theme.dart',
  $pattern,
  $repoRoot
)

$rgMatches = & $rg.Source @rgArgs

if ($LASTEXITCODE -eq 0 -and $rgMatches) {
  Write-Host ''
  Write-Host 'Color centralization check failed.' -ForegroundColor Red
  Write-Host 'Found hardcoded color usage outside approved theme sources (lib/config/app_color_theme.dart, packages/tw_chat/, packages/tw_keywords/lib/src/config/keyword_color_theme.dart):' -ForegroundColor Yellow
  Write-Host ''
  $rgMatches | ForEach-Object { Write-Host $_ }
  Write-Host ''
  Write-Host 'Move these colors into AppColorTheme (or package-owned theme files) and reference semantic tokens.' -ForegroundColor Yellow
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
