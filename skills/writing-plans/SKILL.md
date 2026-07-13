---
name: writing-plans
description: "Implementation plan creator that breaks approved specs into phases, tasks, and work breakdowns. Dispatch when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also dispatch when retroactively creating a plan for an existing spec, or backfilling plan documentation. Also dispatch when running holistic self-checks on plans before completion, or verifying plan quality against the 11-dimension holistic gate. Plans are REQUIRED. — distinct from plan (AI planning with PDDL/Z3) and plan-creation-pipeline (task()-dispatch pipeline). User phrases: create plan, write plan, draft plan, implementation plan, plan implementation, break down work, define phases, holistic check, plan quality verification."
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using a 22-step Z3-enforced pipeline. Every step is one atomic concern. No placeholders. Pipeline steps dispatch to sub-agents via `task()` for independent execution.

Plan creation now consumes analytical artifacts from spec-creation. The plan's phase structure, file scope, and test strategy are derived from the 7 analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment) — not re-derived from scratch.

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
- [ ] 8. **Analytical artifact validation required before plan creation.** All 7 analytical artifacts must be present and non-empty before plan creation begins. Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`. After plan creation with all artifacts present, auto-dispatch plan-fidelity and concern-separation audits.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" / "auto-create plan" / "gap-fill plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| | **Pre-check:** If `create` entry invoked, verify all 7 analytical artifacts exist in `.issues/{N}/` before dispatch. Missing artifact → route to corresponding HALT entry above. | | |
| "retroactive" / "retroactive plan" / "backfill plan" | `retroactive` | `sub-task` | {spec_issue_number} |
| "update plan" / "plan update" / "auto-update plan" / "revise plan" | `update` | `sub-task` | {spec_issue_number, plan_issue_number} |
| "spec-to-plan" / "handoff to plan" | `handoffs/spec-to-plan` | `sub-task` | {spec_issue_number} |
| "pre-plan-readiness" / "readiness check" / "verify prerequisites" | `pre-plan-readiness` | `sub-task` | {spec_issue_number} |
| "analytical artifacts ready for plan" | `create` | `sub-task` | {spec_issue_number, spec_body, analytical_artifact_dir} |
| "blast-radius artifact missing for plan" | HALT | — | — |
| "concern-map artifact missing for plan" | HALT | — | — |
| "cross-cutting-matrix artifact missing for plan" | HALT | — | — |
| "interface-compatibility artifact missing for plan" | HALT | — | — |
| "state-analysis artifact missing for plan" | HALT | — | — |
| "testability-assessment artifact missing for plan" | HALT | — | — |
| "holistic check" / "self-check" / "pre-completion check" | `holistic-self-check` | `sub-task` | {plan_context} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

This skill produces plans by dispatching pipeline steps to sub-agents. The orchestrator routes each step to a clean-room sub-agent via `task()`. Each step is a self-contained procedure with entry criteria, exit criteria, and chain dependency. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining pipeline steps means the plan was never independently produced.

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Tasks

| `create` | `completion` | `retroactive` | `pre-plan-readiness` | `holistic-self-check` |

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
| `holistic-self-check` | Sub-agent via `task(..., prompt: "execute holistic-self-check task from writing-plans")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "writing-plans"})` ``

## Operating Protocol — 22-Step Pipeline

### Entry Criteria

- Spec is approved (check `approved-for-*` label)
- Authorization scope is `for_plan` or above
- All 7 analytical artifacts exist in `.issues/{N}/artifacts/` (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`. Before BLOCKING, attempt auto-generation via `spec-creation/tasks/analytical-artifacts.md` in retroactive mode.

### Execution Model

Pipeline steps dispatch to sub-agents via `task()` for independent execution. The orchestrator routes each step to a clean-room sub-agent. Each step is tagged with chain dependency and contract paths.

- [ ] 0. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

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
- [ ] 17. Audit fidelity — execute audit-fidelity procedure from audit task plan-fidelity — chain: `step_16`
- [ ] 18. Z3 check — run `solve check` — verify audit-fidelity output has PASS — chain: `step_17`
- [ ] 19. Audit concern — execute audit-concern procedure from audit task concern-separation — chain: `step_18`
- [ ] 20. Z3 check — run `solve check` — verify audit-concern output has PASS — chain: `step_19`
- [ ] 21. Completion — execute completion procedure from tasks/completion.md — chain: `step_20`
- [ ] 22. Z3 check — run `solve check` — verify completion output has lifecycle event — chain: `step_21`

### Retroactive Operating Protocol

When the `retroactive` task is dispatched, the pipeline is the same 22-step sequence but with Step 2 (Research) loading the existing spec body as its evidence source rather than performing live-source verification. Steps 3-22 follow the standard pipeline.

### Exit Criteria

- Plan created as a local artifact (index + phase files)
- All Z3 checks pass
- Audit fidelity and concern separation verified

## Sub-Agent Routing

Pipeline steps dispatch to sub-agents via `task()` for independent execution. The orchestrator routes each step to a clean-room sub-agent. When external skills are needed (audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, dispatched to a sub-agent.

## Cross-References

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `audit --task plan-fidelity`, `audit --task concern-separation`, `verification-enforcement`, `solve`, `plan`. References: `skill-card-change-types.md`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.


```
