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

- **Goal:** Wire the 4 spec-level decomposition criteria (atomicity, single deliverable, binary verifiability, PR-gate viability) into the spec-creation validate pipeline so monolithic SCs are rejected at the validate gate instead of passing through to plan creation and implementation. The criteria are added as an inline copy in `spec-creation/tasks/validate.md`, plus two behavioral tests (monolithic rejection, atomic acceptance) following the Two-SC pattern.
- **Architecture:** Add a new 'Decomposition Criteria' section to `spec-creation/tasks/validate.md` after existing validation checks. Each criterion is an imperative binary decision tree with explicit PASS/FAIL branches. A skip-guard short-circuits evaluation when the spec has exactly 1 SC AND 1 affected file. The inline copy includes a cross-reference comment to the authoritative master reference.
- **Files:**
  - `.opencode/skills/spec-creation/tasks/validate.md` — edit (SC-1..SC-8)
  - `.opencode/tests-v2/behaviors/` — new behavioral test scripts for SC-9 and SC-10
- **Dispatch:** `test-driven-development` (per-item RED/GREEN), `verification-before-completion` (verify gates), `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `completion-core`.

## Blast Radius

Single-file edit target for all string SCs (SC-1..SC-8) is `validate.md`. The behavioral SCs (SC-9, SC-10) additionally add test scripts under `tests-v2/behaviors/`. The master reference `audit/reference/decomposition-criteria.md` is read-only (cross-reference only, not modified). Out of scope: `audit/tasks/spec-audit-evaluator.md` (#2117), `writing-plans/tasks/validate.md` (#2115), and the master reference file itself.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | validate.md decomposition criteria content | Inline 4-criterion decomposition checklist in `spec-creation/tasks/validate.md` | SC-1..SC-8 | None | Pre 1-2, P1 1-40 | test-driven-development |
| 2 | Behavioral test scripts | Two-SC behavioral tests for monolithic rejection and atomic acceptance | SC-9, SC-10 | Phase 1 (SC-8 output committed) | P2 1-16 | test-driven-development |

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. All 10 SCs pass their verification (SC-1..SC-8 string greps; SC-9, SC-10 behavioral session.yaml evaluation)
- [ ] C2. `spec-creation/tasks/validate.md` includes the inline 4-criterion decomposition checklist with binary PASS/FAIL decision trees, sub-checks, cross-reference comment, and skip-guard
- [ ] C3. Two behavioral test scripts (artifact-only generators) exist under `tests-v2/behaviors/` for monolithic-SC rejection and atomic-SC acceptance
- [ ] C4. Phase DAG is acyclic (Phase 1 → Phase 2) with no circular dependencies
- [ ] C5. Structural checks, verification, audit, cross-validation, and review-prep all PASS

---

# Pre-implementation (once per plan)

- [ ] 1. **Coherence gate** — Confirm the structure artifact (`structure.yaml`) phase decomposition, the spec's Phase Mapping table, and the traceability table all agree: SC-1..SC-8 in Phase 1 (validate.md content), SC-9, SC-10 in Phase 2 (behavioral tests), with Phase 1 → Phase 2 dependency. If any inconsistency is found, report BLOCKED and do not proceed.
  - Phase 1: SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8
  - Phase 2: SC-9, SC-10
  - Dependency: Phase 2 depends on Phase 1 (the decomposition check must exist before its behavioral behavior can be tested)
- [ ] 2. **Baseline check** — Verify current repo state: `validate.md` does not yet contain the 4 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`); the master reference `audit/reference/decomposition-criteria.md` exists; the working tree and submodule are on `$DEFAULT_BRANCH` at remote-tracking tip with no pending changes. If any precondition fails, report BLOCKED and halt.

---

# Phase 1 — validate.md decomposition criteria content

## Phase Metadata

- **Concern:** Add the inline decomposition criteria checklist with binary PASS/FAIL decision trees, trigger-word/disjunctive/vague-term sub-checks, meta RED/GREEN reference, cross-reference comment, and skip-guard to `spec-creation/tasks/validate.md`.
- **Files:** `.opencode/skills/spec-creation/tasks/validate.md`
- **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8
- **Dependencies:** None
- **Entry condition:** Coherence gate and baseline check passed.
- **Exit condition:** All 8 string SCs pass their grep verification; `validate.md` contains the complete inline decomposition criteria checklist.

**Cost frame:** Verifying the validate.md inline checklist costs one grep per SC. Skipping a verification means a monolithic SC passes validate and ships to plan creation, where decomposition costs exponentially more to unwind. Correctness is the only metric.

## Code Path Coverage

- `.opencode/skills/spec-creation/tasks/validate.md` — Step 3 structural validation; the new 'Decomposition Criteria' section is added after existing checks (Step 3.6 Artifact cross-reference check), operating as a distinct checklist alongside the retained Step 3.3 Compound-SC detection.

## Cross-Cutting SCs

- SC-9 and SC-10 (behavioral, Phase 2) depend on the decomposition check content added here; they are the only SCs spanning more than one file location (`validate.md` behavior plus `tests-v2/behaviors/` scripts). No cross-cutting concern among SC-1..SC-8 — each is a single concern within `validate.md`.

## Interface Boundaries

- `spec-creation/tasks/validate.md` remains a self-contained task card for clean-room dispatch; the change is additive (new Decomposition Criteria section). Existing Step 3.3 Compound-SC detection is retained as a distinct check. No interface signature changes.
- The inline copy mirrors the criteria content of `audit/reference/decomposition-criteria.md`, not its numbered heading format — the inline copy uses unnumbered headings per SC-1. The cross-reference comment governs drift.

## State Transitions

- Each SC transitions `validate.md` from lacking a specific decomposition element to including it: checklist headings (SC-1), binary decision-tree format (SC-2), Atomicity trigger-word sub-check (SC-3), Binary Verifiability disjunctive-pattern sub-check (SC-4), Binary Verifiability vague-term sub-check (SC-5), PR-Gate Viability meta RED/GREEN reference (SC-6), cross-reference comment (SC-7), skip-condition guard (SC-8). All transitions are single-file edits to `validate.md`.

## Step-by-step

### Item 1 (SC-1) — Inline decomposition criteria checklist

- [ ] 1. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")` to confirm existing behavior. Report result.
- [ ] 2. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")` to verify pre-regression results. Report verdict.
- [ ] 3. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for each of the 4 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`) in `validate.md`. Confirm all 4 FAIL (headings absent). Report RED result.
- [ ] 4. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the inline decomposition criteria checklist with the 4 criterion headings (`### Atomicity`, `### Single Deliverable`, `### Binary Verifiability`, `### PR-Gate Viability`) to `validate.md`, using unnumbered headings per the spec.
- [ ] 5. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression patterns after GREEN. Report result.
- [ ] 6. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for each of the 4 exact criterion headings in `validate.md` — all 4 must match for SC-1 to PASS.
- [ ] 7. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 2 (SC-2) — Imperative binary decision-tree format

- [ ] 8. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 9. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 10. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `PASS —` and `FAIL —` branch tokens in the 4 decision-tree blocks. Confirm the branch-token check FAILs (no decision trees with PASS/FAIL branches present). Report RED result.
- [ ] 11. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Express each criterion as an imperative binary decision tree with explicit PASS/FAIL branches (not prose guidance).
- [ ] 12. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 13. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the branch tokens `PASS —` and `FAIL —` in `validate.md` — each of the 4 decision-tree blocks must contain at least one `PASS —` and one `FAIL —` line for SC-2 to PASS.
- [ ] 14. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 3 (SC-3) — Atomicity trigger-word sub-check

- [ ] 15. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 16. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 17. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `and`, `or`, and `comma-separated` within the Atomicity decision-tree block. Confirm the trigger-word sub-check FAILs (strings absent). Report RED result.
- [ ] 18. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the trigger-word sub-check to the Atomicity decision tree, flagging `and`, `or`, and comma-separated lists as compound structure (FAIL).
- [ ] 19. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 20. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `and`, `or`, and `comma-separated` within the Atomicity decision-tree block in `validate.md` — all 3 must match for SC-3 to PASS.
- [ ] 21. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 4 (SC-4) — Binary verifiability disjunctive-pattern sub-check

- [ ] 22. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 23. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 24. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block. Confirm the disjunctive-pattern sub-check FAILs (strings absent). Report RED result.
- [ ] 25. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the disjunctive-pattern sub-check to the Binary Verifiability decision tree, flagging `either/or`, `alternatively`, and `one of` as FAIL.
- [ ] 26. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 27. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `either/or`, `alternatively`, and `one of` within the Binary Verifiability decision-tree block in `validate.md` — all 3 must match for SC-4 to PASS.
- [ ] 28. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 5 (SC-5) — Binary verifiability vague-term sub-check

- [ ] 29. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 30. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 31. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block. Confirm the vague-term sub-check FAILs (strings absent). Report RED result.
- [ ] 32. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the vague-term sub-check to the Binary Verifiability decision tree, flagging `should`, `could`, `ideally`, and `as appropriate` as FAIL.
- [ ] 33. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 34. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `should`, `could`, `ideally`, and `as appropriate` within the Binary Verifiability decision-tree block in `validate.md` — all 4 must match for SC-5 to PASS.
- [ ] 35. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 6 (SC-6) — PR-gate viability meta RED/GREEN reference

- [ ] 36. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 37. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 38. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `RED` and `GREEN` within the PR-Gate Viability decision-tree block. Confirm the meta RED/GREEN reference FAILs (strings absent). Report RED result.
- [ ] 39. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the meta RED/GREEN principle reference to the PR-Gate Viability decision tree.
- [ ] 40. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 41. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `RED` and `GREEN` within the PR-Gate Viability decision-tree block in `validate.md` — both must match for SC-6 to PASS.
- [ ] 42. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 7 (SC-7) — Cross-reference comment

- [ ] 43. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 44. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 45. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `See audit/reference/decomposition-criteria.md for master definition` in `validate.md`. Confirm the cross-reference comment FAILs (string absent). Report RED result.
- [ ] 46. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the cross-reference comment `See audit/reference/decomposition-criteria.md for master definition` to the inline copy.
- [ ] 47. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 48. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact string `See audit/reference/decomposition-criteria.md for master definition` in `validate.md` — must match for SC-7 to PASS.
- [ ] 49. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 8 (SC-8) — Skip condition for single-SC/single-file specs

- [ ] 50. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 51. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 52. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Grep for `1 SC` and `1 affected file` within the skip-condition guard. Confirm the skip-guard FAILs (strings absent). Report RED result.
- [ ] 53. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Add the skip-condition guard that short-circuits the decomposition check when the spec has exactly 1 SC AND 1 affected file.
- [ ] 54. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 55. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Grep for the exact strings `1 SC` and `1 affected file` within the skip-condition guard in `validate.md` — both must match for SC-8 to PASS.
- [ ] 56. **Commit** — Commit the test and change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

## Phase Completion Block

- [ ] 57. Verify all 8 string SCs (SC-1..SC-8) pass their grep verification against `validate.md`. Report `[SC-1..SC-8] [PASS|FAIL]` per SC. If any FAIL, remediate before proceeding to Phase 2.

## Concern Transition

Phase 1 completes the `validate.md` decomposition criteria content. Phase 2 builds and runs the behavioral test scripts that verify the monolithic-SC rejection and atomic-SC acceptance behavior of this content.

---

# Phase 2 — Behavioral test scripts

## Phase Metadata

- **Concern:** Add two behavioral test scripts (artifact-only generators) under `tests-v2/behaviors/` following the Two-SC pattern: one submitting a monolithic `AND`-email SC (expects FAIL with the atomicity reason), one submitting a single atomic SC (expects PASS for decomposition criteria). Both test specs use MORE than 1 affected file so the SC-8 skip-guard does not fire.
- **Files:** `.opencode/tests-v2/behaviors/`
- **SCs:** SC-9, SC-10
- **Dependencies:** Phase 1 (the decomposition check must exist in `validate.md` before its behavioral behavior can be tested)
- **Entry condition:** Phase 1 passed (SC-1..SC-8 committed).
- **Exit condition:** Both behavioral test scripts generate session.yaml artifacts via `with-test-home` (exit 0, no in-script assertion), and clean-room sub-agents evaluate session.yaml for FAIL/PASS evidence.

**Cost frame:** Running the behavioral tests costs minutes of execution time. Skipping means a monolithic SC passes validate and ships, where the defect costs 1000× more to fix in production; skipping the atomic acceptance test risks false rejection of compliant specs. Correctness is the only metric.

## Code Path Coverage

- `.opencode/tests-v2/behaviors/` — new artifact-only generator scripts following the template and Two-SC pattern from `tests-v2/AGENTS.md` §2/§3/§6a. Scripts run the spec through the validate pipeline via `with-test-home`, generate session.yaml (the SQLite DB export), and exit 0 without in-script assertion.

## Cross-Cutting SCs

- SC-9 and SC-10 are behavioral and span both the `validate.md` decomposition check (Phase 1 content) and the `tests-v2/behaviors/` test scripts. They depend on Phase 1 output; no other cross-cutting concern.

## Interface Boundaries

- The behavioral test scripts interface with the test harness (`with-test-home`, `behavior_run` from `helpers.sh`). Scripts are artifact-only generators — they must NOT call assertion helpers, must NOT evaluate model output, and must exit 0 unconditionally. Clean-room sub-agents perform evaluation from session.yaml.

## State Transitions

- SC-9: from "monolithic SC (AND-email) not rejected by decomposition check" to "monolithic SC rejected with atomicity reason `SC contains trigger words indicating multiple concerns`". SC-10: from "atomic SC not accepted by decomposition check" to "atomic SC accepted (PASS) for decomposition criteria". Both verified via behavioral test generation + clean-room session.yaml evaluation.

## Step-by-step

### Item 9 (SC-9) — Monolithic-SC behavioral rejection

- [ ] 1. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 2. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 3. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose single SC is `The system validates email format AND sends confirmation email` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated session.yaml does NOT show the decomposition check returning FAIL with the atomicity reason — the RED is observed because the decomposition check does not yet reject the monolithic SC. Report RED result.
- [ ] 4. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check rejects the monolithic SC with the atomicity reason `SC contains trigger words indicating multiple concerns`. Run the behavioral test script again to generate updated session.yaml artifacts (exit 0).
- [ ] 5. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 6. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room sub-agent to read session.yaml (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned FAIL with the atomicity reason `SC contains trigger words indicating multiple concerns`. The sub-agent receives ONLY the artifact directory path, the SC-9 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-9.
- [ ] 7. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

### Item 10 (SC-10) — Atomic-SC behavioral acceptance

- [ ] 8. **Pre-regression** — Run `task(..., prompt: "execute phase-0 task from test-driven-development")`. Report result.
- [ ] 9. **Pre-regression-verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Report verdict.
- [ ] 10. **RED** — Run `task(..., prompt: "execute red task from test-driven-development")`. Create the behavioral test script (artifact-only generator) under `tests-v2/behaviors/` that submits a spec whose single SC is `The system validates email format on registration` and whose affected-files list contains MORE than 1 file (so the SC-8 skip-guard does not fire). Run it via `with-test-home` (bash tool timeout >= 600000). Confirm the generated session.yaml does NOT show the decomposition check returning PASS for the decomposition criteria check — the RED is observed because the check does not yet accept the atomic SC. Report RED result.
- [ ] 11. **GREEN** — Run `task(..., prompt: "execute green task from test-driven-development")`. Ensure the decomposition check accepts the atomic SC (PASS for decomposition criteria). Run the behavioral test script again to generate updated session.yaml artifacts (exit 0).
- [ ] 12. **Post-regression** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Report result.
- [ ] 13. **Verify** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Dispatch a clean-room sub-agent to read session.yaml (the SQLite DB export — PRIMARY evidence per `tests-v2/AGENTS.md` §2/§5a) and evaluate whether the agent's tool calls/decisions show the decomposition check returned PASS for the decomposition criteria check. The sub-agent receives ONLY the artifact directory path, the SC-10 criterion, and `github.owner`/`github.repo` — no orchestrator reasoning or expected outcomes. Return PASS/FAIL for SC-10.
- [ ] 14. **Commit** — Commit the test script and the GREEN change together as one atomic slice: `git add <files> && git commit -m "<message>"`.

## Phase Completion Block

- [ ] 15. Verify both behavioral SCs (SC-9, SC-10) pass via clean-room session.yaml evaluation. Report `[SC-9] [PASS|FAIL]` and `[SC-10] [PASS|FAIL]`. If any FAIL, remediate before proceeding to post-implementation.

## Concern Transition

Phase 2 completes the behavioral verification of the decomposition check. All 10 SCs are implemented. Proceed to post-implementation verification, audit, cross-validation, review-prep, and PR creation.

---

# Post-implementation (once per plan)

- [ ] 1. **Audit** — Run `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by the validator, evaluator, and arbiter in sequence. Adversarial audit of the deliverable.
- [ ] 2. **Z3 check** — Run `.opencode/tools/solve check --state-path ... --contract-path ...` directly (orchestrator inline). Verify the phase DAG constraint (`z3.Implies(behavioral_tests, phase_2)`) and dependency contract hold.
- [ ] 3. **Structural checks** — Run `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist (lint, typecheck, etc.).
- [ ] 4. **Pre-PR gate** — Run `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; block if any FAIL. Confirm all 10 SCs have clean PASS verdicts (no DONE_WITH_CONCERNS — coerced to FAIL).
- [ ] 5. **Regression check** — Run `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] 6. **Review-prep** — Run `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare the PR review context.
- [ ] 7. **Create PR** — Run `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request.
- [ ] 8. **Exec summary** — Run `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary.
