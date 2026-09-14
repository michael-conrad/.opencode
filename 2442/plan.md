---
plan_schema_version: "1.0"
issue: 2442
title: "Correct .issues/ file-access rule in .opencode/AGENTS.md (git -C for git ops, standard file access otherwise)"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - phase: 1
    skill: test-driven-development
    task: "red/green/verify from test-driven-development; commit via commit-inline (orchestrator, direct)"
  - phase: 2
    skill: test-driven-development
    task: "red/green/verify from test-driven-development (behavioral variant); commit+push before behavioral run"
---

# Implementation Plan — #2442 — Correct .issues/ file-access rule in .opencode/AGENTS.md

**Issue:** `.opencode/.issues/2442/spec.md`

## Goal

Replace the defective blanket prohibition on standard file tools for `.issues/` files in `.opencode/AGENTS.md` with the correct two-part rule — file tools permitted for content access, `git -C <tree>/.issues/` mandatory for git operations — and enforce it with a behavioral scenario.

## Architecture

Two-phase per-SC TDD plan. Phase 1 rewrites the worktree section of `.opencode/AGENTS.md` in four independent RED/GREEN/verify/commit cycles (SC-1..SC-4), each enforced by a grep test against the tracked file. Phase 2 adds one behavioral enforcement scenario under `.opencode/tests-v2/behaviors/` (SC-5), run via `with-test-home opencode run`; phase 2 depends on phase 1's committed outputs.

## Files

- `.opencode/AGENTS.md` — rewrite of section "`.issues/` Is a Worktree — NOT a Regular Directory"
- `.opencode/tests-v2/behaviors/` — one new behavioral scenario script (additive)

## Blast Radius

- `.opencode/AGENTS.md`: LOW — single prose section in one agent-facing file; consumed via the session context instructions array
- `.opencode/tests-v2/behaviors/`: NONE — additive new scenario script
- Unaffected: `guidelines/060-tool-usage.md` (glob LIM notes), root-repo `AGENTS.md` (companion spec), `local` platform skill task cards

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

## Enforcement Gate

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Correct the .issues/ worktree rule in .opencode/AGENTS.md | R-1..R-4 (rule correction + consistency) | SC-1, SC-2, SC-3, SC-4 | — | 1-20 | direct (1-2, 6, 10, 14, 18, 20) + task-card (3-5, 7-9, 11-13, 15-17, 19) |
| 2 | Behavioral enforcement scenario | R-5 (behavioral enforcement) | SC-5 | Phase 1 | 21-29 | direct (21-22, 25-26) + task-card (23-24, 27-29) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1: SC-1 verified — corrected rule text present in `.opencode/AGENTS.md`
- [ ] C2: SC-2 verified — prohibition text absent
- [ ] C3: SC-3 verified — `git -C` mandate and `git add .issues/` FORBIDDEN rule both retained
- [ ] C4: SC-4 verified — no residual contradicting file-access-prohibition phrases
- [ ] C5: SC-5 verified — behavioral scenario passes via `opencode run` through `with-test-home`
- [ ] C6: All SC evidence artifacts recorded under `.opencode/.issues/2442/artifacts/`

# Phase 1 — Correct the .issues/ worktree rule in .opencode/AGENTS.md

- **Concern:** R-1..R-4 — correct two-part rule stated, defective prohibition removed, preserved rules retained, file internally consistent
- **Files:** `.opencode/AGENTS.md` (section "`.issues/` Is a Worktree — NOT a Regular Directory")
- **SCs:** SC-1, SC-2, SC-3, SC-4 (all structural — grep of tracked file)
- **Dependencies:** none (first phase)
- **Entry condition:** clean feature branch in the `.opencode` submodule; working tree clean
- **Exit condition:** all four grep tests PASS and each SC's change is committed

## Code Path Coverage

- Single code path: the agent-facing prose section loaded via the session context instructions array; no runtime code affected

## Cross-Cutting SCs

- SC-4 (consistency sweep) touches the whole file, not only the rewritten section

## Interface Boundaries

- Prose contract with agents only; no API, schema, or CLI surface changes. The `local-issues` mutation path and `git -C` git-op path remain the documented interfaces.

## State Transitions

- None (documentation-only change)

## Step-by-Step

### Pre-implementation (once per plan)

- [ ] 1. Coherence gate — verify spec-to-plan fidelity (**)direct**)
  - Confirm every SC (SC-1..SC-5) appears in exactly one phase item below and the phase DAG matches the structure artifact (1 → 2)
- [ ] 2. Baseline check (**)direct**)
  - Verify the `.opencode` submodule is on `$DEFAULT_BRANCH`, at remote tracking tip, with zero pending changes; run the four SC-1..SC-4 greps against the current file to record the pre-change baseline

### Item 1 — SC-1: corrected rule text present

- [ ] 3. RED — write a failing grep test asserting the corrected two-part rule text (standard file tools permitted for `.issues/` files) is present in `.opencode/AGENTS.md` (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs because the section currently prohibits file tools
- [ ] 4. GREEN — edit the worktree section to state the correct rule: `.issues/` is a git worktree; any git operations target it via `git -C <tree>/.issues/`; standard file access tools (`read`/`write`/`edit`/`glob`/`grep`) are permitted for `.issues/` files (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Preserve the section header and the ✅/🚫 table structure
- [ ] 5. Verify SC-1 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep of tracked file confirms corrected rule text present
- [ ] 6. Commit the test and change together (**)direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` — no co-author trailers

### Item 2 — SC-2: prohibition text absent

- [ ] 7. RED — write a failing grep test asserting the "silently targets the wrong repository and corrupts git state" prohibition on `read`/`write`/`edit`/`glob`/`grep` is ABSENT (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs because the prohibition sentence is still present
- [ ] 8. GREEN — remove the prohibition sentence and its FORBIDDEN table rows covering file-tool usage, keeping git-op rows (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Minimum change only — no other section edits
- [ ] 9. Verify SC-2 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep confirms prohibition text absent
- [ ] 10. Commit the test and change together (**)direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Item 3 — SC-3: git-op rules retained

- [ ] 11. RED — write a failing grep test asserting both preserved rules are present: the `git -C <tree>/.issues/` mandate for git operations and the parent-repo `git add .issues/` FORBIDDEN rule (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs if either rule text was dropped during the rewrite
- [ ] 12. GREEN — restore/confirm both retained rules within the rewritten section (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Only if the SC-3 test FAILs; no change if both texts already present
- [ ] 13. Verify SC-3 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep confirms both retained rules present
- [ ] 14. Commit the test and change together (**)direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Item 4 — SC-4: no residual contradictions

- [ ] 15. RED — write a failing grep test scanning the whole file for contradicting file-access-prohibition phrases ("NEVER read/write `.issues/`", "MUST NOT read/write `.issues/` files") outside the preserved git-op rule (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs if any residual contradicting sentence remains elsewhere in the file
- [ ] 16. GREEN — sweep any remaining contradicted sentences found by the test (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Only if the SC-4 test FAILs; no change if the file is already consistent
- [ ] 17. Verify SC-4 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep returns no file-access-prohibition hits outside the preserved git-op rule
- [ ] 18. Commit the test and change together (**)direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Phase completion

- [ ] 19. Run VbC verification assertions for phase 1 (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - All four grep tests PASS against the tracked file; evidence artifacts recorded
- [ ] 20. Record concern transition to phase 2 (**)direct**)
  - Phase 2's behavioral scenario verifies the corrected rule produced here

**Cost frame:** Verifying each rule correction costs one grep search (seconds). Skipping means the defective prohibition keeps forcing every `.issues/` read through the CLI for every future session — a wrong-rule regression propagating across the whole agent deck, not a one-time cost.

# Phase 2 — Behavioral enforcement scenario

- **Concern:** R-5 — behavioral enforcement proving agents read `.issues/` files with standard tools and route `.issues/` git ops through `git -C .issues/`
- **Files:** `.opencode/tests-v2/behaviors/` (one new scenario script)
- **SCs:** SC-5 (behavioral — `opencode run` via `with-test-home`)
- **Dependencies:** Phase 1 (SC-1..SC-4 committed — the behavioral run tests the corrected rule)
- **Entry condition:** phase 1 complete; all phase-1 commits pushed and fresh-fetched into a remote ref (harness pre-flight gate requires this)
- **Exit condition:** behavioral scenario FAILs against pre-edit state (RED), then passes against corrected state (GREEN), and is committed

## Code Path Coverage

- Behavioral harness path: `bash .opencode/tests-v2/with-test-home opencode run '<message>'` → session stderr → scenario assertions

## Cross-Cutting SCs

- None (single SC)

## Interface Boundaries

- The scenario script is a standalone executable under `.opencode/tests-v2/behaviors/`, discoverable by `test-enforcement.sh --list`; no harness core modifications

## State Transitions

- Test-run lock state in `tmp/.behavior-run.lock` — pre-clean stale locks before each run

## Step-by-Step

### Item 5 — SC-5: behavioral scenario

- [ ] 21. RED — write the behavioral scenario script asserting the corrected rule; run it against the PRE-EDIT committed state (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - RED condition: the run's stderr shows the old prohibition behavior (agent detours around `.issues/` file reads) or the scenario's structural precondition check fails — either way the scenario verdict is FAIL before the phase-1-corrected text is the effective rule
  - Note: the harness tests the effective commit as it exists on the remote — commit and push are prerequisites for this run
- [ ] 22. Verify RED outcome recorded (**)direct**)
  - Scenario FAIL verdict and stderr evidence captured under `tmp/2442/artifacts/` with the pre-edit effective commit recorded
- [ ] 23. GREEN — ensure the scenario passes against the corrected state: run the scenario via `bash .opencode/tests-v2/behaviors/<scenario>.sh` with bash timeout ≥600s (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - GREEN condition: stderr shows an agent read of an `.issues/...` file via a standard file tool and no parent-repo `git add .issues/`; `.issues/` git ops routed via `git -C .issues/`
  - Pre-clean: `rm -f tmp/.behavior-run.lock` before each run
- [ ] 24. Verify SC-5 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Behavioral evidence artifact records the `opencode run` execution, stderr patterns asserted, and PASS verdict
- [ ] 25. Commit the scenario script and change together (**)direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` in the `.opencode` submodule
- [ ] 26. Push the commit and verify remote containment (**)direct**)
  - Push the effective commit to its remote branch; fresh `git fetch` and verify the commit is contained in a remote ref (required before any behavioral run)

### Phase completion

- [ ] 27. Run post-regression test patterns for phase 2 (**)task-card**: `task(..., prompt: "execute phase-4 task from test-driven-development")`)
  - Existing behavior scenarios still pass (no harness regressions from the additive script)
- [ ] 28. Run VbC verification assertions for phase 2 (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - SC-5 behavioral evidence artifact present with PASS verdict
- [ ] 29. Record concern transition to post-implementation (**)direct**)
  - All five SCs now have committed evidence; post-implementation gates may proceed

**Cost frame:** Running the behavioral scenario costs minutes of harness execution time. Skipping means the corrected rule ships with no behavioral enforcement — the prohibition pattern silently regresses in a future edit and is discovered only when agents' `.issues/` research reads start failing, days to weeks later.

# Post-Implementation

Steps 30-40 run once, after the last phase.

- [ ] 30. Adversarial audit of the deliverable (**)task-card**: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`)
  - Followed by validator, evaluator, arbiter in sequence
- [ ] 31. Z3 constraint solver verification (**)direct**)
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly
- [ ] 32. Structural checks — finishing checklist (**)task-card**: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`)
  - Lint and format checks applicable to the changed files
- [ ] 33. Pre-PR gate — verify all SC verdicts (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Reads all SC verdicts; BLOCKs if any FAIL — DONE_WITH_CONCERNS is coerced to FAIL
- [ ] 34. Final regression check before PR (**)task-card**: `task(..., prompt: "execute phase-4 task from test-driven-development")`)
- [ ] 35. Prepare PR review context (**)task-card**: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`)
- [ ] 36. Create the pull request (**)task-card**: `task(..., prompt: "execute create task from git-workflow-pr")`)
  - Stacked PR targeting the trunk; one branch, one PR
- [ ] 37. Completion executive summary (**)task-card**: `task(..., prompt: "execute completion task from completion-core")`)
- [ ] 38. Emit lifecycle event `plan_created` (**)direct**)
  - One event with `plan_file` = `.opencode/.issues/2442/plan.md` and `phase_count` = 2

**Cost frame:** Post-implementation gates cost minutes of harness and audit execution. Skipping means a wrong-rule regression reaches the trunk with no adversarial check — every future session inherits the defect, multiplied across the agent deck.
