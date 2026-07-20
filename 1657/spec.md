## Summary

Remove `_ensure_dev_branch()` from `tools/session-init` so the agent no longer recreates the deleted `dev` branch on every session start.

## Motivation

`session-init` calls `_ensure_dev_branch()` which creates a `dev` branch from `main` if one doesn't exist. Since `dev` was deleted as part of the trunk-based transition, this function recreates it every session, defeating the purpose of the deletion.

## Affected Files

| File | Change |
|------|--------|
| `tools/session-init` | Remove `_ensure_dev_branch()` function; remove call at `run_guard_checks()`; change `git checkout dev` to `git checkout main` in `_setup_main_worktree()` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `_ensure_dev_branch()` function removed from `session-init` | `string` | grep for `_ensure_dev_branch` in `tools/session-init` returns nothing |
| SC-2 | `run_guard_checks()` no longer calls `_ensure_dev_branch()` | `string` | grep for `_ensure_dev_branch` in `tools/session-init` returns nothing |
| SC-3 | `_setup_main_worktree()` uses `git checkout main` not `git checkout dev` | `string` | grep for `checkout.*dev` in `tools/session-init` returns nothing |
| SC-4 | Behavioral: `session-init` does NOT create `dev` branch on session start | `behavioral` | `opencode-cli run` with prompt triggering session-init; verify no `dev` ref created |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)