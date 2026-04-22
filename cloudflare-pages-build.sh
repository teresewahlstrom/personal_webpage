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

BUILD_SHA="${CF_PAGES_COMMIT_SHA:-${GITHUB_SHA:-}}"
if [[ -n "${BUILD_SHA}" ]]; then
  BUILD_SHA="${BUILD_SHA:0:12}"
fi
if [[ -z "${BUILD_SHA}" ]] && command -v git >/dev/null 2>&1; then
  BUILD_SHA="$(git rev-parse --short=12 HEAD 2>/dev/null || true)"
fi
if [[ -z "${BUILD_SHA}" ]]; then
  BUILD_SHA="unknown"
fi

BUILD_TIME_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
BUILD_ID="${BUILD_SHA}@${BUILD_TIME_UTC}"

echo "Build metadata: sha=${BUILD_SHA} built_at=${BUILD_TIME_UTC}"

flutter build web --release --pwa-strategy=none --no-tree-shake-icons \
  --dart-define=APP_BUILD_SHA="${BUILD_SHA}" \
  --dart-define=APP_BUILD_TIME_UTC="${BUILD_TIME_UTC}" \
  --dart-define=APP_BUILD_ID="${BUILD_ID}"

# Add per-build cache-busting query params to critical JS entry points.
if [ -f "build/web/index.html" ]; then
  sed -i "s#flutter_bootstrap.js#flutter_bootstrap.js?v=${BUILD_SHA}#g" build/web/index.html
fi
if [ -f "build/web/flutter_bootstrap.js" ]; then
  sed -i "s#\"main.dart.js\"#\"main.dart.js?v=${BUILD_SHA}\"#g" build/web/flutter_bootstrap.js
fi

# Ensure Cloudflare Pages custom routing headers/redirects are present
# in the final artifact even if Flutter omits underscore-prefixed files.
for pages_file in _headers _redirects; do
  if [ -f "web/$pages_file" ]; then
    cp "web/$pages_file" "build/web/$pages_file"
  fi
done

cat > build/web/version.json <<EOF
{"build_sha":"${BUILD_SHA}","build_time_utc":"${BUILD_TIME_UTC}","build_id":"${BUILD_ID}"}
EOF

# Compatibility output for projects still configured with "dist" on Pages.
rm -rf dist
cp -r build/web dist

# Optionally purge only entry files from Cloudflare cache after a deploy build.
# Required env vars:
# - CF_ZONE_ID
# - CF_API_TOKEN (token with Zone.Cache Purge permission)
# - PURGE_BASE_URLS (space-separated absolute origins)
ENTRY_FILES=(
  "/"
  "/index.html"
  "/flutter_bootstrap.js"
  "/flutter_bootstrap.js?v=${BUILD_SHA}"
  "/flutter.js"
  "/main.dart.js"
  "/main.dart.js?v=${BUILD_SHA}"
  "/flutter_service_worker.js"
  "/manifest.json"
  "/version.json"
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
