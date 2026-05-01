---
name: changelog-generator
description: Use when creating release notes, documenting changes between versions, or preparing a changelog. Triggers on: changelog, release notes, what changed, version history, commit summary, release.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: changelog-generator

## Overview

Transforms git commits into polished, user-friendly changelogs. Category-based organization into Added, Changed, Deprecated, Removed, Fixed, Security.

## Tasks

| Task | Words |
|------|-------|
| `since-last-release` | ≈170 |
| `date-range` | ≈90 |
| `backfill` | ≈120 |
| `completion` | ≈200 |

## Invocation

`/skill changelog-generator --task since-last-release` (since last update), `--task date-range --from DATE --to DATE`, `--task backfill` (historical catchup), `--task completion` (halt guarantee). Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ date_range, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: changelog-001
    title: "Must produce CHANGELOG.md before PR creation"
    conditions:
      all: ["pr_creation_pending == true", "changelog_exists == false"]
    actions: [HALT, GENERATE(changelog)]
    source: "changelog-generator/SKILL.md"
