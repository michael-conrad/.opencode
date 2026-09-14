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
| 1 | Correct the .issues/ worktree rule in .opencode/AGENTS.md | R-1..R-4 (rule correction + consistency) | SC-1, SC-2, SC-3, SC-4 | — | 1-20 | direct (1-20) |
| 2 | Behavioral enforcement scenario | R-5 (behavioral enforcement) | SC-5 | Phase 1 | 21-30 | direct (21-26) + task-card (27-30) |

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

- [ ] 1. Coherence gate — verify spec-to-plan fidelity (**direct**)
  - Confirm every SC (SC-1..SC-5) appears in exactly one phase item below and the phase DAG matches the structure artifact (1 → 2)
- [ ] 2. Baseline check (**direct**)
  - Verify the `.opencode` submodule is on `$DEFAULT_BRANCH`, at remote tracking tip, with zero pending changes; run the four SC-1..SC-4 greps against the current file to record the pre-change baseline

### Item 1 — SC-1: corrected rule text present

- [ ] 3. RED — write a failing grep test asserting the corrected two-part rule text (standard file tools permitted for `.issues/` files) is present in `.opencode/AGENTS.md` (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs because the section currently prohibits file tools
- [ ] 4. GREEN — edit the worktree section to state the correct rule: `.issues/` is a git worktree; any git operations target it via `git -C <tree>/.issues/`; standard file access tools (`read`/`write`/`edit`/`glob`/`grep`) are permitted for `.issues/` files (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Preserve the section header and the ✅/🚫 table structure
- [ ] 5. Verify SC-1 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep of tracked file confirms corrected rule text present
- [ ] 6. Commit the test and change together (**direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"` — no co-author trailers

### Item 2 — SC-2: prohibition text absent

- [ ] 7. RED — write a failing grep test asserting the "silently targets the wrong repository and corrupts git state" prohibition on `read`/`write`/`edit`/`glob`/`grep` is ABSENT (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs because the prohibition sentence is still present
- [ ] 8. GREEN — remove the prohibition sentence and its FORBIDDEN table rows covering file-tool usage, keeping git-op rows (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Minimum change only — no other section edits
- [ ] 9. Verify SC-2 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep confirms prohibition text absent
- [ ] 10. Commit the test and change together (**direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Item 3 — SC-3: git-op rules retained

- [ ] 11. RED — write a failing grep test asserting both preserved rules are present: the `git -C <tree>/.issues/` mandate for git operations and the parent-repo `git add .issues/` FORBIDDEN rule (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs if either rule text was dropped during the rewrite
- [ ] 12. GREEN — restore/confirm both retained rules within the rewritten section (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Only if the SC-3 test FAILs; no change if both texts already present
- [ ] 13. Verify SC-3 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep confirms both retained rules present
- [ ] 14. Commit the test and change together (**direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Item 4 — SC-4: no residual contradictions

- [ ] 15. RED — write a failing grep test scanning the whole file for contradicting file-access-prohibition phrases ("NEVER read/write `.issues/`", "MUST NOT read/write `.issues/` files") outside the preserved git-op rule (**)task-card**: `task(..., prompt: "execute red task from test-driven-development")`)
  - Test FAILs if any residual contradicting sentence remains elsewhere in the file
- [ ] 16. GREEN — sweep any remaining contradicted sentences found by the test (**)task-card**: `task(..., prompt: "execute green task from test-driven-development")`)
  - Only if the SC-4 test FAILs; no change if the file is already consistent
- [ ] 17. Verify SC-4 against the success criterion (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - Grep returns no file-access-prohibition hits outside the preserved git-op rule
- [ ] 18. Commit the test and change together (**direct**)
  - Orchestrator runs `git add <files> && git commit -m "<message>"`

### Phase completion

- [ ] 19. Run VbC verification assertions for phase 1 (**)task-card**: `task(..., prompt: "execute verify task from verification-before-completion")`)
  - All four grep tests PASS against the tracked file; evidence artifacts recorded
- [ ] 20. Record concern transition to phase 2 (**direct**)
  - Phase 2's behavioral scenario verifies the corrected rule produced here

**Cost frame:** Verifying each rule correction costs one grep search (seconds). Skipping means the defective prohibition keeps forcing every `.issues/` read through the CLI for every future session — a wrong-rule regression propagating across the whole agent deck, not a one-time cost.

# Phase 2 — Behavioral enforcement scenario

(phase body stub)

# Post-Implementation

(post-implementation stub)
