# Task: testability-assessment

## Purpose

Assess testability of each success criterion and determine appropriate evidence types.

## Entry Criteria

- `readiness_artifact_path` is provided
- Pipeline readiness gate has passed

## Procedure

- [ ] 1. Read readiness artifact from `readiness_artifact_path`
- [ ] 2. For each SC, assess testability and determine evidence type
- [ ] 3. Document testability assessment with evidence type per SC
- [ ] 4. Write testability assessment artifact to `./tmp/{issue-N}/artifacts/testability-assessment.yaml`

## Exit Criteria

- Testability assessment artifact written with evidence types per SC
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Assessed testability for N SCs" |
| artifact_path | `./tmp/{issue-N}/artifacts/testability-assessment.yaml` |
