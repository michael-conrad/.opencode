---
name: spec-creation
description: Use when creating a spec or writing a specification. Triggers on: create spec, write spec, spec creation, spec writing, structure spec, specification.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: spec-creation

## Overview

Structured discipline for spec writing. Enforces requirements extraction, problem decomposition, interface-first thinking, constraints ledgers, risk analysis, traceability, and change control. Invoked after brainstorming exploration.

Pipeline: `brainstorming → spec-creation → spec-auditor → approval-gate → writing-plans`

## Persona

Spec Architect. Focus: structure investigation results into complete, well-organized spec with traceability, interface definitions, risk analysis, and change control.

## Tasks

| Task | Words |
|------|-------|
| `requirements` | ≈300 |
| `decompose` | ≈250 |
| `traceability` | ≈250 |
| `risk` | ≈250 |
| `diagram` | ≈200 |
| `write` | ≈300 |
| `change-control` | ≈200 |
| `completion` | ≈150 |

## Invocation

`/skill spec-creation` (full workflow), `--task requirements` (requirements only), `--task decompose`, `--task traceability`, `--task risk`, `--task diagram`, `--task write` (assemble + issue), `--task completion`. Overview with no flag.

## Operating Protocol

1. **Pre-spec inspection mandatory** per `015-pre-spec-inspection.md` (code inspection checklist).
2. **Verification-enforcement gate** before generation.
3. **Select-existing pathway:** search GitHub Issues for existing specs before creating new one.
4. **Requirements task mandatory** before write (unless trivial).
5. **Persist as GitHub Issue** via `issue-operations --task creation`.
6. **PR merge boundaries** required when dependencies exist.
7. **Mermaid diagram** required for multi-phase specs (approved structure only, no workflow state).
8. **Concern enumeration guard:** enumerate single concerns before writing.

## Sub-Agent Dispatch Audit

All tasks dispatch via `task(subagent_type="general")` with `{ spec_context, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description }`. No inline work.

## Cross-References

Skills: `brainstorming`, `verification-enforcement`, `issue-operations`, `spec-auditor`. Guidelines: `015-pre-spec-inspection.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: spec-creation-001
    title: "Pre-spec investigation mandatory before requirements"
    conditions:
      all: ["code_inspection_checklist_completed == false", "spec_touches_existing_code == true"]
    actions: [HALT, INVOKE(015-pre-spec-inspection.md)]
    source: "spec-creation/SKILL.md"

  - id: spec-creation-003
    title: "Verification-enforcement gate before spec generation"
    conditions:
      all: ["verification_enforcement_verify_invoked == false"]
    actions: [INVOKE(verification-enforcement --task verify)]
    source: "spec-creation/SKILL.md"

  - id: spec-creation-009
    title: "Concern enumeration guard — Single Concern Principle"
    conditions:
      all: ["concern_enumeration_performed == false", "write_task_pending == true"]
    actions: [HALT, ENUMERATE_CONCERNS]
    source: "spec-creation/SKILL.md"
