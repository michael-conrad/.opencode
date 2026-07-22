# Task: cross-cutting

## Purpose

Identify cross-cutting concerns that span multiple SCs or phases.

## Entry Criteria

- `blast_artifact_path` is provided
- Blast radius analysis is complete

## Procedure

- [ ] 1. Read blast radius from `blast_artifact_path`
- [ ] 2. Identify concerns that span multiple SCs
- [ ] 3. Document cross-cutting SCs and their relationships
- [ ] 4. Write cross-cutting artifact to `./tmp/{issue-N}/artifacts/cross-cutting.yaml`

## Exit Criteria

- Cross-cutting artifact written with cross-cutting SCs
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Identified N cross-cutting concerns" |
| artifact_path | `./tmp/{issue-N}/artifacts/cross-cutting.yaml` |
