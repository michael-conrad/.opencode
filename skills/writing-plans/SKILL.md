---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec. Plans are REQUIRED."
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
| "research" / "evidence" / "verify claims" | `research` | `sub-agent` | {spec_issue_number, spec_body} |
| "readiness" / "pipeline ready check" | `readiness` | `sub-agent` | {spec_issue_number, sc_pipeline_readiness} |
| "structure" / "phase structure" / "combined or separate" | `structure` | `sub-agent` | {spec_body, phase_definitions} |
| "solve" / "dependency check" / "Z3 verify" | `solve` | `sub-agent` | {sc_pipeline_readiness, dependency_contract} |
| "write plan" / "generate plan" | `write` | `sub-agent` | {spec_body, sc_pipeline_readiness} |
| "revisit" / "resolve concerns" | `revisit` | `sub-agent` | {plan_issues_file, spec_body} |
| "validate" / "check plan" | `validate` | `sub-agent` | {plan_issues_file, spec_body} |
| "audit fidelity" / "fidelity check" | `audit-fidelity` | `sub-agent (auditor)` | {plan_issues_file, spec_body} |
| "audit concern" / "concern separation" | `audit-concern` | `sub-agent (auditor)` | {plan_issues_file, spec_body} |

## Programmatic Invocation Table

| Task | Call via task() |
|------|-----------------|
| `research` | `task(subagent_type="general", prompt: "execute research task from writing-plans")` |
| `readiness` | `task(subagent_type="general", prompt: "execute readiness task from writing-plans")` |
| `structure` | `task(subagent_type="general", prompt: "execute structure task from writing-plans")` |
| `solve` | `task(subagent_type="general", prompt: "execute solve task from writing-plans")` |
| `write` | `task(subagent_type="general", prompt: "execute write task from writing-plans")` |
| `revisit` | `task(subagent_type="general", prompt: "execute revisit task from writing-plans")` |
| `validate` | `task(subagent_type="general", prompt: "execute validate task from writing-plans")` |
| `audit-fidelity` | `task(subagent_type="auditor_1", prompt: "execute audit-fidelity task from writing-plans")` |
| `audit-concern` | `task(subagent_type="auditor_2", prompt: "execute audit-concern task from writing-plans")` |

## Persona

This skill produces plans by dispatching sub-agents. The orchestrator routes; sub-agents author. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

## Tasks

| `create` | `completion` | `retroactive` |

## Plan Model

**All plans are local artifacts.** Plans are stored at `.issues/{N}/plan.md` (root repo) or `*/.issues/{N}/plan.md` (submodule/sub-repo). Phases are sections in the local plan file.

- **Separate (multi-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` with stand-alone phase sections, each with concern boundary annotations
- **Combined (single-task):** `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` referencing spec content inline

## Invocation

`skill({name: "writing-plans"})` — orchestrator reads task file and executes steps inline.

**DISPATCH GATE — Inline execution of sub-agent tasks is FORBIDDEN.** Orchestrator-level tasks (`create`, `retroactive`, `completion`) are intentionally inline — the orchestrator reads the task file and executes steps directly. All sub-agent tasks within the 21-step pipeline (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern) MUST be dispatched via `task()`. Reading a sub-agent task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. Professional orchestrators route sub-agent tasks to sub-agents. Amateurs inline.

| Task | Execution |
|------|-----------|
| `create` | Orchestrator reads `tasks/create.md` and executes steps inline |
| `retroactive` | Orchestrator reads `tasks/retroactive.md` and executes steps inline |
| `completion` | Orchestrator reads `tasks/completion.md` and executes steps inline |

**CLI equivalent (for human TUI use):** `/skill writing-plans --task <task>`

## Operating Protocol — 21-Step Pipeline

**Execution model:** Under the hard limit that sub-agents cannot dispatch sub-agents, this skill's pipeline executes entirely at the orchestrator level. The orchestrator reads each step procedure and executes it directly. No `task()` calls are used within the pipeline.

Each item is tagged with chain dependency and contract paths.

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
