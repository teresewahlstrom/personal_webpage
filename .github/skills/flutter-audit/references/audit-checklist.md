# Audit Checklist

Use this quick checklist for targeted frontend audits.

## Correctness

- Confirm renamed or moved files have updated imports.
- Confirm removed helpers are not referenced.
- Confirm constructor/API changes are reflected at all call sites.

## UX and Accessibility

- Confirm keyboard interaction still works for controls and links.
- Confirm interactive controls use semantic widgets (`TextButton`, etc.).
- Confirm hover/focus states still provide clear feedback.

## Maintainability

- Remove dead branches and unused parameters after refactors.
- Keep shared style logic centralized where practical.
- Prefer small utility scripts for repeatable checks.

## Verification

- Run `.github/skills/flutter-audit/references/analyze-dart.ps1` on changed files.
- Capture output to a temporary report for traceability.
- Call out any checks skipped due to time or scope.