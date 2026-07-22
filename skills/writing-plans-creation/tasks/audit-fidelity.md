# Task: audit-fidelity

## Purpose

Load the `audit` skill and execute `--task plan-fidelity` inline. Verifies the plan faithfully reflects the spec.

## Entry Criteria

- Validate step completed with PASS
- Plan index exists at `{N}/plan.md`; phase files at `{N}/plan-{NN}-*.md` (multi-phase) or `{N}/plan.md` (single-phase)
- `clean_room_plan`: Plan text generated independently from the spec (required by plan-fidelity entry criteria)

## Exit Criteria

- Plan-fidelity audit completed
- Result contract contains PASS/FAIL with artifact_path

## Procedure

- [ ] 1. Load `audit` skill: `skill({name: "audit"})`
- [ ] 2. Execute `--task plan-fidelity` inline, passing `clean_room_plan` as context
- [ ] 3. Collect audit artifact path
- [ ] 4. If PASS: return PASS with artifact_path
- [ ] 5. If FAIL: return BLOCKED with findings

## Context Required

- Related skills: `audit`

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/audit-fidelity.yaml" |
| blocker_reason | "..." |
