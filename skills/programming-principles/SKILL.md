---
name: programming-principles
description: "Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; evaluating tradeoffs, or enforcing code size limits. Every violated principle is technical debt incurred, not saved."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as single authoritative source for design judgment and enforcement. Also includes code size limits (formerly `code-size-enforcement` skill): Python functions ≈100 words, notebook cells ≈120 words, source files ≈750 words. Grandfather policy exempts existing files; only new/modified files must comply.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "principles" / "check principles" / "design review" | `principles` | `sub-task` | {context} |
| "check-limits" / "size check" / "word count" | `check-limits` | `sub-task` | {file_paths} |
| "decompose" / "split function" / "refactor" | `decompose` | `sub-task` | {file_paths} |

## Tasks


| `principles` |
| `check-limits` |
| `decompose` |

## Invocation

`skill({name: "programming-principles"})` — call the skill, then call via task():

| Task | Call via task() |

| `principles` | `task(..., prompt: "execute principles task from programming-principles")` |
| `check-limits` | `task(..., prompt: "execute check-limits task from programming-principles")` |
| `decompose` | `task(..., prompt: "execute decompose task from programming-principles")` |

**CLI equivalent (for human TUI use):** `/skill programming-principles --task <task>`

## Relationship

This skill is the master source. `080-code-standards.md` holds project-specific conventions only. Other skills reference HERE, never the reverse.

## Sub-Agent Routing

`principles` runs via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. `check-limits` and `decompose` with `{ file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
  - id: principles-001
    title: "Single authoritative source — no principle drift across files"
    conditions:
      all: ["principle_defined_elsewhere == true"]
    actions: [REMOVE_FROM_OTHER_FILE, REFERENCE_HERE]
    source: "programming-principles/SKILL.md"

  - id: code-size-001
    title: "New/modified files must comply with size limits"
    conditions:
      all: ["file_exceeds_limit == true", "grandfathered == false"]
    actions: [HALT, DECOMPOSE]
    source: "programming-principles/SKILL.md (merged from code-size-enforcement)"
```
