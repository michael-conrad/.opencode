# Sub-Task: pre-work/verify-auth

## Purpose

Authorization verification IS the gate between authorized and unauthorized work. Work without authorization IS unauthorized — period.

## Entry Criteria

- User has provided explicit authorization (`approved`, `go`, or `"#N approved"`)
- `authorization_scope` is known from task context
- `halt_at` is known from task context
- `pipeline_phase` is known from task context

## Procedure

### Step 1: Receive Authorization Context

This sub-task receives authorization context from the orchestration layer. The context contains:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

- Missing `authorization_scope` → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

### Step 2: Verify Authorization Scope

Confirm the authorization matches the intended work:

| Scope | Permits | Halts After |
|-------|---------|-------------|
| `for_analysis` | Read-only investigation, `investigate/*` branches | Analysis complete |
| `for_spec` | Spec creation | Spec created |
| `for_plan` | Spec + plan creation | Plan created |
| `for_implementation` | Spec + plan + code changes | Verification complete |
| `for_review_prep` | Review preparation | Review prep |
| `for_pr` | All above + PR creation | PR created |
| `for_pr_only` | PR creation (no gap-fill) | PR created |
| `for_review_only` | Code review | Code review ready |

### Step 3: Verify Label and Issue State

1. Read the authorized issue via `github_issue_read(method=get, ...)` to confirm it exists and is open
2. Read labels via `github_issue_read(method=get_labels, ...)` to confirm `approved-for-*` label matches scope
3. If multi-task spec: verify sub-issue structure via `github_issue_read(method=get_sub_issues, ...)`

### Step 4: Confirm Scope and Yield

Yield authorization context to orchestration layer:

```yaml
status: verified
authorization_scope: <scope>
halt_at: <stage>
pr_strategy: <strategy>
pipeline_phase: <phase>
issue_number: <N>
branch_name: <branch-name or null>
```

If authorization is invalid or scope is insufficient for the requested work, return `status: BLOCKED` with the reason.

## Exit Criteria

- Authorization verified: scope, halt_at, and pipeline_phase confirmed
- Issue exists, is open, and has matching `approved-for-*` label
- Authorization context yielded to orchestration layer
- If multi-task: sub-issue structure verified

## Task Context Rules

- **must_receive**: `authorization_scope`, `halt_at`, `issue_number`
- **must_not_receive**: Implementation context, file paths, expected outcomes, orchestrator reasoning

Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)