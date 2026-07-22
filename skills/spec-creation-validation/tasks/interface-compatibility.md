# Task: interface-compatibility

## Purpose

Verify interface compatibility of affected APIs and functions.

## Entry Criteria

- `code_path_artifact_path` is provided
- Code path analysis is complete

## Procedure

- [ ] 1. Read code path analysis from `code_path_artifact_path`
- [ ] 2. Check function signatures and type hints for affected interfaces
- [ ] 3. Verify compatibility with existing callers
- [ ] 4. Write interface compatibility artifact to `./tmp/{issue-N}/artifacts/interface-compatibility.yaml`

## Exit Criteria

- Interface compatibility artifact written with interface analysis
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Verified N interfaces, M compatible" |
| artifact_path | `./tmp/{issue-N}/artifacts/interface-compatibility.yaml` |
