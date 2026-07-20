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
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" / "auto-create plan" / "gap-fill plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| "update plan" / "plan update" / "auto-update plan" / "revise plan" | `update` | `sub-task` | {spec_issue_number, plan_issue_number} |
| "retroactive plan" / "retroactive" / "backfill plan" | `retroactive` | `sub-task` | {spec_issue_number, spec_body} |
| "holistic check" / "self-check" / "pre-completion check" | `holistic-self-check` | `sub-task` | {plan_context} |

## Persona

This skill produces plans by dispatching pipeline steps to sub-agents. The orchestrator routes each step to a clean-room sub-agent via `task()`. Each step is a self-contained procedure with entry criteria, exit criteria, and chain dependency. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining pipeline steps means the plan was never independently produced.

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Tasks

| `create` | `update` | `holistic-self-check` |

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

| Task | Canonical Dispatch String |
|------|--------------------------|
| `create` | `task(..., prompt: "execute create from writing-plans-creation. Read \`writing-plans-creation/tasks/create.md\` first")` |
| `update` | `task(..., prompt: "execute update from writing-plans-creation. Read \`writing-plans-creation/tasks/update.md\` first")` |
| `retroactive` | `task(..., prompt: "execute retroactive from writing-plans-creation. Read \`writing-plans-creation/tasks/retroactive.md\` first")` |
| `holistic-self-check` | `task(..., prompt: "execute holistic-self-check from writing-plans. Read \`writing-plans-holistic/tasks/holistic-self-check.md\` first")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "writing-plans"})` ``

## Pipeline

### Workflow 1: `create` — Full pipeline (17 steps)

```
 1. [sub-task] Verify spec approved (pre-plan-readiness)
 2. [sub-task] Research
 3. [inline]  Z3 check — solve check verify research output
 4. [sub-task] Readiness
 5. [sub-task] Artifact validation
 6. [inline]  Z3 check — solve check verify readiness output
 7. [sub-task] Structure
 8. [inline]  Z3 check — solve check verify structure output
 9. [sub-task] Solve
10. [inline]  Z3 check — solve check verify solve output
11. [sub-task] Plan creation pipeline (dispatches to plan-creation-pipeline skill)
12. [sub-task] Write
13. [inline]  Z3 check — solve check verify write output
14. [sub-task] Revisit
15. [inline]  Z3 check — solve check verify revisit output
16. [sub-task] Validate
17. [inline]  Z3 check — solve check verify validate output
18. [sub-task] Audit fidelity
19. [inline]  Z3 check — solve check verify audit-fidelity output
20. [sub-task] Audit concern
21. [inline]  Z3 check — solve check verify audit-concern output
22. [sub-task] Completion
23. [inline]  Z3 check — solve check verify completion output
```

### Workflow 2: `update` — Plan revision (delegates to writing-plans-creation update task)

```
 1. [sub-task] Update
```

### Workflow 3: `retroactive` — Retroactive plan creation (delegates to writing-plans-creation retroactive task)

```
 1. [sub-task] Retroactive
```

### Workflow 4: `holistic-self-check` — Quality gate (delegates to writing-plans-holistic)

```
 1. [sub-task] Holistic self-check
```

### Sub-task Step Contract

Every sub-task step follows the frugal contract pattern. The orchestrator passes only `{spec_issue_number, spec_body}` — no preloaded context, no file paths, no expected outcomes. The sub-agent reads its input from disk, writes its output to disk, and returns a frugal result contract.

**Dispatch contract:**

```
Orchestrator                          Sub-agent
    │                                      │
    │  task(..., {spec_issue_number, spec_body})
    │─────────────────────────────────────>│
    │                                      │
    │                         Reads input from .issues/{N}/spec.md
    │                         Reads prior artifacts from .issues/{N}/artifacts/
    │                         Writes output to .issues/{N}/artifacts/{name}.yaml
    │                                      │
    │  Result contract:                     │
    │    status: DONE | BLOCKED            │
    │    finding_summary: "<1-3 sentences>"│
    │    artifact_path: .issues/{N}/artifacts/{name}.yaml
    │    blocker_reason: ""               │
    │<─────────────────────────────────────│
    │                                      │
    │  Reads artifact file ONLY if         │
    │  routing-significant data needed     │
```

**Rules:**
1. Orchestrator passes ONLY `{spec_issue_number, spec_body}` — no preloaded context, no file paths, no expected outcomes, no orchestrator reasoning
2. Sub-agent reads from disk — `.issues/{N}/spec.md` for the spec body, `.issues/{N}/artifacts/` for prior step outputs
3. Sub-agent writes to disk — `.issues/{N}/artifacts/{name}.yaml` for its output
4. Sub-agent returns frugal result contract — `{status, finding_summary, artifact_path, blocker_reason}`
5. Orchestrator reads artifact files ONLY for routing-significant data — never for full content
6. No contract YAML files at `{project_root}/tmp/{N}/contracts/` — those are phantom infrastructure, stripped

### Inline Steps (orchestrator executes directly)

| Step | What the Orchestrator Does |
|------|---------------------------|
| Verify spec approved | Run `github_issue_read(method=get_labels, issue_number={N})` |
| Z3 check | Run `.opencode/tools/solve check` with contract |
| Plan creation pipeline | Dispatch to `plan-creation-pipeline` skill via SKILL.md Trigger Dispatch Table |

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
