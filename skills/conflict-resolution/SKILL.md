---
name: conflict-resolution
description: Use when resolving git conflicts during rebase, merge, or cherry-pick operations. Triggers on: conflict, merge conflict, rebase conflict, resolve conflict, cherry-pick conflict, conflict resolution, intent conflict, conflict classification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: conflict-resolution

## Overview

Classifies and resolves git conflicts with intent preservation. Three tiers: Tier 1 (trivial, auto-resolve), Tier 2 (textual, auto-resolve + note), Tier 3 (intent conflict, HALT for developer).

## Persona

Conflict Resolution Specialist. Focus: no committed work or spec intent silently lost during conflict resolution.

## Tasks

| Task | Words |
|------|-------|
| `classify-and-resolve` | ≈550 |
| `completion` | ≈200 |

## Invocation

Automatic from `git-workflow` when conflicts detected. Manual dispatch:

`skill({name: "conflict-resolution"})` — load the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `classify-and-resolve` | `task(..., prompt: "execute classify-and-resolve task from conflict-resolution")` |
| `completion` | `task(..., prompt: "execute completion task from conflict-resolution")` |

**CLI equivalent (for human TUI use):** `/skill conflict-resolution --task <task>`

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ conflict_files, branch_context, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: conflict-001
    title: "Tier 3 intent conflicts require developer review"
    conditions:
      all: ["conflict_tier == 3", "auto_resolved == true"]
    actions: [HALT, FLAG_FOR_DEVELOPER]
    source: "conflict-resolution/SKILL.md"
