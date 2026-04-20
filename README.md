# personal_webpage

Flutter web personal site with a local chat prototype split into three layers:

- Flutter UI
- TypeScript gateway service
- Python twin service

Backend setup and run details are documented in [backend/README.md](backend/README.md).
RagGraph orchestration is backend-owned (gateway/twin), not frontend-owned.

## Local Development

Keep the OpenAI API key in the workspace root `.env` file.

Run the shortcut scripts from the workspace root.

Start the local stack:

```powershell
.\scripts\start-local.ps1 -WithFlutter
```

Stop the local stack:

```powershell
.\scripts\stop-local.ps1 -WithFlutter
```

That opens and stops tracked PowerShell windows for the Python twin, the TypeScript gateway, and Flutter Web.
Omit `-WithFlutter` in either command if you only want the backends.

The Python twin keeps in-memory session history while it is running, so that memory resets when the twin process restarts.

## Troubleshooting (Web)

If you see repeated errors like `LateInitializationError: Field '_handledContextLostEvent' has not been initialized` during hot restart in Chrome, use the HTML renderer for local development:

```powershell
flutter run -d chrome --web-renderer html
```

In VS Code, use the `Flutter Web (Chrome, HTML renderer)` launch profile in `.vscode/launch.json`.
