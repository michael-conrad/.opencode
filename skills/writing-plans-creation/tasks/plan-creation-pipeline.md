# Task: plan-creation-pipeline

## Purpose

Execute the plan creation pipeline: take the solve artifact and produce a structured plan with phase decomposition, dependency ordering, and SC-to-step traceability.

## Entry Criteria

- `solve_artifact_path` is provided and points to a valid solve YAML
- Spec is approved and spec_local_dir is available

## Procedure

- [ ] 1. Read solve artifact from `solve_artifact_path`
- [ ] 2. Decompose spec SCs into phases based on solve output
- [ ] 3. Create phase dependency ordering
- [ ] 4. Map each SC to one or more plan steps
- [ ] 5. Write pipeline artifact to `./tmp/{issue-N}/artifacts/pipeline.yaml`

## Exit Criteria

- Pipeline artifact written with phase decomposition, dependency ordering, and SC-to-step mapping
- Artifact path returned in result contract

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Pipeline created: N phases, M steps" |
| artifact_path | `./tmp/{issue-N}/artifacts/pipeline.yaml` |
| blocker_reason | "..." (on BLOCKED) |
