---
name: ui-engineer
description: "Use when implementing UI from design artifacts, producing framework-specific code. Triggers on: implement UI, UI implementation, UI code, frontend code, Streamlit component, framework implementation, build page, create view. Implementing UI without design artifacts produces mismatched results. The design is the contract — implement to it, not past it."
type: discipline-enforcing
license: MIT
provenance: "🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)"
compatibility: opencode
---

# UI Engineer Skill

## Overview

Consumes toolkit-agnostic design artifacts from `ui-design`, translates into framework-specific implementations. Currently Streamlit.

## Persona

UI Implementation Engineer. Focus: component mapping, accessibility implementation, state management, testable UI structure.

## Tasks


| `implement` |
| `validate-impl` |
| `test-ui` |
| `completion` |

## Invocation

`skill({name: "ui-engineer"})` — call the skill, then call via task():

| Task | Call via task() |

| `implement` | `task(..., prompt: "execute implement task from ui-engineer")` |
| `validate-impl` | `task(..., prompt: "execute validate-impl task from ui-engineer")` |
| `test-ui` | `task(..., prompt: "execute test-ui task from ui-engineer")` |
| `completion` | `task(..., prompt: "execute completion task from ui-engineer")` |

**CLI equivalent (for human TUI use):** `/skill ui-engineer --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ design_artifacts, framework_context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: ui-engineer-001
    title: "Must validate implementation against design artifacts"
    conditions:
      all: ["implemented == true", "validated_against_design == false"]
    actions: [HALT, TASK(validate-impl)]
    source: "ui-engineer/SKILL.md"
