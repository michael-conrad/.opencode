# Task: concern-analysis

## Purpose

Analyze concern boundaries and scope isolation for the spec.

## Entry Criteria

- `requirements_artifact_path` is provided
- Requirements have been extracted

## Procedure

- [ ] 1. Read requirements from `requirements_artifact_path`
- [ ] 2. Identify distinct concern areas
- [ ] 3. Document concern boundaries
- [ ] 4. Write concern analysis artifact to `./tmp/{issue-N}/artifacts/concern-analysis.yaml`

## Exit Criteria

- Concern analysis artifact written with concern boundaries
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Identified N concern areas" |
| artifact_path | `./tmp/{issue-N}/artifacts/concern-analysis.yaml` |
