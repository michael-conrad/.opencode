# Executing Plans Operating Protocol

## Entry Criteria

- Plan issue exists and is in task context
- Authorization scope is known

## Procedure

- [ ] 1. **Requires plan_issue** in task context. HALT if absent.
- [ ] 2. **Route to implementation-pipeline** with full context.
- [ ] 3. **Track phase progress** against plan sub-issues.
- [ ] 4. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Exit Criteria

- Plan routed to implementation-pipeline
- Phase progress tracked
- Authorization context verified
