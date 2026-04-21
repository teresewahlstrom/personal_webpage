#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --pwa-strategy=none --no-tree-shake-icons

# Ensure Cloudflare Pages custom routing headers/redirects are present
# in the final artifact even if Flutter omits underscore-prefixed files.
for pages_file in _headers _redirects; do
  if [ -f "web/$pages_file" ]; then
    cp "web/$pages_file" "build/web/$pages_file"
  fi
done

# Compatibility output for projects still configured with "dist" on Pages.
rm -rf dist
cp -r build/web dist

# Optionally purge only entry files from Cloudflare cache after a deploy build.
# Required env vars:
# - CF_ZONE_ID
# - CF_API_TOKEN (token with Zone.Cache Purge permission)
# - PURGE_BASE_URLS (space-separated absolute origins)
ENTRY_FILES=(
  "/index.html"
  "/flutter_bootstrap.js"
  "/flutter.js"
  "/main.dart.js"
  "/flutter_service_worker.js"
  "/manifest.json"
  "/assets/FontManifest.json"
  "/assets/fonts/MaterialIcons-Regular.otf"
)

if [[ -n "${CF_ZONE_ID:-}" && -n "${CF_API_TOKEN:-}" && -n "${PURGE_BASE_URLS:-}" ]]; then
  files_json="["
  first=1

  for base_url in ${PURGE_BASE_URLS}; do
    normalized_base="${base_url%/}"
    for entry_file in "${ENTRY_FILES[@]}"; do
      purge_url="${normalized_base}${entry_file}"
      if [[ ${first} -eq 0 ]]; then
        files_json+=","
      fi
      files_json+="\"${purge_url}\""
      first=0
    done
  done

  files_json+="]"

  purge_response="$(curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"files\":${files_json}}" || true)"

  if [[ "${purge_response}" == *'"success":true'* ]]; then
    echo "Cloudflare entry-file purge completed."
  else
    echo "Cloudflare purge failed: ${purge_response}"
    exit 1
  fi
else
  echo "Skipping Cloudflare purge (set CF_ZONE_ID, CF_API_TOKEN, PURGE_BASE_URLS to enable)."
fi
