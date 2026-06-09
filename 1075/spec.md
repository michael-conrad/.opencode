# [BUG] release-promotion PR body is generic placeholder

## Summary

`git-workflow/tasks/release-promotion.md` Step N4 specifies a generic placeholder PR body (`"Automated dev → main promotion"`) that ships with zero information about what the release actually contains. Step N8 release body has the same defect.

## Root Cause

Lines 211-218 of the original task file defined the PR body as a static template string. The release body (Step N8) used identical boilerplate.

## Impact

Release PR #56 in viewport-editor shipped with empty boilerplate — reviewers got zero context.

## Fix

Replace static boilerplate with a semantic synthesis approach at three levels:

1. **Step N4 (PR body):** The agent reads issue bodies linked from commit messages, categorizes changes by type (feature/fix/maintenance/refactor), and synthesizes a structured PR body summarizing intent and functional impact — not a raw `git log` dump.

2. **Step N8 (release body):** The agent synthesizes the release body from categorized changes, same approach as the PR body but against the tag-to-main delta.

3. **$DEFAULT_BRANCH:** Detect dynamically via `git symbolic-ref refs/remotes/origin/HEAD` to support both `main` and `master` repos.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Step N4 instructs agent to read issue bodies and synthesize categorized PR body summary, not dump raw git output | `string` |
| SC-2 | Step N4 includes empty-output handling when no unreleased changes exist | `string` |
| SC-3 | Step N8 release body is synthesized from categorized changes, not static text or raw dump | `string` |
| SC-4 | Default branch is detected dynamically (`$DEFAULT_BRANCH`), not hardcoded to `main` or `master` | `string` |
| SC-5 | No AI-disclaimer, noise, or boilerplate text in PR/release body templates (byline indicates AI authorship) | `string` |

## Files Changed

- `skills/git-workflow/tasks/release-promotion.md` — ~96 lines net changes across 6 commits
- `tests/behaviors/test-release-pr-body-desired.sh` — new content-verification test
- `tests/behaviors/test-release-pr-body-behavioral.sh` — new behavioral test

## Implementation Details

### Step N4 (PR body — semantic synthesis)

The agent reads each commit's issue body (via `git log "$DEFAULT_BRANCH"..dev`), categorizes by type, and builds a structured PR body:

```
- Summary paragraph: 1-3 sentences synthesizing intent
- Changes section: categorized (features, fixes, maintenance) with issue refs and impact
- Files changed: via git diff --stat
```

No boilerplate, no disclaimers, no raw commit dump.

### Step N8 (release body — semantic synthesis)

The agent applies the same categorization approach against commits since the last tag:

```
- Release version and date
- Summary paragraph
- Changes section: categorized with descriptions
- No boilerplate or disclaimers
```

### Default branch detection

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

### Removed artifacts

- AI-disclaimer warnings ("This PR was prepared by an AI agent") — byline serves this purpose
- Dead-code fallback block in N8 (unreachable conditional)
- Raw `printf`-based body construction

## PR

https://github.com/michael-conrad/.opencode/pull/1095

## Audit

Cross-family dual audit (mistral-large + qwen3.5): **5/5 SCs PASS**, unanimous consensus.