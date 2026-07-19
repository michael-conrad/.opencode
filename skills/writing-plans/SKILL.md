---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also use when retroactively creating a plan for an existing spec, or backfilling plan documentation. Also use when running holistic self-checks on plans before completion, or verifying plan quality against the 11-dimension holistic gate. Invoke for: plan creation, implementation planning, task breakdown, phase definition, work decomposition, retroactive planning, plan backfill, holistic check, self-check, pre-completion check, plan quality verification. Plans are REQUIRED. — distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline). Trigger phrases: create plan, write plan, draft plan, implementation plan, plan implementation, break down work, create tasks, define phases, plan phases, retroactive plan, backfill plan, task breakdown, create a plan, write a plan, draft a plan, make a plan, make plan, create an implementation plan, write an implementation plan, implementation steps, task list, break down the work, create the tasks, define the phases."
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using a Z3-enforced pipeline defined in `create.md`. Every step is one atomic concern. No placeholders. Pipeline steps dispatch to sub-agents via `task()` for independent execution.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Pipeline steps dispatch to sub-agents via `task()` for independent execution — no inline execution of pipeline steps
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **All implementation-pipeline steps are mandatory — no exceptions.** Every step in the implementation-pipeline SKILL.md Trigger Dispatch Table MUST be included in generated plans with the correct skill/task reference. Plans that omit mandatory steps or use incorrect skill/task names are defective and MUST be rejected at the plan validation gate. This applies regardless of scope, authorization level, or perceived simplicity. "Continue" does not waive this requirement. There is no exception for any reason.
- [ ] 6. **Pipeline execution discipline:**
  - `todowrite` lifecycle MUST be maintained throughout pipeline execution (CREATE with status, UPDATE on transition, CLEAR before HALT)
  - `pipeline_phase` MUST be tracked and updated after each step
  - A feature branch MUST be created before any plan artifacts are written
  - Plan artifacts MUST be committed to the feature branch after creation
  - `local-issues sync` MUST be run before any `.issues/` writes and after each write
- [ ] 7. **Sequential step ordering:** Every step with a chain dependency MUST execute sequentially. No parallel dispatch of chain-dependent steps. Each step's output is the next step's input. The "sub-agent dispatch implies independence" rationalization is explicitly prohibited.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" / "auto-create plan" / "gap-fill plan" / "retroactive" / "retroactive plan" / "backfill plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| "update plan" / "plan update" / "auto-update plan" / "revise plan" | `update` | `sub-task` | {spec_issue_number, plan_issue_number} |
| "holistic check" / "self-check" / "pre-completion check" | `holistic-self-check` | `sub-task` | {plan_context} |
| "verify spec approved" / "check spec approval" | `verify-spec-approved` | `sub-task` | {spec_issue_number} |
| "research evidence" / "gather evidence" | `research` | `sub-task` | {spec_issue_number, spec_body} |
| "artifact validation" / "validate artifacts" | `artifact-validation` | `sub-task` | {spec_issue_number, project_root, path} |
| "readiness gate" / "check readiness" | `readiness` | `sub-task` | {spec_issue_number, research_output} |
| "structure phases" / "define phases" | `structure` | `sub-task` | {spec_issue_number, readiness_output} |
| "solve constraints" / "z3 solve" | `solve` | `sub-task` | {spec_issue_number, structure_output} |
| "write plan" / "generate plan" | `write` | `sub-task` | {spec_issue_number, solve_output} |
| "revisit plan" / "resolve conflicts" | `revisit` | `sub-task` | {spec_issue_number, write_output} |
| "validate plan" / "check plan" | `validate` | `sub-task` | {spec_issue_number, plan_file_path} |
| "audit fidelity" / "fidelity audit" | `audit-fidelity` | `sub-task` | {spec_issue_number, plan_file_path, audit_phase} |
| "audit concern" / "concern audit" | `audit-concern` | `sub-task` | {spec_issue_number, plan_file_path, audit_phase} |
| "complete plan" / "finish plan" | `completion` | `sub-task` | {workflow_state} |
| "retroactive plan" / "retroactive" | `retroactive` | `sub-task` | {spec_issue_number} |
| "clean-room plan" / "independent plan" | `clean-room` | `sub-task` | {problem_statement} |

## Persona

This skill produces plans by dispatching pipeline steps to sub-agents. The orchestrator routes each step to a clean-room sub-agent via `task()`. Each step is a self-contained procedure with entry criteria, exit criteria, and chain dependency. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining pipeline steps means the plan was never independently produced.

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Tasks

| `create` | `update` | `holistic-self-check` | `verify-spec-approved` | `research` | `artifact-validation` | `readiness` | `structure` | `solve` | `write` | `revisit` | `validate` | `audit-fidelity` | `audit-concern` | `completion` | `retroactive` | `clean-room` |

## Plan Model

**All plans are local artifacts.** Plans use a split file convention:

- **Index file:** `{N}/plan.md` — contains Goal, Architecture, Files, Phase table, Exit criteria, all admonishments, and self-review evidence. No implementation steps.
- **Phase files:** `{N}/plan-{NN}.md` — one per phase, with full step-by-step instructions, dispatch indicators, RED/GREEN chains, Z3 checks, VbC blocks, phase completion block, and concern transition.

**Numbering rules:**
- Steps are globally sequential across all phase files
- Phase 2's first step continues from Phase 1's last step
- Phase file naming: `plan-{NN}.md` where NN is zero-padded phase number

**Single-task plans** (one phase) use `{N}/plan.md` as the sole file (no split needed).

## Invocation

`skill({name: "writing-plans"})` — orchestrator dispatches pipeline steps to sub-agents via `task()`.

**DISPATCH GATE — Pipeline steps dispatch to sub-agents.** The orchestrator routes each step to a clean-room sub-agent via `task()`. The orchestrator reads each step procedure from its task file and dispatches it. When external skills are needed (e.g., audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, dispatched to a sub-agent.

| Task | Execution |
|------|-----------|
| `create` | Sub-agent via `task(..., prompt: "execute create from writing-plans. Read \`writing-plans-creation/tasks/create.md\` first")` |
| `update` | Sub-agent via `task(..., prompt: "execute update from writing-plans. Read \`writing-plans-creation/tasks/update.md\` first")` |
| `holistic-self-check` | Sub-agent via `task(..., prompt: "execute holistic-self-check from writing-plans. Read \`writing-plans-holistic/tasks/holistic-self-check.md\` first")` |
| `verify-spec-approved` | Sub-agent via `task(..., prompt: "execute verify-spec-approved from writing-plans-creation. Read \`writing-plans-creation/tasks/pre-plan-readiness.md\` first")` |
| `research` | Sub-agent via `task(..., prompt: "execute research from writing-plans-creation. Read \`writing-plans-creation/tasks/research.md\` first")` |
| `artifact-validation` | Sub-agent via `task(..., prompt: "execute artifact-validation from writing-plans-creation. Read \`writing-plans-creation/tasks/artifact-validation.md\` first")` |
| `readiness` | Sub-agent via `task(..., prompt: "execute readiness from writing-plans-creation. Read \`writing-plans-creation/tasks/readiness.md\` first")` |
| `structure` | Sub-agent via `task(..., prompt: "execute structure from writing-plans-creation. Read \`writing-plans-creation/tasks/structure.md\` first")` |
| `solve` | Sub-agent via `task(..., prompt: "execute solve from writing-plans-creation. Read \`writing-plans-creation/tasks/solve.md\` first")` |
| `write` | Sub-agent via `task(..., prompt: "execute write from writing-plans-creation. Read \`writing-plans-creation/tasks/write.md\` first")` |
| `revisit` | Sub-agent via `task(..., prompt: "execute revisit from writing-plans-creation. Read \`writing-plans-creation/tasks/revisit.md\` first")` |
| `validate` | Sub-agent via `task(..., prompt: "execute validate from writing-plans-creation. Read \`writing-plans-creation/tasks/validate.md\` first")` |
| `audit-fidelity` | Sub-agent via `task(..., prompt: "execute audit-fidelity from writing-plans-creation. Read \`writing-plans-creation/tasks/audit-fidelity.md\` first")` |
| `audit-concern` | Sub-agent via `task(..., prompt: "execute audit-concern from writing-plans-creation. Read \`writing-plans-creation/tasks/audit-concern.md\` first")` |
| `completion` | Sub-agent via `task(..., prompt: "execute completion from writing-plans-creation. Read \`writing-plans-creation/tasks/completion.md\` first")` |
| `retroactive` | Sub-agent via `task(..., prompt: "execute retroactive from writing-plans-creation. Read \`writing-plans-creation/tasks/retroactive.md\` first")` |
| `clean-room` | Sub-agent via `task(..., prompt: "execute clean-room from writing-plans-creation. Read \`writing-plans-creation/tasks/clean-room.md\` first")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "writing-plans"})` ``

## Pipeline

The pipeline is defined in `writing-plans-creation/tasks/create.md`. It consists of sequential steps dispatched by the orchestrator via the Trigger Dispatch Table, with Z3 contract verification between each step. See `create.md` for the full step list, dispatch modes, and contract table.

## Sub-Agent Routing

Pipeline steps dispatch to sub-agents via `task()` for independent execution. The orchestrator routes each step to a clean-room sub-agent. When external skills are needed (audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, dispatched to a sub-agent.

## Cross-References

Load [approval-gate](skills/approval-gate/SKILL.md), Load [issue-operations](skills/issue-operations/SKILL.md), Load [executing-plans](skills/executing-plans/SKILL.md), Load [audit](skills/audit/SKILL.md), Load [verification-enforcement](skills/verification-enforcement/SKILL.md), Load [solve](skills/solve/SKILL.md), Load [plan](skills/plan/SKILL.md). Load [010-approval-gate.md](guidelines/010-approval-gate.md), Load [140-planning-spec-creation.md](guidelines/140-planning-spec-creation.md).

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
