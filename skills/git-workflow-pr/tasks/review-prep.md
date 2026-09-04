# Task: review-prep

## Purpose

Generate GitHub compare URL for developer review AFTER implementation. Provides visibility into changes BEFORE deciding to create a PR.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

## ⚠️ MANDATORY INVOCATION

**This task MUST be invoked after every implementation completes. NO decision point. NO asking the developer if they want review. Just generate the compare URL.**

Sequence: Implementation complete → commit → push → **review-prep MUST be invoked**

## Operating Protocol

- [ ] 1. **After implementation:** Runs AFTER all implementation is complete
- [ ] 2. **MANDATORY step:** Branch MUST be pushed for developer review
- [ ] 3. **HALT after push:** Wait for developer to review and authorize PR creation

## Entry Criteria

- All implementation work complete AND pushed to remote
- Feature branch pushed (done by implementation task)
- No explicit "create a PR" instruction yet

## Exit Criteria

- Compare URL generated and reported in CHAT ONLY
- Developer can review changes via GitHub diff viewer

## Procedure

### Steps 1-2: Push, Cleanup, Rebase, Verify

**Route to:** `review-prep/push-and-cleanup`

Tasks sub-agent for submodule changes (if a submodule `.git` file or directory is discovered), then handles temp file cleanup, rebase on current trunk, worktree handoff, and branch push verification.

### Step 2.5: Commit-Count Verification (MANDATORY GATE)

**Before generating the compare URL, verify the commit-count invariant.** Multiple WIP commits during development are acceptable; squash to exactly one commit per issue occurs at PR creation, NOT at review-prep. This gate verifies the branch is in a reviewable state without prematurely squashing.

```bash
# Count commits ahead of trunk
git log origin/"$DEFAULT_BRANCH"..HEAD --oneline

# Detect branch type
ls {project_root}/tmp/{issue-N}/work.md 2>/dev/null
```

| Branch Type | Expected Commits | On Mismatch |
| -- | -- | -- |
| **Single-issue** | 1 or more WIP commits | OK — do NOT squash here; squash is deferred to PR creation |
| **Work branch** | N (N = work items) | HALT — verify commit count matches work state before URL generation |

**Squash is deferred to PR creation, not review-prep.** Multiple WIP commits on a single-issue branch are acceptable and expected during development. Do NOT squash at review-prep — the squash to exactly one commit per issue happens at PR creation via `pr-creation/squash-push.md`.

**If work branch commit count does not match work state items:**

- [ ] 1. DO NOT generate compare URL
- [ ] 2. Verify all implementation items were committed
- [ ] 3. Re-verify — then proceed to URL generation

**AUTHORITY:** Read [Un-Squashed PR](guidelines/000-critical-rules.md), Read [Step 3](skills/git-workflow-pr/tasks/pr-creation/squash-push.md)

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
| `review-prep/push-and-cleanup` | Submodule push via sub-agent, temp cleanup, rebase, branch push, worktree handoff | sub-agent | ≈700 |
| `review-prep/report-url` | URL generation, chat format, HALT protocol | — | ≈600 |

## Enforcement Checklist

- ✅ Implementation work is complete
- ✅ All file changes committed
- ✅ Branch pushed to remote
- ✅ Temp files cleaned
- ✅ Compare URL generated correctly (character-match verified)
- ✅ Chat output format correct (summary BEFORE URL)
- ✅ All verification comparisons use exact-match semantics

## Context Required

- Related skills: `git-workflow-pr` (PR timing)
- Related tasks: `review-prep/push-and-cleanup`, `review-prep/report-url`, `pr-creation`
### [critical-rules-016] Skipping review-prep After Implementation
Review prep is the last gate before your work enters the codebase permanently. Skipping it means the first review your code receives is from a colleague, not from yourself. Professional engineers always run review-prep before submitting — amateurs let reviewers discover their mistakes. Read [git-workflow --task review-prep](skills/git-workflow/SKILL.md). Compare URL required.


