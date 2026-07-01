---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also use when retroactively creating a plan for an existing spec, or backfilling plan documentation. Invoke for: plan creation, implementation planning, task breakdown, phase definition, work decomposition, retroactive planning, plan backfill. Plans are REQUIRED. — distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline). Trigger phrases: create plan, write plan, draft plan, implementation plan, plan implementation, break down work, create tasks, define phases, plan phases, retroactive plan, backfill plan, task breakdown."
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using a 22-step Z3-enforced pipeline executing entirely at orchestrator level. Every step is one atomic concern. No placeholders. No `task()` calls within the pipeline.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. All pipeline steps execute at orchestrator level — no `task()` calls within the pipeline
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 6. **No optimizing out mandatory steps** — All implementation-pipeline gate steps are mandatory regardless of perceived simplicity. Optimizing out steps because they appear "not needed" is defective behavior and produces plans that must be discarded as incomplete and error-ridden.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" / "auto-create plan" / "gap-fill plan" | `create` | `orchestrator` | {spec_issue_number, spec_body} |
| "retroactive" / "retroactive plan" / "backfill plan" | `retroactive` | `orchestrator` | {spec_issue_number} |
| "update plan" / "plan update" / "auto-update plan" / "revise plan" | `update` | `orchestrator` | {spec_issue_number, plan_issue_number} |
| completion / workflow end | `completion` | `orchestrator` | {workflow_state} |

## Programmatic Invocation

| Task | Execution |
|------|-----------|
| `create` | Orchestrator reads `tasks/create.md` and executes steps inline |
| `retroactive` | Orchestrator reads `tasks/retroactive.md` and executes steps inline |
| `update` | Orchestrator reads `tasks/update.md` and executes steps inline |
| `completion` | Orchestrator reads `tasks/completion.md` and executes steps inline |

## Persona

This skill produces plans by executing a 22-step pipeline at orchestrator level. The orchestrator reads each step procedure from its task file and executes it directly. Each step is a self-contained procedure with entry criteria, exit criteria, and chain dependency. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

## Tasks

| `create` | `completion` | `retroactive` |

## Plan Model

**All plans are local artifacts.** Plans use a split file convention:

- **Index file:** `{N}/plan.md` — contains Goal, Architecture, Files, Phase table, Exit criteria, all admonishments, and self-review evidence. No implementation steps.
- **Phase files:** `{N}/plan-{NN}-{short-slug}.md` — one per phase, with full step-by-step instructions, dispatch indicators, RED/GREEN chains, Z3 checks, VbC blocks, phase completion block, and concern transition.

**Numbering rules:**
- Steps are globally sequential across all phase files
- Phase 2's first step continues from Phase 1's last step
- Phase file naming: `plan-{NN}-{short-slug}.md` where NN is zero-padded phase number

**Single-task plans** (one phase) use `{N}/plan.md` as the sole file (no split needed).

## Invocation

`skill({name: "writing-plans"})` — orchestrator reads task file and executes steps inline.

**DISPATCH GATE — All pipeline steps execute at orchestrator level.** Under the hard limit that sub-agents cannot dispatch sub-agents, the 22-step pipeline runs entirely in the orchestrator context. The orchestrator reads each step procedure from its task file and executes it directly. No `task()` calls are used within the pipeline. When external skills are needed (e.g., adversarial-audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, not via sub-agent dispatch.

| Task | Execution |
|------|-----------|
| `create` | Orchestrator reads `tasks/create.md` and executes steps inline |
| `retroactive` | Orchestrator reads `tasks/retroactive.md` and executes steps inline |
| `update` | Orchestrator reads `tasks/update.md` and executes steps inline |
| `completion` | Orchestrator reads `tasks/completion.md` and executes steps inline |

**CLI equivalent (for human TUI use):** `/skill writing-plans --task <task>`

## Operating Protocol — 21-Step Pipeline

**Execution model:** Under the hard limit that sub-agents cannot dispatch sub-agents, this skill's pipeline executes entirely at the orchestrator level. The orchestrator reads each step procedure and executes it directly. No `task()` calls are used within the pipeline.

Each item is tagged with chain dependency and contract paths.
- [ ] 0. **Correctness over speed.** Every result will be independently audited by two different cloud models. A slow correct answer is strictly better than a fast incorrect one. Fabrication wastes time — the work will be re-dispatched. Static grep is NOT acceptable verification — behavioral compliance requires actual model execution with cross-validated PASS verdict.

### Pipeline Steps

- [ ] 1. Verify spec is approved (check `approved-for-*` label) — read tasks/create.md Step 1 — chain: `none`
- [ ] 2. Research — execute research procedure from tasks/research.md — chain: `step_1`
- [ ] 3. Z3 check — run `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. Readiness — execute readiness procedure from tasks/readiness.md — chain: `step_3`
- [ ] 5. Z3 check — run `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. Structure — execute structure procedure from tasks/structure.md — chain: `step_5`
- [ ] 7. Z3 check — run `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. Solve — execute solve procedure from tasks/solve.md — chain: `step_7`
- [ ] 9. Z3 check — run `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. Write — execute write procedure from tasks/write.md — chain: `step_9`
- [ ] 11. Clean-room plan generation — execute write procedure with spec body only, no existing plan context — chain: `step_10`
- [ ] 12. Z3 check — run `solve check` — verify clean-room plan output contains clean_room_plan — chain: `step_11`
- [ ] 13. Revisit — execute revisit procedure from tasks/revisit.md — chain: `step_12`
- [ ] 14. Z3 check — run `solve check` — verify revisit output has resolution_status — chain: `step_13`
- [ ] 15. Validate — execute validate procedure from tasks/validate.md — chain: `step_14`
- [ ] 16. Z3 check — run `solve check` — verify validate output has PASS status — chain: `step_15`
- [ ] 17. Audit fidelity — execute audit-fidelity procedure from adversarial-audit task plan-fidelity — chain: `step_16`
- [ ] 18. Z3 check — run `solve check` — verify audit-fidelity output has PASS — chain: `step_17`
- [ ] 19. Audit concern — execute audit-concern procedure from adversarial-audit task concern-separation — chain: `step_18`
- [ ] 20. Z3 check — run `solve check` — verify audit-concern output has PASS — chain: `step_19`
- [ ] 21. Completion — execute completion procedure from tasks/completion.md — chain: `step_20`
- [ ] 22. Z3 check — run `solve check` — verify completion output has lifecycle event — chain: `step_21`

### Retroactive Operating Protocol

When the `retroactive` task is dispatched, the pipeline is the same 22-step sequence but with Step 2 (Research) loading the existing spec body as its evidence source rather than performing live-source verification. Steps 3-22 follow the standard pipeline above.

## Sub-Agent Routing

Orchestrator-level tasks (`create`, `retroactive`) are executed inline by the orchestrator — the orchestrator reads each step procedure and executes it directly. The pipeline uses no `task()` calls. When external skills are needed (adversarial-audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, not via sub-agent dispatch within the pipeline.

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
