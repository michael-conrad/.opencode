# Task: audit-concern

## Purpose

Load the `audit` skill and execute `--task concern-separation` inline. Verifies each phase addresses exactly one concern.

## Entry Criteria

- Audit-fidelity step completed with PASS
- Plan index exists at `{N}/plan.md`; phase files at `{N}/plan-{NN}-*.md` (multi-phase) or `{N}/plan.md` (single-phase)

## Exit Criteria

- Concern-separation audit completed
- Result contract contains PASS/FAIL with artifact_path

## Procedure

- [ ] 1. Load `audit` skill: `skill({name: "audit"})`
- [ ] 2. Execute `--task concern-separation` inline
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
| artifact_path | ".../artifacts/audit-concern.yaml" |
| blocker_reason | "..." |
