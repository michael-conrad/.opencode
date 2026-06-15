---
number: 1225
title: "[SPEC-FIX] cleanup: add post-merge issue closure check — resolved open issues not verified for closure"
status: approved
labels: ["spec-fix", "approved-for-plan", "cleanup"]
created: 2026-06-15
---

## Bug

The `git-workflow cleanup` task only checks PR merge status and branch deletion — it does not inspect open resolved issues whose PRs have merged, to verify they can be closed. This leaves issues in OPEN state after their implementation PRs have been merged.

## Root Cause

The cleanup pipeline's issue-closure step only closes issues explicitly linked to the just-merged PR. It does not sweep for other open issues that may have been resolved by the merged PR or by prior work. There is no "issue closure sweep" sub-task that checks: is this issue's implementation complete? Can it be closed?

## Fix

Add a post-merge issue-closure sweep to the `cleanup` task (or as a new sub-task `check-issue-closures`) that:

1. Queries all open issues in the repository
2. For each open issue, checks whether its linked PRs (via body references like `Fixes #N` or PR comments) are merged
3. If all linked PRs are merged and the issue is a spec/bug (not a parent/spec container), propose closure with `state_reason: completed`
4. Verifies the issue is genuinely fully implemented (not just PR-merged — e.g., parent issues with sub-issues should not close until children are done)
5. Reports findings and asks for confirmation before closing

## SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | cleanup task (or sub-task) checks open issues for closable candidates after PR merge | behavioral |
| SC-2 | Only closes issues whose linked PRs are confirmed merged | behavioral |
| SC-3 | Parent issues with open children are NOT closed | behavioral |
| SC-4 | Reports findings to chat before closing | behavioral |

## Phases

### Phase 1: Add Post-Merge Issue Closure Sweep

**Concern:** Add post-merge issue-closure sweep to cleanup that checks all open issues for closable candidates (SC-1 through SC-4).

**Files:**
- `.opencode/skills/git-workflow/tasks/cleanup.md` — optionally reference new sweep step
- `.opencode/skills/git-workflow/tasks/cleanup/issue-closure.md` — add sweep step or new sub-task

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)