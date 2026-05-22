# Task: search-issues

## Purpose

Search issues using query syntax. Routes to the appropriate platform sub-skill based on `github.platform`. The dispatcher resolves platform selection — no deliberation about which API to use.

## Entry Criteria

- Search query identified
- `github.platform` value available from session context

## Exit Criteria

- Search results retrieved via platform sub-skill
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
github_search_issues(
    query="<search-query> repo:<github.owner>/<github.repo>",
    owner=<github.owner>,
    repo=<github.repo>
)
```

**GitBucket platform:**
```bash
./.opencode/tools/gitbucket-api search-issues <github.owner> <github.repo> "<search-query>"
```

**Local platform:**
```bash
./.opencode/tools/local-issues search --query "<search-query>"
```

### Step 3: Return Search Results

Return search results to the calling task. Used for:
- Title dedup checks in `pre-creation` Step 0.5
- Authorization scope label search
- Spec/plan overlap detection per `130-authority-source.md`

## Common Issues

| Issue | Resolution |
|-------|------------|
| No results found | Return empty list — this is valid |
| Query syntax error | HALT — report query format requirements |
| Platform unknown | HALT — report `github.platform` is not set |
| API rate limit | HALT — report rate limit, suggest retry with delay |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Session values: github.owner, github.repo, github.platform
- Related tasks: `list-issues` (list with filters), `pre-creation` (uses search for dedup)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`