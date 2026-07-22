---
name: pipeline-executor
description: "Per-item dispatch loop that reads plan steps sequentially and dispatches each step according to its dispatch indicator. The orchestrator processes inline steps directly and dispatches sub-agent/clean-room steps individually via task()."
license: MIT
provenance: AI-generated
---

# Pipeline Executor

Step-level dispatch loop for the implementation pipeline. Reads the plan's steps sequentially, evaluates each step's dispatch indicator, and executes or dispatches accordingly.

## Entry Criteria

- [ ] 1. Plan is approved and available at `{plan_path}`
- [ ] 2. Work state file exists at `{project_root}/tmp/{issue-N}/work.md` with per-item entries
- [ ] 3. `authorization_scope >= for_implementation`
- [ ] 4. Dispatch mode verification gate has passed (no `per-phase` or `batched` modes present)

## Step-Level Dispatch Loop

For each step in the plan (in sequential order):

### 1. Read Step Dispatch Indicator

Read the step's dispatch indicator from the plan:
- `(**inline**)` — orchestrator executes the step directly
- `(**sub-agent**)` — orchestrator dispatches to a sub-agent with context via `task()`
- `(**clean-room**)` — orchestrator dispatches to a sub-agent with routing metadata only via `task()`

**Every step MUST declare an explicit dispatch indicator.** There is no default. If a step lacks a dispatch indicator, the orchestrator MUST BLOCK with `reason: MISSING_DISPATCH_INDICATOR`.

### 2. Execute or Dispatch

| Indicator | Action | Context Passed |
|-----------|--------|----------------|
| `(**inline**)` | Orchestrator executes the step directly | N/A — orchestrator context |
| `(**sub-agent**)` | `task(subagent_type="general", prompt: "{step_description}")` with issue_number, plan_path, step_number, authorization_scope, halt_at | Full context |
| `(**clean-room**)` | `task(subagent_type="general", prompt: "{step_description}")` with issue_number only | Routing metadata only |

### 3. Per-Item Checkpoint

After each step completes with status DONE:
1. Create checkpoint tag: `git tag {parent}/checkpoint/{issue}/item-{step_number}` (exact format per git-workflow convention)
2. Update work state: set `work.md` entry for this step to `status: completed`

### 4. Per-Item Verification

Before proceeding to the next step:
1. If the step was executed inline: the orchestrator verifies the step's SCs directly
2. If the step was dispatched via `task()`: verify the sub-agent's result contract has `status: DONE`
3. On FAIL: remediate per the pipeline's remediation routing, then re-attempt the step

### 5. Advance to Next Step

- Update `pipeline_phase` to the next step number
- Clear `todowrite` state for the current step
- Continue loop from step 1

## Completion

When all steps have been processed:
- [ ] 1. Verify all steps have `status: completed` in work state
- [ ] 2. Verify checkpoint tags exist for all items
- [ ] 3. Append lifecycle event: `{event: pipeline_complete, step_count: N, status: PASS}`
- [ ] 4. Return result contract with `status: DONE` and `artifact_path`

## Verification

- [ ] gor step indicator is present and valid for every step
- [ ] gor batch indicator never present — BLOCK on `per-phase` or `batched`
- [ ] All checkpoint tags follow per-item pattern
- [ ] Work state has one entry per step

## Cross-References

- `assemble-work.md` — Creates the work state and plan input
- Read [Trigger Dispatch Table](skills/implementation-pipeline/SKILL.md) — `step-dispatch` row
- Read [Overview](skills/implementation-pipeline/SKILL.md) — Step-level dispatch mandate
- `enforcement/dispatch-mode-verification.md` — Dispatch mode verification gate
