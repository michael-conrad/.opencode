# Task: audit-concern

## Purpose

Load the `adversarial-audit` skill and execute `--task concern-separation` inline with auditor sub-agent type context. Verifies each phase addresses exactly one concern.

## Entry Criteria

- Audit-fidelity step completed with PASS
- Plan document exists at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`

## Exit Criteria

- Concern-separation audit completed
- Auditor sub-agent type used (not `general`)
- Result contract contains PASS/FAIL with artifact_path

## Procedure

- [ ] 1. Load `adversarial-audit` skill: `skill({name: "adversarial-audit"})`
- [ ] 2. Execute `--task concern-separation` inline with auditor sub-agent type context
- [ ] 3. Collect audit artifact path
- [ ] 4. If PASS: return PASS with artifact_path
- [ ] 5. If FAIL: return BLOCKED with findings

## Context Required

- Related skills: `adversarial-audit`
- Related tools: `resolve-models` for auditor sub-agent type selection
