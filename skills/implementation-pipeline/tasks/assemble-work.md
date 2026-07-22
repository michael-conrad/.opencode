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

### 5. Entry Proof Marker

Add an entry proof marker to the work state file after Step 4 completes:

```yaml
entry_proof:
  marker: "assemble_work_complete"
  timestamp: "{utc_timestamp}"
  step_count: {N}
  authorization_scope: "{authorization_scope}"
```

The entry proof marker confirms that assemble-work completed successfully and the pipeline executor can proceed. The marker is verified by the pipeline executor before it begins step-level execution.

### 6. OVERFLOW Handling

When a sub-agent returns an OVERFLOW result contract during step-level execution, the pipeline executor MUST:

1. Record completed items in work state file (mark as `status: completed`)
2. Create new sub-agent task(s) for remaining items using the suggested split strategy from the OVERFLOW contract
3. Re-dispatch new sub-agent(s) with reduced scope
4. Continue orchestration with accumulated results

The OVERFLOW contract format is defined in `enforcement/overflow-signal.md`:

```yaml
status: OVERFLOW
task: <task-name>
completed_items: [<item-ids-or-names>]
remaining_items: [<item-ids-or-names>]
context_usage: <estimated-percentage>
suggested_split: <proposed-split-strategy>
```

### 7. Work State Verification

After each sub-agent returns a result contract, verify the work state against live state before proceeding:

| Claim | Verification Action | Tool Call |
|-------|---------------------|-----------|
| Sub-agent completed | Result contract exists with status DONE | Read work state file |
| Issue created | Issue exists on GitHub with correct title and labels | `github_issue_read(method=get, issue_number=N)` |
| Branch created | Branch exists in local worktree | `git rev-parse --verify <branch>` |
| All phases complete | Every phase in work state has status DONE | Read work state file |

Claims without tool-call artifacts are verification honesty violations per `enforcement/work-state-verification.md`.

### 8. Post-Sub-Agent Completion Checkpoint

Before accepting any sub-agent result contract as `DONE`, run a completion checkpoint with hash mismatch detection:

1. Compute a hash of the sub-agent's output artifact (file content hash)
2. Compare against the hash recorded in the result contract
3. If hashes match: accept the result as `DONE`
4. If hashes mismatch: treat the result as `BLOCKED` and re-task the sub-agent clean-room

The checkpoint MUST run before any result contract is accepted as `DONE`. A hash mismatch blocks acceptance — the orchestrator treats the result as `BLOCKED` and re-tasks the sub-agent.

## Verification

- [ ] Every step in the plan has an explicit dispatch indicator — zero defaults
- [ ] No `per-phase` or `batched` indicators present anywhere
- [ ] Work state file has exactly N entries where N = total plan steps
- [ ] Work state entries have correct `status: pending` initial state
- [ ] Entry proof marker present in work state file
- [ ] OVERFLOW handling documented in pipeline executor
- [ ] Work state verification table present
- [ ] Post-sub-agent completion checkpoint with hash mismatch detection present

## Cross-References

- `pipeline-executor.md` — Consumes the work state produced by this task
- `enforcement/dispatch-mode-verification.md` — Dispatch mode verification gate
- `enforcement/overflow-signal.md` — OVERFLOW contract format and re-dispatch protocol
- `enforcement/work-state-verification.md` — Live state verification table
- `SKILL.md` §Overview — Step-level dispatch mandate
- `pre-flight-handoff.md` — Pre-flight verification that precedes assemble-work
- `pre-analysis/tasks/analyze.md` §6.5 — Post-sub-agent completion checkpoint with hash mismatch detection
