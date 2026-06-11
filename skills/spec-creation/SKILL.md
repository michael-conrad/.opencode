______________________________________________________________________

## name: spec-creation description: "Use when creating a spec or writing a specification. Triggers on: create spec, write spec, spec creation, spec writing, structure spec, specification. Writing code without a spec is guesswork. Professional engineers spec first." type: discipline-enforcing license: MIT provenance: AI-generated compatibility: opencode

# Skill: spec-creation

## Overview

Structured discipline for spec writing. Enforces requirements extraction, problem decomposition, interface-first thinking, constraints ledgers, risk analysis, traceability, and change control. Invoked after brainstorming exploration.

Pipeline: `brainstorming → spec-creation → adversarial-audit --task spec-audit → approval-gate → writing-plans`

## Persona

Spec Architect. Focus: structure investigation results into complete, well-organized spec with traceability, interface definitions, risk analysis, and change control.

## Tasks

| Task                      | Words |
| ------------------------- | ----- |
| `requirements`            | ≈300  |
| `decompose`               | ≈250  |
| `traceability`            | ≈250  |
| `pipeline-readiness-gate` | ≈250  |
| `risk`                    | ≈250  |
| `diagram`                 | ≈200  |
| `write`                   | ≈300  |
| `change-control`          | ≈200  |
| `completion`              | ≈150  |

## Invocation

`skill({name: "spec-creation"})` — call the skill, then call via task():

| Task                      | Call via task()                                                                |
| ------------------------- | ------------------------------------------------------------------------------ |
| `requirements`            | `task(..., prompt: "execute requirements task from spec-creation")`            |
| `decompose`               | `task(..., prompt: "execute decompose task from spec-creation")`               |
| `traceability`            | `task(..., prompt: "execute traceability task from spec-creation")`            |
| `pipeline-readiness-gate` | `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")` |
| `risk`                    | `task(..., prompt: "execute risk task from spec-creation")`                    |
| `diagram`                 | `task(..., prompt: "execute diagram task from spec-creation")`                 |
| `write`                   | `task(..., prompt: "execute write task from spec-creation")`                   |
| `completion`              | `task(..., prompt: "execute completion task from spec-creation")`              |

**CLI equivalent (for human TUI use):** `/skill spec-creation --task <task>`

## Operating Protocol

1. **Pre-spec inspection mandatory** per `015-pre-spec-inspection.md` (code inspection checklist).
1. **Verification-enforcement gate** before generation.
1. **Select-existing pathway:** search GitHub Issues for existing specs before creating new one.
1. **Requirements task mandatory** before write (unless trivial).
1. **Persist as GitHub Issue** via `issue-operations --task creation`.
1. **Adversarial-audit call:** after issue creation, call `adversarial-audit --task spec-audit --issue <N>` with `audit_phase: spec_creation`.
1. **PR merge boundaries** required when dependencies exist.
1. **Mermaid diagram** required for multi-phase specs (approved structure only, no workflow state).
1. **Concern enumeration guard:** enumerate single concerns before writing.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_context, worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation                        | Forbidden Pattern                                    | Correct Pattern                              |
| -------------------------------- | ---------------------------------------------------- | -------------------------------------------- |
| Preloaded file paths             | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow"     |
| Preloaded step sequences         | "Step 1: sync dev. Step 2: delete branch."           | "execute cleanup task from git-workflow"     |
| Preloaded expected outcomes      | "Return { cleanup_status, branch_deleted }"          | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..."      | Pure objective, no narrative                 |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):

- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:

- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

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

  - id: spec-creation-pipeline-readiness
    title: "Pipeline-readiness gate required before spec finalization"
    conditions:
      all:
        - "spec_sc_finalized == true"
        - "pipeline_readiness_gate_passed == false"
    actions: [HALT, CALL(spec-creation --task pipeline-readiness-gate)]
    source: "spec-creation/SKILL.md"
```
