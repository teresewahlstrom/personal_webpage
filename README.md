# personal_webpage

Flutter web personal site with a local chat prototype split into three layers:

- Flutter UI
- Node.js gateway service
- Python twin service

Backend setup and run details are documented in [backend/README.md](backend/README.md).
RagGraph orchestration is backend-owned (gateway/twin), not frontend-owned.

Primary Flutter entrypoint: `lib/main.dart`.

## Local Development

Prerequisites:

- Flutter SDK on PATH. On this workstation, prefer `D:\tools\flutter\flutter\bin`.
- Node.js and npm
- A Python virtual environment at `.venv` in the workspace root (used by `scripts/run-twin.ps1`)
- `.env` in the workspace root with your OpenAI API key

Run the shortcut scripts from the workspace root.

Start the local stack:

```powershell
.\scripts\start-local.ps1 -WithFlutter
```

Stop the local stack:

```powershell
.\scripts\stop-local.ps1 -WithFlutter
```

That opens and stops tracked PowerShell windows for the Python twin, the Node.js gateway, and Flutter Web.
Omit `-WithFlutter` in either command if you only want the backends.

Useful start flags:

- `-InstallGateway`: runs `npm install` for `backend/gateway` before starting the gateway.
- `-FlutterPubGet`: runs `flutter pub get` before launching Flutter.
- `-Device chrome`: selects the Flutter device.
- `-WebRenderer auto|html|canvaskit|skwasm`: selects the Flutter web renderer.
- `-TwinHost`, `-TwinPort`, and `-GatewayUrl`: override local service endpoints.

If `backend/twin/repo` is not present locally, set `TWIN_REPO_ROOT` in `.env` to a twin runtime checkout before starting the backend.

The Python twin keeps in-memory session history while it is running, so that memory resets when the twin process restarts.

## Frontend Notes

The app is a Flutter Web app with local packages under `packages/`:

- `tw_chat`: chat dock and chat UI
- `tw_primitives`: shared theme, markdown, scroll, panel, and pill primitives
- `tw_keywords`: subject keyword data and keyword rendering support

Bundled font and icon notices are tracked in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Troubleshooting (Web)

If you see repeated errors like `LateInitializationError: Field '_handledContextLostEvent' has not been initialized` during hot restart in Chrome, use the HTML renderer for local development:

```powershell
flutter run -d chrome --web-renderer html
```

## Deploy Cache Behavior

The Cloudflare Pages build script uses:

- `flutter build web --release --pwa-strategy=none --no-tree-shake-icons` to disable Flutter PWA worker generation and keep full Material icon coverage.
- A cross-platform precheck wrapper (`scripts/check-color-centralization.cjs`) so local Windows hooks can run the PowerShell audit while CI/CD environments without PowerShell do not fail before deploy.
- Build metadata defines (`APP_BUILD_SHA`, `APP_BUILD_TIME_UTC`, `APP_BUILD_ID`) and writes `version.json` in the deployed artifact.
- Strict no-store headers for entry files (`no-cache, no-store, must-revalidate`) including `index.html`, `flutter_bootstrap.js`, `main.dart.js`, and `version.json`.
- Long-lived immutable cache for static assets (`/assets/*`, `/canvaskit/*`).

Optional entry-file purge after build is enabled when all these environment variables are set:

- `CF_ZONE_ID`
- `CF_API_TOKEN` (must include Zone Cache Purge permission)
- `PURGE_BASE_URLS` (space-separated origins, for example: `https://t1grid.com https://www.t1grid.com`)

Quick verification after deploy:

- `https://www.t1grid.com/version.json` should return `{"build_sha":"...","build_time_utc":"...","build_id":"..."}` from this script.
- If you instead see Flutter default metadata (`app_name/version/build_number/package_name`), the Pages project is not using this build script/output and is deploying from a different config path.
