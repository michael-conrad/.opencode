# Task: pre-plan-readiness

## Purpose

Verify that the local spec file and feature branch exist before allowing plan creation. This gate prevents plan creation without verified prerequisites.

## Entry Criteria

- Spec file exists at `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
- Feature branch exists (not `dev` or `main`)
- `local-issues sync` has been run

## Exit Criteria

- BLOCKED if spec file is missing
- BLOCKED if feature branch is missing
- BLOCKED if `local-issues sync` has not been run
- PASS if all prerequisites are met

## Procedure

1. Check spec file exists at `.issues/{N}/spec.md` or `{project_root}/{path}/.issues/{N}/spec.md`
   - If missing: return `status: BLOCKED` with `reason: SPEC_FILE_MISSING`
2. Check feature branch exists and is not `dev` or `main`
   - If missing or on dev/main: return `status: BLOCKED` with `reason: FEATURE_BRANCH_MISSING`
3. Check `local-issues sync` has been run (verify `.issues/{N}/` directory is synced)
   - If not synced: return `status: BLOCKED` with `reason: LOCAL_ISSUES_NOT_SYNCED`
4. Return `status: PASS` with `finding_summary: "All prerequisites met"`
