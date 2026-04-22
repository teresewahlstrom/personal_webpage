---
name: flutter-audit
description: Run fast, scoped code-audit checks in this Flutter project using local scripts and produce a concise findings-first report. Use when reviewing frontend refactors, validating changed Dart files, or collecting quick analyzer evidence without full test runs.
---

# Audit Workflows

Use this skill to run lightweight, repeatable audits with minimal wait time.

## Run Scoped Dart Analyze

Use the skill-local script instead of ad-hoc `dart analyze`:

```powershell
powershell -ExecutionPolicy Bypass -File .github\skills\flutter-audit\references\analyze-dart.ps1 -ChangedOnly -TimeoutSeconds 300
```

For explicit files:

```powershell
powershell -ExecutionPolicy Bypass -File .github\skills\flutter-audit\references\analyze-dart.ps1 -Paths lib\widgets\shell\page_scaffold.dart,lib\widgets\shell\_chat_overlay.dart -TimeoutSeconds 300
```

Then read and summarize `docs/tmp/tmp-analyze.txt`.

## Audit Output Style

Report findings first, ordered by severity:

1. Bugs/regressions
2. Accessibility/UX regressions
3. Maintainability risks
4. Missing verification

Keep summary short after findings.

## Scope Guardrails

- Stay in frontend scope unless user asks otherwise.
- Prefer changed-file verification first.
- Avoid long-running full-project checks unless user requests them.

## Optional Checklist

For a quick pass template, read [references/audit-checklist.md](references/audit-checklist.md).