---
name: executing-plans
description: "Read an approved plan file and dispatch each phase through the implementation pipeline in sequence, executing the plan's phases in dependency order. Reading the plan and sequencing phase dispatch is REQUIRED before any implementation work begins."
license: MIT
compatibility: opencode
provenance: AI-generated
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Skill: executing-plans

## Overview

Enables the orchestrator to execute an approved implementation plan by first reading the plan file, then dispatching each phase through the implementation pipeline in sequence. The mandatory plan-reading step guarantees that implementation follows the documented phases in dependency order rather than ad-hoc reordering.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work
     that should be delegated to a sub-agent produces defective
     deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless
     explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`,
     `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Workflows

### Read the plan
When the agent needs to begin executing an approved implementation plan and must first read the plan file to understand its phases and dependency order.

- [ ] 1. **Read the plan file** — read the approved plan and inventory its phases in dependency order
  - Prompt: `Dispatch a sub-agent with the prompt "Follow the instructions in [executing-plans/tasks/read-plan.md](.opencode/skills/executing-plans/tasks/read-plan.md). {issue_number, plan_path, project_root}"`
  - Context: `{issue_number, plan_path, project_root}`
  - Returns: `{status, finding_summary, artifact_path, blocker_reason, phase_order}`
  - Execution mode: sub-agent dispatch

- [ ] 2. **Dispatch phases in sequence** — dispatch each phase through the implementation pipeline in the plan's dependency order
  - Prompt: `Dispatch a sub-agent with the prompt "Follow instructions in [executing-plans/tasks/dispatch-phase.md](.opencode/skills/executing-plans/tasks/dispatch-phase.md). {issue_number, phase, plan_path, project_root, phase_order}"`
  - Context: `{issue_number, phase, plan_path, project_root, phase_order}`
  - Returns: `{status, finding_summary, artifact_path, blocker_reason}`
  - Execution mode: sub-agent dispatch

## Cross-References

- `writing-plans` skill — the plan-creation pipeline that produces the plan file this skill executes
- `test-driven-development` skill — the per-SC RED/GREEN/REFACTOR/COMMIT cycle that governs phase implementation
- `verification-before-completion` skill — the completion gate for each phase's deliverables
- Read [skill-card-schema.md](.opencode/reference/skill-card-schema.md) — frontmatter binary constraints
- Read [skill-card-description-standards.md](.opencode/reference/skill-card-description-standards.md) — description field semantic router

Co-authored with AI: OpenCode (deepseek-v4-flash)
