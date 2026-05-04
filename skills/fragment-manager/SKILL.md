---
name: fragment-manager
description: Use when managing duplicate content blocks (fragments) across guidelines or skills. Triggers on: fragment, duplicate content, sync content, content block, shared content, master copy, synchronize.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: fragment-manager

## Overview

Manages duplicate text blocks across skills. CRUD on master files (`.opencode/.guidelines/`), sync masters to copies, drift detection, conflict resolution when changes diverge.

## Registry

`.opencode/.guidelines/registry.yaml` — tracks fragment masters and destinations. Masters in `.opencode/.guidelines/*.md`. Copies embedded in `.opencode/skills/*/SKILL.md`.

## Tasks

| Task | Words |
|------|-------|
| `create` | ≈250 |
| `sync` | ≈300 |
| `detect-drift` | ≈250 |
| `completion` | ≈150 |

## Invocation

`/skill fragment-manager --task create`, `--task sync`, `--task detect-drift`, `--task completion`. Overview with no flag.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ fragment_name, destination_paths, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: fragment-001
    title: "Master copy is single source of truth — never edit copies directly"
    conditions:
      all: ["destination_copy_edited == true", "master_updated == false"]
    actions: [REVERT, EDIT_MASTER_FIRST]
    source: "fragment-manager/SKILL.md"
