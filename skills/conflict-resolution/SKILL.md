---
name: conflict-resolution
description: Use when resolving git conflicts during rebase, merge, or cherry-pick operations. Triggers on: conflict, merge conflict, rebase conflict, resolve conflict, cherry-pick conflict, conflict resolution, intent conflict, conflict classification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: conflict-resolution

## Overview

Classifies and resolves git conflicts with intent preservation. Three tiers: Tier 1 (trivial, auto-resolve), Tier 2 (textual, auto-resolve + note), Tier 3 (intent conflict, HALT for developer).

## Persona

Conflict Resolution Specialist. Focus: no committed work or spec intent silently lost during conflict resolution.

## Tasks

| Task | Words |
|------|-------|
| `classify-and-resolve` | ≈550 |
| `completion` | ≈200 |

## Invocation

Automatic from `git-workflow` when conflicts detected. Manual: `/skill conflict-resolution --task classify-and-resolve`, `--task completion`.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ conflict_files, branch_context, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: conflict-001
    title: "Tier 3 intent conflicts require developer review"
    conditions:
      all: ["conflict_tier == 3", "auto_resolved == true"]
    actions: [HALT, FLAG_FOR_DEVELOPER]
    source: "conflict-resolution/SKILL.md"
