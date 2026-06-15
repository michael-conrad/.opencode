---
name: brainstorming
description: "Use when creating a spec, planning a feature, or exploring requirements before implementation. Agents who implement without brainstorming build solutions to problems they do not understand."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: brainstorming

## Overview

Conversational-first exploration workflow. One question at a time, user-driven. Dimensions used internally — never as structured output sections. Terminal state invokes spec-creation.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "explore" / "brainstorm" / "discuss requirements" | `explore` | `inline` | — |
| "top-down analysis" / "decompose" | `top-down-analysis` | `sub-task` | {issue_number} |
| "enforcement" / "rule check" | `enforcement` | `sub-task` | {issue_number} |
| "cross-scope" / "scope analysis" | `cross-scope` | `sub-task` | {issue_number} |
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

**CLI equivalent (for human TUI use):** `/skill brainstorming --task <task>`

## Operating Protocol

- [ ] 1. **One question at a time.** Never present multiple questions.
- [ ] 2. **Dimensions are internal.** Six-dimensional checklist runs in agent's mind, not in output.
- [ ] 3. **Pre-spec inspection mandatory** (code inspection checklist) before proposing approach.
- [ ] 4. **Autonomous structural classification:** classify single vs multi-task without asking.
- [ ] 5. **Terminal state** invokes `spec-creation`.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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

## Ideation-Time Classification

When brainstorming specs, if a proposed change affects runtime behavior, its SCs MUST declare `behavioral` evidence type. The classification question ("Does this change affect runtime behavior?") is substrate-determined — not intent-determined. See `guidelines/000-critical-rules.md` §critical-rules-BEH-EV.

## Cross-References

Skills: `spec-creation`, `writing-plans`. Guidelines: `015-pre-spec-inspection.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: brainstorm-001
    title: "Pre-spec inspection mandatory before approach proposal"
    conditions:
      all: ["code_inspection_completed == false", "spec_touches_code == true"]
    actions: [HALT, CALL(guideline: 015-pre-spec-inspection.md)]
    source: "brainstorming/SKILL.md"
