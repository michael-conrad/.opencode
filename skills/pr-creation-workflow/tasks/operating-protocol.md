# PR Creation Workflow Operating Protocol

## Entry Criteria

- PR creation requested or authorization scope >= for_pr
- Branch exists with committed changes

## Procedure

- [ ] 1. **Explicit instruction required** unless `authorization_scope >= for_pr`.
- [ ] 2. **Base branch = target branch** for feature PRs.
- [ ] 3. **Squash verified** before PR (single commit for single-issue).
- [ ] 4. **Changelog generated** before PR.
- [ ] 5. **Adversarial-audit call:** after pre-pr-checklist, call `audit --task spec-summary --pr <N>` with `audit_phase: pr_creation`.
- [ ] 6. **No agent merge** — human-only operation.
- [ ] 7. **Work branch guard:** no individual PRs during work execution (single stacked PR).
- [ ] 8. **Submodule-bump-only PR block (MANDATORY):** Before creating any PR, check whether the diff contains changes outside `.opencode/`. In a parent repo with `.gitmodules`, a PR that only changes `.opencode/` (submodule pointer bump) is BLOCKED by enforcement gate `pr-workflow-003`. This is a CRITICAL GUIDELINE VIOLATION — bypassing this gate results in a HALT.
- [ ] 9. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.
- [ ] 10. **Release PR body format:** version summary line + changelog entries + compare link.

### Authorization Context

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

- PR authorized and created
- Changelog generated
- Audit completed
