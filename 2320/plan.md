---
plan_schema_version: 1
issue: 2320
title: "Fix submodule pointer guidance — pointer rides alongside real root changes (not dropped)"
dispatch: [test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core]
---

# Implementation Plan — Fix submodule pointer guidance

Issue: [.opencode#2320](https://github.com/michael-conrad/.opencode/issues/2320)

## Goal

Reconcile agent-facing guidance so every location states the same unambiguous rule: the submodule pointer rides ALONGSIDE the next real root-repo change on a feature branch, is never dropped when a submodule PR merges, and is never pushed in a standalone pointer-only commit. All changes are agent-facing documentation text — no code, hooks, or git tooling change.

## Architecture

Single-phase documentation alignment. The root AGENTS.md §Submodule Pointer Updates establishes the pointer-rides-alongside principle; four task files align their wording to it. No inter-phase ordering constraints.

## Files

- `AGENTS.md` — §Submodule Pointer Updates (SC-1)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md` — Step 0.5 (SC-2)
- `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md` (SC-3a)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md` — §Pre-Push Submodule Pointer Verification (SC-3b)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` — Step 1.7 (SC-3c)

## Dispatch

- `test-driven-development` — pre-regression, red, green, post-regression, regression-check
- `verification-before-completion` — pre-regression-verify, verify, pre-pr-gate
- `audit` — verification-audit DiMo chain
- `finishing-a-development-branch` — structural-checks
- `git-workflow-pr` — review-prep, create-pr
- `completion-core` — exec-summary

## Blast Radius

Documentation-only change confined to five agent-facing guidance files. No source code, hooks, or git tooling. The submodule-bump-only PR prohibition and the dirty-pointer-cleanup-exemption are preserved invariants — the fix reconciles wording only, never behavior. Downstream consumers are agents reading these guidance files during branch, commit, PR, and cleanup workflows.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Dispatch |
|-------|------|---------|-----|--------------|----------|
| 1 | Pointer-rides-alongside guidance alignment | Align root AGENTS.md and four task files to the pointer-rides-alongside principle | SC-1, SC-2, SC-3a, SC-3b, SC-3c | None (single phase) | test-driven-development, verification-before-completion, audit, finishing-a-development-branch, git-workflow-pr, completion-core |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. Root AGENTS.md §Submodule Pointer Updates states the pointer rides alongside the next real root change and is not dropped on submodule PR merge (SC-1).
- [ ] C2. enforcement-gate.md Step 0.5 closure message clarifies the merged submodule PR does not resolve the root pointer (SC-2).
- [ ] C3. pre-commit-pointer-check.md uses unambiguous pointer-rides-alongside language (SC-3a).
- [ ] C4. pr-creation.md §Pre-Push uses unambiguous pointer-rides-alongside language (SC-3b).
- [ ] C5. branch-cleanup.md Step 1.7 uses unambiguous pointer-rides-alongside language (SC-3c).
- [ ] C6. All five SCs verified behaviorally via `opencode run` under the with-test-home harness.
- [ ] C7. No code, hooks, or git tooling changes made (R-7).
- [ ] C8. Submodule-bump-only PR prohibition preserved (R-3).
- [ ] C9. Dirty-pointer-cleanup-exemption preserved (R-5).

---

# Phase 1 — Pointer-rides-alongside guidance alignment

## Phase Metadata

- **Concern:** Align root AGENTS.md §Submodule Pointer Updates and four task files to the pointer-rides-alongside principle.
- **Files:** `AGENTS.md`, `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`, `.opencode/skills/git-workflow-branch/tasks/pre-commit-pointer-check.md`, `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`, `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- **SCs:** SC-1, SC-2, SC-3a, SC-3b, SC-3c
- **Dependencies:** None — single phase.
- **Entry condition:** Coherence gate and baseline check passed.
- **Exit condition:** All five SCs verified behaviorally; post-implementation gates passed.

## Code Path Coverage

- `AGENTS.md` §Submodule Pointer Updates — root principle statement.
- `enforcement-gate.md` Step 0.5 — submodule-bump-only branch closure message.
- `pre-commit-pointer-check.md` — pre-commit dirty-pointer handling.
- `pr-creation.md` §Pre-Push — pre-push pointer verification.
- `branch-cleanup.md` Step 1.7 — post-merge dirty-pointer cleanup exemption.

## Cross-Cutting SCs

- SC-1 is the root principle; SC-2, SC-3a, SC-3b, SC-3c align to it. All five share the identical pointer-rides-alongside rule and the preserved invariants (R-3, R-5).

## Interface Boundaries

- No code interfaces. The boundary is agent-facing guidance text consumed by agents during branch, commit, PR, and cleanup workflows. Consistency across all five files prevents divergent agent behavior.

## State Transitions

- Pointer lifecycle: DIRTY → CLEAN when a real root change is committed alongside the pointer. DIRTY persists (uncommitted) when no real root change is pending or during post-merge cleanup (exemption). The pointer is never dropped and never committed standalone.

## Cost Frame

**Cost frame:** Running each behavioral test costs minutes of execution time. Skipping means the ambiguous guidance lets an agent drop the root pointer, shipping a stale pointer that breaks downstream builds — a defect discovered in production at 1000× the fix cost.

## Pre-Implementation Steps

- [ ] 1. **Coherence gate** (**inline**)
  - Verify the spec's SCs are atomic, each maps to exactly one deliverable, and the structure artifact's phase DAG has no circular dependencies.
  - Confirm all five SCs are behavioral evidence type and each maps to exactly one phase item.
  - If any SC is compound or the DAG is circular, return BLOCKED with `COHERENCE_GATE_FAIL`.

- [ ] 2. **Baseline check** (**inline**)
  - Verify the current working tree is clean and the feature branch is at trunk tip before any file modification.
  - Confirm the five target files exist at their documented paths.
  - If the baseline is not clean, return BLOCKED with `BASELINE_CHECK_FAIL`.

## Step-by-Step

### Item 1 (SC-1) — Clarify root AGENTS.md §Submodule Pointer Updates

- [ ] 3. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-regression-*` before running.

- [ ] 4. **Pre-regression-verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the pre-regression results.

- [ ] 5. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a behavioral enforcement test asserting the current agent does NOT clearly state the pointer rides alongside a real root change (ambiguity allows pointer-drop).
  - The test must FAIL because the change does not exist yet.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-red-*` before running.

- [ ] 6. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Revise root AGENTS.md §Submodule Pointer Updates to state the pointer must be committed alongside the next real root-repo change, never dropped.
  - The change must make the RED test PASS with no scope creep.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-green-*` before running.

- [ ] 7. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-post-regression-*` before running.

- [ ] 8. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Run `opencode run` with a sub-agent prompt where a root repo has a dirty pointer and a real root change pending.
  - Assert the agent stages and commits the pointer alongside the root change and does not create a pointer-only commit.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-verify-*` before running.

- [ ] 9. **Commit** (**inline**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly.
  - Commit the AGENTS.md revision and its behavioral test together as one atomic slice.
  - No co-author trailers during implementation commits.

### Item 2 (SC-2) — Reconcile enforcement-gate.md Step 0.5 wording

- [ ] 10. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-regression-*` before running.

- [ ] 11. **Pre-regression-verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the pre-regression results.

- [ ] 12. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a behavioral enforcement test asserting the agent reads "No parent PR needed" as permission to drop the root pointer.
  - The test must FAIL because the change does not exist yet.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-red-*` before running.

- [ ] 13. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Revise enforcement-gate.md Step 0.5 closure message to clarify the merged submodule PR does NOT drop the root pointer; the pointer still rides alongside the next real root change.
  - The change must make the RED test PASS with no scope creep.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-green-*` before running.

- [ ] 14. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-post-regression-*` before running.

- [ ] 15. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Run `opencode run` with a sub-agent prompt describing a submodule-bump-only branch.
  - Assert the agent closes the branch per the gate AND records that the root pointer rides alongside the next real root change (does not claim the pointer was resolved/dropped by the submodule merge).
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-verify-*` before running.

- [ ] 16. **Commit** (**inline**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly.
  - Commit the enforcement-gate.md revision and its behavioral test together as one atomic slice.
  - No co-author trailers during implementation commits.

### Item 3a (SC-3a) — Align pre-commit-pointer-check.md pointer-rides-alongside language

- [ ] 17. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-regression-*` before running.

- [ ] 18. **Pre-regression-verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the pre-regression results.

- [ ] 19. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a behavioral enforcement test asserting the agent reads pre-commit-pointer-check.md and does NOT clearly stage/commit the dirty pointer alongside a real root change.
  - The test must FAIL because the change does not exist yet.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-red-*` before running.

- [ ] 20. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Revise pre-commit-pointer-check.md to state the pointer must be committed alongside a real root change, never dropped and never standalone.
  - The change must make the RED test PASS with no scope creep.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-green-*` before running.

- [ ] 21. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-post-regression-*` before running.

- [ ] 22. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Run `opencode run` with a sub-agent prompt where the agent reads pre-commit-pointer-check.md and a root repo has a dirty pointer plus a real root change.
  - Assert the agent stages and commits the pointer alongside the root change.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-verify-*` before running.

- [ ] 23. **Commit** (**inline**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly.
  - Commit the pre-commit-pointer-check.md revision and its behavioral test together as one atomic slice.
  - No co-author trailers during implementation commits.

### Item 3b (SC-3b) — Align pr-creation.md §Pre-Push pointer-rides-alongside language

- [ ] 24. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-regression-*` before running.

- [ ] 25. **Pre-regression-verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the pre-regression results.

- [ ] 26. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a behavioral enforcement test asserting the agent reads pr-creation.md §Pre-Push and treats the submodule merge as resolving the root pointer.
  - The test must FAIL because the change does not exist yet.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-red-*` before running.

- [ ] 27. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Revise pr-creation.md §Pre-Push to clarify the submodule merge does NOT resolve the pointer; it rides alongside the next real root change.
  - The change must make the RED test PASS with no scope creep.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-green-*` before running.

- [ ] 28. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-post-regression-*` before running.

- [ ] 29. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Run `opencode run` with a sub-agent prompt where the agent reads pr-creation.md §Pre-Push and a root repo has a dirty pointer before pushing.
  - Assert the agent verifies the pointer is committed alongside a real root change and does not treat the submodule merge as resolving it.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-verify-*` before running.

- [ ] 30. **Commit** (**inline**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly.
  - Commit the pr-creation.md §Pre-Push revision and its behavioral test together as one atomic slice.
  - No co-author trailers during implementation commits.

### Item 3c (SC-3c) — Align branch-cleanup.md Step 1.7 pointer-rides-alongside language

- [ ] 31. **Pre-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`.
  - Run regression test patterns before the RED phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-regression-*` before running.

- [ ] 32. **Pre-regression-verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Verify the pre-regression results.

- [ ] 33. **RED** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`.
  - Write a behavioral enforcement test asserting the agent reads branch-cleanup.md Step 1.7 and mishandles a dirty pointer during cleanup.
  - The test must FAIL because the change does not exist yet.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-red-*` before running.

- [ ] 34. **GREEN** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`.
  - Revise branch-cleanup.md Step 1.7 to state a dirty pointer is expected, left uncommitted (cleanup exemption), and rides alongside the next real root change.
  - The change must make the RED test PASS with no scope creep.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-green-*` before running.

- [ ] 35. **Post-regression** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Run regression test patterns after the GREEN phase.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-post-regression-*` before running.

- [ ] 36. **Verify** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Run `opencode run` with a sub-agent prompt where the agent reads branch-cleanup.md Step 1.7 and observes a dirty submodule pointer during cleanup.
  - Assert the agent leaves the pointer uncommitted and records that it rides alongside the next real root change.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-verify-*` before running.

- [ ] 37. **Commit** (**inline**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` directly.
  - Commit the branch-cleanup.md Step 1.7 revision and its behavioral test together as one atomic slice.
  - No co-author trailers during implementation commits.

## Post-Implementation Steps

- [ ] 38. **Audit** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`.
  - Follow with validator, evaluator, arbiter in sequence.
  - Adversarial audit of the deliverable.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-audit-*` before running.

- [ ] 39. **Z3-check** (**inline**)
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly.
  - Run Z3 constraint solver verification.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-z3-check-*` before running.

- [ ] 40. **Structural-checks** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`.
  - Run finishing checklist (lint, typecheck, etc.).
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-structural-checks-*` before running.

- [ ] 41. **Pre-pr-gate** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`.
  - Read all SC verdicts; BLOCK if any FAIL.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-pre-pr-gate-*` before running.

- [ ] 42. **Regression-check** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`.
  - Final regression check before PR.
  - Clean `{project_root}/tmp/2320/artifacts/pipeline-regression-check-*` before running.

- [ ] 43. **Review-prep** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`.
  - Prepare PR review context.

- [ ] 44. **Create-pr** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`.
  - Create the pull request.

- [ ] 45. **Exec-summary** (**sub-agent**)
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`.
  - Generate completion executive summary.

## Phase Completion Block

- [ ] All five SCs (SC-1, SC-2, SC-3a, SC-3b, SC-3c) verified behaviorally with clean PASS.
- [ ] No code, hooks, or git tooling changes made.
- [ ] Submodule-bump-only PR prohibition preserved.
- [ ] Dirty-pointer-cleanup-exemption preserved.
- [ ] Post-implementation gates (audit, z3-check, structural-checks, pre-pr-gate, regression-check) passed.

## Concern Transition

Single phase — no transition. The plan completes after the post-implementation steps and the phase completion block.
