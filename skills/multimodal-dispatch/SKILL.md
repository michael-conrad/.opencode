---
name: multimodal-dispatch
description: "Use when routing AI agent tasks to appropriate models based on content modality, probing Ollama model capabilities, or dispatching sub-agents with modality-aware model selection. Modality-aware dispatch is REQUIRED for professional systems — always use the correct model for each modality."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Multimodal Dispatch

## Overview

Modality-aware sub-agent routing infrastructure. Probes Ollama model capabilities, caches capability snapshots, tasks sub-agents to best available model per content modality. Foundation for verification and research skills.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "probe" / "probe models" / "check capabilities" | `probe` | `sub-task` | {modalities} |
| "route" / "route task" / "dispatch to model" | `route` | `sub-task` | {task_description, content_modality} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Modality Router. Focus: probe models, resolve modality hints, task sub-agents to best model. Never implements directly — routes only.

## Tasks


| `probe` |
| `route` |
| `completion` |

## Invocation

`skill({name: "multimodal-dispatch"})` — call the skill, then call via task():

| Task | Call via task() |

| `probe` | `task(..., prompt: "execute probe task from multimodal-dispatch")` |
| `route` | `task(..., prompt: "execute route task from multimodal-dispatch")` |
| `completion` | `task(..., prompt: "execute completion task from multimodal-dispatch")` |

**CLI equivalent (for human TUI use):** `/skill multimodal-dispatch --task <task>`

## Capability Snapshot

Produced by `probe` task: maps model names → modalities (text, vision, audio) + capabilities. Cloud-first for text/vision. Local fallback. Graceful degradation: unavailable modality returns `(unverified)` rather than blocking.

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ task_description, content_modality, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.
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

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: multimodal-001
    title: "Cloud-first policy for text and vision modalities"
    conditions:
      all: ["modality in [text, vision]", "cloud_available == true", "local_chosen_over_cloud == true"]
    actions: [SWITCH_TO_CLOUD]
    source: "multimodal-dispatch/SKILL.md"
