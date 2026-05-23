# Backend

The local backend has two services under one parent directory:

- `gateway`: a Node/Express proxy that exposes the Flutter-facing `/api/chat` endpoint
- `twin`: a Python FastAPI service that hosts the full retrieval-backed digital twin runtime

## Responsibilities

### Gateway

- exposes the stable Flutter-facing `/api/chat` endpoint
- validates and proxies chat requests to the Python twin service
- keeps the frontend contract narrow: `sessionId` and `reply`
- exposes health at `/api/health`
- listens on `http://localhost:8787` by default

### Twin

- uses the workspace `.env` OpenAI key
- serves health at `/health`
- imports runtime package from `TWIN_REPO_ROOT/src/twin`
- loads subject policies + retrieval artifacts from the same runtime root
- keeps in-memory session history keyed by `sessionId` while the service is running
- returns only the final answer text for each turn

## Twin Layout

- `backend/twin/app.py`: FastAPI entrypoint and adapter for `/twin/chat`
- `backend/twin/repo` (optional local default): runtime bridge root used when `TWIN_REPO_ROOT` is not set

Bridge behavior:

- no local sync step is required
- backend imports from `TWIN_REPO_ROOT/src` at runtime
- optional override: set `TWIN_REPO_ROOT` to point at a different twin repo root
- if neither `TWIN_REPO_ROOT` nor `backend/twin/repo` is available, the twin service will fail fast at startup

## Run

Run the shortcut scripts from the workspace root.

Start the local stack:

```powershell
.\scripts\start-local.ps1 -WithFlutter
```

Stop the local stack:

```powershell
.\scripts\stop-local.ps1 -WithFlutter
```

Omit `-WithFlutter` in either command if you only want the backends.

Useful launcher flags:

- `-InstallGateway`: runs `npm install` for `backend/gateway` before starting the gateway
- `-FlutterPubGet`: runs `flutter pub get` before launching Flutter

The Python twin keeps in-memory session history while it is running, so memory resets when the twin process restarts.

If you need different local endpoints, pass them through the launcher script instead of starting services manually. For example:

```powershell
.\scripts\start-local.ps1 -WithFlutter -TwinHost 127.0.0.1 -TwinPort 8000 -GatewayUrl http://localhost:8787
```
