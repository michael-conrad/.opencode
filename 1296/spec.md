---
number: 1296
title: "[BUG] local-issues sync creates nested .issues/.issues/ directory in submodule repos"
state: OPEN
---

## Summary

`local-issues sync` creates a nested `.issues/.issues/` directory inside the `.opencode/.issues/` worktree when run from repos that use `.opencode` as a submodule.

## Steps to Reproduce

1. Clone `opencode-config` (parent repo with `.opencode` submodule)
2. Run `.opencode/tools/local-issues sync` from parent repo
3. The tool reports `no_worktree` for the `.issues` qualifier in the submodule, indicating it detected the worktree metadata issue
4. However, after some `init`/`sync` cycles, a `.opencode/.issues/.issues/` directory appears with orphan issue artifacts (e.g., `1050/`)

## Root Cause

The `local-issues` tool's worktree detection logic does not properly distinguish between:
- The **root repo's** `.issues/` worktree (at `/home/muksihs/git/opencode-config/.issues/` with gitdir `.../.git/worktrees/-issues`)
- The **submodule's** `.opencode/.issues/` worktree (at `/home/muksihs/git/opencode-config/.opencode/.issues/` with gitdir `.../.git/modules/.opencode/worktrees/-issues`)

When the tool scans for an existing `.issues/` directory relative to the submodule's working dir, it finds the root-level `.issues/` (which is the parent's worktree, not the submodule's) and attempts to create or sync into it, producing a nested `.issues/.issues/` inside the submodule's own `.issues/` worktree.

## Evidence

- `.opencode/.issues/.git` contains: `gitdir: /home/muksihs/git/opencode-config/.git/modules/.opencode/worktrees/-issues`
- `.issues/.git` (root) contains: `gitdir: /home/muksihs/git/opencode-config/.git/worktrees/-issues`
- Found orphan directory `.opencode/.issues/.issues/1050/` after sync

## Expected Behavior

`local-issues sync` should correctly identify the submodule's `.opencode/.issues/` worktree boundaries and NOT create nested `.issues/.issues/` directories. The sync should report correct status for all three qualifiers: `opencode-config`, `.issues` (root), and `.opencode` (submodule).

## Environment

- Repo: michael-conrad/opencode-config (with `.opencode` submodule)
- Tool: `.opencode/tools/local-issues`
- Worktree: `.opencode/.issues/` — submodule worktree at `.git/modules/.opencode/worktrees/-issues`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)