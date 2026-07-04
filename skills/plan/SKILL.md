---
name: plan
description: "Use when generating, validating, or managing plans for phase solvability, converting between YAML and PDDL, grounding action schemas, discovering action schemas, or managing state files. Also use when validating workflow constraints, verifying state against contracts, proving theorems, or checking dependency ordering. An approved spec stored as a local `spec.md` file is REQUIRED before any plan operation. Invoke for: problem definition, plan generation, plan validation, PDDL conversion, action grounding, action schema discovery, state file management, Z3 constraint solving, dependency verification. Planning is REQUIRED before implementation. — distinct from writing-plans (implementation plans from specs) and plan-creation-pipeline (6-step orchestrator). Trigger phrases: plan problem, define problem, generate plan, run planner, validate plan, check plan, convert to PDDL, convert from PDDL, ground actions, discover action schemas, manage state, solve constraints, verify dependencies, check ordering."
license: MIT
compatibility: opencode
---

# Skill: plan

## Overview

Provides AI planning capabilities wrapping `unified-planning` with workflow integration. Supports problem definition in YAML, plan generation via Tamer/other engines, plan validation, PDDL conversion, action grounding, action schema discovery, and state file management.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "plan problem" / "define problem" | `problem` | `sub-task` | {problem_context} |
| "generate plan" / "run planner" | `plan` | `sub-task` | {problem_yaml} |
| "validate plan" / "check plan" | `validate` | `sub-task` | {plan_yaml} |
| "pddl" / "convert to PDDL" / "convert from PDDL" | `pddl` | `sub-task` | {yaml_or_pddl} |
| "ground" / "ground actions" | `ground` | `sub-task` | {action_schemas} |
| "fallback" / "manual check" / "acyclic check" | `fallback` | `sub-task` | {dependency_structure} |
| "state" / "state file" / "manage state" | `state` | `sub-task` | {state_path, variable_names} |

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

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

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

**CLI equivalent (for human TUI use):** `` `skill({name: "plan"})` ``

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