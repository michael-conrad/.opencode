# Task: verify-spec-approved

## Purpose

Verify that the spec issue has been approved for implementation before proceeding with plan creation.

## Entry Criteria

- `spec_local_dir` is provided
- Issue number is provided

## Procedure

- [ ] 1. Read the spec file from `spec_local_dir`
- [ ] 2. Check for `approved-for-*` label on the issue
- [ ] 3. If approved, return PASS with `spec_local_dir`
- [ ] 4. If not approved, return BLOCKED with `reason: NOT_APPROVED`

## Exit Criteria

- PASS or BLOCKED status returned
- `spec_local_dir` passed through on PASS

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Spec approved" or "Spec not approved" |
| artifact_path | `spec_local_dir` (on PASS) |
| blocker_reason | "NOT_APPROVED" (on BLOCKED) |
