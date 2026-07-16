# SPEC-FIX: session-enforcement plugin must install git hooks in all registered submodules

## Problem
The session-enforcement plugin (`session-enforcement.ts`) installs git hooks (pre-push, pre-commit, etc.) only in the parent repo's `.git/hooks/`. Submodules — which are independent repos with their own remotes — do not receive these hooks. This means trunk-based development discipline (no direct pushes to default branch, no submodule-pointer-only pushes) is enforced in the parent repo but silently bypassed in every submodule.

## Root Cause
`session-enforcement.ts` hook installation targets only the parent repo's `.git/hooks/`. It does not iterate over `git submodule status` entries and install hooks into each submodule's `.git/hooks/`.

## Scope
- File: `plugins/session-enforcement.ts` (hook installation logic)
- All repos that use the `.opencode` submodule with submodules

## Proposed Fix
After installing hooks in the parent repo, `session-enforcement.ts` must:
1. Read `git submodule status` to enumerate all registered submodules
2. For each submodule, install the same set of hooks into `<submodule>/.git/hooks/`
3. Handle submodules that are not yet initialized or checked out (skip gracefully)
4. Handle submodules that use a `.git` file (superproject worktree) vs a `.git` directory

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Every registered submodule has non-sample hooks in `.git/hooks/` after session-enforcement runs | `string` | `ls <submodule>/.git/hooks/` shows pre-push, pre-commit, etc. |
| SC-2 | Submodule pre-push hook blocks direct pushes to default branch | `behavioral` | Attempt `git -C <submodule> push origin main` → blocked |
| SC-3 | Submodule pre-push hook blocks submodule-pointer-only pushes | `behavioral` | Attempt submodule-only push from parent → blocked |
| SC-4 | Uninitialized submodules are skipped without error | `string` | `git submodule deinit <submodule>` then session-enforcement runs → no crash |
| SC-5 | Hook installation is idempotent (re-running does not duplicate hooks) | `string` | Run session-enforcement twice → hooks unchanged |

## Affected Resources
- `.opencode/plugins/session-enforcement.ts`
- All repos that use `.opencode` as a submodule and have their own submodules
