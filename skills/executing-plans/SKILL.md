---
name: executing-plans
description: "Read an approved plan file and execute its phases in dependency order, with the orchestrator executing each plan step directly in its own context and dispatching a step's task card via task() only where that step marks dispatch. Reading the plan before any implementation work begins is REQUIRED."
license: MIT
compatibility: opencode
provenance: AI-generated
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Skill: executing-plans

## Overview

Enables the orchestrator to execute an approved implementation plan by reading the plan file directly in its own context, then executing the plan's steps step-by-step in its own context in dependency order. A plan step is dispatched via `task()` ONLY where that step explicitly marks dispatch (per-step dispatch mode); the orchestrator never forwards the whole plan or a whole workflow body to a sub-agent.

## Orchestrator Plan Execution (Architecture B)

The orchestrator does NOT forward the plan or workflow to a sub-agent:

- **Read the plan in own context** — the orchestrator reads the plan file itself and inventories phases in dependency order.
- **Execute steps in own context** — the orchestrator performs each plan step directly with its own tool calls, in the plan's dependency order.
- **Dispatch only at marked points** — a step's task card goes to a sub-agent via `task()` ONLY when that step explicitly marks dispatch (per-step dispatch mode `task-card`); steps marked `direct` are executed in the orchestrator's own context.
- **Never forward whole artifacts** — the plan body, a whole phase, or a whole workflow body MUST NOT appear inside any `task()` prompt. A leaf sub-agent receiving a whole plan body rejects with `ORCHESTRATOR_ONLY_PLAN` and halts.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Workflows

### Read the plan
When the agent needs to begin executing an approved implementation plan and must first read the plan file to understand its phases and dependency order.

- [ ] 1. **Read the plan file** — the orchestrator reads the approved plan itself and inventories its phases in dependency order (**orchestrator, own context** — follow [the read-plan procedure](tasks/read-plan.md))
  - Context: `{issue_number, plan_path, project_root}`
  - Returns: `{phase_order}`
  - Execution mode: orchestrator (own context)

- [ ] 2. **Execute phases in sequence** — execute each phase's steps in the plan's dependency order, performing each step in the orchestrator's own context and dispatching a step's task card via `task()` ONLY where that step marks dispatch (**orchestrator, own context** — follow [the execute-phase procedure](tasks/execute-phase.md))
  - Context: `{issue_number, phase, plan_path, project_root, phase_order}`
  - Returns: `{status, finding_summary, artifact_path, blocker_reason}`
  - Execution mode: orchestrator (own context), with step-marked `task()` dispatches

## Cross-References

- `writing-plans` skill — the plan-creation pipeline that produces the plan file this skill executes
- `test-driven-development` skill — the per-SC RED/GREEN/REFACTOR/COMMIT cycle that governs phase implementation
- `verification-before-completion` skill — the completion gate for each phase's deliverables
- Read [skill-card-schema.md](.opencode/reference/skill-card-schema.md) — frontmatter binary constraints
- Read [skill-card-description-standards.md](.opencode/reference/skill-card-description-standards.md) — description field semantic router

Co-authored with AI: OpenCode (deepseek-v4-flash)