# Task: blast-radius

## Purpose

Analyze blast radius of the proposed changes — what files, systems, and behaviors are affected.

## Entry Criteria

- `decompose_artifact_path` is provided
- Decomposition is complete

## Procedure

- [ ] 1. Read decomposition from `decompose_artifact_path`
- [ ] 2. Run `srclight_get_dependents` on affected symbols
- [ ] 3. Document affected files, impact zones, and risk areas
- [ ] 4. Write blast radius artifact to `./tmp/{issue-N}/artifacts/blast-radius.yaml`

## Exit Criteria

- Blast radius artifact written with affected files and impact zones
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Blast radius: N files affected, M impact zones" |
| artifact_path | `./tmp/{issue-N}/artifacts/blast-radius.yaml` |
