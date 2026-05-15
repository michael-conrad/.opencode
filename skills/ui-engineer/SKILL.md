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

`skill({name: "ui-engineer"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `implement` | `task(..., prompt: "execute implement task from ui-engineer")` |
| `validate-impl` | `task(..., prompt: "execute validate-impl task from ui-engineer")` |
| `test-ui` | `task(..., prompt: "execute test-ui task from ui-engineer")` |
| `completion` | `task(..., prompt: "execute completion task from ui-engineer")` |

**CLI equivalent (for human TUI use):** `/skill ui-engineer --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ design_artifacts, framework_context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: ui-engineer-001
    title: "Must validate implementation against design artifacts"
    conditions:
      all: ["implemented == true", "validated_against_design == false"]
    actions: [HALT, TASK(validate-impl)]
    source: "ui-engineer/SKILL.md"
