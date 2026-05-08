---
name: code-size-enforcement
description: Use when writing or modifying code and function length, file size, or cell size may exceed limits. Triggers on: long function, big file, too many lines, size limit, code size, function length, cell size.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Code Size Enforcement

## Overview

Enforces code size limits: Python functions ≈100 words, notebook cells ≈120 words, source files ≈750 words. Grandfather policy exempts existing files; only new/modified files must comply.

## Tasks

| Task | Words |
|------|-------|
| `check-limits` | ≈300 |
| `decompose` | ≈400 |

## Invocation

`/skill code-size-enforcement --task check-limits` (measure before commit), `--task decompose` (decomposition guidance). Overview with no flag.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ file_paths, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, audit_phase, github.owner, github.repo }`. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: code-size-001
    title: "New/modified files must comply with size limits"
    conditions:
      all: ["file_exceeds_limit == true", "grandfathered == false"]
    actions: [HALT, DECOMPOSE]
    source: "code-size-enforcement/SKILL.md"
