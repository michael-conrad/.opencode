## Problem

The `git-workflow-cleanup/tasks/check-pr.md` task file contains multiple invalid or dangerous git commands that produce `"... is not a git command"` errors and can corrupt repository state.

## Root Cause

The check-pr task was written with git commands that were never validated against actual git behavior. The task operates on **already-merged** PRs but runs rebase, force-push, and empty-commit operations as if the branch were still active.

## Invalid Commands Found

### 1. Glob pattern in `git push --delete` (Phase 5, line 122)

```bash
git push origin --delete <parent>/checkpoint/*
```

**Problem:** Git does not support glob expansion in ref names for `git push --delete`. The `*` is passed literally, producing `error: unable to delete 'checkpoint/*': remote ref does not exist`.

**Fix:** Use `git tag -l '<parent>/checkpoint/*' | xargs -r git push origin --delete` or iterate with a loop.

### 2. Rebase + force-push on already-merged branches (Phase 2, Steps 2.3-2.4)

```bash
git fetch origin <target>
git rebase origin/<target>
git push --force-with-lease origin HEAD:<branch_name>
```

**Problem:** The PR is already merged. The branch's commits are already in the target. Running `git rebase` on a merged branch rewrites history that's already been merged. Force-pushing a merged branch is destructive and unnecessary.

**Fix:** Skip rebase/force-push entirely for merged PRs. These steps only apply to open PRs.

### 3. Empty commit + push on merged branch (Phase 2, Step 2.4)

```bash
git commit --allow-empty -m "trigger mergeability" && git push origin HEAD:<branch_name>
```

**Problem:** Creates an empty commit on a branch whose PR is already merged, then pushes it. This creates orphan commits and pollutes history.

**Fix:** This step should only run for open PRs, not merged ones.

### 4. Redundant `git remote prune origin` after `git fetch --prune` (Phase 5, line 123)

```bash
git fetch --prune && git remote prune origin
```

**Problem:** `git fetch --prune` already prunes stale remote-tracking branches. `git remote prune origin` is redundant.

**Fix:** Remove `git remote prune origin` — `git fetch --prune` is sufficient.

### 5. `git pull origin "$DEFAULT_BRANCH" --ff-only` (Phase 5, line 117)

```bash
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH" --ff-only
```

**Problem:** While this syntax may work, the `--ff-only` flag position after the refspec is non-standard and can produce confusing errors depending on git version. The canonical form is `git pull --ff-only origin "$DEFAULT_BRANCH"`.

**Fix:** Use `git pull --ff-only origin "$DEFAULT_BRANCH"`.

### 6. `git status --porcelain` must be empty (Phase 6, line 134) contradicts Step 133

**Problem:** Step 133 says "Submodule pointers in the parent repo are dirty by design" and "Do NOT commit, reset, or otherwise correct them." But Step 134 requires `git status --porcelain` to be empty. A dirty submodule pointer means `git status --porcelain` will show the submodule as modified — the two requirements are contradictory.

**Fix:** Allow `git status --porcelain` to show only submodule pointer changes. Fail only on non-submodule dirty state.

## Severity

All items are **CRITICAL** — they produce git errors, corrupt history, or create contradictory state requirements.

## Affected File

`.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `git push origin --delete <parent>/checkpoint/*` replaced with glob-safe iteration | `string` |
| SC-2 | Rebase/force-push steps (2.3, 2.4) gated to only run on open PRs, not merged | `string` |
| SC-3 | Empty commit + push step gated to only run on open PRs | `string` |
| SC-4 | Redundant `git remote prune origin` removed | `string` |
| SC-5 | `git pull` uses canonical `--ff-only` position | `string` |
| SC-6 | `git status --porcelain` check allows submodule pointer dirtiness | `string` |
| SC-7 | All git commands in check-pr.md produce valid output when run against a merged PR | `behavioral` |
