> **Full spec and artifacts: [`.opencode#2180`](https://github.com/michael-conrad/.opencode/tree/issues-data/2180)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2180/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] Replace `ls -d .git/` glob with `git submodule status` for submodule detection

## Objective

Replace all 8 occurrences of the `ls -d .git/ */.git/ */.git/` glob pattern across 7 task files in `git-workflow-cleanup` and `git-workflow-branch` with `git submodule status`, which correctly detects submodules whose `.git` is a gitdir file rather than a directory.

## Background

The glob pattern `ls -d .git/ */.git/ */.git/` fails when a submodule's `.git` is a gitdir file (e.g., `.opencode/.git` contains `gitdir: ../.git/modules/.opencode`) rather than a directory. The trailing slash in the glob requires directory entries — files are not matched. This caused the `check-pr` sub-agent to report "No submodule `.git/` dirs found" despite `.opencode/.git/` existing, leading to skipped submodule cleanup.

`git submodule status` is the canonical git command for submodule detection. It works regardless of whether `.git` is a directory or a gitdir file, and it also provides the submodule SHA and dirty status.

## Not Included

- No changes to submodule behavior itself — only the detection mechanism
- No changes to parent repo files
- No changes to non-git-workflow skills
- No changes to the `SUBMODULE_PATHS` filtering logic (it works identically regardless of how `REPO_PATHS` was populated)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | `branch-cleanup.md` line 188: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-2 | `issue-closure.md` line 295: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-3 | `check-pr.md` line 34: `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |
| SC-4 | `check-pr.md` line 112: `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |
| SC-5 | `cleanup.md` line 42: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-6 | `operating-protocol.md` line 26: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-7 | `pre-work.md` line 108: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | `string` | grep for absence of old pattern, presence of new pattern |
| SC-8 | `provenance.md` line 17: `ls -d .git/` replaced with `git submodule status` (prose context) | `string` | grep for absence of old pattern, presence of new pattern |

## Requirements

1. All task files SHALL use `git submodule status` instead of `ls -d .git/ */.git/ */.git/` for submodule detection.
2. Code-block contexts (where the output is assigned to a variable) SHALL use `git submodule status 2>/dev/null | awk '{print $2}'`.
3. Prose/checklist contexts SHALL use `git submodule status` without the awk pipeline.
4. The `sed` pipeline that strips `.git` suffix from glob results SHALL be removed where present, since `git submodule status` outputs paths without `.git` suffix.

## Items

| Item | SC | File | Line | Replacement |
|------|----|------|------|-------------|
| 1 | SC-1 | `git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | 188 | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 2 | SC-2 | `git-workflow-cleanup/tasks/cleanup/issue-closure.md` | 295 | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 3 | SC-3 | `git-workflow-cleanup/tasks/check-pr.md` | 34 | `git submodule status` (prose) |
| 4 | SC-4 | `git-workflow-cleanup/tasks/check-pr.md` | 112 | `git submodule status` (prose) |
| 5 | SC-5 | `git-workflow-cleanup/tasks/cleanup.md` | 42 | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 6 | SC-6 | `git-workflow-branch/tasks/operating-protocol.md` | 26 | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 7 | SC-7 | `git-workflow-branch/tasks/pre-work.md` | 108 | `REPO_PATHS=$(git submodule status 2>/dev/null \| awk '{print $2}')` |
| 8 | SC-8 | `git-workflow-branch/tasks/provenance.md` | 17 | `git submodule status` (prose) |

## Dependencies

None. All 8 replacements are independent — any order works.

## Traceability

| Requirement | SCs | Items |
|-------------|-----|-------|
| R1 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | 1-8 |
| R2 | SC-1, SC-2, SC-5, SC-6, SC-7 | 1, 2, 5, 6, 7 |
| R3 | SC-3, SC-4, SC-8 | 3, 4, 8 |
| R4 | SC-1, SC-2, SC-5, SC-6, SC-7 | 1, 2, 5, 6, 7 |
