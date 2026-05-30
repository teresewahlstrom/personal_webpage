#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Cloudflare Pages runs npm scripts before this repo's build script has a
# chance to install Flutter, so make Dart available here as well.
source "${SCRIPT_DIR}/ensure-flutter.sh"

cd "${REPO_ROOT}"
dart run scripts/check_tw_primitives_usage.dart
