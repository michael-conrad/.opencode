# Pair-Mode Cleanup Task

Clean up pair-mode branches and stashes after PR merge is confirmed. This task operates in the main project directory (not a worktree) consistent with pair-mode conventions.

## Purpose

After a pair-mode PR is merged, the local and remote pair branches, related stashes, and orphaned worktrees should be cleaned up. This mirrors the autonomous `cleanup` task but operates directly in the main directory with `[pair-mode]` trailers.

## Entry Criteria

- PR merge confirmed via GitHub API
- Current branch is the merged pair branch
- User is present (pair mode requires developer involvement for stash decisions)

## Procedure

### Step 1: Verify PR Was Merged

```python
pr = github_pull_request_read(
    method="get",
    owner=<github.owner>,
    repo=<github.repo>,
    pullNumber=<N>
)
```

Check that `merged_at` is not None. If not merged, HALT.

### Step 2: Switch to Dev

```bash
git checkout dev
git pull origin dev
```

Verify dev is current before operating on other branches.

### Step 3: Delete Local Pair Branch

```bash
git branch -d <pair-branch>
```

The `-d` flag (lowercase) only deletes if the branch is fully merged. If git refuses, the branch has unmerged commits — investigate before force-deleting.

**Never use `git branch -D` (force) without developer authorization.**

### Step 4: Delete Remote Pair Branch

```bash
git push origin --delete <pair-branch>
```

If the remote branch was already deleted by GitHub's auto-delete, this will fail harmlessly — proceed.

### Step 5: Clean Up Pair-Related Stashes

```bash
git stash list | grep "pair-"
```

For each matching stash, ask developer: "Resume or drop?"

| Choice | Action |
|--------|--------|
| Resume | `git stash pop stash@{N}` to restore changes |
| Drop | `git stash drop stash@{N}` to remove |
| Keep | Leave stash in place, report its existence |

**Never drop stashes without developer confirmation.** Stashes may contain in-progress work from the pair session.

### Step 6: Clean Up Orphaned Worktrees

```bash
git worktree list --porcelain
```

Remove any worktrees for the merged pair branch:

```bash
git worktree remove <worktree-path>
```

Only remove worktrees whose branch matches the merged pair branch.

### Step 7: Verify Dev Sync

```bash
git log origin/dev..HEAD --oneline
```

Confirm local dev HEAD matches origin/dev. If ahead, pull again. If behind, investigate.

### Step 8: Close Related Issue (if applicable)

If the pair branch referenced an issue number:

```python
github_issue_write(
    method="update",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=<N>,
    state="closed",
    state_reason="completed"
)
```

Post a verification comment documenting the PR merge evidence.

## Branch Deletion Discipline

- Delete merged pair branches IMMEDIATELY after merge confirmation
- Never keep merged pair branches around "just in case" — the code is in dev
- Stashes from pair sessions: always ask developer before dropping
- Force-delete (`-D`) requires explicit developer authorization (Tier 1 mandate)

## Error Handling

| Error | Resolution |
|-------|-----------|
| Branch delete refused (`-d`) | Branch has unmerged commits — investigate with `git log` before force-delete |
| Remote delete fails | Already deleted by GitHub — proceed |
| Stash pop conflicts | Report conflicts, let developer resolve |
| Worktree removal fails | Check for uncommitted changes — abort removal if dirty |

## Result Contract

```yaml
status: DONE | BLOCKED
task: pair-cleanup
branches_deleted: [<name>]
stashes_preserved: [<name>]
worktrees_removed: [<path>]
pr_merge_verified: bool
issue_closed: bool
```