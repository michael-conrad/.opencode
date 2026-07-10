---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also use when retroactively creating a plan for an existing spec, or backfilling plan documentation. Invoke for: plan creation, implementation planning, task breakdown, phase definition, work decomposition, retroactive planning, plan backfill. Plans are REQUIRED. — distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline). Trigger phrases: create plan, write plan, draft plan, implementation plan, plan implementation, break down work, create tasks, define phases, plan phases, retroactive plan, backfill plan, task breakdown, create a plan, write a plan, draft a plan, make a plan, make plan, create an implementation plan, write an implementation plan, implementation steps, task list, break down the work, create the tasks, define the phases."
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using a 22-step Z3-enforced pipeline. Every step is one atomic concern. No placeholders. Pipeline steps dispatch to sub-agents via `task()` for independent execution.

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
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" / "auto-create plan" / "gap-fill plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| "retroactive" / "retroactive plan" / "backfill plan" | `retroactive` | `sub-task` | {spec_issue_number} |
| "update plan" / "plan update" / "auto-update plan" / "revise plan" | `update` | `sub-task` | {spec_issue_number, plan_issue_number} |
| "spec-to-plan" / "handoff to plan" | `handoffs/spec-to-plan` | `sub-task` | {spec_issue_number} |
| "pre-plan-readiness" / "readiness check" / "verify prerequisites" | `pre-plan-readiness` | `sub-task` | {spec_issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

This skill produces plans by dispatching pipeline steps to sub-agents. The orchestrator routes each step to a clean-room sub-agent via `task()`. Each step is a self-contained procedure with entry criteria, exit criteria, and chain dependency. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining pipeline steps means the plan was never independently produced.

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Tasks

| `create` | `completion` | `retroactive` | `pre-plan-readiness` |

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
| `create` | Sub-agent via `task(..., prompt: "execute create task from writing-plans")` |
| `retroactive` | Sub-agent via `task(..., prompt: "execute retroactive task from writing-plans")` |
| `update` | Sub-agent via `task(..., prompt: "execute update task from writing-plans")` |
| `completion` | Sub-agent via `task(..., prompt: "execute completion task from writing-plans")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "writing-plans"})` ``

## Operating Protocol — 22-Step Pipeline

See `writing-plans/tasks/operating-protocol.md` for the full 22-step pipeline with chain dependencies and retroactive protocol.

## Sub-Agent Routing

Pipeline steps dispatch to sub-agents via `task()` for independent execution. The orchestrator routes each step to a clean-room sub-agent. When external skills are needed (audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, dispatched to a sub-agent.

## Cross-References

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `audit --task plan-fidelity`, `audit --task concern-separation`, `verification-enforcement`, `solve`, `plan`. References: `skill-card-change-types.md`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.


```
