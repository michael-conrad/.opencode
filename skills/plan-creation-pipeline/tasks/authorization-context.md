# Plan Creation Pipeline Authorization Context

## Entry Criteria

- Authorization has been granted
- Plan creation is in progress

## Procedure

Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

## Exit Criteria

- Authorization context included in all task dispatches
