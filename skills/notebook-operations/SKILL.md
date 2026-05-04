---
name: notebook-operations
description: Use when working with .ipynb Jupyter notebook files for reading, writing, or executing cells. Triggers on: notebook, ipynb, Jupyter, cell, execute cell, kernel, zero tolerance, forbidden operations.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Notebook Operations

## Overview

ZERO TOLERANCE: ALL notebook operations use `the-notebook-mcp` exclusively. Direct access via read/write/edit/sed/cat/grep/python causes corruption. If `the-notebook-mcp` unavailable, ALL notebook operations FORBIDDEN.

## Tasks

| Task | Words |
|------|-------|
| `permitted-operations` | ≈500 |
| `cell-labels` | ≈250 |
| `swap-reorder` | ≈300 |
| `production-data` | ≈350 |

## Invocation

`/skill notebook-operations --task permitted-operations` (25-operation tool reference). Overview with no flag.

## Operating Protocol

1. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ notebook_path, operation }`. Exclusions: implementation context, agent memory. No inline work. ABSOLUTE exception: `.ipynb` → `the-notebook-mcp` MANDATORY.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: notebook-001
    title: ".ipynb files require the-notebook-mcp exclusively — zero tolerance"
    conditions:
      all: ["file_extension == '.ipynb'", "using_notebook_mcp == false"]
    actions: [HALT]
    source: "notebook-operations/SKILL.md"
