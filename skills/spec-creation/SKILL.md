---
name: spec-creation
description: "Use when creating a spec, writing a specification, drafting requirements, authoring a spec document, or specifying a feature. Also use when decomposing a problem into success criteria, extracting requirements, or documenting change control. Invoke for: spec writing, specification creation, requirements documentation, feature specification, problem decomposition, success criteria definition, change control documentation, spec drafting, requirements extraction. Spec creation is REQUIRED before implementation. Trigger phrases: write spec, create spec, draft spec, write specification, create specification, draft specification, spec out, author spec, document requirements, specify feature, write requirements, create requirements doc, decompose problem, define success criteria, extract requirements, document change control."
type: discipline-enforcing
license: MIT
provenance: AI-generated
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
| "write spec" / "create spec" / "draft spec" / "write specification" / "create specification" / "draft specification" / "spec out" / "author spec" / "document requirements" / "specify feature" / "write requirements" / "create requirements doc" | `create` | `sub-task` | {spec_context} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

This skill produces specs by dispatching sub-agents. The orchestrator routes; sub-agents write. An orchestrator that writes a spec inline instead of dispatching to a sub-agent has stopped being a router and started being a contaminant — every inline-written spec carries the orchestrator's preloaded bias through every downstream verification gate, and the pipeline is poisoned from the first byte. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining the write task means the spec was never independently produced — it was authored by the same context that will later verify it, making every subsequent gate a self-review.

## Tasks

| Task                      |
| ------------------------- |
| `create`                  |
| `pipeline-readiness-gate` |
| `completion`              |

## Invocation

`skill({name: "spec-creation"})` — call the skill, then call via task().

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.

| Task                      | Call via task()                                                                  |
| ------------------------- | -------------------------------------------------------------------------------- |
| `create`                  | `task(..., prompt: "execute create task from spec-creation")`                    |
| `pipeline-readiness-gate` | `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")`    |
| `completion`              | `task(..., prompt: "execute completion task from spec-creation")`                |

**CLI equivalent (for human TUI use):** `/skill spec-creation --task <task>`

## Operating Protocol

- [ ] 1. [inline] Pre-spec inspection per `015-pre-spec-inspection.md` — chain: `none`
- [ ] 2. [sub-task: requirements] `task(..., prompt: "execute requirements task from spec-creation")` — input: `./tmp/{N}/contracts/requirements-input.yaml`, output: `./tmp/{N}/contracts/requirements-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml`, chain: `none`
- [ ] 3. [sub-task: decompose] `task(..., prompt: "execute decompose task from spec-creation")` — input: `./tmp/{N}/contracts/decompose-input.yaml`, output: `./tmp/{N}/contracts/decompose-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_2`
- [ ] 4. [sub-task: traceability] `task(..., prompt: "execute traceability task from spec-creation")` — input: `./tmp/{N}/contracts/traceability-input.yaml`, output: `./tmp/{N}/contracts/traceability-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_3`
- [ ] 4.5. [sub-task: pipeline-readiness-gate] `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")` — input: `./tmp/{N}/contracts/pipeline-readiness-input.yaml`, output: `./tmp/{N}/contracts/pipeline-readiness-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4`
- [ ] 6. [sub-task: risk] `task(..., prompt: "execute risk task from spec-creation")` — input: `./tmp/{N}/contracts/risk-input.yaml`, output: `./tmp/{N}/contracts/risk-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4.5`
- [ ] 7. [inline] Invoke `solve model` for dependency-ordering constraints contract — chain: `step_6`
- [ ] 8. [inline] Invoke `solve check` to verify SAT — chain: `step_7`
- [ ] 9. [inline] Invoke `plan plan` for phase solvability validation — chain: `step_8`
- [ ] 10. [sub-task: write] `task(..., prompt: "execute write task from spec-creation")` — input: `./tmp/{N}/contracts/write-input.yaml`, output: `./tmp/{N}/contracts/write-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-input-template.yaml`, chain: `step_6, step_9`
- [ ] 11. [sub-task: completion] `task(..., prompt: "execute completion task from spec-creation")` — input: `./tmp/{N}/contracts/completion-input.yaml`, output: `./tmp/{N}/contracts/completion-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-output-template.yaml` (shared), chain: `step_10`

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_context, worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
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
    title: "Pipeline-readiness gate required between traceability and risk"
    conditions:
      all:
        - "traceability_complete == true"
        - "risk_started == false"
        - "pipeline_readiness_gate_passed == false"
    actions: [HALT, CALL(spec-creation --task pipeline-readiness-gate)]
    source: "spec-creation/SKILL.md"
```
