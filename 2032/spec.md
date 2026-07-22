---
title: "SPEC-FIX: Task cards contain dispatch-level markers that only the orchestrator can execute"
status: draft
created: 2026-07-20
updated: 2026-07-21
license: MIT
provenance: AI-generated
issue: 2032
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20
<<<<<<< HEAD
**REVISED:** 2026-07-22 — Implementation audit: SC-2/SC-5 exempted backtick-quoted documentation references. SC-4/SC-7 deferred to #2020 (issue closed as duplicate). Cards created with audit findings.
=======
**REVISED:** 2026-07-22 — Implementation audit: SC-2/SC-5 exempted backtick-quoted documentation references. SC-4/SC-7 transferred to #2020 (superseding issue). Cards created with audit findings.
>>>>>>> 1eb57ca0 (auto: update #.opencode#2065)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

Task cards (files in `tasks/` directories) are consumed by sub-agents. A sub-agent can ONLY execute steps inline — it cannot call `task()`, cannot dispatch other sub-agents, and cannot route to other skills. However, **19 task cards** across the skill deck contain dispatch-level markers (DiMo role descriptions, chain flow documentation) that belong in the SKILL.md, not in task cards.

Additionally, the DiMo 4-role chain dispatch pattern (Investigator → Validator → Evaluator → Arbiter) is described in task cards when it should be documented only in the SKILL.md Trigger Dispatch Table.

## Scope

This spec is scoped to **fixing dispatch-level content in task cards** and **ensuring all remediated task cards have entry/exit criteria**. The following systemic problems discovered during audit are tracked as separate sub-issues:

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

### Additional Defects Discovered During Audit

The implementation audit revealed two additional defects not in the original scope:

1. **12 sub-role task cards missing entry/exit criteria** — The 12 sub-role files under `closure-verification/`, `coherence-extraction/`, and `spec-summary/` (investigator, validator, evaluator, arbiter for each) had no `## Entry Criteria` or `## Exit Criteria` sections. These files were not in the original 19-file scope because the original spec only counted parent files and standalone files. However, they are task cards consumed by sub-agents and must have entry/exit criteria per the Correct Architecture table.

2. **`resolve-models.md` missing exit criteria** — Had entry criteria but no exit criteria section.

3. **No behavioral test exists for SC-7** — The spec requires a behavioral test verifying sub-agents execute remediated task cards inline. No test was created during implementation.

## Fix

### Phase 1: Strip dispatch markers from 19 task cards

For each affected task card:
- Remove DiMo role descriptions (these belong in SKILL.md Trigger Dispatch Table)
- Remove chain flow documentation (Investigator → Validator → Evaluator → Arbiter)
- Replace with self-contained inline steps
- Add entry criteria and exit criteria where missing

### Phase 2: Add entry/exit criteria to 12 sub-role task cards

The 12 sub-role files under `closure-verification/`, `coherence-extraction/`, and `spec-summary/` (investigator, validator, evaluator, arbiter for each) are missing `## Entry Criteria` and `## Exit Criteria` sections. Add them based on each role's function:
- **Investigator**: Entry = evidence.yaml absent, spec_local_dir provided; Exit = evidence.yaml written
- **Validator**: Entry = evidence.yaml exists; Exit = reasoning.yaml written
- **Evaluator**: Entry = evidence.yaml + reasoning.yaml exist; Exit = verdict.yaml written
- **Arbiter**: Entry = verdict.yaml exists; Exit = judgment.yaml written

Also add `## Exit Criteria` to `resolve-models.md`.

### Phase 3: Create behavioral test for SC-7

Create a behavioral enforcement test in `.opencode/tests-v2/behaviors/` that verifies a sub-agent receiving a remediated task card executes inline (does not attempt to call task() or dispatch other sub-agents).

### Phase 4: Update SKILL.md Trigger Dispatch Tables

Ensure the SKILL.md for each affected skill documents the DiMo chain dispatch pattern in its Trigger Dispatch Table, not in task cards.

## Affected Files

| Category | Count | Files |
|----------|-------|-------|
| Task cards with DiMo content | 19 | `audit/tasks/closure-verification/` (4), `audit/tasks/coherence-extraction/` (4), `audit/tasks/spec-summary/` (4), `audit/tasks/resolve-models.md`, `audit/tasks/cross-validate.md`, `audit/tasks/spec-audit-*.md` (3), `audit/tasks/content-audit-evaluator.md`, `audit/tasks/behavioral-sc-evaluator.md` |
| Sub-role task cards missing entry/exit criteria | 12 | `audit/tasks/closure-verification/investigator.md`, `validator.md`, `evaluator.md`, `arbiter.md`; `coherence-extraction/` same 4; `spec-summary/` same 4 |
| Standalone missing exit criteria | 1 | `audit/tasks/resolve-models.md` |
| Behavioral test for SC-7 | 1 | `.opencode/tests-v2/behaviors/task-card-inline-execution.sh` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No task card contains DiMo role description blockquotes (`> **DiMo Role:**`) or chain flow documentation (`## DiMo Chain Flow` or `**DiMo role chain**`) | `string` | grep for "> \\*\\*DiMo Role:" or "DiMo Chain Flow" or "\\*\\*DiMo role chain\\*\\*" in all `tasks/*.md` — must return 0 matches |
| SC-2 | No task card contains `(**orchestrator**)` or `(**sub-agent**)` or `(**clean-room**)` or `(**inline**)` markers as dispatch instructions | `string` | grep for all 4 patterns in all `tasks/*.md`. Backtick-quoted documentation references (e.g., describing what dispatch indicators look like in plan files) are exempt — they are not dispatch markers. Must return 0 non-backtick-quoted matches. |
| SC-3 | No task card contains "Never task()" or "orchestrator dispatches" language | `string` | grep for both patterns in all `tasks/*.md` — must return 0 matches |
| SC-4 | All 31 remediated task cards (19 original + 12 sub-role) have entry criteria and exit criteria | `string` | Verify each remediated file has both sections — grep for `## Entry Criteria` and `## Exit Criteria` in each |
| SC-5 | All remediated task cards are self-contained (inline-only steps) | `string` | Verify no dispatch markers remain — grep for "> \\*\\*DiMo Role:" or "DiMo Chain Flow" or "\\*\\*DiMo role chain\\*\\*" or "(\*\*orchestrator\*\*)" or "(\*\*sub-agent\*\*)" or "(\*\*clean-room\*\*)" or "(\*\*inline\*\*)" or "Never task()" or "orchestrator dispatches" in all `tasks/*.md`. Backtick-quoted documentation references are exempt. Must return 0 non-backtick-quoted matches. |
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
