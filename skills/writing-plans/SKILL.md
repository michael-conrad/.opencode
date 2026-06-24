---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec. Plans are the map — agents who skip them get lost."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using a 21-step Z3-enforced pipeline: 10 discrete sub-agent dispatches interleaved with 10 z3-check transitions and 1 inline verification step. Every step is one atomic concern. No placeholders. Sub-agents are leaf nodes — only the orchestrator dispatches via `task()`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 6. **No optimizing out mandatory steps** — All implementation-pipeline gate steps are mandatory regardless of perceived simplicity. Optimizing out steps because they appear "not needed" is defective behavior and produces plans that must be discarded as incomplete and error-ridden.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" | `create` | `orchestrator` | {spec_issue_number, spec_body} |
| "retroactive" / "retroactive plan" / "backfill plan" | `retroactive` | `orchestrator` | {spec_issue_number} |
| completion / workflow end | `completion` | `orchestrator` | {workflow_state} |

## Persona

This skill produces plans by dispatching sub-agents. The orchestrator routes; sub-agents author. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

## Tasks

| `create` | `completion` | `retroactive` |

## Plan Model

**All plans are local artifacts.** Plans are stored at `.issues/{N}/plan.md` (root repo) or `*/.issues/{N}/plan.md` (submodule/sub-repo). Phases are sections in the local plan file.

- **Separate (multi-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` with stand-alone phase sections, each with concern boundary annotations
- **Combined (single-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` referencing spec content inline

## Invocation

`skill({name: "writing-plans"})` — orchestrator reads task file and executes steps inline:

| Task | Execution |
|------|-----------|
| `create` | Orchestrator reads `tasks/create.md` and executes steps inline |
| `retroactive` | Orchestrator reads `tasks/retroactive.md` and executes steps inline |
| `completion` | Orchestrator reads `tasks/completion.md` and executes steps inline |

**CLI equivalent (for human TUI use):** `/skill writing-plans --task <task>`

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope, chain dependency, and contract paths.

### Pipeline Steps

- [ ] 1. [inline] Verify spec is approved (check `approved-for-*` label) — chain: `none`
- [ ] 2. [sub-task: research] `task(..., prompt: "execute research task from writing-plans")` — input: `contracts/research-input-template.yaml`, output: `contracts/research-output-template.yaml`, template: `contracts/research-input-template.yaml`, chain: `step_1`
- [ ] 3. [z3-check] `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. [sub-task: readiness] `task(..., prompt: "execute readiness task from writing-plans")` — input: `contracts/readiness-input-template.yaml`, output: `contracts/readiness-output-template.yaml`, template: `contracts/readiness-input-template.yaml`, chain: `step_3`
- [ ] 5. [z3-check] `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. [sub-task: structure] `task(..., prompt: "execute structure task from writing-plans")` — input: `contracts/structure-input-template.yaml`, output: `contracts/structure-output-template.yaml`, template: `contracts/structure-input-template.yaml`, chain: `step_5`
- [ ] 7. [z3-check] `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. [sub-task: solve] `task(..., prompt: "execute solve task from writing-plans")` — input: `contracts/solve-input-template.yaml`, output: `contracts/solve-output-template.yaml`, template: `contracts/solve-input-template.yaml`, chain: `step_7`
- [ ] 9. [z3-check] `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. [sub-task: write] `task(..., prompt: "execute write task from writing-plans")` — input: `contracts/write-input-template.yaml`, output: `contracts/write-output-template.yaml`, template: `contracts/write-input-template.yaml`, chain: `step_9`
- [ ] 11. [z3-check] `solve check` — verify write output has plan file path — chain: `step_10`
- [ ] 12. [sub-task: revisit] `task(..., prompt: "execute revisit task from writing-plans")` — input: `contracts/revisit-input-template.yaml`, output: `contracts/revisit-output-template.yaml`, template: `contracts/revisit-input-template.yaml`, chain: `step_11`
- [ ] 13. [z3-check] `solve check` — verify revisit output has resolution_status — chain: `step_12`
- [ ] 14. [sub-task: validate] `task(..., prompt: "execute validate task from writing-plans")` — input: `contracts/validate-input-template.yaml`, output: `contracts/validate-output-template.yaml`, template: `contracts/validate-input-template.yaml`, chain: `step_13`
- [ ] 15. [z3-check] `solve check` — verify validate output has PASS status — chain: `step_14`
- [ ] 16. [sub-task: audit-fidelity] `task(..., prompt: "execute audit-fidelity task from writing-plans")` — input: `contracts/audit-fidelity-input-template.yaml`, output: `contracts/audit-fidelity-output-template.yaml`, template: `contracts/audit-fidelity-input-template.yaml`, chain: `step_15`
- [ ] 17. [z3-check] `solve check` — verify audit-fidelity output has PASS — chain: `step_16`
- [ ] 18. [sub-task: audit-concern] `task(..., prompt: "execute audit-concern task from writing-plans")` — input: `contracts/audit-concern-input-template.yaml`, output: `contracts/audit-concern-output-template.yaml`, template: `contracts/audit-concern-input-template.yaml`, chain: `step_17`
- [ ] 19. [z3-check] `solve check` — verify audit-concern output has PASS — chain: `step_18`
- [ ] 20. [sub-task: completion] `task(..., prompt: "execute completion task from writing-plans")` — input: `contracts/completion-input-template.yaml`, output: `contracts/completion-output-template.yaml`, template: `contracts/completion-input-template.yaml`, chain: `step_19`
- [ ] 21. [z3-check] `solve check` — verify completion output has lifecycle event — chain: `step_20`

### Retroactive Operating Protocol

When the `retroactive` task is dispatched, the pipeline is the same 21-step sequence but with the research step loading the existing spec body as its evidence source rather than performing live-source verification:

- [ ] 1. [inline] Verify spec exists in `.issues/{N}/spec.md` or `*/.issues/{N}/spec.md` — chain: `none`
- [ ] 2. [sub-task: research] Load existing spec body as evidence source — chain: `step_1`
- [ ] 3-21. Same as standard pipeline above — chain: `step_2`

## Sub-Agent Routing

Orchestrator tasks (`create`, `retroactive`, `completion`) are executed inline by the orchestrator — the orchestrator reads the task file and executes steps directly. Sub-task dispatches within the 21-step pipeline (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion) use `task(subagent_type="general")` with `{ spec_issue_number, spec_body, worktree.path, github.owner, github.repo }`, excluding implementation context. Auditor tasks (`audit-fidelity`, `audit-concern`) use subagent_type from `resolve-models` result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

## Cross-References

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `adversarial-audit --task plan-fidelity`, `adversarial-audit --task concern-separation`, `verification-enforcement`, `solve`, `plan`. References: `skill-card-change-types.md`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-06-23T00:00:00Z"
rules:
  - id: writing-plans-001
    title: "Plan creation from approved spec only"
    conditions:
      all: ["plan_creation_attempted == true", "spec_approved == false"]
    actions: [HALT]
    source: "writing-plans/SKILL.md"

  - id: writing-plans-pipeline-readiness
    title: "Pipeline-readiness artifact required before plan creation"
    conditions:
      all:
        - "plan_creation_pending == true"
        - "sc_pipeline_readiness_exists == false"
    actions: [HALT, REPORT(SPEC_NOT_READY_FOR_PIPELINE)]
    source: "writing-plans/SKILL.md"
```
