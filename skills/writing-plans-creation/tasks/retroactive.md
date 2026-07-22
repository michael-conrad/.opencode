# Task: retroactive

## Purpose

Create a plan for an existing spec that does not yet have one.

## Entry Criteria

- Spec file exists at `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- Feature branch exists (not the trunk)

## Procedure

1. Verify spec exists at `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
   - If missing: return BLOCKED with `SPEC_FILE_MISSING`
2. Read the spec body from the spec file
3. Create a plan from the spec content using the standard plan creation approach
4. Write the plan index to `{N}/plan.md` and phase files to `{N}/plan-{NN}-*.md`
5. Return PASS with plan file path

## Exit Criteria

- Plan index written to `{N}/plan.md` with phase table
- Phase files written to `{N}/plan-{NN}-*.md` (one per phase)
- Result contract contains plan file path

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/retroactive-plan.yaml" |
| blocker_reason | "..." |
