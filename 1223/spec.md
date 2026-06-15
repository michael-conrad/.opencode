---
number: 1223
title: "[SPEC-FIX] local-issues: no-remote push/pull guard"
status: approved
labels: ["spec-fix", "approved-for-plan"]
created: 2026-06-15
---

## Problem

The `local-issues` tool (`tools/local-issues`) fails on repos with no remote configured. When the parent repo or any child repo has no `origin` remote, operations that call `_sync_repo()` produce misleading error statuses (`"conflict"`, `"push_failed"`) instead of gracefully skipping remote-dependent steps.

Observed in the `ollama` repo which has no remote: `init` and `sync` commands fail because `_rebase_issues_branch()` and `_push_issues_branch_safe()` unconditionally call `git pull --rebase origin issues-data` and `git push origin issues-data`.

## Solution

Add a no-remote guard that skips push/pull operations when no remote exists. The local worktree abstraction (orphan branch) remains intact — only the remote-dependent operations are gated.

## Affected Code

- `tools/local-issues` — three locations in the `_sync_repo()` pipeline:

  1. `_rebase_issues_branch()` (line 1592) — `git pull --rebase origin issues-data`
  2. `_push_issues_branch_safe()` (line 1609) — `git push origin issues-data`
  3. `_sync_repo()` (line 1622) — status reporting for no-remote case

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Repo with no remote: `_rebase_issues_branch()` returns None (skips) instead of attempting `git pull` | `behavioral` |
| SC-2 | Repo with no remote: `_push_issues_branch_safe()` returns None (skips) instead of attempting `git push` | `behavioral` |
| SC-3 | Repo with no remote: `_sync_repo()` returns `{"status": "no_remote"}` rather than `"conflict"` or `"push_failed"` | `behavioral` |
| SC-4 | Repo with remote: existing push/pull behavior is completely unaffected | `behavioral` |

## Implementation Notes

- Add `_has_remote(repo_path: Path) -> bool` helper that wraps `git -C <path> remote get-url origin`
- Use `_has_remote()` in `_rebase_issues_branch()` and `_push_issues_branch_safe()` as early-return guards
- In `_sync_repo()`, set `entry["status"] = "no_remote"` and return before the fetch/pull/push chain when no remote exists
- The `_push_orphan_if_needed()` and `_push_issues_changes()` helpers already have remote guards — no changes needed
- The orphan branch + worktree abstraction stays intact for local-only repos

## Phases

### Phase 1: Add `_has_remote()` helper and guard push/pull operations

**Concern:** Add a no-remote guard that skips push/pull operations when no remote exists (SC-1 through SC-4).

**Files:**
- `.opencode/tools/local-issues` — add `_has_remote()`, modify `_rebase_issues_branch()`, `_push_issues_branch_safe()`, `_sync_repo()`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)