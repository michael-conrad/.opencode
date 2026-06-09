# [BUG] release-promotion PR body is generic placeholder

## Summary

`git-workflow/tasks/release-promotion.md` Step N4 specifies a generic placeholder PR body (`"Automated dev → main promotion"`) that ships with zero information about what the release actually contains. Step N8 release body has the same defect.

## Root Cause

Lines 211-218 of the original task file defined the PR body as a static template string. The release body (Step N8) used identical boilerplate.

## Impact

Release PR #56 in viewport-editor shipped with empty boilerplate — reviewers got zero context.

## Fix

Replace static boilerplate with dynamically generated content at three levels:

1. **Step N4 (PR body):** Capture `git log $DEFAULT_BRANCH..dev --oneline` and `git diff $DEFAULT_BRANCH...dev --stat` at PR creation time. Include empty-output fallback for when no unreleased changes exist.

2. **Step N8 (release body):** Capture `git log <last-tag>..$DEFAULT_BRANCH` and `git diff <last-tag>..$DEFAULT_BRANCH --stat` at release-creation time, with release date.

3. **$DEFAULT_BRANCH:** Detect dynamically via `git symbolic-ref refs/remotes/origin/HEAD` to support both `main` and `master` repos.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Step N4 PR body is dynamically generated from `git log` and `git diff` instead of static boilerplate | `string` |
| SC-2 | Step N4 includes empty-output fallback for when no unreleased changes exist | `string` |
| SC-3 | Step N8 release body is dynamically generated from git history with release date, not static text | `string` |
| SC-4 | Default branch is detected dynamically (`$DEFAULT_BRANCH`), not hardcoded to `main` or `master` | `string` |
| SC-5 | Clarifying comment explains `git log` and `git diff` are complementary views of the same delta | `string` |

## Files Changed

- `skills/git-workflow/tasks/release-promotion.md` — +96/-28 across 5 commits
- `tests/behaviors/test-release-pr-body-desired.sh` — new content-verification test
- `tests/behaviors/test-release-pr-body-behavioral.sh` — new behavioral test

## Implementation Details

### Step N4 (PR body generation)

```bash
RELEASE_COMMITS=$(git log "$DEFAULT_BRANCH"..dev --oneline)
RELEASE_FILES=$(git diff "$DEFAULT_BRANCH"...dev --stat)

if [ -z "$RELEASE_COMMITS" ]; then
    RELEASE_COMMITS="No unreleased changes found — this release may be a dependency-sync or infrastructure update."
    RELEASE_FILES=""
fi
```

PR body built via `printf` with `$RELEASE_COMMITS` and `$RELEASE_FILES` as format arguments.

### Step N8 (release body)

```bash
RELEASE_DATE=$(date +%Y-%m-%d)
RELEASE_COMMITS=$(git log "$(git tag --sort=-v:refname | head -1)..$DEFAULT_BRANCH" --oneline 2>/dev/null)
RELEASE_FILES=$(git diff "$(git tag --sort=-v:refname | head -1)..$DEFAULT_BRANCH" --stat 2>/dev/null)
```

### Default branch detection

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

## PR

https://github.com/michael-conrad/.opencode/pull/1095

## Audit

Cross-family dual audit (mistral-large + qwen3.5): **5/5 SCs PASS**, unanimous consensus.