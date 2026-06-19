# Plan — [SPEC-FIX] local-issues `_discover_all_repos()` includes root `.issues/` worktree as child repo

**Spec:** [michael-conrad/.opencode#1300](https://github.com/michael-conrad/.opencode/issues/1300)
**Goal:** Add a worktree filter to `_discover_all_repos()` so git worktrees (`.issues/`) are excluded while submodules (`.opencode/`) are still discovered.
**Architecture:** Single-function guard clause in `.opencode/tools/local-issues`.
**Tech Stack:** Python 3.12+, pathlib.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1: Add worktree filter to `_discover_all_repos()`

**Concern:** Core fix — add guard clause to skip git worktrees in repo discovery.
**Files:** `.opencode/tools/local-issues`
**SCs covered:** SC-1, SC-2, SC-3

### Pre-RED Common

- [ ] 1. **Read approved spec** (**inline**). Read spec at [michael-conrad/.opencode#1300](https://github.com/michael-conrad/.opencode/issues/1300) to confirm fix scope: one-line guard clause in `_discover_all_repos()` at the `.git` file check. → SC-1, SC-2, SC-3
- [ ] 2. **Read target function** (**inline**). Read `_discover_all_repos()` in `.opencode/tools/local-issues` to understand current `.git` detection logic and identify exact insertion point. → SC-1

### Per-Item RED+green Chains

- [ ] 3. **TDD-1: Add worktree filter guard clause** (SC-1, SC-2)
  - [ ] 3a. **RED: Verify guard clause does not exist** (**inline**). Confirm `_discover_all_repos()` has no `worktrees` filter in its `.git` file detection block. The function currently treats all `.git` entries identically.
  - [ ] 3b. **GREEN: Add guard clause** (**clean-room**). Add a guard clause after the `.git` file existence check: read the `.git` file content and `continue` if it contains `worktrees/`. Submodule `.git` files contain `modules/` and pass through. → SC-1, SC-2

### Post-RED/green

- [ ] 4. **Verification before completion** (**clean-room**). Run `verification-before-completion` to verify all SCs:
  - SC-1: `_discover_all_repos()` no longer returns `.issues/` as a child repo
  - SC-2: `.opencode/` submodule is still discovered
  - SC-3: `_sync_repo()` no longer probes `.issues/.issues/.git`
- [ ] 5. **Finishing checklist** (**clean-room**). Run `finishing-a-development-branch` — git status clean, lint/typecheck pass.
- [ ] 6. **Review prep** (**clean-room**). Run `requesting-code-review` — prepare PR with summary, outcome, and compare URL.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

**Plan:** See [plan.md](.issues/1300/plan.md) for the implementation plan.
