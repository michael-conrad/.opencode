---
name: assemble-work
description: "Orchestrator entry point that reads the plan, creates per-item work state entries, validates dispatch indicators, and hands off to pipeline-executor for step-level execution."
license: MIT
provenance: AI-generated
---

# Assemble Work

Orchestrator entry point for the implementation pipeline. Reads the approved plan, validates dispatch indicators, creates per-item work state entries, and hands off to the pipeline executor.

## Entry Criteria

- [ ] 1. Plan is approved (check `approved-for-*` label on spec issue)
- [ ] 2. Plan has per-item steps with dispatch indicators (``, `(**sub-agent**)`, `(**clean-room**)`)
- [ ] 3. `authorization_scope >= for_implementation`

## Procedure

### 1. Read and Validate Plan

1. Read the plan from `{plan_path}`
2. Verify every step has an explicit dispatch indicator — no step may be missing ``, `(**sub-agent**)`, or `(**clean-room**)`
3. Verify NO step uses `per-phase` or `batched` indicators — BLOCK if found with `reason: BATCHED_DISPATCH_NOT_ALLOWED`
4. Count total steps: `N = len(steps)`

### 2. Create Per-Item Work State

Create per-item work state entries in `{project_root}/tmp/{issue-N}/work.md`:

```yaml
plan:
  issue: "{issue-N}"
  total_steps: {N}
  authorization_scope: "{authorization_scope}"
  halt_at: "{halt_at}"

steps:
  - step: 1
    name: "{step_name}"
    dispatch: "{inline|sub-agent|clean-room}"
    status: pending
    checkpoint_tag: ""
    result_contract: ""
  - step: 2
    name: "{step_name}"
    dispatch: "{inline|sub-agent|clean-room}"
    status: pending
    checkpoint_tag: ""
    result_contract: ""
  # ... one entry per step
```

### 3. Run Dispatch Mode Verification Gate

Dispatch `dispatch-mode-verification` gate to verify:
- No step uses `per-phase` or `batched` indicators
- Every step has a valid dispatch indicator
- Total step count matches plan

Gate must return PASS before proceeding.

### 4. Hand Off to Pipeline Executor

1. Set `pipeline_phase = pipeline-executor`
2. Append lifecycle event: `{event: assemble_work_complete, total_steps: N, status: PASS}`
3. Return result contract with:
   - `status: DONE`
   - `artifact_path: {project_root}/tmp/{issue-N}/work.md`
   - `step_count: N`

## Verification

- [ ] Every step in the plan has an explicit dispatch indicator — zero defaults
- [ ] No `per-phase` or `batched` indicators present anywhere
- [ ] Work state file has exactly N entries where N = total plan steps
- [ ] Work state entries have correct `status: pending` initial state

## Cross-References

- `pipeline-executor.md` — Consumes the work state produced by this task
- `enforcement/dispatch-mode-verification.md` — Dispatch mode verification gate
- `SKILL.md` §Overview — Step-level dispatch mandate
- `pre-flight-handoff.md` — Pre-flight verification that precedes assemble-work
