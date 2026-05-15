---
name: programming-principles
description: Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; evaluating tradeoffs, or enforcing code size limits. Triggers on: design, implement, refactor, architecture, tradeoff, principle, KISS, DRY, SRP, coupling, cohesion, YAGNI, code size, function length, file size.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as single authoritative source for design judgment and enforcement. Also includes code size limits (formerly `code-size-enforcement` skill): Python functions ≈100 words, notebook cells ≈120 words, source files ≈750 words. Grandfather policy exempts existing files; only new/modified files must comply.

## Tasks

| Task | Words |
|------|-------|
| `principles` | ≈2200 |
| `check-limits` | ≈300 |
| `decompose` | ≈400 |

## Invocation

`skill({name: "programming-principles"})` — call the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `principles` | `task(..., prompt: "execute principles task from programming-principles")` |
| `check-limits` | `task(..., prompt: "execute check-limits task from programming-principles")` |
| `decompose` | `task(..., prompt: "execute decompose task from programming-principles")` |

**CLI equivalent (for human TUI use):** `/skill programming-principles --task <task>`

## Relationship

This skill is the master source. `080-code-standards.md` holds project-specific conventions only. Other skills reference HERE, never the reverse.

## Sub-Agent Dispatch Audit

`principles` dispatches via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. `check-limits` and `decompose` with `{ file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
