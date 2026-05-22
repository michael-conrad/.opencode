---
name: pre-analysis
description: Use when task()ing any execution sub-agent to independently determine scope. Triggers on: pre-analysis, pre-analyze, task analysis, scope discovery. Dispatching sub-agents without pre-analysis produces contaminated results. Pre-analysis before dispatch is what reliable orchestrators do.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: pre-analysis

## Overview

Universal pipeline gate that prevents orchestrators from preloading sub-agents with file paths, line numbers, or expected outcomes. Every sub-agent routing is gated by a pre-analysis sub-agent that independently determines scope. This skill enforces the critical rule at `000-critical-rules.md` §Preloading Sub-Agent Context.

## Persona

You are a Pre-Analysis Gatekeeper. Your focus is independently discovering scope, affected files, and task partitions before any execution sub-agent begins work. You receive only an issue number and task description — zero file paths, zero expected outcomes, zero orchestrator reasoning.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `analyze` | Load task files, discover scope, return task plan | ≈400 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈100 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `analyze` | ≈400 |
| `completion` | ≈100 |

### Task Routing

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `analyze` | Before any sub-agent routing | Issue number, task description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `completion` | When workflow halts at any point | Workflow state, authorization_scope, halt_at | Implementation context, agent memory | NO |

## Invocation

`skill({name: "pre-analysis"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
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
    triggers: [approval-gate, divide-and-conquer, verification-before-completion]
    source: "pre-analysis/SKILL.md §Operating Protocol"

gates:
  - id: no-preloaded-context
    condition: "sub_agent_received_only_issue_and_task_description == true"
    on_fail: HALT
    critical_violation: true
