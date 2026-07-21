---
title: "SPEC-FIX: 6 skills have task directories but no Trigger Dispatch Table in SKILL.md"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2040
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order.

## Problem

6 skills have `tasks/` directories with task card files but their SKILL.md files lack a Trigger Dispatch Table section. Without a TDT, the orchestrator has no routing information for these tasks — they are unreachable.

## Affected Skills

| Skill | Task Count | Notes |
|-------|-----------|-------|
| `spec-creation-change-control` | 1 | `change-control.md` |
| `spec-creation-decomposition` | 9 | Analytical artifact task cards |
| `spec-creation-requirements` | 1 | `requirements.md` |
| `spec-creation-validation` | 8 | Create, holistic check, risk, etc. |
| `writing-plans-creation` | 16 | Full plan creation pipeline |
| `writing-plans-holistic` | 1 | `holistic-self-check.md` |

## Root Cause

These skills were created as sub-skills (task containers) without their own TDT. The parent skills (`spec-creation`, `writing-plans`) reference them via Invocation sections, but the sub-skills themselves have no TDT for their own task cards.

## Fix

For each skill, add a Trigger Dispatch Table to the SKILL.md that references all task card files in its `tasks/` directory. Each TDT entry must have:
- User says / Context trigger
- Task name
- Dispatch type
- Context passed

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 6 skills have a TDT in their SKILL.md | `string` | Verify each SKILL.md has a `## Trigger Dispatch Table` section |
| SC-2 | Each TDT references all task card files in the skill's `tasks/` directory | `string` | Cross-reference TDT entries against filesystem |

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
