# Task: state-analysis

## Purpose

Analyze state transitions and state management affected by the proposed changes.

## Entry Criteria

- `interface_artifact_path` is provided
- Interface compatibility analysis is complete

## Procedure

- [ ] 1. Read interface compatibility from `interface_artifact_path`
- [ ] 2. Identify stateful components and their state machines
- [ ] 3. Document states, transitions, and invariants
- [ ] 4. Write state analysis artifact to `./tmp/{issue-N}/artifacts/state-analysis.yaml`

## Exit Criteria

- State analysis artifact written with states and transitions
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Analyzed N stateful components, M transitions" |
| artifact_path | `./tmp/{issue-N}/artifacts/state-analysis.yaml` |
