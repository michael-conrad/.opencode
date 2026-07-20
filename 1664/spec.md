> **Migrated from `michael-conrad/opencode-config#244`** — originally filed against the wrong repo. The `local-issues` tool lives in this repo (`.opencode/tools/local-issues`).

## Problem

`local-issues init` fails for repos on GitBucket that have a `master` branch but no `issues-data` branch. The tool is supposed to auto-create the remote `issues-data` branch as orphaned and blank when it is missing, but four defects in `.opencode/tools/local-issues` prevent this from working.

## Root Cause

Four defects in `.opencode/tools/local-issues`:

1. **`_create_orphan_branch()` (line 481):** Returns `None` (void) regardless of success/failure. `_init_orphan_branch()` can return `None` on failure (e.g., stale temp worktree), but `_create_orphan_branch()` never propagates this — it just returns void.

2. **`_create_issues_worktree()` (line 592):** Calls `_create_orphan_branch()` without checking the return value. When orphan branch creation fails, it proceeds to `_setup_worktree()` which fails because `issues-data` branch doesn't exist.

3. **No stale cleanup:** If a prior `local-issues init` run failed midway, `.issues-worktree-tmp/` remains on disk. The next run's `git worktree add --detach .issues-worktree-tmp` fails because the path already exists.

4. **`-C git_dir` overrides `cwd=wt_tmp`:** `_init_orphan_branch()`, `_commit_orphan_init()`, and `_remove_temp_worktree()` all pass both `-C git_dir` (operate on main repo) and `cwd=wt_tmp` (operate on temp worktree) to subprocess calls. The `-C` flag wins, so `git checkout --orphan issues-data` runs on the **main repo**, switching its HEAD to the orphan branch. This prevents the subsequent `worktree add .issues issues-data` because the main repo is already on `issues-data`.

## Scope

- **In scope:** Fix `_create_orphan_branch()` return type, add return-value check in `_create_issues_worktree()`, add stale `.issues-worktree-tmp` cleanup, remove `-C git_dir` from orphan branch subprocess calls
- **Out of scope:** Any other `local-issues` functionality, GitBucket-specific API changes, worktree lifecycle beyond the init path

## Approach

1. Change `_create_orphan_branch()` to return `bool` (True on success, False on failure).
2. Add a stale cleanup step that removes `.issues-worktree-tmp` before retrying orphan branch creation.
3. Add a return-value check in `_create_issues_worktree()` that returns False when orphan branch creation fails.
4. Remove `-C git_dir` from `_init_orphan_branch()`, `_commit_orphan_init()`, and `_remove_temp_worktree()` subprocess calls — the `cwd=wt_tmp` parameter already resolves the correct repo via the worktree's `.git` file.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `_create_orphan_branch()` returns `True` on success, `False` on failure | `structural` | Read function signature — return type annotation changed from `None` to `bool` |
| SC-2 | `_create_issues_worktree()` checks `_create_orphan_branch()` return value and returns `False` on failure | `structural` | Read function body — conditional check present after `_create_orphan_branch()` call |
| SC-3 | Stale `.issues-worktree-tmp` is cleaned up before orphan branch creation retry | `structural` | Read function body — cleanup call present before retry |
| SC-4 | `local-issues init` succeeds on a repo with `master` branch and no `issues-data` branch | `behavioral` | Run `local-issues init` in a test repo with `master` branch and no `issues-data` branch; verify exit code 0 and `.issues/` worktree created |
| SC-5 | `-C git_dir` removed from orphan branch subprocess calls in `_init_orphan_branch()`, `_commit_orphan_init()`, and `_remove_temp_worktree()` | `structural` | Read each function body — confirm `-C git_dir` is absent from subprocess.run calls that also use `cwd=wt_tmp` |

## Edge Cases

- **Already clean state:** If `.issues-worktree-tmp` does not exist, cleanup is a no-op
- **Concurrent init:** If another process holds `.issues-worktree-tmp`, cleanup may fail — the tool should warn and continue
- **Non-writable directory:** If `.issues-worktree-tmp` exists but is not writable, `shutil.rmtree` will raise — the tool should catch and report

🤖 OpenCode (deepseek-v4-flash)