---
number: 1217
title: "[SPEC] Replace .gitmodules-based submodule detection with filesystem glob scan in git-workflow tasks"
status: approved
labels: ["spec", "approved-for-pr", "approved-for-plan"]
created: 2026-06-15
---

## Problem

All git-workflow tasks that need to operate across repos (`check-pr`, `cleanup`, `branch-cleanup`, `issue-closure`, `release-promotion`, `review-prep/push-and-cleanup`, `pr-creation/enforcement-gate`, `pre-work`, `provenance`) rely on `.gitmodules` parsing for submodule discovery. This is a single point of failure:

- `.gitmodules` can be stale, missing, or out of sync with actual submodule state
- Submodules initialized via `git submodule init` create `*/.git` files (gitlinks) or `*/.git/` directories that are not reflected in `.gitmodules`
- Nested submodules in subrepos are invisible
- The `check-pr` task has no operational submodule detection at all — its `submodules` variable is undefined pseudo-code

## Solution

Replace all `.gitmodules`-based detection with a filesystem glob scan using three patterns:

```
.git/       # main repo
*/.git/     # submodule directories
*/.git      # submodule gitlink files
```

For each discovered path, resolve the remote URL via `git -C <path> remote get-url origin` to determine owner/repo. No `.gitmodules` parsing anywhere. No recursion — single-level scan only.

### Affected Files (10 total)

| # | File | Current `.gitmodules` Usage | Replacement |
|---|---|---|---|
| 1 | `tasks/check-pr.md` | Undefined `submodules` variable — no real detection | Scan glob paths → build repo list → query all for PRs |
| 2 | `tasks/cleanup.md` Step 0 | `test -f .gitmodules` + `git config --file .gitmodules --list` | Scan glob paths → resolve remotes → build `submodule_paths` routing context |
| 3 | `tasks/cleanup/branch-cleanup.md` Step 1.9 | `git config --file .gitmodules` to collect paths | Scan glob paths → iterate each for dev sync + branch cleanup |
| 4 | `tasks/cleanup/issue-closure.md` Step 8.5 | Fallback: `.gitmodules` entries for path→owner/repo | Use `submodule_paths` from `cleanup.md` (glob-scan based) |
| 5 | `tasks/release-promotion.md` | `test -f .gitmodules` gate + `git config --file .gitmodules` | Scan glob paths → iterate all repos for tag + push |
| 6 | `tasks/review-prep/push-and-cleanup.md` | `test -f .gitmodules` gate | Scan glob paths → dispatch sub-agent per repo |
| 7 | `tasks/pr-creation/enforcement-gate.md` | `test -f .gitmodules` gate | Scan glob paths → liveness check per repo |
| 8 | `tasks/pre-work.md` | `test -f .gitmodules` gate for sub-agent dispatch | Scan glob paths → dispatch per repo |
| 9 | `tasks/provenance.md` | `.gitmodules` existence as entry criterion | Scan glob paths → provenance per repo |
| 10 | `SKILL.md` Line 106 | Tag suffix from `.gitmodules` path name | Tag suffix from discovered repo directory name |

## Core Detection Pattern (reusable across all files)

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/$||')
for RP in $REPO_PATHS; do
    REMOTE_URL=$(git -C "$RP" remote get-url origin 2>/dev/null || echo "")
done
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 10 files replace `.gitmodules` references with filesystem glob scan | `string` | grep for `.gitmodules` in git-workflow tasks returns 0 matches |
| SC-2 | `check-pr` queries all discovered repos (main + submodules) for PRs | `behavioral` | `opencode-cli run` with "check prs" prompt → stderr shows PR queries for both parent and submodule repos |
| SC-3 | `cleanup` Step 0 builds `submodule_paths` routing context from glob scan | `string` | `cleanup.md` Step 0 no longer references `.gitmodules` |
| SC-4 | `branch-cleanup` Step 1.9 iterates all glob-discovered repos for dev sync + branch cleanup | `string` | `branch-cleanup.md` Step 1.9 no longer references `.gitmodules` |
| SC-5 | `release-promotion` iterates all glob-discovered repos | `string` | `release-promotion.md` no longer references `.gitmodules` |
| SC-6 | `pre-work` dispatches sub-agents per glob-discovered repo | `string` | `pre-work.md` no longer references `.gitmodules` |
| SC-7 | `provenance.md` entry criterion uses glob scan instead of `.gitmodules` existence | `string` | `provenance.md` no longer references `.gitmodules` |
| SC-8 | `SKILL.md` tag suffix rule uses discovered repo directory name | `string` | `SKILL.md` no longer references `.gitmodules` for tag suffix |
| SC-9 | No recursion — scan is single-level only | `string` | All detection commands use `ls -d` with no recursive flags |

## Phases

### Phase 1: Core Detection Pattern + check-pr
Replace `.gitmodules` in `check-pr.md` with the glob scan pattern. This is the highest-priority fix since `check-pr` currently has no operational detection at all.

### Phase 2: cleanup.md + sub-tasks
Replace `.gitmodules` in `cleanup.md` Step 0, `branch-cleanup.md` Step 1.9, and `issue-closure.md` Step 8.5 fallback.

### Phase 3: Remaining task files
Replace `.gitmodules` in `release-promotion.md`, `review-prep/push-and-cleanup.md`, `pr-creation/enforcement-gate.md`, `pre-work.md`, `provenance.md`.

### Phase 4: SKILL.md tag convention
Replace `.gitmodules` path reference in tag suffix rule with discovered repo directory name.

## Constraints

- No `.gitmodules` parsing anywhere in git-workflow tasks
- No recursion — single-level `ls -d` scan only
- All three glob patterns must be checked: `.git/`, `*/.git/`, `*/.git`
- Remote URL resolution must handle both SSH (`git@github.com:owner/repo.git`) and HTTPS (`https://github.com/owner/repo.git`) formats

---

Co-authored with AI: OpenCode (deepseek-v4-flash)