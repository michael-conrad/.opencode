# Plan: #1059 — local-issues Multi-Repo Worktree Auto-Discovery

> **Parent spec:** [`.issues/1059/spec.md`](https://github.com/michael-conrad/.opencode/blob/issues-data/1059/spec.md)
> **Planning method:** Formal PDDL planning (`plan` tool) + Z3 validation (`solve` tool)
> **Branch:** `spec/1059-local-issues-plan`
> **Status:** `plan`

---

## Scope

**Single-phase implementation.** This spec has one deliverable (modify `local-issues`), executed through the standard 14-step implementation pipeline. No sub-phases or PR boundaries — one branch, one commit, one PR.

---

## Pipeline Overview (PDDL-Generated)

The `plan` tool generated a 27-step plan from the PDDL domain model (`local-issues-worktree-pipeline-v1`) with 14 serial pipeline steps. Each step in the 14-step implementation pipeline maps to a real dispatch in the pipeline executor:

```
  ┌─────────────────────────────────────────────────────────────────┐
  │  implementation-pipeline (14 serial steps)                      │
  │                                                                  │
  │   1. sc-coherence-gate     → adversarial-audit coherence-extraction │
  │   2. pre-red-baseline      → baseline state capture              │
  │   3. red-phase             → TDD red (behavioral tests)         │
  │   4. red-doublecheck       → verification-before-completion     │
  │   5. green-phase           → TDD green (implementation)         │
  │   6. checkpoint-commit     → git-workflow commit-prep           │
  │   7. structural-checks     → finishing-a-dev-branch checklist   │
  │   8. green-doublecheck     → verification-before-completion     │
  │   9. green-vbc             → verification-before-completion     │
  │  10. adversarial-audit     → dual-auditor verification-audit    │
  │  11. cross-validate        → adversarial-audit cross-validate   │
  │  12. regression-check      → TDD patterns (regression)          │
  │  13. review-prep           → git-workflow review-prep           │
  │  14. exec-summary          → completion-core completion         │
  └─────────────────────────────────────────────────────────────────┘
```

### Plan Sequence (Tamer Engine — SOLVED_SATISFICING)

```
Step  Action
────  ─────────────────────────────────────
  1.   execute(sc-coherence-gate)
  2.   unlock-pre-red-baseline()
  3.   execute(pre-red-baseline)
  4.   unlock-red-phase()
  5.   execute(red-phase)
  6.   unlock-red-doublecheck()
  7.   execute(red-doublecheck)
  8.   unlock-green-phase()
  9.   execute(green-phase)
 10.   unlock-checkpoint-commit()
 11.   execute(checkpoint-commit)
 12.   unlock-structural-checks()
 13.   execute(structural-checks)
 14.   unlock-green-doublecheck()
 15.   execute(green-doublecheck)
 16.   unlock-green-vbc()
 17.   execute(green-vbc)
 18.   unlock-adversarial-audit()
 19.   execute(adversarial-audit)
 20.   unlock-cross-validate()
 21.   execute(cross-validate)
 22.   unlock-regression-check()
 23.   execute(regression-check)
 24.   unlock-review-prep()
 25.   execute(review-prep)
 26.   unlock-exec-summary()
 27.   execute(exec-summary)
```

**Plan length:** 27 steps (14 execute + 13 unlock actions)
**Engine:** Tamer
**Status:** SOLVED_SATISFICING

---

## SC-to-Step Mapping

Each SC is verified at a specific pipeline stage. Some are verified in RED (test fails before change) and again in GREEN (test passes after change).

| SC | Criterion | RED Phase Test | GREEN Phase Test | Primary Verification Step |
|----|-----------|----------------|------------------|---------------------------|
| SC-0 | Behavioral enforcement tests written; confirm RED state | red-phase (SC-0 itself) | green-doublecheck | red-phase → red-doublecheck |
| SC-1 | `.issues/` worktree created in main + all child repos | red-phase: behavioral test FAILS | green-phase: behavioral test PASS | green-doublecheck |
| SC-2 | `WORKTREE_BRANCH = "issues-data"` | red-phase: grep FAILS | green-phase: grep PASS | green-doublecheck |
| SC-3 | No regression in single-repo commands | red-phase: cmd suite FAILS | green-phase: cmd suite PASS | regression-check |
| SC-4 | Dual-branch detection without auto-merge | red-phase: behavioral FAILS | green-phase: behavioral PASS | green-doublecheck |
| SC-5 | Sub-repo discovery | red-phase: behavioral FAILS | green-phase: behavioral PASS | green-doublecheck |
| SC-6 | No nested recursion | red-phase: behavioral FAILS | green-phase: behavioral PASS | green-doublecheck |
| SC-7 | Orphan branch pushed to remote | red-phase: behavioral FAILS | green-phase: behavioral PASS | green-doublecheck |
| SC-8 | Existing worktree is no-op | red-phase: behavioral FAILS | green-phase: behavioral PASS | green-doublecheck |

---

## Dispatched Work Items

| Pipeline Step | Dispatches To | What Gets Produced |
|---------------|---------------|--------------------|
| sc-coherence-gate | `adversarial-audit --task coherence-extraction` | Coherence check: spec vs codebase |
| pre-red-baseline | `implementation-pipeline --task pre-red-baseline` | Baseline state file; `solve state init` |
| red-phase | `test-driven-development --task red` | Behavioral tests in `.opencode/tests/behaviors/` — RED state confirmed (all fail) |
| red-doublecheck | `verification-before-completion --task verify` | RED-side evidence: each behavioral test confirmed failing |
| green-phase | `test-driven-development --task green` | Implementation in `.opencode/tools/local-issues`; behavioral tests now PASS |
| checkpoint-commit | `git-workflow --task commit-prep` | WIP commit of GREEN artifacts |
| structural-checks | `finishing-a-development-branch --task checklist` | Lint, format, typecheck — pass/fail |
| green-doublecheck | `verification-before-completion --task verify` | GREEN-side evidence: each SC verified against implementation |
| green-vbc | `verification-before-completion --task completion` | VbC completion artifact |
| adversarial-audit | `adversarial-audit --task verification-audit` | Dual-auditor YAML verdicts (2 auditors) |
| cross-validate | `adversarial-audit --task cross-validate` | Cross-validate findings YAML |
| regression-check | `test-driven-development --task patterns` | Regression test results (SC-3 verified here) |
| review-prep | `git-workflow --task review-prep` | PR body, compare URL, review checklist |
| exec-summary | `completion-core --task completion` | Push status, issue comment, byline |

---

## Z3 Validation

**Contract:** `.opencode/.issues/1059/spec-artifacts/contract.yaml`
**Initial state:** `.opencode/.issues/1059/spec-artifacts/state.yaml`

| State | Result | Meaning |
|-------|--------|---------|
| Initial (all 14 steps = false) | SAT | Valid starting point |
| Terminal (all 14 steps = true) | SAT (+ postconditions) | Valid completion: postconditions satisfied |
| Green-phase before red-phase | UNSAT | Invariant enforced — RED before GREEN |
| Exec-summary before review-prep | UNSAT | Invariant enforced — serial chain |
| Mid-pipeline (6/14 steps done) | SAT | Partial progress valid |

All invalid transitions properly blocked by Z3. The pipeline is monotonic — no step can be done without its predecessor.

---

## Artifacts

```
.opencode/.issues/1059/
  spec-artifacts/
    domain.yaml     — PDDL domain: 14-step pipeline, 2 fluents, 14 actions
    contract.yaml   — Z3 contract: 14 boolean variables, serial chain constraints
    state.yaml      — Initial state (all false)
```

---

## Dependency

This issue is an infrastructure prerequisite for [issue #1065](https://github.com/michael-conrad/.opencode/issues/1065) (output format + cross-repo operations). Phase 1 of #1065 requires #1059 PR to merge before it can begin.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)