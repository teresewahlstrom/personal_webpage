# Backend

The local backend has two services under one parent directory:

- `gateway`: a TypeScript proxy that exposes the Flutter-facing `/api/chat` endpoint
- `twin`: a Python service that owns prompt construction, session memory, and the LangChain LLM call

## Responsibilities

### Gateway

- exposes the stable Flutter-facing `/api/chat` endpoint
- validates and proxies chat requests to the Python twin service
- keeps the frontend contract narrow: `sessionId` and `reply`
- listens on `http://localhost:8787` by default

### Twin

- uses the workspace `.env` OpenAI key
- calls GPT-4 through LangChain
- owns RagGraph orchestration and retrieval flow
- injects one fixed prototype context payload as retrieved evidence
- keeps in-memory session history keyed by `sessionId` while the service is running
- returns only the final answer

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

The Python twin keeps in-memory session history while it is running, so that memory resets when the twin process restarts.

If you need different local endpoints, pass them through the launcher script instead of starting services manually. For example:

```powershell
.\scripts\start-local.ps1 -WithFlutter -TwinHost 127.0.0.1 -TwinPort 8000 -GatewayUrl http://localhost:8787
```