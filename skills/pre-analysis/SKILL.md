---
name: pre-analysis
description: "Use when task()ing any execution sub-agent to independently determine scope, affected files, and task partitions. Also use when discovering scope boundaries before any execution sub-agent begins work. Invoke for: scope discovery, affected file analysis, task partition identification, pre-dispatch analysis, independent scope determination. Pre-analysis MUST be performed before dispatch — always required. Trigger phrases: pre-analysis, discover scope, analyze affected files, identify partitions, pre-dispatch analysis."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: pre-analysis

## Overview

Universal pipeline gate that prevents orchestrators from preloading sub-agents with file paths, line numbers, or expected outcomes. Every sub-agent routing is gated by a pre-analysis sub-agent that independently determines scope. This skill enforces the critical rule at `000-critical-rules.md` §Preloading Sub-Agent Context.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "analyze" / "pre-analysis" / "discover scope" | `analyze` | `sub-task` | {issue_number, task_description} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Invocation

`skill({name: "pre-analysis"})` — call the skill, then call via task():

| Task | Call via task() |

| `analyze` | `task(..., prompt: "execute analyze task from pre-analysis")` |
| `completion` | `task(..., prompt: "execute completion task from pre-analysis")` |

**CLI equivalent (for human TUI use):** `/skill pre-analysis --task <task>`

**⚠️ COMPLETION GUARANTEE:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting. The completion subtask is idempotent and safe to invoke multiple times.

## Operating Protocol

- [ ] 1. **Mandatory call:** The orchestrator MUST call this skill before ANY sub-agent routing
- [ ] 2. **Minimal context:** Pre-analysis sub-agents receive only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, pr_strategy, github.owner, github.repo }`
- [ ] 3. **Autonomous discovery:** Independently search the codebase to discover affected files
- [ ] 4. **Return task plan:** Return a structured plan with task partitions and file scope

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
