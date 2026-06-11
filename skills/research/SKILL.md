---
name: research
description: Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. Triggers on: research, discover, investigate, find information, multimodal research, information discovery. Research without tool calls produces memory guesses. Every unverified finding is a liability, not evidence.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Research

## Overview

Invokes `multimodal-dispatch` to discover information using best available model per modality. Produces findings with source attribution, explicit gap reporting, unverified modality tracking. Unlike verification (validates claims), research discovers new information.

## Persona

Research Agent. Focus: discover information, produce findings with source attribution, report gaps explicitly.

## Tasks


| `research` |
| `completion` |

## Invocation

`skill({name: "research"})` — call the skill, then call via task():

| Task | Call via task() |

| `research` | `task(..., prompt: "execute research task from research")` |
| `completion` | `task(..., prompt: "execute completion task from research")` |

**CLI equivalent (for human TUI use):** `/skill research --task <task>`

## ResearchResult Schema

`{ status: completed|partial|inconclusive|failed, findings: [{text, source_attribution}], gaps: [{description, modality}], model_used }`. Source attribution mandatory (REQ-11). Unavailable modalities → `(unverified)` with gap description (REQ-5).

## Sub-Agent Routing

`research` runs via `task(subagent_type="general")` with `{ query, modalities, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
  - id: research-001
    title: "Source attribution mandatory for all findings"
    conditions:
      all: ["source_attribution_missing == true"]
    actions: [REJECT_FINDING]
    source: "research/SKILL.md"
