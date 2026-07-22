# Task: pre-spec-inspection

## Purpose

Inspect the codebase before writing the spec to gather context about affected files, existing patterns, and potential impacts.

## Entry Criteria

- Issue number is provided
- Clean-room: only issue_number passed

## Procedure

- [ ] 1. Search codebase for affected files using `srclight_hybrid_search` or `srclight_get_dependents`
- [ ] 2. Identify existing patterns and conventions in the affected area
- [ ] 3. Document findings in `./tmp/{issue-N}/artifacts/pre-spec-inspection.yaml`

## Exit Criteria

- Inspection artifact written with affected files, patterns, and findings
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Inspection complete: N files affected" |
| artifact_path | `./tmp/{issue-N}/artifacts/pre-spec-inspection.yaml` |
