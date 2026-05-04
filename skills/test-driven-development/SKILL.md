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
4. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ spec_context, test_path, github.owner, github.repo }`. Exclusions: implementation context, agent memory, prior test results. No inline work.

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
