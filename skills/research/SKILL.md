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

`/skill research --task research` (full research workflow), `--task completion`. Overview with no flag.

## ResearchResult Schema

`{ status: completed|partial|inconclusive|failed, findings: [{text, source_attribution}], gaps: [{description, modality}], model_used }`. Source attribution mandatory (REQ-11). Unavailable modalities → `(unverified)` with gap description (REQ-5).

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

`research` dispatches via `task(subagent_type="general")` with `{ query, modalities, github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

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
