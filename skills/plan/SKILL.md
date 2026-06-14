---
name: plan
description: "Use when generating, validating, or managing plans for phase solvability, converting between YAML and PDDL, grounding action schemas, discovering action schemas, or managing state files. Triggers on: plan plan, plan validate, plan ground, plan pddl, plan discover, plan state, PDDL, phase solvability. Agents who skip planning produce unverified phase orderings — every unplanned phase is a risk."
type: domain
license: MIT
provenance: "🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)"
compatibility: opencode
---

# Skill: plan

## Overview

Provides AI planning capabilities wrapping `unified-planning` with workflow integration. Supports problem definition in YAML, plan generation via Tamer/other engines, plan validation, PDDL conversion, action grounding, action schema discovery, and state file management.

## Persona

Planner Router. Focus: phase solvability, action schema management, PDDL conversion, state file management.

## Tasks

| Task | Purpose |
|------|---------|
| `problem` | Problem YAML schema reference |
| `plan` | Plan generation procedure |
| `validate` | Plan validation |
| `pddl` | Bidirectional YAML-PDDL conversion |
| `ground` | Action schema grounding |
| `fallback` | Manual acyclic check when planner unavailable |
| `state` | State file management |

## Sub-Agent Tasks

| `problem` | `plan` | `validate` | `pddl` | `ground` | `fallback` | `state` |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read tasks/problem.md then execute step 1" | "execute problem task from plan skill" |
| Preloaded step sequences | "Step 1: build problem YAML. Step 2: run planner." | "execute plan task from plan skill" |
| Preloaded expected outcomes | "Return { status, plan_length }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The phases are ordered so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:
- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the task context above.

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

`skill({name: "plan"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------------|
| `problem` | `task(..., prompt: "execute problem task from plan skill")` |
| `plan` | `task(..., prompt: "execute plan task from plan skill")` |
| `validate` | `task(..., prompt: "execute validate task from plan skill")` |
| `pddl` | `task(..., prompt: "execute pddl task from plan skill")` |
| `ground` | `task(..., prompt: "execute ground task from plan skill")` |
| `fallback` | `task(..., prompt: "execute fallback task from plan skill")` |
| `state` | `task(..., prompt: "execute state task from plan skill")` |

**CLI equivalent (for human TUI use):** `/skill plan --task <task>`

** Completion Guarantee:** If this workflow halts at ANY point — including error, failure, or early termination — you MUST invoke `--task completion` before halting.

## Cross-References

- `git-workflow` skill — phase order management in multi-phase plans
- `approval-gate` skill — authorization scope for plan creation
- `writing-plans` skill — writing implementation plans from approved specs
- `executing-plans` skill — executing approved plans step by step
-`.opencode/tools/plan` — CLI tool wrapping unified-planning

## Worktree Mode

When `worktree.path` is set, all file operations and tool invocations MUST use it as the base directory.

```yaml+symbolic
schema_version: "1.0"
last_updated: "2026-06-12T00:00:00Z"
rules:
  - id: plan-001
    title: "Problem YAML must be validated before planner invocation"
    conditions:
      all:
        - "plan_generation_pending == true"
        - "problem_yaml_validated == false"
    actions:
      - HALT
      - RUN(schema validation)
    conflicts_with: []
    requires: []
    triggers: []
    source: "plan/SKILL.md"
```