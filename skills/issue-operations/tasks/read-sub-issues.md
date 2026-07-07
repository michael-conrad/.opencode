# Task: read-sub-issues

## Purpose

Read sub-issues for a parent issue. Routes to the appropriate platform sub-skill based on `github.platform`. The dispatcher resolves platform selection — no deliberation about which API to use.

## Entry Criteria

- Parent issue number identified
- `github.platform` value available from session context

## Exit Criteria

- Sub-issue data retrieved via platform sub-skill
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Procedure

### Step 1: Resolve Platform

Route based on `github.platform`:

| `github.platform` | Route to |
|---|---|
| `github` | `platforms/github-mcp/` sub-skill |
| `gitbucket` | `platforms/gitbucket-api/` sub-skill |
| `local` | `platforms/local/` sub-skill |

### Step 2: Dispatch to Platform Sub-Skill

**GitHub platform:**
```python
github_issue_read(
    method="get_sub_issues",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N
)
```

**GitBucket platform:**
```bash
# Sub-issues are not supported by the GitBucket API.
# Use comment-based linking instead. See link-sub-issue.md for the fallback pattern.
echo "Sub-issues not supported by GitBucket API. Use comment-based linking."
```

**Local platform:**
Route to `platforms/local/tasks/read.md` via task(). Pass: `{issue_number: N}`. Extract sub-issue data from returned issue metadata.

### Step 3: Return Sub-Issue Data

Return sub-issue data to the calling task. Used for:
- Authorization cascade verification per `010-approval-gate.md`
- Parent/child closure order verification per `git-workflow --task cleanup`
- Multi-task plan verification per `020-go-prohibitions.md`

## Common Issues

| Issue | Resolution |
|-------|------------|
| Issue not found | Report "Issue #N not found" |
| No sub-issues | Return empty list — this is valid |
| Platform unknown | HALT — report `github.platform` is not set |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `read-issue` (reads parent issue body), `link-sub-issue` (creates sub-issue links)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`