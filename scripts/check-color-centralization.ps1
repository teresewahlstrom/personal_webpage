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

$args = @(
  '--line-number',
  '--with-filename',
  '--glob', 'lib/**/*.dart',
  '--glob', 'packages/**/*.dart',
  '--glob', '!lib/config/app_color_theme.dart',
  '--glob', '!packages/tw_chat/**',
  $pattern,
  $repoRoot
)

$matches = & $rg.Source @args

if ($LASTEXITCODE -eq 0 -and $matches) {
  Write-Host ''
  Write-Host 'Color centralization check failed.' -ForegroundColor Red
  Write-Host 'Found hardcoded color usage outside lib/config/app_color_theme.dart and packages/tw_chat/:' -ForegroundColor Yellow
  Write-Host ''
  $matches | ForEach-Object { Write-Host $_ }
  Write-Host ''
  Write-Host 'Move these colors into AppColorTheme (or tw_chat skin if applicable) and reference semantic tokens.' -ForegroundColor Yellow
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
