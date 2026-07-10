---
name: executing-plans
description: "Use when executing an approved plan step-by-step or moving through implementation gates sequentially. Also use when dispatching each plan step to clean-room sub-agents for independent execution. Invoke for: plan execution, step-by-step implementation, gate progression, sub-agent dispatch for plan steps. Every step in the plan MUST be executed — skipping, combining, or reordering steps is not optional. Trigger phrases: execute plan, implement plan, run plan steps, progress through gates, dispatch plan step."
license: MIT
compatibility: opencode
---

# Skill: executing-plans

## Overview

Thin routing layer routing plan execution to `implementation-pipeline`. Receives plan context from `approval-gate`. Every approval follows one path: executing-plans → implementation-pipeline per the SKILL.md Trigger Dispatch Table → work branch → one PR.

No single-issue bypass — single = work of one = one sub-agent.

## Persona

Plan executor. Routes each plan step to a clean-room sub-agent that independently reads the plan and executes. An orchestrator that executes plan steps inline instead of dispatching to execution sub-agents has produced a monolithic implementation, not a step-by-step verified execution — every step carries the orchestrator's preloaded context from previous steps, and the isolation that makes each step independently verifiable is lost. Professional executors dispatch each step to a fresh sub-agent. Inlining means no step was ever independently verified.


## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "execute plan" / "run plan" / "implement plan" | `execute` | `sub-task` | {plan_issue, spec_issue} |
| "tdd cycle" / "per-item tdd" / "tdd enforcement" / "red green interleave" | `tdd-cycle-enforcement` | `sub-task` | {plan_issue, spec_issue} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Tasks


| `execute` |
| `completion` |

## Invocation

`skill({name: "executing-plans"})` — call the skill, then call via task():

| Task | Call via task() |

| `execute` | `task(..., prompt: "execute execute task from executing-plans")` |
| `completion` | `task(..., prompt: "execute completion task from executing-plans")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "executing-plans"})` ``

## Operating Protocol

See `executing-plans/tasks/operating-protocol.md` for the full operating protocol and authorization context.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")`. `execute` receives plan context + session vars. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
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


