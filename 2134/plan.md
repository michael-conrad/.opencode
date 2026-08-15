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
