---
name: multimodal-dispatch
description: Use when routing AI agent tasks to appropriate models based on content modality, probing Ollama model capabilities, or dispatching sub-agents with modality-aware model selection. Triggers on: multimodal dispatch, modality routing, capability probe, model selection, sub-agent dispatch, content modality, vision task, audio task.
type: routing
license: Apache-2.0
provenance: AI-generated
compatibility: opencode
---

# Multimodal Dispatch

## Overview

Modality-aware sub-agent routing infrastructure. Probes Ollama model capabilities, caches capability snapshots, dispatches sub-agents to best available model per content modality. Foundation for verification and research skills.

## Persona

Modality Router. Focus: probe models, resolve modality hints, dispatch sub-agents to best model. Never implements directly — routes only.

## Tasks

| Task | Words |
|------|-------|
| `probe` | ≈300 |
| `dispatch` | ≈400 |
| `completion` | ≈150 |

## Invocation

`/skill multimodal-dispatch --task probe` (capability snapshot), `--task dispatch` (route task to best model), `--task completion`. Overview with no flag.

## Capability Snapshot

Produced by `probe` task: maps model names → modalities (text, vision, audio) + capabilities. Cloud-first for text/vision. Local fallback. Graceful degradation: unavailable modality returns `(unverified)` rather than blocking.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ task_description, content_modality, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: multimodal-001
    title: "Cloud-first policy for text and vision modalities"
    conditions:
      all: ["modality in [text, vision]", "cloud_available == true", "local_chosen_over_cloud == true"]
    actions: [SWITCH_TO_CLOUD]
    source: "multimodal-dispatch/SKILL.md"
