# Task: read-labels

## Purpose

Read labels for an issue. Reads from local `{issues_prefix}/{N}/issue.yaml` by default as the canonical source. Remote API read is used only when explicitly requested. Labels are used for authorization scope verification per `010-approval-gate.md`.

## Entry Criteria

- Issue number identified
- `{issues_prefix}/{N}/issue.yaml` exists (or remote read explicitly requested)

## Exit Criteria

- Labels retrieved from local `issue.yaml` by default
- Remote API read performed only when explicitly requested
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Procedure

### Step 1: Read Labels from Local `issue.yaml` (Default)

Read labels from the local canonical source by default:

```bash
./.opencode/tools/local-issues read-labels --number <N>
```

Extract the `labels` array from the returned YAML. This is the default and primary source for authorization labels.

### Step 2: Remote Read Only When Explicitly Requested

Remote API read is performed ONLY when the calling task explicitly requests it. Do not read from the remote API by default. When explicitly requested, route based on `github.platform`:

| `github.platform` | Route to |
|---|---|
| `github` | `platforms/github-mcp/` sub-skill |
| `gitbucket` | `platforms/gitbucket-api/` sub-skill |
| `local` | `platforms/local/` sub-skill |

**GitHub platform:**
```python
github_issue_read(
    method="get_labels",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N
)
```

**GitBucket platform:**
```bash
./.opencode/tools/gitbucket-api get-labels <github.owner> <github.repo> <issue-number>
```

**Local platform:**
Route to `platforms/local/tasks/read.md`. Pass: `{issue_number: N}`. Extract labels from returned issue data.

### Step 3: Return Label Data

Return label data to the calling task. Labels are used for authorization scope verification per `010-approval-gate.md`.

## Common Issues

| Issue | Resolution |
|-------|------------|
| Local `issue.yaml` missing | HALT — report `MISSING_LOCAL_ISSUE`; auth state is unknown |
| No labels | Return empty list — this is valid (equivalent to `needs-approval`) |
| Remote read requested but platform unknown | HALT — report `github.platform` is not set |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Context Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Session values: github.owner, github.repo, github.platform
- `{issues_prefix}/{N}/issue.yaml` — canonical local label source
- Related tasks: `read-issue` (reads issue body), `read-comments` (reads comments)
- Platform routing (remote read only when explicitly requested): `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`