# Task: issue-closure-sweep

## Purpose

Post-merge sweep that checks open issues for closable candidates — issues whose linked PRs have been merged.

## Entry Criteria

- PR merge confirmed by upstream caller
- GitHub API access available

## Procedure

### Step 1: Query all OPEN issues

Use `github_list_issues(state=OPEN)` to fetch all open issues.

### Step 2: Classify issues

For each open issue:
- If it has sub-issues (check `get_sub_issues`), it's a parent — SKIP unless all children are CLOSED
- If it's a spec/bug with linked PR references ("Fixes #N" in body), proceed to Step 3

### Step 3: Verify linked PRs are merged

For each linked PR reference:
- Use `github_pull_request_read(method=get)` to check merge status
- If ALL linked PRs are merged → candidate for closure

### Step 4: Report findings to chat

Before closing any issue, report:
- Issue #N — linked PR #M merged → candidate for closure
- Issue #N — parent with open children → SKIP

### Step 5: Close qualified candidates

Use `github_issue_write(method=update, state=closed, state_reason=completed)` for each confirmed candidate.

## Exit Criteria

- All closable issues reported to chat
- All confirmed closures executed with state_reason: completed
- Parent issues with open children left open