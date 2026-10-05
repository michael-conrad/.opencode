# Enforcement: Halt Conditions

## Rule
Agent must not halt at process completion when halt_at >= verification_complete.

## Verification
Verify `halt_at` pipeline stage before halting.

## `observe/` Branch Discard Enforcement

### Pre-Halt Verification
Before halting under `for_analysis` scope, verify ALL `observe/` branches have been discarded:

```bash
git branch | grep "observe/"
```

If any `observe/` branches remain:
1. Delete each: `git branch -D observe/<topic>`
2. Re-verify: `git branch | grep "observe/"` returns empty
3. Only then proceed with halt message

### Violation
Leaving an `observe/` branch in the repo after HALT is a CRITICAL GUIDELINE VIOLATION.

## `feature/` and `spec/` Branch Scope Gate

### Blocked Under `for_analysis`
Creating `feature/*` or `spec/*` branches under `for_analysis` scope is BLOCKED. Pre-flight check:

```bash
git branch --show-current | grep -E "^(feature|spec)/"
```

If the agent detects it is on a `feature/` or `spec/` branch without `for_implementation` scope or above, it MUST HALT and report a scope boundary violation.

## Scope-Check Rules for task()

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- Git operations that exceed `halt_at` boundary (e.g., pushing when `halt_at == verification_complete`) MUST be BLOCKED

## References
- See approval-gate skill for scope model
- See git-workflow pre-work for observe/ branch rules
