# Task: verify-authorization — Step 5d.2: Verify Blockers

## Purpose

Thin wrapper dispatching `tasks/verify-blockers.md` for blocking dependency check.

## Entry Criteria

- Authorization verified (from Step 1)
- Sub-issues verified (from Step 5)
- Codebase verified (from Step 5d.1)

## Exit Criteria

- No blocking issues, no unresolved dependencies

## Procedure

Dispatch `tasks/verify-blockers.md` with the current issue context. Reads from `{project_root}/tmp/{issue-N}/verify-authorization/verify-codebase.yaml`, writes to `{project_root}/tmp/{issue-N}/verify-authorization/verify-blockers.yaml`.

## Result Contract

This sub-task writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/verify-blockers.yaml`.

Before proceeding, read the prior step's result contract from `{project_root}/tmp/{issue-N}/verify-authorization/verify-codebase.yaml`. If the prior step's `status` is not `DONE`, return BLOCKED with `reason: PRIOR_STEP_FAILED`.

```yaml
status: DONE|BLOCKED
finding_summary: "<blocking dependency findings>"
artifact_path: "{project_root}/tmp/{issue-N}/verify-authorization/verify-blockers.yaml"
blocker_reason: "<reason if BLOCKED>"
```
