---
name: requesting-code-review
description: Use when preparing a PR for code review, or when reviewer context and documentation are needed. Triggers on: request review, code review, review request, ready for review, review preparation.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: requesting-code-review

## Overview

Prepares and requests code reviews. Ensures PR descriptions have proper context, reviewers understand changes, requests are targeted.

## Tasks

| Task | Words |
|------|-------|
| `prepare` | ≈400 |
| `request` | ≈250 |

## Invocation

`skill({name: "requesting-code-review"})` — call the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `prepare` | `task(..., prompt: "execute prepare task from requesting-code-review")` |
| `request` | `task(..., prompt: "execute request task from requesting-code-review")` |

**CLI equivalent (for human TUI use):** `/skill requesting-code-review --task <task>`

## Sub-Agent Dispatch Audit

Sub-agents dispatch via `task(subagent_type="general")` with `{ pr_number, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: req-review-001
    title: "Review context must reference spec/plan tracking"
    conditions:
      all: ["review_context_missing_spec == true"]
    actions: [ADD_SPEC_REFERENCE]
    source: "requesting-code-review/SKILL.md"
