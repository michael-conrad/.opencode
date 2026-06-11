---
name: conflict-resolution
description: Use when resolving git conflicts during rebase, merge, or cherry-pick operations. Triggers on: conflict, merge conflict, rebase conflict, resolve conflict, cherry-pick conflict, conflict resolution, intent conflict, conflict classification. Resolving conflicts blindly produces broken merges. Intent analysis before resolution separates correct merges from silent corruption.
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


| `classify-and-resolve` |
| `completion` |

## Invocation

Automatic from `git-workflow` when conflicts detected. Manual invocation:

`skill({name: "conflict-resolution"})` — call the skill, then call via task():

| Task | Call via task() |

| `classify-and-resolve` | `task(..., prompt: "execute classify-and-resolve task from conflict-resolution")` |
| `completion` | `task(..., prompt: "execute completion task from conflict-resolution")` |

**CLI equivalent (for human TUI use):** `/skill conflict-resolution --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ conflict_files, branch_context, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pr_strategy, pipeline_phase }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

### Authorization Context
```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

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
