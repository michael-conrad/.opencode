# Plan: Mandatory trunk-tip verification gate

## Goal

Add a mandatory trunk-tip verification gate that enforces every session starts from a clean trunk-tip state before any work begins. The gate verifies: parent repo on `$DEFAULT_BRANCH` at remote tip, all submodules on `$DEFAULT_BRANCH` at remote tip, zero pending changes, and submodule pointer matches committed SHA.

## Architecture

The trunk-tip verification gate is implemented as a new task card (`trunk-tip-verification.md`) in `git-workflow-branch/tasks/`, called as step 0 of `pre-work.md`. A critical violation entry in `000-critical-rules.md` provides the enforcement mandate. The `session-init` tool emits a `trunk_clean` status section for session-level awareness.

## Files to modify/create

| File | Action | Phase |
|------|--------|-------|
| `skills/git-workflow-branch/tasks/trunk-tip-verification.md` | CREATE | 1 |
| `skills/git-workflow-branch/tasks/pre-work.md` | MODIFY (add step 0) | 2 |
| `guidelines/000-critical-rules.md` | MODIFY (add critical violation) | 3 |
| `tools/session-init` | MODIFY (add trunk_clean section) | 4 |

## Phases

| Phase | Description | Files | Chain Dependency |
|-------|-------------|-------|-----------------|
| 1 | Create `trunk-tip-verification.md` task card | `skills/git-workflow-branch/tasks/trunk-tip-verification.md` | None (foundational) |
| 2 | Update `pre-work.md` to call trunk-tip-verification as step 0 | `skills/git-workflow-branch/tasks/pre-work.md` | Phase 1 (task card must exist) |
| 3 | Add critical violation to `000-critical-rules.md` | `guidelines/000-critical-rules.md` | None (independent) |
| 4 | Update `session-init` tool to emit `trunk_clean` | `tools/session-init` | None (independent) |

## Exit Criteria

- SC-1: `trunk-tip-verification.md` exists at `git-workflow-branch/tasks/`
- SC-2 through SC-6: All verification steps present in task card (parent branch, pending changes, remote tip, submodules, pointer)
- SC-7: `pre-work.md` calls trunk-tip-verification as step 0
- SC-8: `000-critical-rules.md` contains non-trunk-tip violation entry
- SC-9: `session-init` emits `trunk_clean` field

## Admonishments

- **Phase ordering:** Phase 1 MUST complete before Phase 2. Phases 3 and 4 are independent and may execute in parallel with each other and with Phase 1.
- **Sub-agent dispatch:** Each phase dispatches to a clean-room sub-agent via `task()`. No inline execution.
- **Verification:** After all phases complete, run `verification-before-completion` to verify all SCs.
- **Commit discipline:** Each phase produces one commit. All commits on the `feature/1996-1999-trunk-tip-cleanup-verify` branch.
