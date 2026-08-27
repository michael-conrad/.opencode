---
plan_schema_version: "1.0"
issue: 2339
title: "Skill card pre-flight guard for sub-agent dispatch"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
---

# Implementation Plan — #2339 — Skill Card Pre-Flight Guard for Sub-Agent Dispatch

**Goal:** Add a uniform pre-flight guard to every skill card that detects sub-agent context and returns `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` before any routing metadata is consumed, backed by lint/validation enforcement and a documentation mandate.

**Architecture:** A single canonical guard definition is established in the four requirements reference documents first (mandate, then canonical definition), then applied to all 51 skill cards, then enforced mechanically by `skildeck-lint` and `validate_skill_cards.py`, embedded in the `init_skill.py` template, and referenced by the critical-rules-XXX rule as the defensive backstop. The phase order follows the dependency DAG: documentation mandate and canonical definition sequence before content application; content application precedes lint/validation enforcement; the canonical definition feeds the template and the critical rule.

**Files:**
- `.opencode/skills/*/SKILL.md` and `.opencode/skills/*/platforms/*/SKILL.md` (51 cards)
- `.opencode/tools/impl/skildeck/skildeck-lint`
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/reference/skill-card-schema.md`
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/skills/skill-creator/reference/skill-card-spec.md`
- `.opencode/skills/skill-creator/reference/routing-only-template.md`
- `.opencode/skills/skill-creator/scripts/init_skill.py`
- `.opencode/guidelines/000-critical-rules.md`

---

## Blast Radius

The change touches the skill-card content layer (all 51 SKILL.md files), the enforcement tooling (`skildeck-lint`, `validate_skill_cards.py`), the documentation layer (four reference documents), the template generator (`init_skill.py`), and the normative guideline (`000-critical-rules.md`). Out of scope: task cards (`tasks/*.md`), behavioral enforcement test authoring, and the canonical skill card template redesign tracked separately in #2052. The guard is additive — it does not alter frontmatter or the Workflows dispatch contract.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

---

## Pre-Implementation

- [ ] 1. **Coherence gate (**inline**).** Verify the spec is internally coherent: all seven SCs (SC-1 through SC-7) are traceable to requirements R-1 through R-7, and each SC maps to exactly one phase per the structure artifact. HALT if any SC is unmapped or multiply-mapped.
- [ ] 2. **Baseline check (**inline**).** Verify the feature branch exists and the working tree is clean. Confirm the 51 skill card files, the four reference documents, and the three tooling files exist and are readable. HALT if any required source file is missing.
- [ ] 3. **Pre-regression (**sub-agent**).** Dispatch `test-driven-development` phase-0 task to run regression test patterns before the first RED phase. **→ all SCs**
- [ ] 4. **Pre-regression-verify (**sub-agent**).** Dispatch `verification-before-completion` verify task to confirm pre-regression results. **→ all SCs**

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Requirements documentation guard mandate | `test-driven-development` | `red` / `green` | four reference documents | SC-4 | — |
| 2 — Canonical guard definition | `test-driven-development` | `red` / `green` | four reference documents | SC-5 | 1 |
| 3 — Apply pre-flight guard to all skill cards | `test-driven-development` | `red` / `green` | 51 SKILL.md files | SC-1 | 2 |
| 4 — skildeck-lint guard enforcement | `test-driven-development` | `red` / `green` | `skildeck-lint` | SC-2 | 3 |
| 5 — validate_skill_cards.py guard enforcement | `test-driven-development` | `red` / `green` | `validate_skill_cards.py` | SC-3 | 3 |
| 6 — Template generator guard | `test-driven-development` | `red` / `green` | `init_skill.py` | SC-6 | 2 |
| 7 — Critical rule references the guard | `test-driven-development` | `red` / `green` | `000-critical-rules.md` | SC-7 | 2 |

---

## Phase Details

### Phase 1 — Requirements Documentation Guard Mandate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/reference/skill-card-schema.md`, `.opencode/reference/skill-card-description-standards.md`, `.opencode/skills/skill-creator/reference/skill-card-spec.md`, `.opencode/skills/skill-creator/reference/routing-only-template.md` |
| SCs | SC-4 |
| Depends On | — |

**Context:**
- Add the pre-flight guard mandate to the four requirements documentation documents: `skill-card-schema.md`, `skill-card-description-standards.md`, `skill-card-spec.md`, `routing-only-template.md`.
- The mandate states that every SKILL.md must carry a pre-flight guard that detects sub-agent context and returns `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` before routing metadata is consumed.
- SC-4 is string (static content assertion across four documents).

**Procedure:**
1. **SC-4 RED.** Write an enforcement check that greps the four reference documents for the guard mandate marker and expects FAIL (mandate not yet present).
2. **SC-4 GREEN.** Add the guard mandate to all four reference documents.
3. **SC-4 post-regression.** Run the `test-driven-development` phase-4 regression task.
4. **SC-4 verify.** Dispatch `verification-before-completion` verify task; assert the mandate is present in all four documents.
5. **SC-4 COMMIT.** `git add` the four reference documents `&& git commit -m "checkpoint(#2339): item-4 — guard mandate added to four reference docs"`.

### Phase 2 — Canonical Guard Definition

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `skill-card-schema.md`, `skill-card-description-standards.md`, `skill-card-spec.md`, `routing-only-template.md` |
| SCs | SC-5 |
| Depends On | 1 |

**Context:**
- Define a single canonical guard definition in the four requirements documentation documents, consistent across all of them.
- The canonical definition encodes the exact guard wording and the `ORCHESTRATOR_ONLY_SKILL_CARD` behavior consumed by SC-1 (per-card wording), SC-6 (template), and SC-7 (critical rule).
- SC-5 is string (consistency assertion across four documents).

**Procedure:**
1. **SC-5 RED.** Write an enforcement check that asserts the four reference documents contain a single consistent canonical guard definition and expects FAIL (not yet present or inconsistent).
2. **SC-5 GREEN.** Define the single canonical guard definition in all four reference documents.
3. **SC-5 post-regression.** Run the `test-driven-development` phase-4 regression task.
4. **SC-5 verify.** Dispatch `verification-before-completion` verify task; assert a single consistent canonical definition is present across all four documents.
5. **SC-5 COMMIT.** `git add` the four reference documents `&& git commit -m "checkpoint(#2339): item-5 — canonical guard definition finalized"`.

### Phase 3 — Apply Pre-Flight Guard to All Skill Cards

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | 51 SKILL.md files under `.opencode/skills/` including `.opencode/skills/*/platforms/*/SKILL.md` |
| SCs | SC-1 |
| Depends On | 2 |

**Context:**
- Apply the canonical guard definition (from Phase 2) to every one of the 51 skill cards, verbatim, before any routing metadata section.
- The guard is positioned as a pre-flight entry check ahead of the Workflows/routing sections.
- SC-1 is string (grep across all 51 SKILL.md files for the guard marker; `skildeck lint` run with no guard findings).

**Procedure:**
1. **SC-1 RED.** Write an enforcement check that asserts a skill card without the guard produces a guard finding (grep-based or lint-based) and expects FAIL (cards not yet guarded).
2. **SC-1 GREEN.** Add the canonical pre-flight guard section to all 51 SKILL.md files using the canonical wording from the requirements docs.
3. **SC-1 post-regression.** Run the `test-driven-development` phase-4 regression task.
4. **SC-1 verify.** Grep all 51 SKILL.md files for the guard marker; run `skildeck lint` and confirm no guard finding.
5. **SC-1 COMMIT.** `git add` all 51 skill card files `&& git commit -m "checkpoint(#2339): item-1 — pre-flight guard applied to 51 skill cards"`.

### Phase 4 — skildeck-lint Guard Enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/tools/impl/skildeck/skildeck-lint` |
| SCs | SC-2 |
| Depends On | 3 |

**Context:**
- Add a `lint_skill_preflight_guard` rule to `skildeck-lint` that flags a SKILL.md lacking the guard and does not flag a card with the guard (idempotent — no double-guard finding).
- The lint rule reads the guard marker; additive and does not alter frontmatter or the Workflows dispatch contract.
- SC-2 is behavioral (run `skildeck-lint` against a card with and without the guard; assert finding when guard missing, absent when present).

**Procedure:**
1. **SC-2 RED.** Write an enforcement test asserting a card without the guard produces a lint finding and expects FAIL.
2. **SC-2 GREEN.** Add the `lint_skill_preflight_guard` rule to `skildeck-lint`.
3. **SC-2 post-regression.** Run the phase-4 regression task.
4. **SC-2 verify.** Run `skildeck-lint` against a guarded and an unguarded card; assert a finding is present when the guard is missing and absent when the guard is present.
5. **SC-2 COMMIT.** `git add .opencode/tools/impl/skildeck/skildeck-lint && git commit -m "checkpoint(#2339): item-2 — skildeck-lint guard enforcement"`.

### Phase 5 — validate_skill_cards.py Guard Enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` |
| SCs | SC-3 |
| Depends On | 3 |

**Context:**
- Add a REQ rule to `validate_skill_cards.py` that flags a SKILL.md lacking the guard.
- Independent enforcement backstop parallel to `skildeck-lint`.
- SC-3 is behavioral (run `validate_skill_cards.py` against a card with and without the guard; assert finding when guard missing, absent when present).

**Procedure:**
1. **SC-3 RED.** Write an enforcement test asserting a card without the guard produces a validation finding and expects FAIL.
2. **SC-3 GREEN.** Add the REQ rule to `validate_skill_cards.py`.
3. **SC-3 post-regression.** Run the phase-4 regression task.
4. **SC-3 verify.** Run `validate_skill_cards.py` against a guarded and an unguarded card; assert a finding is present when the guard is missing and absent when the guard is present.
5. **SC-3 COMMIT.** `git add .opencode/skills/skill-creator/scripts/validate_skill_cards.py && git commit -m "checkpoint(#2339): item-3 — validate_skill_cards.py guard enforcement"`.

### Phase 6 — Template Generator Guard

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/skills/skill-creator/scripts/init_skill.py` |
| SCs | SC-6 |
| Depends On | 2 |

**Context:**
- Add the pre-flight guard section to the `SKILL_TEMPLATE` string in `init_skill.py` so newly generated cards are born guarded.
- The generated card must pass lint/validation.
- SC-6 is behavioral (run the template generator, generate a card, and assert the guard is present).

**Procedure:**
1. **SC-6 RED.** Write an enforcement test asserting the generated card from the template contains the guard and expects FAIL.
2. **SC-6 GREEN.** Add the pre-flight guard section to the `SKILL_TEMPLATE` in `init_skill.py`.
3. **SC-6 post-regression.** Run the phase-4 regression task.
4. **SC-6 verify.** Unit-test the template string; generate a card from the template and confirm the guard is present.
5. **SC-6 COMMIT.** `git add .opencode/skills/skill-creator/scripts/init_skill.py && git commit -m "checkpoint(#2339): item-6 — template generator emits guard"`.

### Phase 7 — Critical Rule References the Guard

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/guidelines/000-critical-rules.md` |
| SCs | SC-7 |
| Depends On | 2 |

**Context:**
- Update the `critical-rules-XXX` section (dispatching SKILL.md to sub-agents) in `000-critical-rules.md` to reference the pre-flight guard as the defensive backstop.
- SC-7 is string (read the critical rule section; assert the guard reference is present).

**Procedure:**
1. **SC-7 RED.** Write an enforcement check that asserts the `critical-rules-XXX` section references the guard and expects FAIL.
2. **SC-7 GREEN.** Update the `critical-rules-XXX` section in `000-critical-rules.md` to reference the pre-flight guard as the defensive backstop.
3. **SC-7 post-regression.** Run the phase-4 regression task.
4. **SC-7 verify.** Read the critical rule section and confirm the guard reference is present.
5. **SC-7 COMMIT.** `git add .opencode/guidelines/000-critical-rules.md && git commit -m "checkpoint(#2339): item-7 — critical rule references guard backstop"`.

---

## Post-Implementation

- [ ] 54. **Audit (**sub-agent**).** Dispatch the `audit` verification-audit DiMo investigator over the deliverable, followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 55. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` against the dependency contract. **→ all SCs**
- [ ] 56. **Structural checks (**sub-agent**).** Dispatch the `finishing-a-development-branch` checklist task (lint, typecheck, etc.). **→ all SCs**
- [ ] 57. **Pre-PR gate (**sub-agent**).** Dispatch the `verification-before-completion` verify task; it reads all SC verdicts and BLOCKs if any is FAIL. **→ all SCs**
- [ ] 58. **Regression check (**sub-agent**).** Dispatch the `test-driven-development` phase-4 task for a final regression check. **→ all SCs**
- [ ] 59. **Review prep (**sub-agent**).** Dispatch the `git-workflow-pr` review-prep task. **→ all SCs**
- [ ] 60. **Create PR (**sub-agent**).** Dispatch the `git-workflow-pr` create task. **→ all SCs**
- [ ] 61. **Completion summary (**sub-agent**).** Dispatch the `completion-core` completion task for the executive summary. **→ all SCs**

---

## Exit Criteria

- [ ] C1. Every SKILL.md under `.opencode/skills/` (including `platforms/*/SKILL.md`) contains the pre-flight guard (SC-1)
- [ ] C2. `skildeck-lint` flags a card lacking the guard and passes a guarded card (SC-2)
- [ ] C3. `validate_skill_cards.py` flags a card lacking the guard and passes a guarded card (SC-3)
- [ ] C4. The four requirements documentation documents mandate the guard (SC-4)
- [ ] C5. A single canonical guard definition is consistent across the four documents (SC-5)
- [ ] C6. The template generator (`init_skill.py`) emits the guard in new cards (SC-6)
- [ ] C7. The critical-rules-XXX section references the guard as the defensive backstop (SC-7)

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-26 | `plan_created` | Plan file: `.opencode/.issues/2339/plan.md`; phase count: 7 |
