# Task: audit-concern

## Purpose

Load the `audit` skill and execute `--task concern-separation` inline with auditor sub-agent type context. Verifies each phase addresses exactly one concern.

## Entry Criteria

- Audit-fidelity step completed with PASS
- Plan index exists at `{N}/plan.md`; phase files at `{N}/plan-{NN}-*.md` (multi-phase) or `{N}/plan.md` (single-phase)

## Exit Criteria

- Concern-separation audit completed
- Auditor sub-agent type used (not `general`)
- Result contract contains PASS/FAIL with artifact_path

## Procedure

- [ ] 1. Load `audit` skill: `skill({name: "audit"})`
- [ ] 2. Execute `--task concern-separation` inline with auditor sub-agent type context
- [ ] 3. Collect audit artifact path
- [ ] 4. If PASS: return PASS with artifact_path
- [ ] 5. If FAIL: return BLOCKED with findings

## Context Required

- Related skills: `audit`
- Related tools: single-agent dispatch (all audits use task(subagent_type='general'))
