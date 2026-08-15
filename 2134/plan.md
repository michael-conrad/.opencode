---
plan_schema_version: "1.0"
issue: 2134
title: "Rewrite 117-session-trigger-behavior.md — cover self-simulation attack surface"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2134 — Rewrite 117-session-trigger-behavior.md

**Goal:** Rewrite `.opencode/guidelines/117-session-trigger-behavior.md` to add a mechanism-independent Self-Simulation Prohibition while preserving all actionable instructions from the original guideline.

**Architecture:** The rewrite restructures the guideline into four sections: (1) a new Self-Simulation Prohibition covering all five unauthorized mechanisms with an authorization-provenance carve-out, (2) the existing Session Trigger No-Echo narrowed as a specific case of the prohibition, (3) the Trigger Behavior Map narrowed to the two remaining triggers, and (4) the Suppression Rule. Phase 4 is a verification-only integration gate over all ten SCs. Phases 1-3 sequentially rewrite the single guideline file; Phase 4 depends on all three.

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md` (rewritten)

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**inline**).** Verify the spec is internally coherent: all ten SCs (SC-1 through SC-10) are traceable to requirements R-1 through R-5, and each SC maps to exactly one phase per the structure artifact. HALT if any SC is unmapped or multiply-mapped.
- [ ] 2. **Baseline check (**inline**).** Verify the original guideline `.opencode/guidelines/117-session-trigger-behavior.md` exists and is readable (needed as the SC-9 comparison source). Confirm the feature branch exists and the working tree is clean. HALT if the original file is missing or unreadable.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Self-Simulation Prohibition | `test-driven-development` | `red` / `green` | `.opencode/guidelines/117-session-trigger-behavior.md` | SC-1, SC-2, SC-10 | — |
| 2 — Narrow existing sections | `test-driven-development` | `red` / `green` | `.opencode/guidelines/117-session-trigger-behavior.md` | SC-3, SC-4, SC-5, SC-9 | 1 |
| 3 — Remove stale content | `test-driven-development` | `red` / `green` | `.opencode/guidelines/117-session-trigger-behavior.md` | SC-6, SC-7, SC-8 | 2 |
| 4 — Verify sections | `verification-before-completion` | `verify` | `.opencode/guidelines/117-session-trigger-behavior.md` | SC-1..SC-10 | 1, 2, 3 |

---

## Phase Details

### Phase 1 — Self-Simulation Prohibition

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/guidelines/117-session-trigger-behavior.md` |
| SCs | SC-1, SC-2, SC-10 |
| Depends On | — |

**Context:**
- Write the new Self-Simulation Prohibition section per Proposed Solution §1 of the spec.
- Cover all five unauthorized mechanisms: shell output, file write + read, comment + process, tool output re-ingestion, session trigger echoing.
- Encode the three-way distinction: unauthorized self-simulation (forbidden), authorized pipeline (permitted), data consumption (permitted).
- Include the authorization-provenance carve-out covering all four categories (spec→plan→implementation, task tracking files, spec and plan files, authorization-gated project items).
- SC-1 is string (grep for 'Self-Simulation'); SC-2 and SC-10 are semantic (V-SC-2, V-SC-10 checklists).

**Procedure:**
1. **SC-1 RED.** Write an enforcement test that greps the rewritten guideline for 'Self-Simulation' and expects FAIL (section not yet added).
2. **SC-1 GREEN.** Write the Self-Simulation Prohibition section (Proposed Solution §1).
3. **SC-1 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-1 — Self-Simulation Prohibition section"`.
4. **SC-2 RED.** Verifier runs V-SC-2 checklist against the guideline and expects FAIL (not all mechanisms covered).
5. **SC-2 GREEN.** Ensure the 5 mechanisms and the authorized-pipeline carve-out are present in the guideline body.
6. **SC-2 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-2 — 5 mechanisms + carve-out verified"`.
7. **SC-10 RED.** Verifier runs V-SC-10 checklist and expects FAIL (carve-out incomplete).
8. **SC-10 GREEN.** Ensure the guideline covers all 4 carve-out categories.
9. **SC-10 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-10 — carve-out coverage verified"`.

### Phase 2 — Narrow Existing Sections

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/guidelines/117-session-trigger-behavior.md` |
| SCs | SC-3, SC-4, SC-5, SC-9 |
| Depends On | 1 |

**Context:**
- Narrow the existing No-Echo section as a specific case of the Self-Simulation Prohibition.
- Narrow the Trigger Behavior Map to the two remaining triggers: `pair_mode_resume` and `nested_opencode_fatal`.
- Ensure the Suppression Rule section is preserved.
- Preserve all four original actionable instructions with equivalent semantic force (V-SC-9).
- SC-3, SC-4, SC-5 are string (grep); SC-9 is semantic (V-SC-9 checklist).

**Procedure:**
1. **SC-3 RED.** grep for 'No-Echo' in the rewritten guideline — expect FAIL (not yet narrowed).
2. **SC-3 GREEN.** Narrow the existing No-Echo section as a specific case of the Self-Simulation Prohibition.
3. **SC-3 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-3 — No-Echo section narrowed"`.
4. **SC-4 RED.** grep for 'pair_mode_resume' and 'nested_opencode_fatal' — expect FAIL (not yet narrowed).
5. **SC-4 GREEN.** Narrow the Trigger Behavior Map to the two remaining triggers.
6. **SC-4 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-4 — Trigger Behavior Map narrowed"`.
7. **SC-5 RED.** grep for 'Suppression Rule' — expect FAIL (not yet preserved).
8. **SC-5 GREEN.** Ensure the Suppression Rule section is present in the rewritten guideline.
9. **SC-5 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-5 — Suppression Rule preserved"`.
10. **SC-9 RED.** Verifier runs V-SC-9 checklist and expects FAIL (original instructions not all preserved).
11. **SC-9 GREEN.** Ensure all 4 original actionable instructions are preserved with equivalent semantic force.
12. **SC-9 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-9 — semantic preservation verified"`.

### Phase 3 — Remove Stale Content

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/guidelines/117-session-trigger-behavior.md` |
| SCs | SC-6, SC-7, SC-8 |
| Depends On | 2 |

**Context:**
- Remove the purged triggers list, the spec #426 historical reference, the per-turn guard reference, and any non-actionable content (V-SC-6).
- Remove cross-references to `session_context_triggers.py`, `session-enforcement.ts`, and non-preloaded files (V-SC-7).
- Remove the standalone cross-reference to `000-critical-rules.md` (V-SC-8).
- SC-6, SC-7, SC-8 are semantic (V-SC-6, V-SC-7, V-SC-8 checklists).

**Procedure:**
1. **SC-6 RED.** Verifier runs V-SC-6 checklist and expects FAIL (historical records present).
2. **SC-6 GREEN.** Remove purged triggers list, spec #426 reference, per-turn guard reference, and non-actionable content.
3. **SC-6 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-6 — non-actionable records removed"`.
4. **SC-7 RED.** Verifier runs V-SC-7 checklist and expects FAIL (stale cross-references present).
5. **SC-7 GREEN.** Remove cross-references to `session_context_triggers.py`, `session-enforcement.ts`, and non-preloaded files.
6. **SC-7 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-7 — stale cross-references removed"`.
7. **SC-8 RED.** Verifier runs V-SC-8 checklist and expects FAIL (standalone reference present).
8. **SC-8 GREEN.** Remove the standalone cross-reference to `000-critical-rules.md`.
9. **SC-8 COMMIT.** `git add .opencode/guidelines/117-session-trigger-behavior.md && git commit -m "checkpoint(#2134): item-8 — standalone reference removed"`.

### Phase 4 — Verify Sections

| Field | Value |
|-------|-------|
| Skill | `verification-before-completion` |
| Task | `verify` |
| Target | `.opencode/guidelines/117-session-trigger-behavior.md` |
| SCs | SC-1..SC-10 |
| Depends On | 1, 2, 3 |

**Context:**
- Run the integration verification gate over all ten SCs.
- Re-run all grep checks and V-SC checklists (V-SC-2, V-SC-6, V-SC-7, V-SC-8, V-SC-9, V-SC-10) across the full rewritten guideline.
- Execute post-implementation steps: audit, Z3 check, structural checks, pre-PR gate, regression check, review prep, PR creation, completion summary.

**Procedure:**
1. **Verify SC-1, SC-3, SC-4, SC-5 (string).** Re-run the grep checks for 'Self-Simulation', 'No-Echo', 'pair_mode_resume' + 'nested_opencode_fatal', and 'Suppression Rule' across the full rewritten guideline; each must PASS.
2. **Verify SC-2, SC-6, SC-7, SC-8, SC-9, SC-10 (semantic).** Re-run the V-SC-2, V-SC-6, V-SC-7, V-SC-8, V-SC-9, V-SC-10 checklists via clean-room sub-agent; all checks must PASS.
3. **Audit.** Dispatch `audit` verification-audit DiMo investigator (then validator, evaluator, arbiter) over the rewritten guideline.
4. **Z3 check.** Run `.opencode/tools/solve check --state-path ... --contract-path ...` against the dependency contract.
5. **Structural checks.** Dispatch `finishing-a-development-branch` checklist task (lint, typecheck, etc.).
6. **Pre-PR gate.** Dispatch `verification-before-completion` verify task; BLOCK if any SC verdict is FAIL.
7. **Regression check.** Dispatch `test-driven-development` phase-4 task for final regression.
8. **Review prep.** Dispatch `git-workflow-pr` review-prep task.
9. **Create PR.** Dispatch `git-workflow-pr` create task.
10. **Completion summary.** Dispatch `completion-core` completion task for the executive summary.

---

## Exit Criteria

- [ ] C1. Self-Simulation Prohibition section exists (SC-1)
- [ ] C2. Prohibition covers all five unauthorized mechanisms and the authorized-pipeline carve-out (SC-2)
- [ ] C3. Session Trigger No-Echo section narrowed (SC-3)
- [ ] C4. Trigger Behavior Map with the two remaining triggers (SC-4)
- [ ] C5. Suppression Rule present (SC-5)
- [ ] C6. No non-actionable historical records (SC-6)
- [ ] C7. No stale cross-references (SC-7)
- [ ] C8. No standalone 000-critical-rules.md reference (SC-8)
- [ ] C9. Semantic preservation of original actionable instructions (SC-9)
- [ ] C10. Authorization carve-out coverage (SC-10)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-15T14:24:13Z | `plan_created` | Plan file: `.opencode/.issues/2134/plan.md`; phase count: 4 |
