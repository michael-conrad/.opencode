---
name: requesting-code-review
description: Use when preparing a PR for code review, or when reviewer context and documentation are needed. Triggers on: request review, code review, review request, ready for review, review preparation.
type: technique
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

`/skill requesting-code-review --task prepare` (prepare PR context), `--task request` (submit review). Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ pr_number, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

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
