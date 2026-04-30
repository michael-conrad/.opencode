# Task: check-pr

## ⚠️ Enforcement Gate

**This task is MANDATORY when the user says "check pr", "check prs", "check merged prs", "check merged pr", or "check pull request(s)". The agent MUST NOT respond with a raw PR listing without routing through this task's Step 3 decision point. Bypassing this gate to list PRs directly via `github_list_pull_requests` is a CRITICAL GUIDELINE VIOLATION — see `000-critical-rules.md` §"Listing Merged PRs Without Invoking Cleanup".**

## Purpose

List all PRs (open and merged) for the repository. If merged PRs with uncleaned branches are detected, activate the `cleanup` task. If only open PRs exist, report and HALT.

## Entry Triggers

- "check pr"
- "check prs"
- "check pull request"
- "check pull requests"
- "check merged prs"
- "check merged pr"

## Procedure

### Step 1: Query All PRs

```python
# List open PRs
open_prs = github_list_pull_requests(
    owner=<github.owner>, repo=<github.repo>, state="open", perPage=50
)

# List merged PRs
merged_prs = github_list_pull_requests(
    owner=<github.owner>, repo=<github.repo>, state="closed", perPage=50
)
# Note: GitHub "closed" includes both merged and unmerged; filter by merged_at
merged_prs = [pr for pr in merged_prs if pr.get("merged_at") is not None]
```

### Step 2: Report PR Status

Report all PRs found:

```
**Open PRs:** <count>
<list of PR #, title, branch>

**Merged PRs:** <count>
<list of PR #, title, branch, merged_at>
```

### Step 3: Decision

| Condition | Action |
| -- | -- |
| Merged PRs exist with local branches | Activate `--task cleanup` |
| Merged PRs exist, no local branches | Report "already cleaned up" |
| Only open PRs exist | Report PRs and HALT |
| No PRs exist | Report "No PRs found" and HALT |

### Step 4: If Cleanup Needed

Delegates to `cleanup` task — do NOT duplicate cleanup logic here.

```python
# If any merged PR has an uncleaned local branch:
# Invoke cleanup task
invoke("--task cleanup")
```

## Exit Criteria

- All PRs listed (open and merged)
- If merged PRs with branches → cleanup activated
- If only open PRs → reported and HALT