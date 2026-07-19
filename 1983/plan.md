# Plan: Fix Post-Merge Cleanup Worktree Conflict

**Issue:** #1983 — Post-merge cleanup fails when main worktree blocks trunk checkout
**Spec:** [GitHub Issue #1983](https://github.com/michael-conrad/.opencode/issues/1983)
**Authorization scope:** `for_pr` (halt at `pr_created`)
**Strategy:** Single phase, single item, single PR

---

## Phase Table

| Phase | Description | Steps | SCs Covered |
|-------|-------------|-------|-------------|
| 1 | Add worktree conflict detection and remediation to cleanup workflow | 1.1–1.6 | SC-1, SC-2, SC-3 |

---

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Cleanup detects worktree conflict before `git checkout $DEFAULT_BRANCH` | 1 | 1.1 |
| SC-2 | Cleanup removes conflicting worktree, switches to trunk, deletes branch, pulls tip, recreates worktree | 1 | 1.2, 1.3, 1.4, 1.5 |
| SC-3 | Cleanup completes to proper conclusion (parked on trunk tip, no stale branches) | 1 | 1.6 |

---

## Item Decomposition

### Phase 1 — Worktree Conflict Remediation

**File:** `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`

**Step 1.1 — Add worktree conflict detection before `git checkout $DEFAULT_BRANCH`**

Insert a pre-check in the "Branch Cleanup After Merge" section (line 215) before the `git checkout` command. Run `git worktree list` and grep for the default branch. If a worktree entry for `$DEFAULT_BRANCH` exists, set a flag `WORKTREE_CONFLICT=true` and capture the worktree path.

```bash
WORKTREE_CONFLICT=false
WORKTREE_PATH=""
while IFS= read -r line; do
  if echo "$line" | grep -q "\[$DEFAULT_BRANCH\]"; then
    WORKTREE_CONFLICT=true
    WORKTREE_PATH=$(echo "$line" | awk '{print $1}')
    break
  fi
done < <(git worktree list 2>/dev/null || true)
```

**Step 1.2 — Remove conflicting worktree**

When `WORKTREE_CONFLICT=true`, remove the worktree before switching branches:

```bash
if [ "$WORKTREE_CONFLICT" = true ] && [ -n "$WORKTREE_PATH" ]; then
  git worktree remove "$WORKTREE_PATH" 2>/dev/null || git worktree remove -f "$WORKTREE_PATH"
fi
```

**Step 1.3 — Switch to trunk**

```bash
git checkout "$DEFAULT_BRANCH"
```

**Step 1.4 — Delete local feature branch and pull trunk tip**

```bash
git branch -d <branch-name>
git pull origin "$DEFAULT_BRANCH"
```

**Step 1.5 — Recreate the worktree**

```bash
git worktree add "$WORKTREE_PATH" "$DEFAULT_BRANCH"
```

**Step 1.6 — Verify final state**

Confirm `git branch --show-current` returns `$DEFAULT_BRANCH`, no stale local feature branch exists, and `git worktree list` shows the recreated worktree.

---

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- **Destructive operations:** `git worktree remove` (removes a worktree), `git branch -d` (deletes local branch)
- **Rollback plan:** If worktree removal fails, fall back to `git worktree remove -f`. If branch deletion fails (unmerged commits), report warning and skip deletion. If worktree recreation fails, the main repo is still on trunk tip — acceptable degraded state.
- **Data loss risk:** Low — the feature branch was already merged (PR merged confirmed before cleanup). Worktree removal is safe since the worktree is checked out to trunk, not the feature branch.
- **No destructive operations on unmerged work:** The `git branch -d` only runs after PR merge is confirmed (existing gate). The worktree removal targets the trunk worktree, not the feature worktree.

---

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `git worktree list` | ✅ | Standard git command |
| 1.2 | `git worktree remove` | ✅ | Standard git command |
| 1.3 | `git checkout` | ✅ | Standard git command |
| 1.4 | `git branch -d`, `git pull` | ✅ | Standard git commands |
| 1.5 | `git worktree add` | ✅ | Standard git command |
| 1.6 | `git branch --show-current`, `git worktree list` | ✅ | Standard git commands |

---

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `git worktree list` outputs worktree paths with branch names | `man git-worktree` | ✅ |
| `git worktree remove` removes a worktree directory | `man git-worktree` | ✅ |
| `git checkout` fails when branch is used by another worktree | `man git-worktree` | ✅ |
| Cleanup.md line 215 has `git checkout "$DEFAULT_BRANCH"` without pre-check | `read(cleanup.md)` | ✅ |
