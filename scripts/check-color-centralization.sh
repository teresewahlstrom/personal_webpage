#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS1_PATH="${SCRIPT_DIR}/check-color-centralization.ps1"

if command -v powershell >/dev/null 2>&1; then
  powershell -ExecutionPolicy Bypass -File "${PS1_PATH}"
  exit 0
fi

if command -v pwsh >/dev/null 2>&1; then
  pwsh -File "${PS1_PATH}"
  exit 0
fi

echo "Skipping color centralization check: PowerShell is not available in this environment."
echo "Continuing build so CI/CD providers without PowerShell (for example Cloudflare Pages Linux) can deploy."
