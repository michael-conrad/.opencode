---
name: plan-fidelity-auditor
description: Use when auditing a plan for fidelity against a spec. Triggers on: plan fidelity, plan audit, spec vs plan, discrepancy, clean-room plan.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: plan-fidelity-auditor

## Overview

Generates clean-room plan from spec's problem statement, compares against existing plan to identify discrepancies. Report-only — no auto-fixes. Now invoked via spec-auditor orchestrator as `fidelity` subtask.

## Tasks

| Task | Words |
|------|-------|
| `audit` | ≈600 |
| `compare` | ≈500 |
| `report` | ≈300 |
| `sub-issue-fidelity` | ≈350 |

## Invocation

`/skill plan-fidelity-auditor --task audit` (full workflow), `--task compare` (clean-room comparison), `--task report` (findings), `--task sub-issue-fidelity`. Overview with no flag.

## Operating Protocol

1. **Clean-room isolation:** input must NOT contain existing plan details.
2. **Report-only:** findings reported to orchestrator, no auto-fixes.
3. **Prose-driven clean-room:** uses prose exploration, not template structure.
4. **Significant gaps** → recommend brainstorming for deeper exploration.
5. **Invoked via spec-auditor orchestrator** as `fidelity` subtask, not called directly.

## Sub-Agent Dispatch Audit

Tasks dispatch via `task(subagent_type="general")` with `{ spec_issue, plan_issue, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `spec-auditor`, `writing-plans`, `brainstorming`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: plan-fidelity-001
    title: "Clean-room input must not contain existing plan details"
    conditions:
      all: ["clean_room_input_leaks_plan == true"]
    actions: [REGENERATE_INPUT]
    source: "plan-fidelity-auditor/SKILL.md"
