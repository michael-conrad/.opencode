---
name: ui-design
description: Use when designing UI wireframes, mockups, interaction specs, or visual artifacts. Triggers on: ui design, wireframe, mockup, interaction spec, visual layout, UI mock, screenshot capture, sidebar navigation, page layout. Designing UI without wireframes produces inconsistent interfaces. Wireframes are the spec — agents who skip them produce unpredictable layouts.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# UI Design Skill

## Overview

Produces toolkit-agnostic design artifacts (wireframes, mockups, interaction specs) consumable by any implementation skill. Framework-neutral — framework binding is the responsibility of `ui-engineer`.

## Persona

UI Design Specialist. Focus: information architecture, component relationships, navigation flow, accessibility. Produces clear, implementable design artifacts.

## Tasks

| Task | Words |
|------|-------|
| `design` | ≈800 |
| `wireframe` | ≈400 |
| `mockup` | ≈400 |
| `interaction-spec` | ≈400 |
| `completion` | ≈150 |

## Invocation

`skill({name: "ui-design"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `design` | `task(..., prompt: "execute design task from ui-design")` |
| `wireframe` | `task(..., prompt: "execute wireframe task from ui-design")` |
| `mockup` | `task(..., prompt: "execute mockup task from ui-design")` |
| `interaction-spec` | `task(..., prompt: "execute interaction-spec task from ui-design")` |
| `completion` | `task(..., prompt: "execute completion task from ui-design")` |

**CLI equivalent (for human TUI use):** `/skill ui-design --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ design_requirements, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
  - id: ui-design-001
    title: "Framework-neutral output — no framework-specific concepts"
    conditions:
      all: ["output_contains_framework_concept == true"]
    actions: [STRIP_FRAMEWORK_REFERENCES]
    source: "ui-design/SKILL.md"
