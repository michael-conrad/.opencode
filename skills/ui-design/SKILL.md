---
name: ui-design
description: Use when designing UI wireframes, mockups, interaction specs, or visual artifacts. Triggers on: ui design, wireframe, mockup, interaction spec, visual layout, UI mock, screenshot capture, sidebar navigation, page layout.
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

`/skill ui-design --task design` (full design), `--task wireframe`, `--task mockup`, `--task interaction-spec`, `--task completion`. Overview with no flag.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ design_requirements, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

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
