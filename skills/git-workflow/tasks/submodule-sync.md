# Task: submodule-sync

## Purpose
Sync dirty submodule pointers to latest dev tip. Used for mid-feature submodule currency and user "sync submodules" requests.

## Entry Criteria
- One or more submodules have dirty pointers in parent repo
- `.gitmodules` exists in worktree

## Procedure
- [ ] 1. Detect submodules: read `.gitmodules` for `[submodule "..."]` paths
- [ ] 2. For each submodule path:
      - `git checkout dev && git pull origin dev --ff-only`
      - On failure: log the submodule path and error; continue to next submodule
- [ ] 3. Return to parent repo: `git -C <parent> checkout <original-branch>`
- [ ] 4. Report: which submodules were synced successfully, which (if any) failed

## Exit Criteria
All accessible submodules point to latest dev tip. Failed submodules reported but do not block.

## Cross-References
- `git-workflow/SKILL.md` §Tag Convention — hash permanence tags preserve SHAs before sync
- `pre-work` task — submodule tagging at feature start
- Sub-Agent Tasks for Submodule Operations table — submodule ops NEVER done inline