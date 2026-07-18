---
name: brainstorming
description: "Requirements exploration and problem decomposition. Load via skill() when creating a spec, planning a feature, or exploring requirements before implementation. Also load when decomposing a problem into success criteria, extracting requirements, or documenting change control. Brainstorming is REQUIRED before spec creation — it is not optional. User phrases: brainstorm, explore requirements, decompose problem, extract requirements, create spec"
license: MIT
compatibility: opencode
---

# Skill: brainstorming

## Overview

Conversational-first exploration workflow. One question at a time, user-driven. Dimensions used internally — never as structured output sections. Terminal state invokes spec-creation.

Brainstorming now produces preliminary analytical artifacts before handing off to spec-creation. These preliminary artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment) are raw investigation outputs that spec-creation formalizes. Handoff to spec-creation is blocked until all required preliminary artifacts are present.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **Preliminary analytical artifact production required before spec-creation handoff.** Artifact requirements are conditional: blast-radius always required; concern-map required for multi-concern specs; code-path-inventory required when spec touches existing code; cross-cutting-matrix required for multi-concern specs; interface-compatibility required when spec modifies public APIs; state-analysis required when spec modifies stateful components; testability-assessment required when spec has behavioral SCs.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "explore" / "brainstorm" / "discuss requirements" | `explore` | `inline` | — |
| "top-down analysis" / "decompose" | `top-down-analysis` | `sub-task` | {issue_number} |
| "enforcement" / "rule check" | `enforcement` | `sub-task` | {issue_number} |
| "cross-scope" / "scope analysis" | `cross-scope` | `sub-task` | {issue_number} |
| "analytical artifacts needed" | `explore` | `inline` | — |
| "blast-radius analysis needed" | `top-down-analysis` | `sub-task` | {issue_number} |
| "concern-map needed" | `cross-scope` | `sub-task` | {issue_number} |
| "code-path-inventory needed" | `top-down-analysis` | `sub-task` | {issue_number} |
| "cross-cutting-matrix needed" | `cross-scope` | `sub-task` | {issue_number} |
| "interface-compatibility needed" | `top-down-analysis` | `sub-task` | {issue_number} |
| "state-analysis needed" | `top-down-analysis` | `sub-task` | {issue_number} |
| "testability-assessment needed" | `top-down-analysis` | `sub-task` | {issue_number} |
| "all analytical artifacts present" | `completion` | `sub-task` | {workflow_state} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Requirements Explorer. Focus: understand what user wants through natural conversation, one question at a time, following their answers.

## Tasks


| `explore` |
| `top-down-analysis` |
| `enforcement` |
| `cross-scope` |
| `completion` |

## Invocation

`skill({name: "brainstorming"})` — call the skill, then call via task():

| Task | Call via task() |

| `explore` | `task(..., prompt: "execute explore task from brainstorming")` |
| `top-down-analysis` | `task(..., prompt: "execute top-down-analysis task from brainstorming")` |
| `enforcement` | `task(..., prompt: "execute enforcement task from brainstorming")` |
| `cross-scope` | `task(..., prompt: "execute cross-scope task from brainstorming")` |
| `completion` | `task(..., prompt: "execute completion task from brainstorming")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "brainstorming"})` ``

## Operating Protocol

Load [the full operating protocol](skills/brainstorming/tasks/operating-protocol.md).

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. Load [audit SKILL.md §DISPATCH_GATE](skills/audit/SKILL.md). `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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
| Missing task file discovery directive | "execute explore task from brainstorming" without task file path | "execute explore task from brainstorming. Read `brainstorming/tasks/explore.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

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

## Ideation-Time Classification

When brainstorming specs, if a proposed change affects runtime behavior, its SCs MUST declare `behavioral` evidence type. The classification question ("Does this change affect runtime behavior?") is substrate-determined — not intent-determined. Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md).

## Cross-References

Skills: `spec-creation`, `writing-plans`. Guidelines: `015-pre-spec-inspection.md`.


