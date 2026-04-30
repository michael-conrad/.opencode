# Task: check-pr

## ⚠️ Enforcement Gate

**This task is MANDATORY when the user says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)". The agent MUST NOT respond with a raw PR listing without routing through this task's Step 3 decision point. Bypassing this gate to list PRs directly via `github_list_pull_requests` is a CRITICAL GUIDELINE VIOLATION — see `000-critical-rules.md` §"Listing Merged PRs Without Invoking Cleanup".**

## Purpose

List all PRs (open and merged) for the repository. If merged PRs with uncleaned branches are detected, activate the `cleanup` task. If only open PRs exist, report and HALT.

## Entry Triggers

Any of these phrases triggers this task:
- "check pr"
- "check prs"
- "check pull request"
- "check pull requests"
- "check merged prs"
- "check merged pr"

## Procedure

### Step 1: Query All PRs

List both open and recently closed PRs:

```python
# List open PRs
open_prs = github_list_pull_requests(
    owner=<github.owner>, repo=<github.repo>, state="open", perPage=50
)

# List merged PRs (GitHub "closed" includes both merged and unmerged)
merged_prs = github_list_pull_requests(
    owner=<github.owner>, repo=<github.repo>, state="closed", perPage=50
)
# Filter: only actually merged (has merged_at)
merged_prs = [pr for pr in merged_prs if pr.get("merged_at") is not None]
```

Extract from each PR:
- PR number
- Title
- Head branch name
- Base branch
- State (open/closed/merged)
- `merged_at` timestamp
- Author

### Step 2: Report PR Status

Report all PRs found in a structured format:

```
**Open PRs:** <count>

| # | Title | Branch | Author |
|---|-------|--------|--------|
| 42 | Fix login | fix/login | dev1 |

**Merged PRs:** <count>

| # | Title | Branch | Merged At |
|---|-------|--------|-----------|
| 40 | Update docs | docs/update | 2026-04-27 |
```

### Step 3: Decision — Cleanup Trigger

This is the CRITICAL enforcement gate. The agent MUST NOT produce a static listing and stop. It MUST evaluate the decision point:

| Condition | Action |
|-----------|--------|
| Merged PRs exist with local branches | **Activate `--task cleanup`** — delete merged branches, close issues |
| Merged PRs exist, no local branches | Report "already cleaned up" — no action needed |
| Only open PRs exist | Report PRs and HALT |
| No PRs exist at all | Report "No PRs found" and HALT |

**Checking for local branches:**

```bash
# For each merged PR head branch, check if local branch exists
git branch --list "<head-branch>"
```

If any merged PR's head branch still exists locally, that branch needs cleanup.

### Step 4: If Cleanup Needed

Delegate to `cleanup` task — do NOT duplicate cleanup logic here:

```python
# If any merged PR has an uncleaned local branch:
# Invoke cleanup task
invoke("--task cleanup")
```

The cleanup task handles:
- Branch deletion (local and remote)
- Issue closure with verification
- Dev sync verification
- Worktree cleanup

### Step 5: If No Cleanup Needed

Report and HALT:

```
**Open PRs:** 2 (see table above)
**Merged PRs:** 5 (all branches already cleaned up)

No cleanup needed. All merged PR branches have been deleted.
```

### Step 3.5: Submodule PR Status Check (MANDATORY when submodules exist)

**⚠️ When `.gitmodules` exists, the agent MUST check submodule PR status as part of the cleanup decision. Submodule PRs that are merged require submodule branch cleanup, just like parent PRs.**

Invoke `/command submodule-workflow-state` to discover submodule PR state.

For each submodule with `pr_state.has_pr == true` and `pr_state.pr_merged == true`:

1. **Trigger submodule branch cleanup** — the submodule branch for the merged submodule PR should be deleted using the submodule's remote, not the parent remote
2. **Route deletion to submodule repo:**

   ```bash
   cd <submodule-path>
   git branch -d <submodule-branch>
   git push origin --delete <submodule-branch> 2>/dev/null || echo "Remote branch already deleted"
   cd <parent-repo-root>
   ```

For each submodule with `pr_state.has_pr == true` and `pr_state.pr_merged == false`:

1. **Report as open submodule PR** — include in the PR status report
2. **No automatic cleanup** — submodule PR not yet merged

**Add to PR status report:**

```
**Submodule PRs:**

| Submodule | PR # | Branch | State | Action |
|-----------|------|--------|-------|--------|
| .opencode | #42 | feature/xyz | Merged | Branch deleted |
| .opencode | #55 | feature/abc | Open | No action |
```

🚫 FORBIDDEN: Ignoring submodule PRs when checking merged PRs
✅ REQUIRED: Include submodule PR status in the PR status report
✅ REQUIRED: Route submodule branch deletion to the submodule remote

When cleanup is activated, the `cleanup` task performs content verification before deleting any branch:

- Compare branch content against dev using `git diff --stat origin/dev...<branch>`
- For each changed file, verify content exists (IDENTICAL or SUPERSEDED) on dev
- Flag any file unique to the branch as `UNIQUE` — do NOT auto-delete
- Produce content comparison table before declaring deletion safe

This prevents deletion of branches that still contain unreleased work.

## Exit Criteria

- All PRs listed (open and merged)
- If merged PRs with branches → cleanup activated
- If only open PRs → reported and HALT
- No PR listing produced without Step 3 evaluation