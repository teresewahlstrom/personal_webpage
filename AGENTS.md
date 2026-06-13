# Project guardrails

- Framework is **Flutter Web**. Primary entry: `lib/main.dart`
- Dev quickstart: ensure PATH includes PowerShell + Git + `D:\tools\flutter\flutter\bin`; prefer `./scripts/start-local.ps1 -WithFlutter` to start everything and `./scripts/stop-local.ps1 -WithFlutter` to stop it.
- Search tooling note: `rg` is installed, but some agent PowerShell invocations can mis-parse plain `rg ...` calls. Prefer explicit invocation `& 'C:\Users\teres\AppData\Local\Microsoft\WinGet\Links\rg.exe' ...` (or `cmd.exe /c rg ...`) and fall back to PowerShell `Select-String` if needed.
- Copilot project skills should live under `.github/skills/`.
- Use the `flutter-audit` skill for fast, scoped frontend/code-audit passes **only** when introducing or refactoring Dart code logic. Do NOT use it for trivial edits (e.g., assets, text, JSON, YAML, or documentation updates).
- When that skill is used, prefer its helper script at `.github/skills/flutter-audit/references/analyze-dart.ps1` for targeted Dart analysis.

- When running .bat or .cmd tools from PowerShell, invoke them with the explicit call operator &. For Dart formatting, use & dart format . rather than dart.bat format ..