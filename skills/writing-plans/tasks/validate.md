# Task: validate

## Purpose

Performs structural validation of the plan against 6 check categories: skill+task validity, SC coverage, concern separation, DAG validation, artifact alignment, and holistic quality.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The solve output must exist at `{issues_prefix}/{N}/artifacts/solve-output.yaml` with SAT status

## Procedure

1. Read the solve output from `{issues_prefix}/{N}/artifacts/solve-output.yaml`.
   - If missing or not SAT: return BLOCKED with `SOLVE_NOT_SAT`.
2. Read the plan from `{issues_prefix}/{N}/plan.md`.
3. Read the dependency contract from `{issues_prefix}/{N}/dependency-contract.yaml`.
4. Execute the 6 validation check categories:

   **Category 1 — Structural validation:**
   - Verify plan.md has a phase table with all required columns.
   - Verify each phase has a procedure section with numbered steps.
   - Verify exit criteria section exists with SC-to-phase mapping.

   **Category 2 — Skill+task validity:**
   - Verify every skill+task reference in the plan matches a valid entry in the implementation-pipeline TDT.
   - If any reference is invalid: record as a finding with FAIL.

   **Category 3 — SC coverage:**
   - Verify every SC from the spec appears in at least one phase's exit criteria.
   - If any SC is uncovered: record as a finding with FAIL.

   **Category 4 — Concern separation:**
   - Verify each phase addresses exactly one concern from the concern-map artifact.
   - Verify no two phases address the same concern.
   - If violation: record as a finding with FAIL.

   **Category 5 — DAG validation:**
   - Verify the dependency contract DAG has no cycles.
   - Verify all phases are reachable from the start node.
   - Verify no orphan phases (no incoming or outgoing edges).
   - If violation: record as a finding with FAIL.

   **Category 6 — Holistic quality:**
   - Verify no TBD/TODO placeholders in the plan body.
   - Verify all steps use checkbox format.
   - Verify dispatch mode consistency (inline phases have no dispatched steps, clean-room phases have no inline steps).
   - If violation: record as a finding with FAIL.

5. Write the validation findings to `{issues_prefix}/{N}/artifacts/validate-findings.yaml`.
   - Include: per-category results with PASS/FAIL per check, finding details, overall status.
6. Return the result contract.

## Exit Criteria

- All 6 validation categories have been executed with PASS/FAIL per check
- Each check produces a deterministic PASS/FAIL result
- The validation findings have been written to `{issues_prefix}/{N}/artifacts/validate-findings.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing PASS/FAIL per category and overall status>"
artifact_path: "<{issues_prefix}/{N}/artifacts/validate-findings.yaml>"
blocker_reason: "<reason if BLOCKED>"
```
