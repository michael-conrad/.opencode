---
name: spec-creation
description: Use when creating a spec or writing a specification. Triggers on: create spec, write spec, spec creation, spec writing, structure spec, specification. Writing code without a spec is guesswork. Professional engineers spec first.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: spec-creation

## Overview

Structured discipline for spec writing. Enforces requirements extraction, problem decomposition, interface-first thinking, constraints ledgers, risk analysis, traceability, and change control. Invoked after brainstorming exploration.

Pipeline: `brainstorming → spec-creation → adversarial-audit --task spec-audit → approval-gate → writing-plans`

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

`skill({name: "spec-creation"})` — call the skill, then call via task():

| Task | Call via task() |
|------|----------|
| `requirements` | `task(..., prompt: "execute requirements task from spec-creation")` |
| `decompose` | `task(..., prompt: "execute decompose task from spec-creation")` |
| `traceability` | `task(..., prompt: "execute traceability task from spec-creation")` |
| `risk` | `task(..., prompt: "execute risk task from spec-creation")` |
| `diagram` | `task(..., prompt: "execute diagram task from spec-creation")` |
| `write` | `task(..., prompt: "execute write task from spec-creation")` |
| `completion` | `task(..., prompt: "execute completion task from spec-creation")` |

**CLI equivalent (for human TUI use):** `/skill spec-creation --task <task>`

## Operating Protocol

1. **Pre-spec inspection mandatory** per `015-pre-spec-inspection.md` (code inspection checklist).
2. **Verification-enforcement gate** before generation.
3. **Select-existing pathway:** search GitHub Issues for existing specs before creating new one.
4. **Requirements task mandatory** before write (unless trivial).
5. **Persist as GitHub Issue** via `issue-operations --task creation`.
6. **Adversarial-audit call:** after issue creation, call `adversarial-audit --task spec-audit --issue <N>` with `audit_phase: spec_creation`.
7. **PR merge boundaries** required when dependencies exist.
8. **Mermaid diagram** required for multi-phase specs (approved structure only, no workflow state).
9. **Concern enumeration guard:** enumerate single concerns before writing.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_context, worktree.path, github.owner, github.repo }`. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

## Cross-References

Skills: `brainstorming`, `verification-enforcement`, `issue-operations`, `adversarial-audit --task spec-audit`. Guidelines: `015-pre-spec-inspection.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
rules:
  - id: spec-creation-001
    title: "Pre-spec investigation mandatory before requirements"
    conditions:
      all: ["code_inspection_checklist_completed == false", "spec_touches_existing_code == true"]
    actions: [HALT, CALL(guideline: 015-pre-spec-inspection.md)]
    source: "spec-creation/SKILL.md"

  - id: spec-creation-003
    title: "Verification-enforcement gate before spec generation"
    conditions:
      all: ["verification_enforcement_verify_invoked == false"]
    actions: [CALL(verification-enforcement --task verify)]
    source: "spec-creation/SKILL.md"

  - id: spec-creation-009
    title: "Concern enumeration guard — Single Concern Principle"
    conditions:
      all: ["concern_enumeration_performed == false", "write_task_pending == true"]
    actions: [HALT, ENUMERATE_CONCERNS]
    source: "spec-creation/SKILL.md"
