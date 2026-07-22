# Task: decompose

## Purpose

Decompose the problem into success criteria for the spec.

## Entry Criteria

- `concern_artifact_path` is provided
- Concern analysis is complete

## Procedure

- [ ] 1. Read concern analysis from `concern_artifact_path`
- [ ] 2. Decompose each concern into specific, testable success criteria
- [ ] 3. Assign evidence types to each SC
- [ ] 4. Write decomposition artifact to `./tmp/{issue-N}/artifacts/decomposition.yaml`

## Exit Criteria

- Decomposition artifact written with SCs and evidence types
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Decomposed into N success criteria" |
| artifact_path | `./tmp/{issue-N}/artifacts/decomposition.yaml` |
