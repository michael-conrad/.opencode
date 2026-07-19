---
name: writing-plans-creation
description: "Implementation plan creator that breaks approved specs into phases, tasks, and work breakdowns. Load via skill() when creating an implementation plan from an approved spec, breaking down work into phases, planning implementation steps, or creating task breakdowns. Also load when retroactively creating a plan for an existing spec, or backfilling plan documentation. Plans MUST be created before implementation. User phrases: create plan, break down work, plan phases, create task breakdown"
license: MIT
provenance: AI-generated
---

# Skill: writing-plans-creation

## Overview

Creates implementation plans from approved specs. Breaks work into phases, tasks, and work breakdowns. Supports retroactive plan creation for existing specs.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
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
| "pre-plan readiness" / "prerequisites check" | `pre-plan-readiness` | `sub-task` | {spec_issue_number} |
| "operating protocol" / "workflow docs" | `operating-protocol` | `sub-task` | {spec_issue_number} |
| "update plan" / "plan update" | `update` | `sub-task` | {spec_issue_number, plan_issue_number} |
| "holistic check" / "self-check" | `holistic-self-check` | `sub-task` | {plan_context} |

## Tasks

- artifact-validation.md
- audit-concern.md
- audit-fidelity.md
- clean-room.md
- completion.md
- create.md
- handoffs/ (directory)
- operating-protocol.md
- pre-plan-readiness.md
- readiness.md
- research.md
- retroactive.md
- revisit.md
- solve.md
- structure.md
- update.md
- validate.md
- write.md

## Contracts

- contracts/ (contract templates — see contracts/INDEX.md for mapping)

## Cross-References

Parent skill: `writing-plans`. Sub-skill: `writing-plans-holistic`. Skills: `spec-creation`, `approval-gate`, `implementation-pipeline`.

## Invocation

`skill({name: "writing-plans-creation"})` — orchestrator dispatches pipeline steps to sub-agents via `task()`.

**DISPATCH GATE — Pipeline steps dispatch to sub-agents.** The orchestrator routes each step to a clean-room sub-agent via `task()`. The orchestrator reads each step procedure from its task file and dispatches it. When external skills are needed (e.g., audit for fidelity/concern audits), invoke them via `skill({name: "..."})` with the appropriate task, dispatched to a sub-agent.

| Task | Canonical Dispatch String |
|------|--------------------------|
| `verify-spec-approved` | `task(..., prompt: "execute verify-spec-approved from writing-plans-creation. Read \`writing-plans-creation/tasks/pre-plan-readiness.md\` first")` |
| `research` | `task(..., prompt: "execute research from writing-plans-creation. Read \`writing-plans-creation/tasks/research.md\` first")` |
| `artifact-validation` | `task(..., prompt: "execute artifact-validation from writing-plans-creation. Read \`writing-plans-creation/tasks/artifact-validation.md\` first")` |
| `readiness` | `task(..., prompt: "execute readiness from writing-plans-creation. Read \`writing-plans-creation/tasks/readiness.md\` first")` |
| `structure` | `task(..., prompt: "execute structure from writing-plans-creation. Read \`writing-plans-creation/tasks/structure.md\` first")` |
| `solve` | `task(..., prompt: "execute solve from writing-plans-creation. Read \`writing-plans-creation/tasks/solve.md\` first")` |
| `write` | `task(..., prompt: "execute write from writing-plans-creation. Read \`writing-plans-creation/tasks/write.md\` first")` |
| `revisit` | `task(..., prompt: "execute revisit from writing-plans-creation. Read \`writing-plans-creation/tasks/revisit.md\` first")` |
| `validate` | `task(..., prompt: "execute validate from writing-plans-creation. Read \`writing-plans-creation/tasks/validate.md\` first")` |
| `audit-fidelity` | `task(..., prompt: "execute audit-fidelity from writing-plans-creation. Read \`writing-plans-creation/tasks/audit-fidelity.md\` first")` |
| `audit-concern` | `task(..., prompt: "execute audit-concern from writing-plans-creation. Read \`writing-plans-creation/tasks/audit-concern.md\` first")` |
| `completion` | `task(..., prompt: "execute completion from writing-plans-creation. Read \`writing-plans-creation/tasks/completion.md\` first")` |
| `retroactive` | `task(..., prompt: "execute retroactive from writing-plans-creation. Read \`writing-plans-creation/tasks/retroactive.md\` first")` |
| `clean-room` | `task(..., prompt: "execute clean-room from writing-plans-creation. Read \`writing-plans-creation/tasks/clean-room.md\` first")` |
| `pre-plan-readiness` | `task(..., prompt: "execute pre-plan-readiness from writing-plans-creation. Read \`writing-plans-creation/tasks/pre-plan-readiness.md\` first")` |
| `operating-protocol` | `task(..., prompt: "execute operating-protocol from writing-plans-creation. Read \`writing-plans-creation/tasks/operating-protocol.md\` first")` |
| `update` | `task(..., prompt: "execute update from writing-plans-creation. Read \`writing-plans-creation/tasks/update.md\` first")` |
| `holistic-self-check` | `task(..., prompt: "execute holistic-self-check from writing-plans-creation. Read \`writing-plans-holistic/tasks/holistic-self-check.md\` first")` |

**CLI equivalent (for human TUI use):** `` `skill({name: "writing-plans-creation"})` ``
