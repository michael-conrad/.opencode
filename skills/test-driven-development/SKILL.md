---
name: test-driven-development
description: Use when writing tests before implementation, or when adopting a test-first development approach. Triggers on: TDD, test first, red green refactor, write test, test-driven, unit test, regression.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: test-driven-development

## Overview

TDD workflow: tests define the contract, implementation satisfies the contract, refactoring maintains quality. Optional quality gate invoked contextually.

## Tasks

| Task | Words |
|------|-------|
| `red` | ≈200 |
| `green` | ≈150 |
| `refactor` | ≈200 |

## Invocation

`/skill test-driven-development --task red` (failing test), `--task green` (minimal impl), `--task refactor` (cleanup). Overview with no flag.

## Operating Protocol

1. **RED:** write test, verify it fails. Must produce tool-call evidence of failure.
2. **GREEN:** write minimal implementation to pass. No extras.
3. **REFACTOR:** clean up while tests stay green. No scope creep.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ spec_context, test_path, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, prior test results. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: tdd-001
    title: "RED phase must produce evidence of test failure"
    conditions:
      all: ["red_phase_started == true", "test_failure_evidence_missing == true"]
    actions: [HALT, COLLECT_EVIDENCE]
    source: "test-driven-development/SKILL.md"
