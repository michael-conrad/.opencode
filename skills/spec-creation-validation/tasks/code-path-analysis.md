# Task: code-path-analysis

## Purpose

Analyze code paths affected by the proposed changes.

## Entry Criteria

- `traceability_artifact_path` is provided
- Traceability analysis is complete

## Procedure

- [ ] 1. Read traceability artifact from `traceability_artifact_path`
- [ ] 2. Trace code paths for each affected file
- [ ] 3. Document entry points, branches, and exit points
- [ ] 4. Write code path analysis artifact to `./tmp/{issue-N}/artifacts/code-path-analysis.yaml`

## Exit Criteria

- Code path analysis artifact written with code path inventory
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Analyzed N code paths across M files" |
| artifact_path | `./tmp/{issue-N}/artifacts/code-path-analysis.yaml` |
