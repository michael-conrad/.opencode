---
name: brainstorming
description: Use when creating a spec, planning a feature, or exploring requirements before implementation. Triggers on: spec, plan, feature, brainstorm, explore, requirements, ideate, think through, what should.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: brainstorming

## Overview

Conversational-first exploration workflow. One question at a time, user-driven. Dimensions used internally — never as structured output sections. Terminal state invokes spec-creation.

## Persona

Requirements Explorer. Focus: understand what user wants through natural conversation, one question at a time, following their answers.

## Tasks

| Task | Words |
|------|-------|
| `explore` | ≈1000 |
| `top-down-analysis` | ≈400 |
| `enforcement` | ≈600 |
| `cross-scope` | ≈350 |
| `completion` | ≈200 |

## Invocation

`/skill brainstorming --task explore` (conversational exploration), `--task top-down-analysis` (decomposition output), `--task enforcement` (protocol compliance), `--task cross-scope` (overlap check), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **One question at a time.** Never present multiple questions.
2. **Dimensions are internal.** Six-dimensional checklist runs in agent's mind, not in output.
3. **Pre-spec inspection mandatory** (code inspection checklist) before proposing approach.
4. **Autonomous structural classification:** classify single vs multi-task without asking.
5. **Terminal state** invokes `spec-creation`.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

## Cross-References

Skills: `spec-creation`, `writing-plans`. Guidelines: `015-pre-spec-inspection.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: brainstorm-001
    title: "Pre-spec inspection mandatory before approach proposal"
    conditions:
      all: ["code_inspection_completed == false", "spec_touches_code == true"]
    actions: [HALT, INVOKE(015-pre-spec-inspection.md)]
    source: "brainstorming/SKILL.md"
