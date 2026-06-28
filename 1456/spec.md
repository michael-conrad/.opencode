# [SPEC-FIX] Fix G: adversarial-audit description completeness (D3)

**Parent:** https://github.com/michael-conrad/.opencode/issues/1384 — Audit: Skill Card "Use When" Description Compliance

## Problem

The `adversarial-audit` SKILL.md description lists only 6 of 14 dispatch targets from the Trigger Dispatch Table. This violates D3 (Completeness) — the description must cover all dispatch conditions.

## Current Description

```
Use when running adversarial audits of specs, plans, or code. Audits are not optional — dispatch to spec-audit, plan-fidelity, concern-separation, coherence-extraction, guideline-audit, or cross-validate. Every unverified deliverable is a defect.
```

## Missing Dispatch Targets

The Trigger Dispatch Table lists 14 tasks. The description covers only 6:

| Covered | Missing |
|---------|---------|
| spec-audit, plan-fidelity, concern-separation, coherence-extraction, guideline-audit, cross-validate | drift-detection, spec-summary, closure-verification, test-quality-audit, resolve-models, verification-audit, coherence-maintenance, completion |

## Requirements

1. Add all 8 missing dispatch targets to the description
2. Remove the narrative-only sentence ("Every unverified deliverable is a defect.")
3. Retain mandatory language ("Audits are not optional")

## Proposed Description

```
Use when running adversarial audits of specs, plans, or code. Dispatch to spec-audit, plan-fidelity, concern-separation, coherence-extraction, coherence-maintenance, guideline-audit, drift-detection, spec-summary, closure-verification, test-quality-audit, verification-audit, resolve-models, cross-validate, or completion. Audits are not optional — dispatch is MANDATORY.
```

## File

`.opencode/skills/adversarial-audit/SKILL.md` — `description` field in YAML frontmatter

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Description lists all 14 dispatch targets from the Trigger Dispatch Table | `string` |
| SC-2 | Description retains mandatory language | `string` |
| SC-3 | Narrative-only sentence removed | `string` |
| SC-4 | Description matches proposed text exactly | `string` |
