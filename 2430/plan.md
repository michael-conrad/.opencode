---
plan_schema_version: "1.0"
issue: 2430
title: "Mechanical Pre-Flight Guard (task-tool probe) for skill cards and plan files"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
dispatch:
  - phase: 1
    tasks: [test-driven-development:red, test-driven-development:green, verification-before-completion:verify]
  - phase: 2
    tasks: [test-driven-development:red, test-driven-development:green, verification-before-completion:verify]
  - phase: 3
    tasks: [test-driven-development:red, test-driven-development:green, verification-before-completion:verify]
  - phase: 4
    tasks: [test-driven-development:red, test-driven-development:green, verification-before-completion:verify]
  - phase: 5
    tasks: [test-driven-development:red, test-driven-development:green, test-driven-development:post-regression, verification-before-completion:verify]
  - post-implementation:
      tasks: [audit:verification-audit, finishing-a-development-branch:checklist, verification-before-completion:verify, test-driven-development:post-regression, git-workflow-pr:review-prep, git-workflow-pr:create, completion-core:completion]
---

# Implementation Plan — [.opencode#2430](https://github.com/michael-conrad/.opencode/issues/2430) — Mechanical Pre-Flight Guard (task-tool probe) for skill cards and plan files

**Goal:** Define one canonical mechanical Pre-Flight Guard block (task-tool presence check), embed it verbatim in all 51 skill cards and every `writing-plans` plan, add deck-lint and plan-audit flagging for missing/deviant guards, and prove the guard behaviorally in the tests-v2 harness.

**Architecture:** The guard is defined exactly once as a canonical reference document under `.opencode/guidelines/` (R-2). A content-based, position-independent lint rule (skildeck + `validate_skill_cards.py`) verifies cards against the canonical text; the `audit` plan-fidelity path gains a FAIL finding class for plans missing the guard. The rollout is strictly additive: canonical doc → lint rule → 51-card sweep → plan template → behavioral enforcement tests. Dispatch strings, Trigger Dispatch Tables, and result contracts are untouched. The sole discriminator is absence of a tool named `task` — the `skill` tool is NOT a discriminator (probe `ses_f9ac0f59bffetMsE6s3sQOHoQ8`: skill present in sub-agent context, 96 tools, no `task`). Cards use reason code `ORCHESTRATOR_ONLY_SKILL_CARD`; plans use `ORCHESTRATOR_ONLY_PLAN`. The guard governs ACTION, not perception.

**Files:**

- `.opencode/guidelines/` — new canonical guard reference document + `INDEX.md` cross-link
- `.opencode/tools/skildeck` and `.opencode/tools/impl/skildeck/` — guard-verbatim lint rule + fixture
- `.opencode/skills/skill-creator/scripts/` — `validate_skill_cards.py` guard-verbatim check
- `.opencode/skills/*/SKILL.md` (48 top-level) and `.opencode/skills/issue-operations/platforms/{github-mcp,gitbucket-api,local}/SKILL.md` (3 nested) — 51-card guard sweep
- `.opencode/skills/writing-plans/` — plan template + `tasks/create.md` + `tasks/revise.md` guard emission
- `.opencode/skills/audit/tasks/` — plan-fidelity investigator/evaluator/arbiter/validator FAIL finding class
- `.opencode/tests-v2/behaviors/` — new behavioral scenario scripts + fixtures

**Dispatch:** Pre-implementation (coherence gate, baseline check, pre-regression, pre-regression-verify) runs once per plan. Each item runs the RED → GREEN → verify → commit-inline daisy chain; RED/GREEN dispatch via `test-driven-development` task cards, verify via `verification-before-completion`, commit-inline is orchestrator-direct. Post-implementation (audit DiMo chain, z3-check, structural checks, pre-PR gate, regression check, review-prep, PR creation, completion summary) runs once at plan end.

---

## Blast Radius

- **Phase 1 — low.** Purely additive new reference document; no existing content restructured. All guard-consuming surfaces (cards, plans, lint, audit, tests) must reference the single canonical definition — no divergent inline variants.
- **Phase 2 — medium.** Every SKILL.md becomes subject to the new lint rule; pre-existing cards without the guard flag once the rule lands (ahead of the phase-3 sweep — that flag is the phase-3 RED, not a regression). `skill-creator` card validation behavior changes for all future create/update flows.
- **Phase 3 — medium.** All 51 cards change the Pre-Flight Guard section in place; TDTs, dispatch strings, and result contracts untouched. A partial/missed replacement leaves a prose-guard card that phase-2 lint must catch.
- **Phase 4 — low.** Additive template section; backward compatible with existing plan consumers. Existing pre-guard plans remain valid — no retroactive regeneration.
- **Phase 5 — low.** Tests only; runtime cost per run is minutes of model execution. Behavioral scenarios become the regression gate for future card/plan template changes; SC-5 no-false-halt is the recovery gate for any over-firing guard variant.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete. Partial implementation is not permitted.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Canonical guard reference | `test-driven-development` | `red`, `green` | `.opencode/guidelines/` canonical guard reference doc + `INDEX.md` cross-link | — (preparatory, R-2 infrastructure) | — |
| 2 — Deck-lint rule + fixture | `test-driven-development` | `red`, `green` | `.opencode/tools/impl/skildeck/` lint rule, `validate_skill_cards.py` check, guard-missing fixture card | SC-6a | 1 |
| 3 — Card sweep (51 cards) | `test-driven-development` | `red`, `green` | 48 top-level SKILL.md + 3 nested platform cards | SC-1 | 1, 2 |
| 4 — Plan template guard | `test-driven-development` | `red`, `green` | `writing-plans` plan template + `tasks/create.md` + `tasks/revise.md` | SC-2 | 1 |
| 5 — Behavioral enforcement tests | `test-driven-development` | `red`, `green`, `post-regression` | `.opencode/tests-v2/behaviors/` scenario scripts; `audit` plan-fidelity tasks | SC-3, SC-4, SC-5, SC-6b | 1, 3, 4 |

**SC coverage check:** SC-1 → phase 3; SC-2 → phase 4; SC-3, SC-4, SC-5, SC-6b → phase 5; SC-6a → phase 2. Phase 1 completes no SC — it is the preparatory single-source-of-truth phase every later phase consumes. No circular dependencies: the DAG is 1 → 2 → 3 → 5 and 1 → 4 → 5, strictly forward.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation (Global Steps)

- [ ] 1. **Coherence gate (**direct**).** Verify spec-to-plan coherence before any work.
  - Confirm all seven SCs from the spec map to exactly one phase item each: SC-6a → phase 2, SC-1 → phase 3, SC-2 → phase 4, SC-3/SC-4/SC-5/SC-6b → phase 5, and phase 1 is preparatory (no SC).
  - Confirm the phase DAG (1 → 2 → 3 → 5; 1 → 4 → 5) has no circular dependencies and no RED test depends on SC output committed in a later phase.
  - Confirm each item references exactly one SC-ID; no item covers multiple SCs.

- [ ] 2. **Baseline check (**direct**).** Verify repository state before implementation.
  - Confirm the parent repo and the `.opencode` submodule are on the default branch, at the remote tracking tip, with zero pending changes and matching submodule pointers.
  - Confirm the feature branch for this issue exists (created under `for_pr` authorization — label `approved-for-pr` is present in the local issue record) and is checked out in both repos.
  - If any baseline condition fails, run git-workflow pre-work before proceeding; do not start from a non-trunk-tip state.

- [ ] 3. **Pre-regression (**task-card**).** Run regression test patterns before the RED phase.
  - Dispatch: `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-pre-regression-*` before dispatch.

- [ ] 4. **Pre-regression verify (**task-card**).** Verify the pre-regression results.
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Pre-clean step artifacts: `rm -f tmp/2430/artifacts/pipeline-pre-regression-verify-*` before dispatch.
  - Halt on FAIL — do not enter phase 1 with a failing regression baseline.

---

## Exit Criteria

- [ ] C1. The canonical mechanical Pre-Flight Guard is defined exactly once in a reference document under `.opencode/guidelines/` with an `INDEX.md` cross-link (R-2).
- [ ] C2. Deck lint flags a fixture card missing the guard or carrying a deviant variant, and `validate_skill_cards.py` verifies guard-verbatim embedding (SC-6a, R-4).
- [ ] C3. All 51 SKILL.md files — 48 top-level plus 3 nested platform cards — embed the canonical mechanical guard verbatim; deck lint reports zero cards missing/deviant (SC-1, R-1).
- [ ] C4. Every plan produced by `writing-plans` embeds the canonical guard with reason code `ORCHESTRATOR_ONLY_PLAN`; the behavioral create-run confirms it (SC-2, R-3).
- [ ] C5. The card-leak behavioral scenario shows a sub-agent returning `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` with no dispatch attempt (SC-3).
- [ ] C6. The plan-leak behavioral scenario shows a sub-agent returning `BLOCKED` + `ORCHESTRATOR_ONLY_PLAN` with no phase execution (SC-4).
- [ ] C7. The no-false-halt behavioral scenario shows an orchestrator session reaching Trigger Dispatch Table use with no `BLOCKED` output (SC-5).
- [ ] C8. The plan-fidelity audit path flags a fixture plan missing the guard as a FAIL finding (SC-6b, R-4).
- [ ] C9. Audit DiMo chain, Z3 check, structural checks, pre-PR gate, and final regression check all pass; the PR is created (stacked, one branch) and the completion summary is reported.

## lifecycle_events

- **2026-09-05T00:43:32Z** — `plan_created` — plan file: `.opencode/.issues/2430/plan.md` — phase count: 5 (+ post-implementation). Appended by writing-plans completion task.
