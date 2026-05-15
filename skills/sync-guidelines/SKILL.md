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

`skill({name: "sync-guidelines"})` — call the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `classify` | `task(..., prompt: "execute classify task from sync-guidelines")` |
| `sync-push` | `task(..., prompt: "execute sync-push task from sync-guidelines")` |
| `sync-pull` | `task(..., prompt: "execute sync-pull task from sync-guidelines")` |
| `issue-format` | `task(..., prompt: "execute issue-format task from sync-guidelines")` |
| `completion` | `task(..., prompt: "execute completion task from sync-guidelines")` |

**CLI equivalent (for human TUI use):** `/skill sync-guidelines --task <task>`

## Sub-Agent Dispatch Audit

Sub-agents dispatch via `task(subagent_type="general")` with `{ source_repo, target_repo, file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

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
