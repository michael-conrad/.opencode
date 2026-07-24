# Task: backfill

## Purpose

Generates missing analytical artifacts from the spec body when spec-creation did not produce them, enabling retroactive plan creation for pre-existing specs.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The spec file must exist at `{issues_prefix}/{N}/spec.md`

## Procedure

1. Verify the spec file exists at `{issues_prefix}/{N}/spec.md`.
   - If missing: return BLOCKED with `SPEC_NOT_FOUND` and the resolved path.
2. Read the spec body and extract success criteria, affected files, and scope information.
3. Check for existing analytical artifacts at `{issues_prefix}/{N}/artifacts/`.
   - If all 7 artifacts exist: return DONE with no backfill needed.
   - If any artifact is missing: proceed to backfill.
4. For each missing artifact, backfill from the spec body:
   - `blast-radius.yaml`: Extract affected files from spec, verify each exists in codebase.
   - `concern-map.yaml`: Decompose SCs into concern groups, map each to a phase boundary.
   - `code-path-inventory.yaml`: List code paths implied by each SC.
   - `cross-cutting-matrix.yaml`: Identify SCs that span multiple concerns.
   - `interface-compatibility.yaml`: Check interface boundaries between affected modules.
   - `state-analysis.yaml`: Identify state transitions required by each SC.
   - `testability-assessment.yaml`: Assign evidence types to each SC.
5. Write each backfilled artifact to `{issues_prefix}/{N}/artifacts/{name}.yaml`.
6. Write the analysis summary to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
   - Include: spec path, SC count, artifact status per artifact (existing or backfilled), scope summary.
7. Return the result contract.

## Exit Criteria

- The spec file has been verified to exist
- All 7 analytical artifacts exist (either pre-existing or backfilled)
- The analysis summary has been written to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing artifact status and backfill actions>"
artifact_path: "<{issues_prefix}/{N}/artifacts/analysis-summary.yaml>"
blocker_reason: "<reason if BLOCKED>"
```
