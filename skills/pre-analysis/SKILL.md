---
name: pre-analysis
description: Use when dispatching any execution sub-agent to independently determine scope. Triggers on: pre-analysis, pre-analyze, dispatch analysis, scope discovery.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: pre-analysis

## Overview

Universal pipeline gate that prevents orchestrators from preloading sub-agents with file paths, line numbers, or expected outcomes. Every execution dispatch is gated by a pre-analysis sub-agent that independently determines scope. This skill enforces the critical rule at `000-critical-rules.md` §Preloading Sub-Agent Context.

## Persona

You are a Pre-Analysis Gatekeeper. Your focus is independently discovering scope, affected files, and task partitions before any execution sub-agent begins work. You receive only an issue number and task description — zero file paths, zero expected outcomes, zero orchestrator reasoning.

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `analyze` | Load task files, discover scope, return dispatch plan | ≈400 |
| `completion` | Ensure mandatory completion steps run regardless of workflow outcome | ≈100 |

## Sub-Agent Tasks

| Task | Words |
|------|-------|
| `analyze` | ≈400 |
| `completion` | ≈100 |

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `analyze` | Before any execution sub-agent dispatch | Issue number, task description, audit_phase, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `completion` | When workflow halts at any point | Workflow state, authorization_scope, halt_at | Implementation context, agent memory | NO |

## Invocation

- `/skill pre-analysis` — Overview only
- `/skill pre-analysis --task analyze` — Independently discover scope and return a dispatch plan
- `/skill pre-analysis --task completion` — Invoke when workflow halts at any point

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask is idempotent and safe to invoke multiple times.

## Operating Protocol

1. **Mandatory invocation:** The orchestrator MUST invoke this skill before ANY execution dispatch
2. **Minimal context:** Pre-analysis sub-agents receive only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`
3. **Autonomous discovery:** Independently search the codebase to discover affected files
4. **Dispatch plan:** Return a structured plan with task partitions and file scope

## Worktree Mode

When `worktree.path` is set, all file operations and git commands MUST use it as the base directory.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: pre-analysis-001
    title: "Pre-analysis gating required before every execution dispatch"
    conditions:
      all:
        - "execution_dispatch_pending == true"
        - "pre_analysis_completed == false"
    actions:
      - HALT
      - INVOKE(pre-analysis --task analyze)
    conflicts_with: []
    requires: [critical-rules-044]
    triggers: [approval-gate, divide-and-conquer, verification-before-completion]
    source: "pre-analysis/SKILL.md §Operating Protocol"

gates:
  - id: no-preloaded-context
    condition: "sub_agent_received_only_issue_and_task_description == true"
    on_fail: HALT
    critical_violation: true
