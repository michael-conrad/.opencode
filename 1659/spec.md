# [SPEC] Remove worktree bootstrap from session-init for trunk-based development

## Summary

Remove `bootstrap_worktree_layout()` and `is_worktree_setup()` from `tools/session-init`. With trunk-based development, there is no `dev` branch to park on — work happens on feature branches checked out directly in the main working directory. The `.worktrees/main/` worktree is no longer needed.

## Motivation

The worktree bootstrap was designed for the old three-branch model: the main working directory stayed on `dev`, and a `.worktrees/main/` worktree held the `main` branch for release operations. With trunk-based development:

- There is no `dev` branch to park on
- Feature branches are checked out directly in the main working directory
- `main` is the trunk — no separate worktree needed
- The bootstrap function still references `git checkout dev` (being removed in #1657) but the entire concept is obsolete

## Mandate

**All changes MUST be made on a feature branch — never directly on `main` or `master`.** This is enforced by the pre-commit hook (Gate 1) which blocks direct commits to `main`. The worktree bootstrap was a workaround for the old model; removing it does not change the branch discipline requirement.

## Affected Files

| File | Change |
|------|--------|
| `tools/session-init` | Remove `is_worktree_setup()` function; remove `bootstrap_worktree_layout()` function; remove call to `bootstrap_worktree_layout()` in `main()` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `is_worktree_setup()` function removed from `session-init` | `string` | grep for `is_worktree_setup` in `tools/session-init` returns nothing |
| SC-2 | `bootstrap_worktree_layout()` function removed from `session-init` | `string` | grep for `bootstrap_worktree_layout` in `tools/session-init` returns nothing |
| SC-3 | `main()` no longer calls `bootstrap_worktree_layout()` | `string` | grep for `bootstrap_worktree_layout` in `tools/session-init` returns nothing |
| SC-4 | Behavioral: `session-init` completes without attempting worktree creation | `behavioral` | `opencode-cli run` with prompt triggering session-init; verify no worktree-related errors |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
