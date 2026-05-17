---
name: receiving-code-review
description: Use when receiving code review feedback on a PR, or when addressing review comments. Triggers on: code review, PR feedback, review comment, address feedback, fix review, respond to review. Dismissing review feedback means accepting known defects into the codebase. Every unresolved comment is a regression waiting to surface.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: receiving-code-review

## Overview

Responds to PR review feedback. Ensures all comments addressed systematically, changes are minimal, no scope creep.

## Tasks

| Task | Words |
|------|-------|
| `address` | ≈350 |
| `respond` | ≈250 |
| `completion` | ≈200 |

## Invocation

`skill({name: "receiving-code-review"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `address` | `task(..., prompt: "execute address task from receiving-code-review")` |
| `respond` | `task(..., prompt: "execute respond task from receiving-code-review")` |
| `completion` | `task(..., prompt: "execute completion task from receiving-code-review")` |

**CLI equivalent (for human TUI use):** `/skill receiving-code-review --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ pr_number, review_comments, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: rec-review-001
    title: "Review fixes must be minimal and targeted — no scope creep"
    conditions:
      all: ["fix_includes_unrelated_changes == true"]
    actions: [REVERT_UNRELATED]
    source: "receiving-code-review/SKILL.md"
