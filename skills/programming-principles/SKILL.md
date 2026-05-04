---
name: programming-principles
description: Use when designing functions, classes, or modules; writing or reviewing implementation code; making architecture decisions; or evaluating tradeoffs. Triggers on: design, implement, refactor, architecture, tradeoff, principle, KISS, DRY, SRP, coupling, cohesion, YAGNI.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: programming-principles

## Overview

20 engineering principles as single authoritative source for design judgment and enforcement. Each principle includes hard rule + judgment context (when to apply strongly, when to relax). Core ethic: intelligent judgment, not dogmatism — document tradeoffs.

## Tasks

| Task | Words |
|------|-------|
| `principles` | ≈2200 |

## Invocation

`/skill programming-principles --task principles` (full reference). Overview with no flag.

## Relationship

This skill is the master source. `080-code-standards.md` holds project-specific conventions only. Other skills reference HERE, never the reverse.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

`principles` dispatches via `task(subagent_type="general")` with `{ context, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

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
