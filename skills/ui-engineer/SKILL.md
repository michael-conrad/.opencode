---
name: ui-engineer
description: Use when implementing UI from design artifacts, producing framework-specific code. Triggers on: implement UI, UI implementation, UI code, frontend code, Streamlit component, framework implementation, build page, create view.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# UI Engineer Skill

## Overview

Consumes toolkit-agnostic design artifacts from `ui-design`, translates into framework-specific implementations. Currently Streamlit.

## Persona

UI Implementation Engineer. Focus: component mapping, accessibility implementation, state management, testable UI structure.

## Tasks

| Task | Words |
|------|-------|
| `implement` | ≈800 |
| `validate-impl` | ≈400 |
| `test-ui` | ≈400 |
| `completion` | ≈150 |

## Invocation

`/skill ui-engineer --task implement` (full implementation), `--task validate-impl` (design compliance), `--task test-ui` (test specs), `--task completion`. Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ design_artifacts, framework_context, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: ui-engineer-001
    title: "Must validate implementation against design artifacts"
    conditions:
      all: ["implemented == true", "validated_against_design == false"]
    actions: [HALT, INVOKE(validate-impl)]
    source: "ui-engineer/SKILL.md"
