# Authorization Context Template

## Entry Criteria

- Authorization has been granted by the developer
- Authorization scope is known

## Procedure

Every `task()` call MUST include the authorization context block:

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules

- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- The `pipeline_phase` field tracks which phase of a multi-phase plan is currently executing

## Exit Criteria

- Authorization context block included in task context
- Routing rules verified
