# Task: update-issue

## Purpose

Update an issue's body, labels, state, or other mutable properties. Routes to the appropriate platform sub-skill based on `github.platform`. The dispatcher resolves platform selection — no deliberation about which API to use.

**CRITICAL: Body-preservation safeguard applies.** If `github_issue_write(method=update, body=...)` is used, the body parameter MUST preserve all original content. If `len(new_body) < 0.8 * len(original_body)`, HALT — this indicates content erasure per `000-critical-rules.md`.

## Entry Criteria

- Issue number identified
- Update fields specified (body, labels, state, title, etc.)
- `github.platform` value available from session context
- Original body content preserved if updating body (body-preservation safeguard)

## Exit Criteria

- Issue updated via platform sub-skill
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`
- Body-preservation safeguard verified if body was updated

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
github_issue_write(
    method="update",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N,
    body=<preserved_body>,
    labels=["<label>"],
    state="open" | "closed"
)
```

**GitBucket platform:**
```bash
./.opencode/tools/gitbucket-api update-issue <github.owner> <github.repo> <issue-number> --body "<body>" --labels "<labels>"
```

**Local platform:**
```bash
./.opencode/tools/local-issues update <issue-number> --body "<body>" --labels "<labels>"
```

### Step 3: Verify Body Preservation

If the update includes a body change, verify:
1. `len(new_body) >= 0.8 * len(original_body)` — body erasure safeguard per `000-critical-rules.md`
2. No content sections were removed without replacement
3. Original byline is preserved (if present)

### Step 4: Return Update Result

Return the update confirmation to the calling task.

## Common Issues

| Issue | Resolution |
|-------|------------|
| Issue not found | Report "Issue #N not found" — do not guess or create |
| Body too short (erasure) | HALT — report body-preservation violation per `000-critical-rules.md` |
| Labels not updated (GitBucket) | Per `creation.md` Step 2.1 Note: GitBucket labels can ONLY be set during creation |
| Platform unknown | HALT — report `github.platform` is not set |

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
- Related tasks: `read-issue` (read before update for body preservation), `creation` (uses update for body edits)
- `body-edit` task (4-agent dispatch for complex body edits with structural verification)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`