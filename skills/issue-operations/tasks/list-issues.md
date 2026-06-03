# Task: list-issues

## Purpose

List issues with filters. Routes to the appropriate platform sub-skill based on `github.platform`. The dispatcher resolves platform selection — no deliberation about which API to use.

## Entry Criteria

- Filter criteria identified (state, labels, since date, etc.)
- `github.platform` value available from session context

## Exit Criteria

- Issue list retrieved via platform sub-skill
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
github_list_issues(
    owner=<github.owner>,
    repo=<github.repo>,
    labels=["<label>"],
    state="open",
    since="<ISO-date>"
)
```

**GitBucket platform:**
```bash
./.opencode/tools/gitbucket-api list-issues <github.owner> <github.repo> --state open --labels "<label>"
```

**Local platform:**
Route to `platforms/local/tasks/list.md` via task(). Pass: `{status: "open", label: "<label>"}`.

### Step 3: Return Issue List

Return the issue list to the calling task. Used for:
- Dedup checks in `pre-creation` task
- Authorization scope label verification
- Spec/plan overlap detection

## Common Issues

| Issue | Resolution |
|-------|------------|
| No issues found | Return empty list — this is valid, not an error |
| Filter syntax error | HALT — report filter format requirements |
| Platform unknown | HALT — report `github.platform` is not set |
| API rate limit | HALT — report rate limit, suggest retry with delay |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `search-issues` (search with query), `pre-creation` (uses list for dedup)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`