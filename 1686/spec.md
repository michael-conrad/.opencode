## Problem

The pre-work task (`git-workflow/tasks/pre-work.md`) has a step ordering defect. The current order is:

1. Step 2: Sync default branch in main repo
2. Step 3: Create feature branch in main repo
3. Step 3.5: Submodule init/sync/tag

Step 3 creates the feature branch from the default branch. But the submodule pointer in the default branch points to an old submodule commit. Step 3.5 then updates submodules to trunk tip and tags them. But the feature branch in the main repo was already created from the old submodule pointer.

This means:
- The main repo's feature branch has the stale submodule pointer
- When the submodule feature branch is later created, it's based on the updated submodule tip, but the main repo still references the old SHA
- This causes the "stale commit" problem: the main repo's feature branch references a submodule commit that doesn't match what the submodule feature branch is working against

## Root Cause

Step ordering in `pre-work.md`: submodule sync (Step 3.5) runs AFTER feature branch creation (Step 3), not before. The submodule pointer in the main repo's feature branch is stale because it was captured before submodules were updated.

## Fix

Reorder pre-work steps so submodule sync happens BEFORE feature branch creation:

1. Step 2: Sync default branch in main repo
2. Step 3 (was Step 3.5, moved up): Submodule init/sync to trunk tip, tag each submodule
3. Step 4 (was Step 3, moved down): Create feature branch in main repo — now from a state with up-to-date submodule pointers
4. Step 5 (new): Create feature branches in submodules from the tagged commit

The submodule feature branch should be created from the tagged commit (the same SHA the main repo's feature branch now references), not from trunk tip.

## Affected Files

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/pre-work.md` | Reorder steps: move submodule sync before feature branch creation; add submodule feature branch creation step; renumber all steps |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Submodule sync appears BEFORE feature branch creation in pre-work.md | `string` | grep for step ordering — submodule steps precede branch creation |
| SC-2 | Submodule feature branch creation step references the tagged commit, not trunk tip | `string` | grep for submodule branch creation using the tag |
| SC-3 | Behavioral test verifies agent syncs submodules before creating main repo feature branch | `behavioral` | opencode-cli run with pre-work scenario; verify stderr shows submodule ops before `git checkout -b feature/` |
| SC-4 | All step numbers in pre-work.md are internally consistent | `string` | grep for orphan references to old step numbers |
| SC-5 | Submodule feature branch creation handles the "already exists" edge case | `string` | grep for existence check before branch creation |

## Risk Callouts

| Risk | Description | Mitigation |
|------|-------------|------------|
| External cross-references to old step numbers | Other files reference Step 3 or Step 3.5 | Grep all `.opencode/` files before renumbering |
| Submodule feature branch already exists | Prior interrupted session left a branch | Add `git branch --list` check before creation; skip if exists |
| Submodule tag push fails | Network error, permission | Verify tag exists locally before creating branch from it |