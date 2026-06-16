---
name: executing-plans
description: "Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Every skipped step is a defect waiting for CI to find."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: executing-plans

## Overview

Thin routing layer routing plan execution to `implementation-pipeline`. Receives plan context from `approval-gate`. Every approval follows one path: executing-plans → assemble-work → work branch → one PR.

No single-issue bypass — single = work of one = one sub-agent.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
| -- | -- | -- | -- |
| "execute plan" / "run plan" / "implement plan" | `execute` | `sub-task` | {plan_issue, spec_issue} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks

| `execute` |
| `completion` |

## Invocation

`skill({name: "executing-plans"})` — call the skill, then call via task():

| Task | Call via task() |

| `execute` | `task(..., prompt: "execute execute task from executing-plans")` |
| `completion` | `task(..., prompt: "execute completion task from executing-plans")` |

**CLI equivalent (for human TUI use):** `/skill executing-plans --task <task>`

## Operating Protocol

- [ ] 1. **Requires plan_issue** in task context. HALT if absent.
- [ ] 2. **Route to implementation-pipeline** with full context.
- [ ] 3. **Track phase progress** against plan sub-issues.
- [ ] 4. **Unified path:** no single-task exemption.

## Received Context

From approval-gate: `{ plan_issue, spec_issue, authorization_scope, halt_at, pr_strategy, worktree.path, phase_progress, github.owner, github.repo }`.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")`. `execute` receives plan context + session vars. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`. No inline work.

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
| -- | -- | -- |
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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:

- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `implementation-pipeline`, `approval-gate`, `git-workflow`.

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
```
