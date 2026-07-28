---
issue: 2170
repo: michael-conrad/.opencode
state: OPEN
labels: [bug, spec]
title: "[SPEC] Git workflow regression: submodule-first processing order broken"
---

## Problem

The agent has stopped processing git workflows in the correct submodule-first order. This affects multiple operations:

1. **PR merged checking** — does not check submodule PRs before parent PRs
2. **PR creation** — does not verify submodule pointers before push
3. **Cleanup** — does not process submodule branches/issues before parent
4. **Issue closure** — leaves issue tickets open after PR merge
5. **PR body references** — does not reference submodule issues correctly in PR bodies

## Expected Behavior

Per the git workflow skills, the invariant across all lifecycle stages is **submodules first, then parent repo**:

| Lifecycle Stage | File | Ordering |
|-----------------|------|----------|
| Branch creation | `pre-work.md` | Step 3 (submodule work) → Step 4 (main repo pointer + branch) |
| Review prep / push | `push-and-cleanup.md` | Step 0 (submodule push) → Step 1+ (temp cleanup, rebase, push) |
| PR creation | `pr-creation.md` | Pre-Push (submodule pointer verification) → squash/push |
| Cleanup — issue closure | `issue-closure.md` | Step 8.5 (submodule issue closure routing) |
| Cleanup — branch deletion | `branch-cleanup.md` | Step 1.7 (parent trunk park) → Step 1.9 (submodule branch cleanup descent) |
| Cleanup — PR check | `check-pr.md` | Phase 3 (close issues depth-first: sub-repos first) → Phase 4 (submodule branch cleanup) → Phase 5 (parent branch cleanup) |

## Observed Symptoms

- Agent processes root repo operations before submodule operations
- PR bodies lack correct cross-repo issue references
- Issue tickets left open after PR merges
- Cleanup skips submodule branch deletion
- Submodule pointer verification skipped before push

## Affected Files

- `skills/git-workflow-branch/tasks/pre-work.md`
- `skills/git-workflow-cleanup/tasks/check-pr.md`
- `skills/git-workflow-cleanup/tasks/cleanup.md`
- `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
- `skills/git-workflow-cleanup/tasks/cleanup/issue-closure.md`
- `skills/git-workflow-pr/tasks/pr-creation.md`
- `skills/git-workflow-pr/tasks/review-prep/push-and-cleanup.md`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Agent processes submodule operations before parent repo operations in all lifecycle stages | `behavioral` | `opencode run` → stderr assertions |
| SC-2 | PR body contains `Closes #N` for same-repo issues and `Closes owner/repo#N` for cross-repo issues, plus full markdown links `[owner/repo#N](full-url)` for cross-repo references. Each referenced issue exists (verified via API). | `string + semantic` | grep + sub-agent read + API verification |
| SC-3 | All linked issues are closed after PR merge (sub-repo issues first, then parent) | `behavioral` | `opencode run` → stderr assertions |
| SC-4 | Submodule branches are cleaned up before parent branches | `behavioral` | `opencode run` → stderr assertions |
| SC-5 | Submodule pointer verification runs before PR push | `behavioral` | `opencode run` → stderr assertions |
| SC-6 | Behavioral enforcement tests verify submodule-first ordering for each lifecycle stage | `behavioral` | `opencode run` → stderr assertions |
