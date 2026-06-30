---
name: research
description: "Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. All findings MUST be verified against live sources."
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Research

## Overview

Invokes `multimodal-dispatch` to discover information using best available model per modality. Produces findings with source attribution, explicit gap reporting, unverified modality tracking. Unlike verification (validates claims), research discovers new information.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "research" / "investigate" / "find information" | `research` | `sub-task` | {query, modalities} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

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
