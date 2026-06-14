---
name: pre-analysis
description: "Use when task()ing any execution sub-agent to independently determine scope. Triggers on: pre-analysis, pre-analyze, task analysis, scope discovery. Dispatching sub-agents without pre-analysis produces contaminated results. Pre-analysis before dispatch is what reliable orchestrators do."
type: discipline-enforcing
license: MIT
provenance: "🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)"
compatibility: opencode
---

# Skill: pre-analysis

## Overview

Universal pipeline gate that prevents orchestrators from preloading sub-agents with file paths, line numbers, or expected outcomes. Every sub-agent routing is gated by a pre-analysis sub-agent that independently determines scope. This skill enforces the critical rule at `000-critical-rules.md` §Preloading Sub-Agent Context.

## Persona

You are a Pre-Analysis Gatekeeper. Your focus is independently discovering scope, affected files, and task partitions before any execution sub-agent begins work. You receive only an issue number and task description — zero file paths, zero expected outcomes, zero orchestrator reasoning.

## Tasks

| Task | Purpose |
|------|---------|
| `analyze` | Load task files, discover scope, return task plan |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome |

## Sub-Agent Tasks


| `analyze` |
| `completion` |

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `analyze` | Before any sub-agent routing | Issue number, task description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `completion` | When workflow halts at any point | Workflow state, authorization_scope, halt_at | Implementation context, agent memory | NO |

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

## Invocation

`skill({name: "pre-analysis"})` — call the skill, then call via task():

| Task | Call via task() |

| `analyze` | `task(..., prompt: "execute analyze task from pre-analysis")` |
| `completion` | `task(..., prompt: "execute completion task from pre-analysis")` |

**CLI equivalent (for human TUI use):** `/skill pre-analysis --task <task>`

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask is idempotent and safe to invoke multiple times.

## Operating Protocol

1. **Mandatory call:** The orchestrator MUST call this skill before ANY sub-agent routing
2. **Minimal context:** Pre-analysis sub-agents receive only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`
3. **Autonomous discovery:** Independently search the codebase to discover affected files
4. **Return task plan:** Return a structured plan with task partitions and file scope

## Worktree Mode

When `worktree.path` is set, all file operations and git commands MUST use it as the base directory.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: pre-analysis-001
    title: "Pre-analysis gating required before every sub-agent routing"
    conditions:
      all:
        - "execution_routing_pending == true"
        - "pre_analysis_completed == false"
    actions:
      - HALT
      - CALL(pre-analysis --task analyze)
    conflicts_with: []
    requires: [critical-rules-044]
    triggers: [approval-gate, implementation-pipeline, verification-before-completion]
    source: "pre-analysis/SKILL.md §Operating Protocol"

gates:
  - id: no-preloaded-context
    condition: "sub_agent_received_only_issue_and_task_description == true"
    on_fail: HALT
    critical_violation: true
