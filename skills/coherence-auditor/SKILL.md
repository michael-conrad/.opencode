---
name: coherence-auditor
description: Use when guidelines or skills are updated, to check consistency between rules and behavior. Triggers on: coherence, consistency, audit guidelines, skill extraction, drift detection, guideline update, skill update.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: coherence-auditor

## Overview

Ensures guidelines, skills, and AI agent behavior work together effectively. Identifies procedural workflows for extraction as skills and detects drift over time.

**Audit Phase:** `coherence` — This skill operates in the `coherence` audit phase. When dispatched, receive `audit_phase: coherence` in dispatch context.

## Tasks

| Task | Words |
|------|-------|
| `extract-scan` | ≈450 |
| `extract-analyze` | ≈380 |
| `maintenance-detect` | ≈370 |
| `maintenance-verify` | ≈310 |
| `create-report` | ≈400 |

## Invocation

`/skill coherence-auditor --mode extraction` (scan for candidates), `--mode maintenance` (detect drift), `--task <task>` (individual load). Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ mode, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: coherence-001
    title: "Skill extraction candidates require full analysis before migration"
    conditions:
      all: ["content_migrating == true", "extract_analyze_completed == false"]
    actions: [HALT, RUN_ANALYZE]
    source: "coherence-auditor/SKILL.md"
