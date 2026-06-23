# Task: audit-fidelity

## Purpose

Load the `adversarial-audit` skill and execute `--task plan-fidelity` inline with auditor sub-agent type context. Verifies the plan faithfully reflects the spec.

## Entry Criteria

- Validate step completed with PASS
- Plan document exists at `.issues/{N}/plan.md`

## Exit Criteria

- Plan-fidelity audit completed
- Auditor sub-agent type used (not `general`)
- Result contract contains PASS/FAIL with artifact_path

## Procedure

1. Load `adversarial-audit` skill: `skill({name: "adversarial-audit"})`
2. Execute `--task plan-fidelity` inline with auditor sub-agent type context
3. Collect audit artifact path
4. If PASS: return PASS with artifact_path
5. If FAIL: return BLOCKED with findings

## Context Required

- Related skills: `adversarial-audit`
- Related tools: `resolve-models` for auditor sub-agent type selection
