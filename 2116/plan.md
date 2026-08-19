---
plan_schema_version: 1
issue: 2116
title: "Phase 2: Add decomposition criteria to spec-creation validate"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — Phase 2: Add decomposition criteria to spec-creation validate

Spec: [`.opencode/.issues/2116/spec.md`](https://github.com/michael-conrad/.opencode/tree/issues-data/2116/spec.md)

## Goal / Architecture / Files / Dispatch

- **Goal:** Wire the 6 spec-level decomposition criteria (atomicity, single deliverable, binary verifiability, PR-gate viability, ceremony, coverage / covered-by-prior) into the spec-creation validate pipeline so monolithic, ceremonial, and covered-by-prior SCs are rejected at the validate gate instead of passing through to plan creation and implementation. The criteria are added as an inline copy in `spec-creation/tasks/validate.md`, with the new Ceremony and Coverage criteria mirrored into the master reference in lockstep, plus four behavioral tests (monolithic rejection, atomic acceptance, ceremony rejection, covered-by-prior rejection) following the Two-SC pattern.
- **Architecture:** Add a new 'Decomposition Criteria' section to `spec-creation/tasks/validate.md` after existing validation checks. Each of the 6 criteria is an imperative binary decision tree with explicit PASS/FAIL branches. A skip-guard short-circuits evaluation when the spec has exactly 1 SC AND 1 affected file. The inline copy includes a cross-reference comment to the authoritative master reference. SC-11 and SC-12 (Ceremony and Coverage) additionally mirror their criteria into `audit/reference/decomposition-criteria.md` in lockstep per the maintainer note.
- **Files:**
  - `.opencode/skills/spec-creation/tasks/validate.md` — edit (SC-1..SC-8, SC-11, SC-12)
  - `.opencode/audit/reference/decomposition-criteria.md` — edit (lockstep Ceremony and Coverage results for SC-11, SC-12)
  - `.opencode/tests-v2/behaviors/` — new behavioral test scripts for SC-9, SC-10, SC-13, SC-14
- **Dispatch:** `test-driven-development` (per-item RED/GREEN/post-regression), `verification-before-completion` (pre-regression-verify, verify, pre-PR gate), `audit` (post-implementation adversarial audit), `finishing-a-development-branch` (structural checks), `git-workflow-pr` (review-prep, create-pr), `completion-core` (exec summary).

## Blast Radius

The primary edit target for all string SCs (SC-1..SC-8, SC-11, SC-12) is `spec-creation/tasks/validate.md`. The behavioral SCs (SC-9, SC-10, SC-13, SC-14) additionally add test scripts under `tests-v2/behaviors/`. SC-11 and SC-12 also edit `audit/reference/decomposition-criteria.md` (add the spec-level Ceremony and Coverage items section, in lockstep per the maintainer note) — the plan-level criteria (acyclic DAG, file collision freedom, explicit dependency declaration) in that file are NOT modified. Out of scope: `audit/tasks/spec-audit-evaluator.md` (#2117) and `writing-plans/tasks/validate.md` (#2115).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | Inline decomposition criteria (validate.md content) | Add the 6-criterion decomposition checklist with binary decision trees, sub-checks, cross-reference comment, skip-guard, and Ceremony/Coverage SCs to `spec-creation/tasks/validate.md`; mirror SCs and Coverage into the master reference | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-11, SC-12 | None | Pre 1-2, P1 1-70 | test-driven-development |
| 2 | Decomposition behavioral enforcement tests | Add four behavioral test scripts (artifact-only generators) under `tests-v2/behaviors/` for monolithic-SC rejection, atomic-SC acceptance, ceremony-SC rejection, and covered-by-prior-SC rejection, each evaluated via clean-room session.yaml inspection | SC-9, SC-10, SC-13, SC-14 | Phase 1 (decomposition check content must exist before its behavior can be tested) | P2 1-28 | test-driven-development |

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. All 14 SCs pass their verification (SC-1..SC-8, SC-11, SC-12 string greps; SC-9, SC-10, SC-13, SC-14 behavioral session.yaml evaluation)
- [ ] C2. `spec-creation/tasks/validate.md` includes the inline 6-criteria decomposition checklist with binary PASS/FAIL decision trees, sub-checks, skip-guard, and cross-reference comment
- [ ] C3. `audit/reference/decomposition-criteria.md` includes the spec-level Ceremony and Coverage / covered-by-prior criteria in lockstep (SC-11, SC-12)
- [ ] C4. Four behavioral test scripts (artifact-only generators) exist under `tests-v2/behaviors/` for monolithic-SC rejection, atomic-SC acceptance, ceremony-SC rejection, and covered-by-prior-SC rejection
- [ ] C5. Phase DAG is acyclic (Phase 1 → Phase 2) with no circular dependencies; each item references exactly one SC
- [ ] C6. Structural checks, verification, audit, cross-validation, and review-prep all PASS

---

# Pre-implementation (once per plan)

- [ ] 1. **Coherence gate** — Confirm the structure artifact (`structure.yaml`) phase decomposition, the spec's Phase Mapping table, and the traceability table all agree on the SC-to-phase assignment: SC-1..SC-8, SC-11, SC-12 in Phase 1 (validate.md content, with SC-11/SC-12 also touching the master reference in lockstep); SC-9, SC-10, SC-13, SC-14 in Phase 2 (behavioral tests); dependency Phase 1 → Phase 2. If any inconsistency is found, report BLOCKED and do not proceed.
  - Phase 1: SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-11, SC-12
  - Phase 2: SC-9, SC-10, SC-13, SC-14
  - Dependency: Phase 2 depends on Phase 1 (the decomposition check must exist in `validate.md` before its rejection/acceptance behavior can be behaviorally tested)
- [ ] 2. **Baseline check** — Verify current repo state: `validate.md` does not yet contain the 6 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`, `### Ceremony`, `### Coverage / Covered-by-Prior`); the master reference `audit/reference/decomposition-criteria.md` exists and currently lacks the spec-level Ceremony and Coverage criteria sections; the working tree and submodule are on `$DEFAULT_BRANCH` at remote-tracking tip with no pending changes. If any precondition fails, report BLOCKED and halt.

---

# Phase 1 — Inline decomposition criteria (validate.md content)

## Phase Metadata

- **Concern:** Add the inline decomposition criteria checklist with binary PASS/FAIL decision trees, trigger-word/disjunctive/vague-term sub-checks, meta RED/GREEN reference, cross-reference comment, and skip-guard to `spec-creation/tasks/validate.md`; add the Ceremony and Coverage / covered-by-prior criteria (computed as set-entailment over prior SCs only) to both `validate.md` and the master reference file in lockstep.
- **Files:** `.opencode/skills/spec-creation/tasks/validate.md`, `.opencode/audit/reference/decomposition-criteria.md` (SC-11, SC-12 lockstep)
- **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-11, SC-12
- **Dependencies:** None
- **Entry condition:** Coherence gate and baseline check passed.
- **Exit condition:** All 10 string SCs pass their grep verification; `validate.md` contains the complete inline decomposition criteria checklist and the master reference mirrors the Ceremony and Coverage criteria.

**Cost frame:** Verifying the validate.md inline checklist costs one grep per SC. Skipping a verification means a monolithic, ceremonial, or duplicate SC passes validate and ships to plan creation, where decomposition costs exponentially more to unwind. Correctness is the only metric.

## Code Path Coverage

- `.opencode/skills/spec-creation/tasks/validate.md` — Step 3 structural validation; the new 'Decomposition Criteria' section is added after existing checks (Step 3.6 Artifact cross-reference check), operating as a distinct checklist alongside the retained Step 3.3 Compound-SC detection.
- `.opencode/audit/reference/decomposition-criteria.md` — the master reference; add the spec-level Ceremony and Coverage / covered-by-prior criteria section per the maintainer note. The plan-level criteria section (Acyclic DAG, File Collision Freedom, Explicit Dependency Declaration) is NOT modified.

## Cross-Cutting SCs

- SC-11 and SC-12 (Ceremony and Coverage criteria) touch BOTH `validate.md` and the master reference file `audit/reference/decomposition-criteria.md` — a shared-file dependency within the phase, not a cross-phase concern. Each is a single concern. No SC spans a phase boundary.

## Interface Boundaries

- `spec-creation/tasks/validate.md` remains a self-contained task card for clean-room dispatch; the change is additive (new Decomposition Criteria section). Existing Step 3.3 Compound-SC detection is retained as a distinct check. No interface signature changes.
- The inline copy mirrors the criteria CONTENT of the master reference, not its numbered heading format — the inline copy uses unnumbered headings per SC-1. The cross-reference comment governs drift. The master reference file is a pointer, not a load dependency.

## State Transitions

- Each SC transitions `validate.md` from lacking a specific decomposition element to including it: checklist headings (SC-1), binary decision-tree format (SC-2), Atomicity trigger-word sub-check (SC-3), Binary Verifiability disjunctive-pattern sub-check (SC-4), Binary Verifiability vague-term sub-check (SC-5), PR-Gate Viability meta RED/GREEN reference (SC-6), cross-reference comment (SC-7), skip-condition guard (SC-8). SC-11 and SC-12 additionally transition the master reference to include the Ceremony and Coverage criteria sections in lockstep. All transitions are single-file edits (plus lockstep mirror for SC-11/SC-12).

## Step-by-step

### Item 1 (SC-1) — Inline decomposition criteria checklist

- [ ] 1. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")` to establish existing behavior. Report result. `(**sub-agent**)`
- [ ] 2. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")` to verify pre-regression results. Report verdict. `(**sub-agent**)`
- [ ] 3. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for each of the 6 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`, `### Ceremony`, `### Coverage / Covered-by-Prior`) in `validate.md`. Confirm all 6 FAIL (headings absent). Report RED result. `(**sub-agent**)`
- [ ] 4. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the inline decomposition criteria checklist with the 6 criterion headings to `validate.md`, using unnumbered headings per the spec. `(**sub-agent**)`
- [ ] 5. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression patterns after GREEN. Report result. `(**sub-agent**)`
- [ ] 6. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for each of the 6 exact criterion headings in `validate.md` — all 6 must match for SC-1 to PASS. Report verdict. `(**sub-agent**)`
- [ ] 7. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 2 (SC-2) — Imperative binary decision-tree format

- [ ] 8. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 9. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 10. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `PASS —` and `FAIL —` branch tokens in the 6 decision-tree blocks. Confirm the branch-token check FAILs (no decision trees with PASS/FAIL branches present). Report RED result. `(**sub-agent**)`
- [ ] 11. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Express each of the 6 criteria as an imperative binary decision tree with explicit PASS/FAIL branches (not prose guidance). `(**sub-agent**)`
- [ ] 12. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 13. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the branch tokens `PASS —` and `FAIL —` in `validate.md` — each of the 6 decision-tree blocks must contain at least one `PASS —` and one `FAIL —` line for SC-2 to pass. Report verdict. `(**sub-agent**)`
- [ ] 14. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 3 (SC-3) — Atomicity trigger-word sub-check

- [ ] 15. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 16. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 17. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `and`, `or`, and `comma-separated` within the Atomicity decision-tree block. Confirm the trigger-word sub-check FAILs (strings absent). Report RED result. `(**sub-agent**)`
- [ ] 18. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the trigger-word sub-check to the Atomicity decision tree, flagging `and`, `or`, and comma-separated lists as compound structure (FAIL). `(**sub-agent**)`
- [ ] 19. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 20. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `and`, `or`, and `comma-separated` within the Atomicity decision-tree block in `validate.md` — all 3 must match for SC-3 to pass. Report verdict. `(**sub-agent**)`
- [ ] 21. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 4 (SC-4) — Binary verifiability disjunctive-pattern sub-check

- [ ] 22. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 23. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 24. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block. Confirm the disjunctive-pattern sub-check FAILs (strings absent). Report RED result. `(**sub-agent**)`
- [ ] 25. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the disjunctive-pattern sub-check to the Binary Verifiability decision tree, flagging `either/or`, `alternatively`, and `one of` as FAIL. `(**sub-agent**)`
- [ ] 26. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 27. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block in `validate.md` — all 3 must match for SC-4 to pass. Report verdict. `(**sub-agent**)`
- [ ] 28. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 5 (SC-5) — Binary verifiability vague-term sub-check

- [ ] 29. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 30. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 31. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block. Confirm the vague-term sub-check FAILs (strings absent). Report RED result. `(**sub-agent**)`
- [ ] 32. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the vague-term sub-check to the Binary Verifiability decision tree, flagging `should`, `could`, `ideally`, and `as appropriate` as FAIL. `(**sub-agent**)`
- [ ] 33. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 34. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block in `validate.md` — all 4 must match for SC-5 to pass. Report verdict. `(**sub-agent**)`
- [ ] 35. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 6 (SC-6) — PR-gate viability meta RED/GREEN reference

- [ ] 36. **Pre-regression** — Run `task(..., phase: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 37. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 38. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `RED` and `GREEN` within the PR-Gate Viability decision-tree block. Confirm the meta RED/GREEN reference FAILs (strings absent). Report RED result. `(**sub-agent**)`
- [ ] 39. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the meta RED/GREEN principle reference to the PR-Gate Viability decision tree. `(**sub-agent**)`
- [ ] 40. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 41. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `RED` and `GREEN` within the PR-Gate Viability decision-tree block in `validate.md` — both must match for SC-6 to pass. Report verdict. `(**sub-agent**)`
- [ ] 42. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 7 (SC-7) — Cross-reference comment

- [ ] 43. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 44. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 45. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `See audit/reference/decomposition-criteria.md for master definition` in `validate.md`. Confirm the cross-reference comment FAILs (string absent). Report RED result. `(**sub-agent**)`
- [ ] 46. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the cross-reference comment `See audit/reference/decomposition-criteria.md for master definition` to the inline copy. `(**sub-agent**)`
- [ ] 47. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 48. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact string `See audit/reference/decomposition-criteria.md for master definition` in `validate.md` — must match for SC-7 to pass. Report verdict. `(**sub-agent**)`
- [ ] 49. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 8 (SC-8) — Skip condition for single-SC/single-file specs

- [ ] 50. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 51. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 52. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `1 SC` and `1 affected file` within the skip-condition guard. Confirm the skip-guard FAILs (strings absent). Report RED result. `(**sub-agent**)`
- [ ] 53. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the skip-condition guard that short-circuits the decomposition check when the spec has exactly 1 SC AND 1 affected file. `(**sub-agent**)`
- [ ] 54. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 55. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `1 SC` and `1 affected file` within the skip-condition guard in `validate.md` — both must match for SC-8 to pass. Report verdict. `(**sub-agent**)`
- [ ] 56. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 9 (SC-11) — Ceremony criterion

- [ ] 57. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 58. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 59. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for the `### Ceremony` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Ceremony block in `validate.md`. Confirm the criterion FAILs (elements absent). Report RED result. `(**sub-agent**)`
- [ ] 60. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the Ceremony criterion to the Decomposition Criteria section in `validate.md`, expressed as an imperative PASS/FAIL binary decision tree, computed as set-entailment over prior SCs only. Mirror the spec-level Ceremony criterion into `audit/reference/decomposition-criteria.md` in lockstep per the maintainer note. `(**sub-agent**)`
- [ ] 61. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 62. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the `### Ceremony` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Ceremony block in `validate.md` — all must match for SC-11 to pass. `(**sub-agent**)`
- [ ] 63. **Commit** — Commit the test and change (both files) together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 10 (SC-12) — Coverage / covered-by-prior criterion

- [ ] 64. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 65. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 66. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for the `### Coverage / Covered-by-Prior` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Coverage block in `validate.md`. Confirm the criterion FAILs (elements absent). Report RED result. `(**sub-agent**)`
- [ ] 67. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the Coverage / covered-by-prior criterion to the Decomposition Criteria section in `validate.md`, expressed as an imperative binary decision tree with explicit PASS/FAIL branches, computed as set-entailment over prior SCs only. Mirror the spec-level Coverage criterion into `audit/reference/decomposition-criteria.md` in lockstep per the maintainer note. `(**sub-agent**)`
- [ ] 68. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 69. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the `### Coverage / Covered-by-Prior` heading, `PASS —`/`FAIL —` branch tokens, and `prior SCs` within the Coverage block in `validate.md` — all must match for SC-12 to pass. `(**sub-agent**)`
- [ ] 70. **Commit** — Commit the test and change (both files) together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

## Phase Completion Block

- [ ] 71. Verify all 10 string SCs (SC-1..SC-8, SC-11, SC-12) pass their grep verification against `validate.md` (and the master reference mirror for SC-11/SC-12). Report `[SC-N] [PASS|FAIL]` per SC. If any FAIL, remediate before proceeding to Phase 2.

## Concern Transition

Phase 1 completes the `validate.md` decomposition criteria content (plus the lockstep mirror in the master reference). Phase 2 builds and runs the behavioral test scripts that verify the monolithic-SC rejection, atomic-SC acceptance, ceremony-SC rejection, and covered-by-prior-SC rejection behavior of this content.

---

# Phase 2 — Behavioral enforcement tests

## Phase Metadata

- **Concern:** Add four behavioral test scripts (artifact-only generators) under `tests-v2/behaviors/` following the Two-SC pattern. Each script submits a spec with a specific decomposition defect (monolithic-AND, atomic, ceremony, covered-by-prior) and MORE than 1 affected file (so the SC-8 skip-guard does not fire) via `with-test-home`, generating `session.yaml` artifacts; clean-room subagents evaluate `session.yaml` for PASS/FAIL evidence.
- **Files:** `.opencode/tests-v2/behaviors/` (new scripts) and any required fixtures under `tests-v2/behaviors/fixtures/issues/`
- **SCs:** SC-9, SC-10, SC-13, SC-14
- **Dependencies:** Phase 1 (the decomposition check must exist in `validate.md` before its rejection/acceptance behavior can be behaviorally tested)
- **Entry condition:** Phase 1 passed (SC-1..SC-8, SC-11, SC-12 committed).
- **Exit condition:** Four behavioral test scripts generate `session.yaml` artifacts via `with-test-home` (exit 0, no in-script assertion), and clean-room subagents evaluate `session.yaml` for PASS/FAIL evidence matching each SC.

**Cost frame:** Running the behavioral tests costs minutes of execution time per SC. Skipping a behavioral test means a monolithic, ceremonial, or covered-by-prior SC passes validation and ships, where the defect costs 1000× more to fix in production; skipping the atomic acceptance test risks false rejection of compliant specs. Correctness is the only metric.

## Code Path Coverage

- `.opencode/tests-v2/behaviors/` — new artifact-only generator scripts following the template and Two-SC pattern from `tests-v2/AGENTS.md` §2/§3/§6a. Scripts run the spec through the validate pipeline via `with-test-home` (bash tool timeout >= 600000), generate `session.yaml` (the SQLite DB export), and exit 0 without in-script assertion.
- `.opencode/tests-v2/behaviors/fixtures/issues/{N}/` — fixture spec files that the behavioral test prompts reference (each fixture uses MORE than 1 affected file so the SC-8 skip-guard does not fire).

## Cross-Cutting SCs

- SC-9, SC-10, SC-13, SC-14 are behavioral and span both the `validate.md` decomposition check (Phase 1 content) and the `tests-v2/behaviors/` test scripts. They depend on Phase 1 output; no other cross-cutting concern.

## Interface Boundaries

- The behavioral test scripts interface with the test harness (`with-test-home`, `behavior_run` from `helpers.sh`). Scripts are artifact-only generators — they must NOT call assertion helpers, MUST NOT evaluate model output, and MUST exit 0 unconditionally. Clean-room subagents perform evaluation from `session.yaml`.
- The behavioral test specs MUST specify MORE than 1 affected file so the SC-8 skip-guard (1 SC AND 1 affected file) does not fire; the skip-guard requires BOTH conditions.

## State Transitions

- SC-9: from "monolithic SC (AND-email) not rejected by decomposition check" to "monolithic SC rejected with atomicity reason `SC contains trigger words indicating multiple concerns`". SC-10: from "atomic SC not accepted by decomposition check" to "atomic SC accepted (PASS) for decomposition criteria". SC-13: from "ceremony SC passes validate" to "ceremony SC rejected with ceremony reason `SC is ceremony`". SC-14: from "covered-by-prior SC passes validate" to "covered-by-prior SC rejected with coverage reason `SC is covered by a prior SC`". Each verified via behavioral test generation + clean-room session.yaml evaluation.

## Step-by-step

### Item 11 (SC-9) — Monolithic-SC behavioral rejection

- [ ] 1. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 2. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 3. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose single SC is `The system validates email format AND sends confirmation email` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated `session.yaml` does NOT show the decomposition check returning FAIL with the atomicity reason — the RED is observed because the check does not yet reject the monolithic SC. Report RED result. `(**sub-agent**)`
- [ ] 4. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check rejects the monolithic SC with the atomicity reason `SC contains trigger words indicating multiple concerns`. Re-run the behavioral test script to generate updated `session.yaml` artifacts (exit 0). `(**sub-agent**)`
- [ ] 5. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 6. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room subagent to read `session.yaml` (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned FAIL with the atomicity reason `SC contains trigger words indicating multiple concerns`. The subagent receives ONLY the artifact directory path, the SC-9 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-9. `(**clean-room**)`
- [ ] 7. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 12 (SC-10) — Atomic-SC behavioral acceptance

- [ ] 8. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 9. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 10. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose single SC is `The system validates email format on registration` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated `session.yaml` does NOT show the decomposition check returning PASS for the decomposition criteria check — the RED is observed because the check does not yet accept the atomic SC. Report RED result. `(**sub-agent**)`
- [ ] 11. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check accepts the atomic SC (PASS for decomposition criteria). Run the behavioral test script again to generate updated `session.yaml` artifacts (exit 0). `(**sub-agent**)`
- [ ] 12. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 13. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room subagent to read `session.yaml` (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned PASS for the decomposition criteria check. The subagent receives ONLY the artifact directory path, the SC-10 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-10. `(**clean-room**)`
- [ ] 14. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 13 (SC-13) — Ceremony-SC behavioral rejection

- [ ] 15. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 16. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 17. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose second SC is ceremony (identical deliverable and verification method to the first SC, no new requirement) and whose affected-files list contains MORE than 1 file (so the skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated `session.yaml` does NOT show the decomposition check returning FAIL with the ceremony reason — the RED is observed because the check does not yet reject the ceremony SC. Report RED result. `(**sub-agent**)`
- [ ] 18. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check rejects the ceremony SC with the ceremony reason `SC is ceremony`. Run the behavioral test script again to generate updated `session.yaml` artifacts (exit 0). `(**sub-agent**)`
- [ ] 19. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 20. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room subagent to read `session.yaml` (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned FAIL with the ceremony reason `SC is ceremony`. The subagent receives ONLY the artifact directory path, the SC-13 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-13. `(**clean-room**)`
- [ ] 21. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

### Item 14 (SC-14) — Covered-by-prior-SC behavioral rejection

- [ ] 22. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Confirm result. `(**sub-agent**)`
- [ ] 23. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict. `(**sub-agent**)`
- [ ] 24. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose second SC is covered by a prior SC (requirement set already entailed) and whose affected-files list contains MORE than 1 file (so the skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated `session.yaml` does NOT show the decomposition check returning FAIL with the coverage reason — the RED is observed because the check does not yet reject the covered-by-prior SC. Report RED result. `(**sub-agent**)`
- [ ] 25. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check rejects the covered-by-prior SC with the coverage reason `SC is covered by a prior SC`. Run the behavioral test script again to generate updated `session.yaml` artifacts (exit 0). `(**sub-agent**)`
- [ ] 26. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result. `(**sub-agent**)`
- [ ] 27. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room subagent to read `session.yaml` (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned FAIL with the reason `SC is covered by a prior SC`. The subagent receives ONLY the artifact directory path, the SC-14 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-14. `(**clean-room**)`
- [ ] 28. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`. `(**inline**)`

## Phase Completion Block

- [ ] 29. Verify all four behavioral SCs (SC-9, SC-10, SC-13, SC-14) pass via clean-room `session.yaml` evaluation. Report `[SC-N] [PASS|FAIL]` per SC. If any FAIL, remediate before proceeding to post-implementation.

## Concern Transition

Phase 2 completes the behavioral verification of the decomposition check. All 14 SCs are implemented. Proceed to post-implementation verification, audit, cross-validation, review-prep, and PR creation.

---

# Post-implementation (once per plan)

- [ ] 1. **Audit** — Run `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by the validator, evaluator, and arbiter in sequence. Adversarial audit of the deliverable. `(**clean-room**)`
- [ ] 2. **Z3 check** — Run `.opencode/tools/solve check --state-path ... --contract-path ...` directly (orchestrator inline). Verify the phase DAG constraint (`behavioral_tests` implies `phase_2`) and the dependency contract hold. `(**inline**)`
- [ ] 3. **Structural checks** — Run `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist (lint, typecheck, etc.). `(**sub-agent**)`
- [ ] 4. **Pre-PR gate** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; block if any FAIL. Confirm all 14 SCs have clean PASS verdicts (no DONE_WITH_CONCERNS — coerced to FAIL). `(**sub-agent**)`
- [ ] 5. **Regression check** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR. `(**sub-agent**)`
- [ ] 6. **Review-prep** — Run `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare the PR review context. `(**sub-agent**)`
- [ ] 7. **Create PR** — Run `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request. `(**sub-agent**)`
- [ ] 8. **Exec summary** — Run `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary. `(**sub-agent**)`

---

## Lifecycle Events

- `plan_created` at `2026-08-19T17:33:59Z` — Plan file: `2116/plan.md`, 2 phases (Phase 1: inline decomposition criteria; Phase 2: behavioral enforcement tests).

---

## Lifecycle Events

- **plan_created** at `2026-08-19T17:33:59Z` — Plan file: `.opencode/.issues/2116/plan.md`, 2 phases.
