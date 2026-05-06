---
name: writing-plans
description: Use when creating an implementation plan from an approved spec. Triggers on: write plan, create plan, implementation plan, plan spec, approved plan, plan creation.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using hybrid structure: phases for sub-issue tracking, TDD steps within tasks for execution guidance. Every step is one action (2-5 min). No placeholders.

## Persona

Plan Author. Focus: transform spec into phased plan with file structure, TDD steps, and sub-issue hierarchy.

## Tasks

| Task | Words |
|------|-------|
| `create` | ≈600 |
| `completion` | ≈200 |

## Plan Issue Model

**Separate plan** (multi-task): spec body → linked reference → `[PLAN]` issue → phase sub-issues. **Combined spec+plan** (single-task): plan appended under `## Implementation Plan` in spec body, no sub-issues.

## Invocation

`/skill writing-plans --task create` (create plan from approved spec), `--task completion` (halt guarantee). Overview with no flag.

## Operating Protocol

1. **Plan from approved spec only.** No plan without approved spec.
2. **TDD steps mandatory:** each step is RED→GREEN→REFACTOR within tasks.
3. **No placeholders:** exact file paths, exact function/class names, exact commands.
4. **Phase structure:** phases for sub-issues, tasks within phases for TDD steps.
5. **Decision gate:** multi-task → separate plan. Single-task + simple → combined or separate per agent judgment.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")` with `{ spec_issue_number, spec_body, github.owner, github.repo }`, excluding implementation context. When dispatching auditor sub-agents, include `audit_phase` in dispatch context per SC-6. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `plan-fidelity-auditor`, `concern-separation-auditor`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: writing-plans-001
    title: "Plan creation from approved spec only"
    conditions:
      all: ["plan_creation_attempted == true", "spec_approved == false"]
    actions: [HALT]
    source: "writing-plans/SKILL.md"
