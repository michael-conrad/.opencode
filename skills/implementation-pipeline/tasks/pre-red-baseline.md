# Task: pre-red-baseline

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Initialize pipeline state and verify document source currency before RED phase begins. Runs as step 2 of the implementation pipeline after sc-coherence-gate. Produces a machine-parseable manifest documenting document source currency and SC-ID cross-reference traceability.

## Entry Criteria

- sc-coherence-gate step completed with PASS status
- Plan index exists at `{issue-N}/plan.md`; phase files at `{issue-N}/plan-{NN}-*.md` (multi-phase) or `{issue-N}/plan.md` (single-phase)
- Spec exists at `.issues/{issue-N}/spec.md`
- Authorization context available (authorization_scope, halt_at)

## Exit Criteria

- Solve state initialized at `{project_root}/tmp/{issue-N}/state/state.yaml`
- Handoff manifest written at `{project_root}/tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-{STATUS}-{timestamp}.yaml`
- Manifest contains `status: PASS` or `status: BLOCKED` with `blocked_reason`
- All validation checks completed

## Procedure

### Step 1: Initialize Solve State

- [ ] 1. Create state directory: `mkdir -p {project_root}/tmp/{issue-N}/state/`
- [ ] 2. Initialize solve state:
  ```bash
  solve state init {project_root}/tmp/{issue-N}/state/
  ```
- [ ] 3. Verify state file created at `{project_root}/tmp/{issue-N}/state/state.yaml`
- [ ] 4. Confirm state contains `current_step: pre-red-baseline` and `pipeline_state: init`

### Step 2: Document Source Currency Check

- [ ] 1. Read `{issue-N}/plan.md` (index) for phase table, then read `{issue-N}/plan-{NN}-*.md` for current phase
- [ ] 2. Read `.issues/{issue-N}/spec.md`
- [ ] 3. Extract all file paths referenced in the plan (source files, test files, config files)
- [ ] 4. For each referenced file path, verify the file exists in the codebase
- [ ] 5. For each referenced file path, check if the file has been modified since the plan was created
- [ ] 6. Flag missing files as `MISSING-FILE`
- [ ] 7. Flag modified files as `SOURCE-DRIFT`
- [ ] 8. Check submodule state: resolve default branch via `git remote show origin | sed -n 's/.*HEAD branch: //p'`, then run `git submodule status` and verify submodules are at that branch's tip
- [ ] 9. Flag stale submodules as `SUBMODULE-DRIFT`
- [ ] 10. Check the plan's creation timestamp against the spec's last revision timestamp
- [ ] 11. Flag if spec was revised after plan creation as `SPEC-REVISED-AFTER-PLAN`

### Step 3: SC-ID Cross-Reference Traceability

- [ ] 1. Read `.issues/{issue-N}/sc-summary.yaml` (if exists)
- [ ] 2. Read `{issue-N}/plan.md` (index) and `{issue-N}/plan-{NN}-*.md` (phase files)
- [ ] 3. Extract all SC-IDs referenced in the plan — collect as `sc_ids_in_plan`
- [ ] 4. Extract all SC-IDs from `sc-summary.yaml` — collect as `sc_ids_in_summary`
- [ ] 5. Compare `sc_ids_in_plan` against `sc_ids_in_summary`
- [ ] 6. Flag SC-IDs in plan but not in summary as `SCOPE-CREEP`
- [ ] 7. Flag SC-IDs in summary but not in plan as `MISSING-TRACEABILITY`
- [ ] 8. Verify each SC-ID in the plan has a corresponding test step in the TDD structure
- [ ] 9. Flag SC-IDs without test steps as `MISSING-TEST-STEP`

### Step 4: Write Baseline Manifest

Generate timestamp via `.opencode/tools/schema-version`. Store result in `$TIMESTAMP`.

Write `{project_root}/tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-{STATUS}-$TIMESTAMP.yaml`:

```yaml
schema_version: "1.0"
generated_at: "$TIMESTAMP"
step_label: pre-red-baseline
issue_number: {issue-N}
status: PASS | BLOCKED
blocked_reason: "<reason if BLOCKED, else null>"
checks:
  - check_id: SOLVE_STATE_INIT
    result: PASS | FAIL
    detail: "..."
  - check_id: DOCUMENT_SOURCE_CURRENCY
    result: PASS | FAIL
    detail: "..."
  - check_id: SUBMODULE_STATE
    result: PASS | FAIL
    detail: "..."
  - check_id: SC_ID_TRACEABILITY
    result: PASS | FAIL
    detail: "..."
summary:
  total_checks: 4
  pass: <count>
  fail: <count>
  missing_files: <list>
  source_drift: <list>
  submodule_drift: <list>
  scope_creep: <list>
  missing_traceability: <list>
  missing_test_steps: <list>
```

## Context Required

- Preceded by: sc-coherence-gate (implementation-pipeline step 1)
- Feeds into: red-phase (implementation-pipeline step 3)
- Related artifacts: `{issue-N}/plan.md` (index), `{issue-N}/plan-{NN}-*.md` (phase files), `{issue-N}/spec.md`, `{issue-N}/sc-summary.yaml`

## Z3 State Integration

### State Initialization
```bash
solve state init {project_root}/tmp/{issue-N}/state/
```

Creates state file with:
- `current_step: pre-red-baseline`
- `pipeline_state: init`

### State Update (after manifest write)
```bash
solve state update {project_root}/tmp/{issue-N}/state/ --var-name previous_step --var-value pre-red-baseline --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update {project_root}/tmp/{issue-N}/state/ --var-name current_step --var-value red-phase --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
solve state update {project_root}/tmp/{issue-N}/state/ --var-name pipeline_state --var-value running --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

### State Validation
```bash
solve check --state-path {project_root}/tmp/{issue-N}/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

## Artifact Format

All artifacts follow the #932 naming convention:
```
{project_root}/tmp/{issue-N}/artifacts/pipeline-pre-red-baseline-{STATUS}-{timestamp}.yaml
```

Where `{STATUS}` is uppercase: `PASS`, `FAIL`, `UNVERIFIED`.

## Related Files

- `skills/implementation-pipeline/SKILL.md` — dispatch routing table
- `skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table (pipeline step definitions)
- `skills/implementation-pipeline/pipeline-state-machine.yaml` — Z3 legal transition definitions
- `.opencode/tools/solve` — Z3 constraint solver for state management
