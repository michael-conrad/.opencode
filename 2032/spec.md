---
title: "SPEC-FIX: Task cards contain dispatch-level markers that only the orchestrator can execute"
status: draft
created: 2026-07-20
updated: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2032
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

Task cards (files in `tasks/` directories) are consumed by sub-agents. A sub-agent can ONLY execute steps inline — it cannot call `task()`, cannot dispatch other sub-agents, and cannot route to other skills. However, **19 task cards** across the skill deck contain dispatch-level markers (DiMo role descriptions, chain flow documentation) that belong in the SKILL.md, not in task cards.

Additionally, the DiMo 4-role chain dispatch pattern (Investigator → Validator → Evaluator → Arbiter) is described in task cards when it should be documented only in the SKILL.md Trigger Dispatch Table.

## Scope

This spec is scoped to **fixing dispatch-level content in task cards** only. The following systemic problems discovered during audit are tracked as separate sub-issues:

| Issue | Problem |
|-------|---------|
| #2039 | 28 task cards referenced in TDTs but missing from `tasks/` directories |
| #2040 | 42 orphaned task card files not referenced by any TDT |
| #2042 | 6 skills with task directories but no TDT in SKILL.md |
| #2041 | 4 naming inconsistency patterns across skill deck |

## Root Cause

Task cards were written with orchestrator-level routing content (DiMo role descriptions, chain flow documentation, `(**orchestrator**)` tags). This content belongs in the SKILL.md Pipeline section or Trigger Dispatch Table, not in task cards that sub-agents read.

## Correct Architecture

| Artifact | Consumer | Content | Rules |
|----------|----------|---------|-------|
| **SKILL.md** | Orchestrator | YAML description, enumerated workflow lists, Trigger Dispatch Table, Invocation | Workflow steps with `[sub-task]`/`[inline]`/`[clean-room]` markers. Orchestrator reads these to know the sequence. |
| **Task card** (`tasks/<name>.md`) | Sub-agent | Self-contained procedure with entry criteria, inline-only steps, exit criteria | NO dispatch markers. NO `task()` references. NO DiMo chain descriptions. Sub-agent reads and executes inline. |

## Audit Findings

### Task Cards with Dispatch Content (19 files)

All 19 are **documentation-type** (DiMo role descriptions, chain flow descriptions) — not instructional. They do not tell the sub-agent to call `task()`. However, they contain dispatch-level markers that belong in the SKILL.md.

| # | File | Content |
|---|------|---------|
| 1-4 | `audit/tasks/closure-verification.md` + sub-roles | DiMo 4-role chain description |
| 5-8 | `audit/tasks/coherence-extraction.md` + sub-roles | DiMo 4-role chain description |
| 9-12 | `audit/tasks/spec-summary.md` + sub-roles | DiMo 4-role chain description |
| 13 | `audit/tasks/resolve-models.md` | DiMo Arbiter role reference |
| 14 | `audit/tasks/cross-validate.md` | "Never task() auditors from within cross-validate" |
| 15 | `audit/tasks/spec-audit-evaluator.md` | DiMo Role: Evaluator |
| 16 | `audit/tasks/spec-audit-investigator.md` | DiMo Role: Investigator |
| 17 | `audit/tasks/spec-audit-validator.md` | DiMo Role: Validator |
| 18 | `audit/tasks/content-audit-evaluator.md` | DiMo Role: Evaluator |
| 19 | `audit/tasks/behavioral-sc-evaluator.md` | DiMo Role reference |

## Fix

### Phase 1: Strip dispatch markers from 19 task cards

For each affected task card:
- Remove DiMo role descriptions (these belong in SKILL.md Trigger Dispatch Table)
- Remove chain flow documentation (Investigator → Validator → Evaluator → Arbiter)
- Replace with self-contained inline steps
- Add entry criteria and exit criteria where missing

### Phase 2: Update SKILL.md Trigger Dispatch Tables

Ensure the SKILL.md for each affected skill documents the DiMo chain dispatch pattern in its Trigger Dispatch Table, not in task cards.

## Affected Files

| Category | Count | Files |
|----------|-------|-------|
| Task cards with DiMo content | 19 | `audit/tasks/closure-verification/` (4), `audit/tasks/coherence-extraction/` (4), `audit/tasks/spec-summary/` (4), `audit/tasks/resolve-models.md`, `audit/tasks/cross-validate.md`, `audit/tasks/spec-audit-*.md` (3), `audit/tasks/content-audit-evaluator.md`, `audit/tasks/behavioral-sc-evaluator.md` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No task card contains DiMo role descriptions or chain flow documentation | `string` | grep for "DiMo.*Role" or "DiMo.*chain" in all `tasks/*.md` — must return 0 matches |
| SC-2 | No task card contains `(**orchestrator**)` or `(**sub-agent**)` or `(**clean-room**)` or `(**inline**)` markers | `string` | grep for all 4 patterns in all `tasks/*.md` — must return 0 matches |
| SC-3 | No task card contains "Never task()" or "orchestrator dispatches" language | `string` | grep for both patterns in all `tasks/*.md` — must return 0 matches |
| SC-4 | All 19 remediated task cards have entry criteria and exit criteria | `string` | Verify each remediated file has both sections |
| SC-5 | All 19 remediated task cards are self-contained (inline-only steps) | `string` | Verify no dispatch markers remain |
| SC-6 | audit SKILL.md Trigger Dispatch Table documents DiMo chain dispatch | `string` | Verify TDT has DiMo chain documentation |
| SC-7 | Behavioral test: sub-agent receiving remediated task card executes inline | `behavioral` | `opencode run` with task card execution prompt |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Removing DiMo role descriptions breaks sub-agent role awareness | Medium | Medium | Ensure SKILL.md TDT documents the role chain |
| Some task cards need restructuring to be self-contained | Medium | Medium | Each task card must be independently executable |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Full semantic audit | Read all 337 task cards across 60 skills | Identify dispatch-level content in task cards |
| DiMo audit | 4-role chain (Investigator → Validator → Evaluator → Arbiter) | Validate findings and produce judgment |
| Supplementary audit | Cross-reference TDTs against filesystem | Identify missing/orphaned task cards |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
