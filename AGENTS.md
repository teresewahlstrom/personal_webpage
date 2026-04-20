# Project guardrails

- Framework is **Flutter Web**. Primary entry: `lib/main.dart`
- Dev quickstart: ensure PATH includes PowerShell + Git + `D:\tools\flutter\flutter\bin`; prefer `./scripts/start-local.ps1 -WithFlutter` to start everything and `./scripts/stop-local.ps1 -WithFlutter` to stop it.
- Search tooling note: `rg` is installed, but some agent PowerShell invocations can mis-parse plain `rg ...` calls. Prefer explicit invocation `& 'C:\Users\teres\AppData\Local\Microsoft\WinGet\Links\rg.exe' ...` (or `cmd.exe /c rg ...`) and fall back to PowerShell `Select-String` if needed.
