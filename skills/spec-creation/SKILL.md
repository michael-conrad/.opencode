---
name: spec-creation
description: "Use when creating a spec or writing a specification. Spec creation is REQUIRED before implementation — professional engineers spec first."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: spec-creation

## Overview

Structured discipline for spec writing. Enforces requirements extraction, problem decomposition, interface-first thinking, constraints ledgers, risk analysis, traceability, and change control. Invoked after brainstorming exploration.

Pipeline: `brainstorming → spec-creation → adversarial-audit --task spec-audit → approval-gate → writing-plans`

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "requirements" / "extract requirements" | `requirements` | `sub-task` | {spec_context} |
| "decompose" / "decompose problem" | `decompose` | `sub-task` | {spec_context} |
| "traceability" / "trace SCs" | `traceability` | `sub-task` | {spec_context} |
| "pipeline-readiness-gate" / "readiness check" | `pipeline-readiness-gate` | `sub-task` | {spec_context} |
| "risk" / "risk analysis" | `risk` | `sub-task` | {spec_context} |
| "diagram" / "mermaid diagram" | `diagram` | `sub-task` | {spec_context} |
| "write" / "write spec" | `write` | `sub-task` | {spec_context} |
| "change-control" / "change log" | `change-control` | `sub-task` | {spec_context} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

This skill produces specs by dispatching sub-agents. The orchestrator routes; sub-agents write. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

## Tasks

| Task                      |
| ------------------------- |
| `requirements`            |
| `decompose`               |
| `traceability`            |
| `pipeline-readiness-gate` |
| `risk`                    |
| `diagram`                 |
| `write`                   |
| `change-control`          |
| `completion`              |

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

- [ ] 1. [inline] Pre-spec inspection per `015-pre-spec-inspection.md` — chain: `none`
- [ ] 2. [sub-task: requirements] `task(..., prompt: "execute requirements task from spec-creation")` — input: `./tmp/{N}/contracts/requirements-input.yaml`, output: `./tmp/{N}/contracts/requirements-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml`, chain: `none`
- [ ] 3. [sub-task: decompose] `task(..., prompt: "execute decompose task from spec-creation")` — input: `./tmp/{N}/contracts/decompose-input.yaml`, output: `./tmp/{N}/contracts/decompose-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_2`
- [ ] 4. [sub-task: traceability] `task(..., prompt: "execute traceability task from spec-creation")` — input: `./tmp/{N}/contracts/traceability-input.yaml`, output: `./tmp/{N}/contracts/traceability-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_3`
- [ ] 5. [sub-task: risk] `task(..., prompt: "execute risk task from spec-creation")` — input: `./tmp/{N}/contracts/risk-input.yaml`, output: `./tmp/{N}/contracts/risk-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4`
- [ ] 6. [inline] Invoke `solve model` for dependency-ordering constraints contract — chain: `step_5`
- [ ] 7. [inline] Invoke `solve check` to verify SAT — chain: `step_6`
- [ ] 8. [inline] Invoke `plan plan` for phase solvability validation — chain: `step_7`
- [ ] 9. [sub-task: write] `task(..., prompt: "execute write task from spec-creation")` — input: `./tmp/{N}/contracts/write-input.yaml`, output: `./tmp/{N}/contracts/write-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-input-template.yaml`, chain: `step_5, step_8`
- [ ] 10. [sub-task: completion] `task(..., prompt: "execute completion task from spec-creation")` — input: `./tmp/{N}/contracts/completion-input.yaml`, output: `./tmp/{N}/contracts/completion-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-output-template.yaml` (shared), chain: `step_9`

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_context, worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

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

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `brainstorming`, `verification-enforcement`, `issue-operations`, `adversarial-audit --task spec-audit`. References: `skill-card-change-types.md`. Guidelines: `015-pre-spec-inspection.md`, `000-critical-rules.md`.

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
