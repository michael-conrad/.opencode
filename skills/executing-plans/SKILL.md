---
name: executing-plans
description: Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Triggers on: execute plan, next step, continue implementation, plan approved, start implementation.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: executing-plans

## Overview

Thin dispatch layer routing plan execution to `divide-and-conquer/assemble-work`. Receives plan context from `approval-gate`. Every approval follows one path: executing-plans → assemble-work → work branch → one PR.

No single-issue bypass — single = work of one = one sub-agent.

## Tasks

| Task | Words |
|------|-------|
| `execute` | ≈300 |
| `completion` | ≈150 |

## Invocation

`/skill executing-plans --task execute` (dispatch to assemble-work), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Requires plan_issue** in dispatch context. HALT if absent.
2. **Dispatch to divide-and-conquer/assemble-work** with full context.
3. **Track phase progress** against plan sub-issues.
4. **Unified path:** no single-task exemption.

## Received Context

From approval-gate: `{ plan_issue, spec_issue, authorization_scope, halt_at, pr_strategy, worktree.path, phase_progress, github.owner, github.repo }`.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")`. `execute` receives plan context + session vars. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|implementation_complete|review_prep|pr_created>
pr_strategy: <none|individual|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Dispatch Rules
- Missing `authorization_scope` in dispatch context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Cross-References

Skills: `divide-and-conquer`, `approval-gate`, `git-workflow`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: exec-plans-001
    title: "Plan context required before execution — HALT if absent"
    conditions:
      all: ["plan_issue_not_in_context == true"]
    actions: [HALT, REPORT(missing_plan_context)]
    source: "executing-plans/SKILL.md"
