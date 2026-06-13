#!/usr/bin/env node

const { spawnSync } = require('node:child_process');
const path = require('node:path');

const repoRoot = path.resolve(__dirname, '..');
const ps1Path = path.join(__dirname, 'check-color-centralization.ps1');

function tryRun(command, args) {
  const result = spawnSync(command, args, {
    cwd: repoRoot,
    stdio: 'inherit',
  });

  if (result.error && result.error.code === 'ENOENT') {
    return false;
  }

  if (result.error) {
    throw result.error;
  }

  process.exit(result.status ?? 1);
}

if (tryRun('powershell', ['-ExecutionPolicy', 'Bypass', '-File', ps1Path])) {
  process.exit(0);
}

if (tryRun('pwsh', ['-File', ps1Path])) {
  process.exit(0);
}

console.log('Skipping color centralization check: PowerShell is not available in this environment.');
console.log('Continuing build so CI/CD providers without PowerShell (for example Cloudflare Pages Linux) can deploy.');
process.exit(0);