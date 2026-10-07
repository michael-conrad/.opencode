---
number: 698
title: "[SPEC-FIX] local-issues setup + creation flow: worktree migration and local/remote number sync"
status: "open"
labels: [spec-fix, issue-operations]
created: "2026-05-18T17:10:26.723931Z"
updated: "2026-05-18T17:17:22.444428Z"
github_issue: 698
remote_issue: 698
remote_url: "https://github.com/michael-conrad/.opencode/issues/698"
promoted_at: "2026-05-18T17:24:00Z"
author: "Michael Conrad"
---

## Summary

`local-issues setup` fails when `.issues/` already exists as a regular tracked directory on a feature branch. `git worktree add` errors with `fatal: '/path/.issues' already exists` because the path is occupied by a normal directory, not a linked worktree.

This blocks the `.issues/` worktree on the `issues-data` branch from being established.

## Root Cause

Two defects:

1. **Spec #523 integration gap**: `git-workflow pre-work` Step 3.7 creates `.issues/<N>/` directories via plain `mkdir -p` but never calls `local-issues setup` first. The `.issues/` directory was never initialized as a worktree.

2. **`local-issues setup` fragility**: `cmd_setup` at `tools/local-issues:670` calls `git worktree add .issues/ issues-data` without first checking if `.issues/` already exists as a regular directory. When it does, git refuses because the path is already occupied by a non-worktree directory.

3. **Creation flow ordering defect**: `creation.md` Step 2 creates local issue first (incrementing a local counter), then promotes to remote. When a remote platform is available, the local number (e.g. 8) never matches the remote number (e.g. 698). The correct flow is: promote to remote first → get remote issue number → create `.issues/open/<REMOTE_NUMBER>-slug/` using that number → advance local counter past it. This affects issue-operations `creation.md` Step 2.

## Success Criteria

- SC-1: In a repo where `.issues/` exists as a regular directory with tracked files, `local-issues setup` succeeds — creates the `issues-data` worktree, migrates existing content into it, and removes `.issues/` from the working branch tracking.
- SC-2: `git-workflow pre-work` Step 3.7 runs `local-issues setup` before `mkdir -p .issues/<N>/`, ensuring `.issues/` is a worktree before new files are created.
- SC-3: `local-issues setup` is idempotent — subsequent calls on an already-established worktree exit cleanly with "already setup" status.

## Items

### Item 1: `local-issues setup` handles pre-existing `.issues/` directory

In `cmd_setup`, before calling `git worktree add`:
1. Check if `.issues/` exists and is NOT already a worktree (via `git worktree list`)
2. If regular directory: rename it to `.issues.bak`, create worktree via `git worktree add`, then migrate content from `.issues.bak` into the worktree, then remove `.issues.bak`
3. If already a worktree: exit idempotent (existing behavior)

**Files edited:** `.opencode/tools/local-issues` — `cmd_setup` function

### Item 2: `pre-work` Step 3.7 calls `local-issues setup` first

Before `mkdir -p .issues/<N>/`:
1. Call `local-issues setup` (idempotent)
2. Then proceed with existing Step 3.7 logic

**Files edited:** `.opencode/skills/git-workflow/tasks/pre-work.md`

### Item 3: Reverse creation ordering — remote-first when platform is available

In `issue-operations/tasks/creation.md` Step 2:
1. If `github.platform` is NOT `local`: promote to remote FIRST → get remote issue number (e.g. 698)
2. Create local directory as `.issues/open/698-slug/` — the remote number IS the local number
3. Set local counter to `max(counter, remote_number + 1)` so subsequent local-only creations don't collide
4. If `github.platform IS local`: use existing local-first flow (counter-based numbering)
5. Update `creation.md` Steps 2.0 and 2.1 to reflect this reversed order

**SC-4:** When `github.platform != local`, `creation` creates remote issue first, then creates local `.issues/open/<REMOTE_NUMBER>-slug/`. Verified by: local directory name matches remote issue number.

**SC-5:** After remote-first creation, local counter advances past remote number. Verified by: reading `.counter` shows value > remote number.

**Files edited:** `.opencode/skills/issue-operations/tasks/creation.md`

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `.issues.bak` collision on concurrent runs | Low | Medium | Check `.issues.bak` existence before rename; fail if already exists |
| Worktree creation succeeds but migration fails | Low | High | Atomic: fail worktree creation if migration would prevent it |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
