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

## Content Verification Before Branch Deletion

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