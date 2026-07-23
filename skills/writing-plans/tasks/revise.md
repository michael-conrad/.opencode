# Task: revise

## Purpose

Revises an existing plan and dependency contract based on validation findings or a direct revision request, updating the plan body, phase structure, and dependency edges.

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
2. Determine the revision source:
   - If validation findings exist at `{issues_prefix}/{N}/artifacts/validate-findings.yaml`: read them as the revision reason.
   - If a revision reason was provided directly: use it.
   - If neither: return BLOCKED with `NO_REVISION_SOURCE`.
3. Read the current plan from `{issues_prefix}/{N}/plan.md`.
4. Read the current dependency contract from `{issues_prefix}/{N}/dependency-contract.yaml`.
5. Apply revisions based on the revision source:
   - For each FAIL finding in validation: fix the root cause in the plan or dependency contract.
   - For direct revision requests: apply the requested changes.
6. Write the updated plan to `{issues_prefix}/{N}/plan.md`.
7. Write the updated dependency contract to `{issues_prefix}/{N}/dependency-contract.yaml`.
8. Return the result contract.

## Exit Criteria

- The plan has been updated at `{issues_prefix}/{N}/plan.md`
- The dependency contract has been updated at `{issues_prefix}/{N}/dependency-contract.yaml`
- All revision findings have been addressed
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing what was revised and why>"
artifact_path: "<{issues_prefix}/{N}/plan.md>"
blocker_reason: "<reason if BLOCKED>"
```
