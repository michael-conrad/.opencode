---
name: research
description: Use when discovering information using appropriate modalities, producing findings with source attribution and explicit gap reporting. Triggers on: research, discover, investigate, find information, multimodal research, information discovery.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Research

## Overview

Invokes `multimodal-dispatch` to discover information using best available model per modality. Produces findings with source attribution, explicit gap reporting, unverified modality tracking. Unlike verification (validates claims), research discovers new information.

## Persona

Research Agent. Focus: discover information, produce findings with source attribution, report gaps explicitly.

## Tasks

| Task | Words |
|------|-------|
| `research` | ≈400 |
| `completion` | ≈150 |

## Invocation

`skill({name: "research"})` — load the skill, then dispatch a task:

| Task | Dispatch |
|------|----------|
| `research` | `task(..., prompt: "execute research task from research")` |
| `completion` | `task(..., prompt: "execute completion task from research")` |

**CLI equivalent (for human TUI use):** `/skill research --task <task>`

## ResearchResult Schema

`{ status: completed|partial|inconclusive|failed, findings: [{text, source_attribution}], gaps: [{description, modality}], model_used }`. Source attribution mandatory (REQ-11). Unavailable modalities → `(unverified)` with gap description (REQ-5).

## Sub-Agent Dispatch Audit

`research` dispatches via `task(subagent_type="general")` with `{ query, modalities, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: research-001
    title: "Source attribution mandatory for all findings"
    conditions:
      all: ["source_attribution_missing == true"]
    actions: [REJECT_FINDING]
    source: "research/SKILL.md"
