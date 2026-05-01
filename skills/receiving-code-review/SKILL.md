---
name: receiving-code-review
description: Use when receiving code review feedback on a PR, or when addressing review comments. Triggers on: code review, PR feedback, review comment, address feedback, fix review, respond to review.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: receiving-code-review

## Overview

Responds to PR review feedback. Ensures all comments addressed systematically, changes are minimal, no scope creep.

## Tasks

| Task | Words |
|------|-------|
| `address` | ≈350 |
| `respond` | ≈250 |
| `completion` | ≈200 |

## Invocation

`/skill receiving-code-review --task address` (address comments), `--task respond` (reply), `--task completion`. Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ pr_number, review_comments, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: rec-review-001
    title: "Review fixes must be minimal and targeted — no scope creep"
    conditions:
      all: ["fix_includes_unrelated_changes == true"]
    actions: [REVERT_UNRELATED]
    source: "receiving-code-review/SKILL.md"
