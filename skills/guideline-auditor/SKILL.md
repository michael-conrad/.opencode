---
name: guideline-auditor
description: Use when checking guideline files for ambiguity, conflicts, or LLM compliance issues. Triggers on: audit guidelines, guideline quality, guideline conflict, ambiguous rule, LLM compliance.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Guideline Auditor

## Overview

Audits guideline files for ambiguity, conflicts, and LLM compliance. Identifies problems one at a time with concise prompts. Writes findings to `./tmp/audit-YYYYMMDD.md`.

## Task

| Task | Words |
|------|-------|
| `audit` | ≈500 |
| `completion` | ≈100 |

## Invocation

`/skill guideline-auditor --task audit`. Overview with no flag.

## Operating Protocol

1. **One issue at a time.** Present exactly one finding per interaction.
2. **Brevity:** prompts ≤200 words. Tables ≤10 rows. Quotes ≤3 lines.
3. **Problem classes:** AMBIGUOUS, CONFLICTING, UNENFORCEABLE, REDUNDANT-CROSS-FILE, MISSING, CONTEXT-OVERFLOW, REORGANIZE.
4. **Format:** `File: <path> | Rule: <1-line> | Problem: <class> | Fix? (fix/skip/stop)`.
5. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

## Sub-Agent Dispatch Audit

`audit` dispatches via `task(subagent_type="general")` with `{ file_paths, audit_scope }`. `completion` dispatches via `task(subagent_type="general")` with `{ github.owner, github.repo }`. Exclusions: implementation context, agent memory. No inline work.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: guideline-auditor-001
    title: "One issue at a time — no batching"
    conditions:
      all: ["multiple_issues_in_single_report == true"]
    actions: [SPLIT_INTO_SINGLE_ISSUES]
    source: "guideline-auditor/SKILL.md"
