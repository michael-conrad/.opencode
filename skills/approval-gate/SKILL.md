Sub-Agent Task Context Audit

All tasks run via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `screen-issue` receives issue body + authorization context + pipeline_phase. `pre-implementation-analysis` receives all issue numbers + authorization context + pipeline_phase. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }` with zero file paths. No inline work — all tasks use sub-agents. If a sub-agent returns empty, re-task with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/DONE_WITH_CONCERNS/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas.

### Authorization Context Template
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`
- The `pipeline_phase` field is NEW — it tracks which phase of a multi-phase plan is currently executing

## Cross-References

Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `divide-and-conquer`, `writing-plans`, `executing-plans`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: approval-gate-skill-001
    title: "Pre-implementation authorization verification required"
    conditions:
      all: ["spec_exists == true", "user_authorized == false"]
    actions: [HALT]
    triggers: [git-workflow]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-002
    title: "Multi-task cascade extends authorization from plan to all sub-issues"
    conditions:
      all: ["plan_has_sub_issues == true", "user_authorized == true"]
    actions: [PROCEED]
    triggers: [divide-and-conquer, executing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-005
    title: "Spec-to-plan approval cascade — spec approves existing plan"
    conditions:
      all: ["spec_approved == true", "spec_has_existing_plan == true"]
    actions: [APPLY_LABEL(approved-for-*, plan), ADD_COMMENT(cascade docs), PROCEED_TO(plan-approved run)]
    triggers: [writing-plans]
    source: "approval-gate/SKILL.md"

  - id: approval-gate-skill-006
    title: "PR merge boundary check — block if required PR not merged"
    conditions:
      all: ["plan_has_pr_boundaries == true", "required_pr_not_merged == true"]
    actions: [HALT, REPORT(CRITICAL: required PR not merged)]
    triggers: [divide-and-conquer, git-workflow]
    source: "approval-gate/SKILL.md"
