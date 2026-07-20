## Problem

The git workflow cleanup tasks (`git-workflow/tasks/cleanup.md` and related task files) define issue closure, branch deletion, and trunk sync as parallel or sequential-but-ungated steps. This allows the agent to delete branches and report "done" without ever executing issue closure.

**Observed failure (SEC-Filings-Scraper PR #7):**
1. PR #7 merged
2. Agent deleted local and remote branches, synced trunk
3. Agent reported "Issue #1 auto-closed via merge commit" — a false claim
4. Issue #1 remained OPEN
5. When challenged, agent gave surface-level explanations (platform differences) instead of identifying the structural workflow defect

**Root cause:** Issue closure is a soft step in the cleanup procedure, not a hard gate. The agent can complete branch deletion and trunk sync without ever calling the issue closure API. The procedure allows this because the steps are not dependency-ordered.

## Required Analysis

All git workflow task files need to be re-analyzed for:

1. **Dependency ordering** — Every step must have explicit prerequisites. Steps that depend on prior steps must fail if the prerequisite was skipped.
2. **Hard gates** — Steps like "verify issue state changed to closed" must block subsequent steps (branch deletion, trunk sync) from executing.
3. **Checklist integrity** — Every task file must use proper checkbox lists (`- [ ]`) for all mandatory steps, with the understanding that unchecked checkboxes at the end of a workflow are a defect signal.
4. **Verification-after-mutation** — Every state-changing API call (close issue, delete branch) must be followed by a read-back verification that the state actually changed.
5. **No platform-specific assumptions** — No reliance on `Closes #N` commit keywords, auto-close, or any platform feature. All closure is explicit API calls with read-back verification.

## Files Requiring Review

- `git-workflow/tasks/cleanup.md` — Primary cleanup procedure
- `git-workflow/tasks/cleanup/issue-closure.md` — Issue closure sub-task
- `git-workflow/tasks/cleanup/branch-cleanup.md` — Branch deletion sub-task
- `git-workflow/tasks/cleanup/verify-merge.md` — PR merge verification
- `git-workflow/tasks/pr-creation.md` — PR creation (may embed closure assumptions)
- `git-workflow/tasks/review-prep.md` — Review prep (may reference closure timing)
- `git-workflow/tasks/implementation.md` — Implementation task (may reference closure)
- `git-workflow/tasks/pre-work.md` — Pre-work setup
- `git-workflow/tasks/rebase-pending.md` — Rebase handling
- `git-workflow/tasks/check-pr.md` — PR check workflow
- `git-workflow/tasks/completion.md` — Workflow completion
- `git-workflow/tasks/pair-pre-work.md` — Pair mode pre-work
- `git-workflow/tasks/pair-commit.md` — Pair mode commit
- `git-workflow/tasks/pair-pr-creation.md` — Pair mode PR creation
- `git-workflow/tasks/pair-cleanup.md` — Pair mode cleanup
- `git-workflow/tasks/pair-mode-resume.md` — Pair mode resume
- `git-workflow/tasks/submodule-sync.md` — Submodule sync
- `git-workflow/enforcement/` — All enforcement files

**Note:** `release-promotion.md` is intentionally excluded from this list — it is eliminated under trunk-based development (no dev→main promotion).

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Every state-changing API call in cleanup is followed by a read-back verification | `string` |
| SC-2 | Issue closure is a hard prerequisite for branch deletion in the dependency graph | `string` |
| SC-3 | All mandatory steps use `- [ ]` checkbox lists | `string` |
| SC-4 | No task file references `Closes #N`, auto-close, or any platform-specific closure mechanism | `string` |
| SC-5 | A behavioral test exists that verifies the agent closes issues after PR merge before deleting branches | `behavioral` |

## Interdependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| **#580** (PR staleness verification) | MEDIUM | #580 adds a new mandatory gate (staleness check) to the PR-creation enforcement gate. This spec ensures all cleanup/gate tasks have hard-gate dependency ordering. #580's new gate should be non-skippable per this spec's hard-gate discipline. |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)