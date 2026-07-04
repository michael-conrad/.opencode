---
type: SPEC
status: DRAFT
version: 3.0
created: 2026-05-09
updated: 2026-07-01
labels: [SPEC, pipeline, drift-detection, pre-pr, stale-branch]
priority: medium
---

# [SPEC] Stale-branch detection before PR creation

## Problem

Feature branches can be forked from a stale `dev` checkout and accumulate commits while `dev` moves ahead. When the developer pushes the branch and creates a PR, the diff is against an outdated base — the PR may conflict, duplicate work already done on `dev`, or miss required changes. This wastes review cycles and creates avoidable rebase work.

The `drift-detection` task file exists at `.opencode/skills/adversarial-audit/tasks/drift-detection.md` but has no automated trigger. It is designed for manual spec-vs-code comparison, not for pre-PR staleness detection.

**This is NOT about post-merge drift** (spec vs codebase diverging over time). That is a separate concern. This spec addresses **pre-PR staleness**: detecting that a feature branch's base is behind `dev` before the branch is pushed or a PR is created.

## Requirements

- [ ] Integration point: add a staleness-check + auto-rebase step to `review-prep/push-and-cleanup.md` before the existing Step 1.5 rebase
- [ ] Detection method: `git rev-list --count --left-right origin/dev...HEAD` — if `behind > 0`, the branch is stale
- [ ] On staleness detected: **auto-rebase** the feature branch onto `origin/dev`. The agent performs the rebase autonomously — this is a mechanical operation, not a developer decision
- [ ] On rebase success (clean): proceed normally to push and PR creation
- [ ] On rebase conflict: classify per `conflict-resolution` skill's three-tier system:
  - **Tier 1-2 (trivial/textual):** auto-resolve, proceed
  - **Tier 3 (intent):** HALT and escalate to developer with conflict details
- [ ] On clean (behind == 0): proceed normally to push and PR creation

## Open Questions (Resolved)

| Question | Resolution |
|----------|-----------|
| Trigger mechanism? | `git-workflow --task review-prep` — the pre-PR gate. Not a webhook, not scheduled. |
| Merge scope? | Every PR creation. Not limited to spec-linked PRs — any stale branch is a problem. |
| On staleness: halt or auto-fix? | **Auto-rebase.** Agent rebases onto `origin/dev`. Only escalate to developer on Tier 3 (intent) conflicts. |
| Who owns implementation? | `git-workflow` skill — add a staleness-check + auto-rebase sub-step to `review-prep/push-and-cleanup.md`. The `drift-detection` task file is NOT the right mechanism for this; this is a git-level check, not an adversarial audit. |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `review-prep/push-and-cleanup.md` includes a staleness-check step before push | `string` | `grep "behind\|stale\|rev-list" .opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` returns matches |
| SC-2 | Staleness detected → agent auto-rebases onto `origin/dev` | `behavioral` | Clean-room sub-agent evaluates agent output: agent runs rebase on behind > 0, does not halt |
| SC-3 | Rebase succeeds → proceeds to push and PR creation | `behavioral` | Clean-room sub-agent evaluates agent output: agent pushes and creates PR after successful rebase |
| SC-4 | Tier 3 conflict during rebase → HALT and escalate to developer | `behavioral` | Clean-room sub-agent evaluates agent output: agent halts on intent conflict, reports conflict details |
| SC-5 | Clean branch (behind == 0) → proceeds normally | `behavioral` | Clean-room sub-agent evaluates agent output: agent proceeds through push and PR creation |
| SC-6 | Behavioral enforcement test exists for stale-branch auto-rebase | `behavioral` | Test script exists at `tests/behaviors/492-stale-branch-auto-rebase.sh` and passes |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | Add staleness-check + auto-rebase step before existing Step 1.5 |
| `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` | New behavioral test for stale-branch auto-rebase |

## Constraints

- Staleness check is `git rev-list --count --left-right`, not a full drift-detection audit
- On staleness: auto-rebase onto `origin/dev` — agent performs rebase autonomously
- On Tier 1-2 conflict: auto-resolve per `conflict-resolution` skill
- On Tier 3 conflict: HALT, escalate to developer with conflict details
- On clean (behind == 0): proceed normally
- This is a git-level check, not an adversarial-audit invocation — the `drift-detection` task file is for spec-vs-code comparison, not for branch staleness

## Test Fixture Repos

Behavioral tests for this spec require a real remote to execute `git fetch`/`git rebase` against `origin/dev`. Two blank fixture repos are available for this purpose — no fixed roles, no pre-seeded content:

| Repository | URL |
|------------|-----|
| test-submodule-1 | `https://github.com/michael-conrad/test-submodule-1` |
| test-submodule-2 | `https://github.com/michael-conrad/test-submodule-2` |

The test script pushes content to the repo at runtime (dev branch, feature branch, ahead commits). Either repo can be used as the remote origin.

## Dependencies

- None — self-contained spec. Does NOT depend on #483 (partially superseded) or #1645 (baseline generation, optional).
