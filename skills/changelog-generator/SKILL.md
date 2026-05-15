---
name: changelog-generator
description: Use when creating release notes, documenting changes between versions, or preparing a changelog. Triggers on: changelog, release notes, what changed, version history, commit summary, release.
type: discipline-enforcing
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

`skill({name: "changelog-generator"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `since-last-release` | `task(..., prompt: "execute since-last-release task from changelog-generator")` |
| `date-range` | `task(..., prompt: "execute date-range task from changelog-generator with --from DATE --to DATE")` |
| `backfill` | `task(..., prompt: "execute backfill task from changelog-generator")` |
| `completion` | `task(..., prompt: "execute completion task from changelog-generator")` |

**CLI equivalent (for human TUI use):** `/skill changelog-generator --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ date_range, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When routing auditor sub-agents, include `audit_phase` in task context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

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
