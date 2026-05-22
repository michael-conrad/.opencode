---
name: ui-design
description: Use when designing UI wireframes, mockups, interaction specs, or visual artifacts. Triggers on: ui design, wireframe, mockup, interaction spec, visual layout, UI mock, screenshot capture, sidebar navigation, page layout. Designing UI without wireframes produces inconsistent interfaces. Wireframes are the spec — agents who skip them produce unpredictable layouts.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# UI Design Skill

## Overview

Produces toolkit-agnostic design artifacts (wireframes, mockups, interaction specs) consumable by any implementation skill. Framework-neutral — framework binding is the responsibility of `ui-engineer`.

## Persona

UI Design Specialist. Focus: information architecture, component relationships, navigation flow, accessibility. Produces clear, implementable design artifacts.

## Tasks

| Task | Words |
|------|-------|
| `design` | ≈800 |
| `wireframe` | ≈400 |
| `mockup` | ≈400 |
| `interaction-spec` | ≈400 |
| `completion` | ≈150 |

## Invocation

`skill({name: "ui-design"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `design` | `task(..., prompt: "execute design task from ui-design")` |
| `wireframe` | `task(..., prompt: "execute wireframe task from ui-design")` |
| `mockup` | `task(..., prompt: "execute mockup task from ui-design")` |
| `interaction-spec` | `task(..., prompt: "execute interaction-spec task from ui-design")` |
| `completion` | `task(..., prompt: "execute completion task from ui-design")` |

**CLI equivalent (for human TUI use):** `/skill ui-design --task <task>`

## Sub-Agent Routing

Sub-agents run via `task(subagent_type="general")` with `{ design_requirements, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: ui-design-001
    title: "Framework-neutral output — no framework-specific concepts"
    conditions:
      all: ["output_contains_framework_concept == true"]
    actions: [STRIP_FRAMEWORK_REFERENCES]
    source: "ui-design/SKILL.md"
