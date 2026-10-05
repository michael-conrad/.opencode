# Task: verify-plan-pipeline

## Purpose

Verify that the writing-plans pipeline was followed before accepting a plan. This gate prevents acceptance of plans created by dispatching a single sub-agent with a custom prompt instead of following the full pipeline.

## Entry Criteria

- Plan artifacts exist at `.issues/{N}/plan.md` or `{project_root}/{path}/.issues/{N}/plan.md`
- Feature branch exists

## Exit Criteria

- PASS if all pipeline artifacts are present
- FAIL if any pipeline artifact is missing

## Procedure

1. Check local spec file exists at `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
   - If missing: return `status: FAIL` with `reason: SPEC_FILE_MISSING`
2. Check feature branch exists and is not the trunk
   - If missing or on the trunk: return `status: FAIL` with `reason: FEATURE_BRANCH_MISSING`
3. Check Z3 check artifacts exist (look for `solve check` output artifacts)
   - If missing: return `status: FAIL` with `reason: Z3_CHECK_ARTIFACTS_MISSING`
4. Check audit artifacts exist (look for audit-fidelity and audit-concern output)
   - If missing: return `status: FAIL` with `reason: AUDIT_ARTIFACTS_MISSING`
5. Check completion artifact exists (look for lifecycle event or completion output)
   - If missing: return `status: FAIL` with `reason: COMPLETION_ARTIFACT_MISSING`
6. Return `status: PASS` with `finding_summary: "All pipeline artifacts present"`
