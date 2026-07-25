# Task: verify-authorization — Step 5d.4: Verify Already Implemented

## Purpose

Thin wrapper dispatching `tasks/verify-already-implemented.md` for terminal gate: auto-close or proceed.

## Entry Criteria

- Authorization verified (from Step 1)
- Codebase checked (from Step 5d.1)
- No blockers (from Step 5d.2)
- Main issue closure verified (from Step 5d.3)

## Exit Criteria

- Auto-close or proceed to implementation

## Procedure

Dispatch `tasks/verify-already-implemented.md` with the current issue context. Reads from `{project_root}/tmp/{issue-N}/verify-authorization/verify-closed-issue-main.yaml`, writes to `{project_root}/tmp/{issue-N}/verify-authorization/verify-already-implemented.yaml`.

## Result Contract

This sub-task writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/verify-already-implemented.yaml`.

Before proceeding, read the prior step's result contract from `{project_root}/tmp/{issue-N}/verify-authorization/verify-closed-issue-main.yaml`. If the prior step's `status` is not `DONE`, return BLOCKED with `reason: PRIOR_STEP_FAILED`.

```yaml
status: DONE|BLOCKED
finding_summary: "<already-implemented verification findings>"
artifact_path: "{project_root}/tmp/{issue-N}/verify-authorization/verify-already-implemented.yaml"
blocker_reason: "<reason if BLOCKED>"
```
