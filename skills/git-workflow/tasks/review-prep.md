# Task: review-prep

## Purpose

Generate GitHub compare URL for developer review AFTER implementation. Provides visibility into changes BEFORE deciding to create a PR.

## ⚠️ MANDATORY INVOCATION

**This task MUST be invoked after every implementation completes. NO decision point. NO asking the developer if they want review. Just generate the compare URL.**

Sequence: Implementation complete → commit → push → **review-prep MUST be invoked**

## Operating Protocol

1. **After implementation:** Runs AFTER all implementation is complete
2. **MANDATORY step:** Branch MUST be pushed for developer review
3. **HALT after push:** Wait for developer to review and authorize PR creation

## Entry Criteria

- All implementation work complete AND pushed to remote
- Feature branch pushed (done by implementation task)
- No explicit "create a PR" instruction yet

## Exit Criteria

- Compare URL generated and reported in CHAT ONLY
- Developer can review changes via GitHub diff viewer

## Procedure

### Step 0: Auto-Commit Dirty .issues/<N>/ Files (MANDATORY)

Before push, auto-commit any dirty `.issues/<issue_number>/` files to ensure all tracking artifacts ride with the feature PR:

```bash
# Check for uncommitted .issues/ changes
if git status --porcelain -- .issues/ 2>/dev/null | grep -q '^'; then
    git add .issues/
    git commit -m "docs(issues): <issue_number> - tracking artifacts checkpoint before review-prep"
fi
```

**No separate PR required.** `.issues/<N>/` commits ride along with the feature branch PR. No additional authorization needed — covered by feature branch authorization per `000-critical-rules.md` §Auto-Commit Convention.

### Steps 0-2: Push, Cleanup, Rebase, Verify

**Route to:** `review-prep/push-and-cleanup`

Tasks `submodule-feature-push` sub-agent for submodule changes (if `.gitmodules` exists), then handles temp file cleanup, rebase on current dev, worktree handoff, and branch push verification.

### Step 2.5: Squash Verification (MANDATORY GATE)

**Before generating the compare URL, verify the commit-per-issue invariant.** This gate catches unsquashed branches before the compare URL is exposed to the developer.

```bash
# Count commits ahead of dev
git log origin/dev..HEAD --oneline

# Detect branch type
ls tmp/work-*.md 2>/dev/null
```

| Branch Type | Expected Commits | On Mismatch |
| -- | -- | -- |
| **Single-issue** | Exactly 1 | HALT — squash via `pr-creation/squash-push.md` Step 3 before URL generation |
| **Work branch** | N (N = work items) | HALT — verify commit count matches work state before URL generation |

**If single-issue branch has >1 commit:**

1. DO NOT generate compare URL
2. Squash per `pr-creation/squash-push.md` Step 3
3. Re-push with `--force-with-lease`
4. Re-verify commit count — then proceed to URL generation

**If work branch commit count does not match work state items:**

1. DO NOT generate compare URL
2. Verify all implementation items were committed
3. Re-verify — then proceed to URL generation

**AUTHORITY:** `000-critical-rules.md` §Un-Squashed PR, `pr-creation/squash-push.md` Step 3

### Steps 3-5: Generate URL, Report, HALT

**Route to:** `review-prep/report-url`

Generates compare URL from session-init values with character-match verification, reports completion in mandatory chat format, and HALTs waiting for "create a PR".

## "No File Changes" Edge Case

| Scenario | Workflow |
| -- | -- |
| Zero files modified | Skip PR workflow, close with verification |
| ANY file modified (including docs/guidelines) | FULL PR workflow REQUIRED |

Guideline and documentation changes are NOT exempt from PR workflow.

## Model ID Detection (CRITICAL)

**MUST dynamically detect model ID at runtime.** NEVER use hardcoded `<ModelId>`. If unknown: ask user.

## Sub-Task Files

| Sub-Task | Purpose | Handler | Words |
| -- | -- | -- | -- |
| `review-prep/push-and-cleanup` | Submodule push via sub-agent, temp cleanup, rebase, branch push, worktree handoff | `submodule-feature-push` sub-agent (Step 0, conditional) | ≈700 |
| `review-prep/report-url` | URL generation, chat format, HALT protocol | — | ≈600 |

## Enforcement Checklist

- ✅ Implementation work is complete
- ✅ `.issues/<N>/` dirty files auto-committed (Step 0)
- ✅ All file changes committed
- ✅ Branch pushed to remote
- ✅ Temp files cleaned
- ✅ Compare URL generated correctly (character-match verified)
- ✅ Chat output format correct (summary BEFORE URL)
- ✅ All verification comparisons use exact-match semantics

## Context Required

- Related skills: `pr-creation-workflow` (PR timing)
- Related tasks: `review-prep/push-and-cleanup`, `review-prep/report-url`, `pr-creation`