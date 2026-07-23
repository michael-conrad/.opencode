# Task: completion

## Purpose

Verifies that plan files exist, appends a lifecycle event to the issue body, and reports the execution strategy for downstream pipeline routing.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The plan must exist at `{issues_prefix}/{N}/plan.md`

## Procedure

1. Verify the plan exists at `{issues_prefix}/{N}/plan.md`.
   - If missing: return BLOCKED with `PLAN_NOT_FOUND`.
2. Verify the dependency contract exists at `{issues_prefix}/{N}/dependency-contract.yaml`.
   - If missing: record as a finding but do not block.
3. Read the plan and extract the execution strategy:
   - Phase count and names.
   - Dispatch mode per phase (inline, clean-room).
   - Pipeline signal for downstream routing.
4. Append a lifecycle event to the plan file at `{issues_prefix}/{N}/plan.md`:
   - Add a `lifecycle_events` section with the current timestamp and event type `plan_created`.
   - Include the plan file path and phase count.
5. Report the execution strategy in the finding summary:
   - Phase count, dispatch mode summary, and recommended next pipeline step.
6. Return the result contract.

## Exit Criteria

- The plan file has been verified to exist
- The lifecycle event has been appended to the issue body
- The execution strategy has been reported in the finding summary
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing plan verification, lifecycle event, and execution strategy>"
artifact_path: "<{issues_prefix}/{N}/plan.md>"
blocker_reason: "<reason if BLOCKED>"
```
