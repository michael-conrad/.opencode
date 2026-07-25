# Task: verify-authorization — Step 5d.1: Verify Codebase

## Purpose

Thin wrapper dispatching `tasks/verify-codebase.md` for staleness detection and superseding issue check.

## Entry Criteria

- Authorization verified (from Step 1)
- Sub-issues verified (from Step 5)

## Exit Criteria

- Files exist, code valid, no superseding issues, no staleness

## Procedure

Dispatch `tasks/verify-codebase.md` with the current issue context. Reads from `{project_root}/tmp/{issue-N}/verify-authorization/sub-issue-verification.yaml`, writes to `{project_root}/tmp/{issue-N}/verify-authorization/verify-codebase.yaml`.

## Result Contract

This sub-task writes its result contract to `{project_root}/tmp/{issue-N}/verify-authorization/verify-codebase.yaml`.

Before proceeding, read the prior step's result contract from `{project_root}/tmp/{issue-N}/verify-authorization/sub-issue-verification.yaml`. If the prior step's `status` is not `DONE`, return BLOCKED with `reason: PRIOR_STEP_FAILED`.

```yaml
status: DONE|BLOCKED
finding_summary: "<codebase staleness and superseding issue findings>"
artifact_path: "{project_root}/tmp/{issue-N}/verify-authorization/verify-codebase.yaml"
blocker_reason: "<reason if BLOCKED>"
```
