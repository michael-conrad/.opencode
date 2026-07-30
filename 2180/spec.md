# [SPEC-FIX] Replace `ls -d .git/` glob with `git submodule status` for submodule detection

## Intent and Executive Summary

### Problem Statement
The `ls -d .git/ */.git/ */.git/` glob pattern used across 7 task files in `git-workflow-cleanup` and `git-workflow-branch` fails to detect submodules whose `.git` is a gitdir file (e.g., `.opencode/.git` contains `gitdir: ../.git/modules/.opencode`) rather than a directory. The trailing slash in the glob requires directory entries — files are not matched. This causes the `check-pr` sub-agent to report "No submodule `.git/` dirs found" despite `.opencode/.git/` existing, leading to skipped submodule cleanup.

### Root Cause / Motivation
The glob pattern `ls -d .git/ */.git/ */.git/` uses trailing slashes, which in POSIX globbing require the matched path to be a directory. When git submodules are checked out as submodule repos, their `.git` entry is a gitdir file (containing a pointer like `gitdir: ../.git/modules/.opencode`), not a directory. The glob silently returns nothing for these entries, and the submodule detection logic proceeds as if no submodules exist.

The defect-discovery-latency (DDL) cost: this defect was discovered in production when the `check-pr` sub-agent skipped submodule cleanup, leaving stale worktree state. The cost of the behavioral test that would have caught it (running `ls -d .git/` against a gitdir-file submodule) is near-zero. The cost of the production incident (manual cleanup, investigation time, delayed PRs) is orders of magnitude higher.

### Approach Chosen
Replace all 8 occurrences of the `ls -d .git/ */.git/ */.git/` glob pattern with `git submodule status`, the canonical git command for submodule detection. `git submodule status` works regardless of whether `.git` is a directory or a gitdir file, and also provides the submodule SHA and dirty status.

### Alternatives Considered & Why Discarded
- **Keep glob but remove trailing slash**: Would match both directories and files, but would also match non-submodule `.git` entries (e.g., the parent repo's `.git`). Discarded because it introduces false positives.
- **Use `find -name .git`**: Would recursively search all directories, potentially matching nested git repos. Discarded because it's less precise than `git submodule status`.
- **Use `git config --file .gitmodules --get-regexp`**: Would parse `.gitmodules` directly but would miss submodules that are initialized but not yet in `.gitmodules`. Discarded because `git submodule status` is the canonical, maintained interface.

### Key Design Decisions
- Code-block contexts use `git submodule status 2>/dev/null | awk '{print $2}'` to extract submodule paths from the status output.
- Prose/checklist contexts use `git submodule status` without the awk pipeline, since the context is descriptive.
- The `sed` pipeline that strips `.git` suffix from glob results is removed, since `git submodule status` outputs paths without `.git` suffix.
- No changes to the `SUBMODULE_PATHS` filtering logic — it works identically regardless of how `REPO_PATHS` was populated.

## Not Included
- No changes to submodule behavior itself — only the detection mechanism
- No changes to parent repo files
- No changes to non-git-workflow skills
- No changes to the `SUBMODULE_PATHS` filtering logic

## Documentation Sources
- `git submodule status` — Git documentation: https://git-scm.com/docs/git-submodule#Documentation/git-submodule.txt-status
- POSIX glob behavior (trailing slash requires directory entries) — documented in POSIX.1-2017 `glob()` specification

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | `branch-cleanup.md` submodule detection section: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-2 | `issue-closure.md` submodule detection section: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-3 | `check-pr.md` submodule detection prose: `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |
| SC-4 | `check-pr.md` submodule detection prose (second occurrence): `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |
| SC-5 | `cleanup.md` submodule detection section: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-6 | `operating-protocol.md` submodule detection section: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-7 | `pre-work.md` submodule detection section: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-8 | `provenance.md` submodule detection prose: `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |

**SC Enforcement Gate:** All 8 SCs must PASS for the implementation to be considered complete. Any single FAIL blocks the implementation.

## Requirements

1. All task files SHALL use `git submodule status` instead of `ls -d .git/ */.git/ */.git/` for submodule detection.
2. Code-block contexts (where the output is assigned to a variable) SHALL use `git submodule status 2>/dev/null | awk '{print $2}'`.
3. Prose/checklist contexts SHALL use `git submodule status` without the awk pipeline.
4. The `sed` pipeline that strips `.git` suffix from glob results SHALL be removed where present, since `git submodule status` outputs paths without `.git` suffix.

## Items

| Item | SC | File | Area | Replacement |
|------|----|------|------|-------------|
| 1 | SC-1 | `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Submodule detection variable assignment | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 2 | SC-2 | `git-workflow-cleanup/tasks/cleanup/issue-closure.md` | Submodule detection variable assignment | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 3 | SC-3 | `git-workflow-cleanup/tasks/check-pr.md` | Submodule detection prose (first occurrence) | `git submodule status` (prose) |
| 4 | SC-4 | `git-workflow-cleanup/tasks/check-pr.md` | Submodule detection prose (second occurrence) | `git submodule status` (prose) |
| 5 | SC-5 | `git-workflow-cleanup/tasks/cleanup.md` | Submodule detection variable assignment | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 6 | SC-6 | `git-workflow-branch/tasks/operating-protocol.md` | Submodule detection variable assignment | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 7 | SC-7 | `git-workflow-branch/tasks/pre-work.md` | Submodule detection variable assignment | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 8 | SC-8 | `git-workflow-branch/tasks/provenance.md` | Submodule detection prose | `git submodule status` (prose) |

## Dependencies

None. All 8 replacements are independent — any order works.

## Traceability

| Requirement | SCs | Items |
|-------------|-----|-------|
| R1 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | 1-8 |
| R2 | SC-1, SC-2, SC-5, SC-6, SC-7 | 1, 2, 5, 6, 7 |
| R3 | SC-3, SC-4, SC-8 | 3, 4, 8 |
| R4 | SC-1, SC-2, SC-5, SC-6, SC-7 | 1, 2, 5, 6, 7 |
