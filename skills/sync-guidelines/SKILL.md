---
name: sync-guidelines
description: Use when synchronizing guidelines, skills, or tools between repositories. Triggers on: sync guidelines, cross-repo sync, guideline update, skill update, multi-repo, consistency between repos.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: sync-guidelines

## Overview

Intelligently synchronizes guidelines, skills, and tools between repos via GitHub issues. Files classified by content understanding — not pattern matching — as core (syncable) vs project-specific (protected).

## Tasks

| Task | Words |
|------|-------|
| `classify` | ≈250 |
| `sync-push` | ≈300 |
| `sync-pull` | ≈300 |
| `issue-format` | ≈350 |
| `completion` | ≈200 |

## Invocation

`/skill sync-guidelines --task classify`, `--task sync-push`, `--task sync-pull`, `--task issue-format`, `--task completion`. Overview with no flag.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ source_repo, target_repo, file_paths, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: sync-001
    title: "Classify by content, not pattern matching"
    conditions:
      all: ["classification_by_pattern_only == true"]
    actions: [RE_CLASSIFY_BY_CONTENT]
    source: "sync-guidelines/SKILL.md"
