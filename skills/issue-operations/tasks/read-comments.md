# Task: read-comments

## Purpose

Read all comments for an issue. Routes to the appropriate platform sub-skill based on `github.platform`. The dispatcher resolves platform selection — no deliberation about which API to use.

## Entry Criteria

- Issue number identified
- `github.platform` value available from session context

## Exit Criteria

- All comments retrieved via platform sub-skill
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
    method="get_comments",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N
)
```

**GitBucket platform:**
```bash
./.opencode/tools/gitbucket-api get-comments <github.owner> <github.repo> <issue-number>
```

**Local platform:**
```bash
./.opencode/tools/local-issues read-comments <issue-number>
```

### Step 3: Return Comment Data

Return all comments to the calling task. Per `067-context-completeness.md`, ALL comments must be read before acting on any resource — this task provides the complete comment set.

## Context Completeness Requirement

This task exists because `067-context-completeness.md` mandates reading ALL comments before acting on an issue. The calling task must NOT proceed without the full comment set from this task.

## Common Issues

| Issue | Resolution |
|-------|------------|
| Issue not found | Report "Issue #N not found" — do not guess |
| No comments | Return empty list — this is valid, not an error |
| Platform unknown | HALT — report `github.platform` is not set |
| API error | HALT — report the error, do not retry silently |

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
- Related tasks: `read-issue` (reads issue body), `read-labels` (reads labels)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`