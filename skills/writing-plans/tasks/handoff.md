# Task: handoff

## Purpose

Verifies authorization via `approval-gate --task verify-authorization` before the plan creation pipeline begins. This is the entry gate that ensures only authorized plan creation proceeds.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- The issue number `{N}` must be provided
- The project root and issues prefix must be set
- The spec must exist at `{issues_prefix}/{N}/spec.md`

## Procedure

1. Verify the spec exists at `{issues_prefix}/{N}/spec.md`.
   - If missing: return BLOCKED with `SPEC_NOT_FOUND`.
2. Verify authorization via `approval-gate --task verify-authorization`:
   - Check that the issue has an `approved-for-*` label matching the required scope.
   - If no `approved-for-*` label: return BLOCKED with `SPEC_NOT_APPROVED`.
3. Report the authorization status in the finding summary.
4. Return the result contract.

## Exit Criteria

- The spec has been verified to exist
- Authorization has been verified via approval-gate
- The authorization status has been reported in the finding summary

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing authorization verification>"
artifact_path: "<{issues_prefix}/{N}/spec.md>"
blocker_reason: "<reason if BLOCKED>"
```
