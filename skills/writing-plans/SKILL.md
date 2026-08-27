---
name: writing-plans
description: "Generate implementation plans from approved specs with phase decomposition, self-contained code, TDD cycles, and execution handoff. Also load when verifying plan pipeline completeness or checking pipeline artifacts. Plans are REQUIRED before implementation. User phrases: create plan, verify plan pipeline, check pipeline completeness"
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: writing-plans

## Overview

Generate and validate implementation plans from approved specs. Flat architecture — no sub-skills, 7 task files. The orchestrator sequences a clean-room pipeline: HANDOFF (authorization verification) → ANALYZE (entry gates) → RESEARCH (scope discovery, structure, Z3 solving) → CREATE (plan writing) → VALIDATE (structural validation, holistic check) → (revise loop) → COMPLETION (lifecycle event). Each sub-agent receives only its scoped context — no preloaded reasoning, no orchestrator conclusions.

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Workflows

### Create a plan from an approved spec

- [ ] 1. **handoff** — Verifies authorization via approval-gate before plan creation pipeline begins
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [verify plan authorization handoff](.opencode/skills/writing-plans/tasks/handoff.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **analyze** — Verifies spec exists locally, checks approval from issue.yaml labels, validates analytical artifacts exist
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [verify plan preconditions](.opencode/skills/writing-plans/tasks/analyze.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 3. **research** — Decomposes SCs into phases, builds dependency DAG, selects skill+task, runs Z3 constraint solving
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [research plan phase structure](.opencode/skills/writing-plans/tasks/research.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 4. **create** — Writes self-contained plan with full implementation-workflow reference card per-task cycle
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [create implementation plan](.opencode/skills/writing-plans/tasks/create.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 5. **validate** — Runs structural validation, skill+task validity, SC coverage check, and holistic quality gate
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [validate plan structure](.opencode/skills/writing-plans/tasks/validate.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 6. **If validate returns FAIL:** Revises plan from validation findings (max 3 iterations, then HALT)
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [revise implementation plan](.opencode/skills/writing-plans/tasks/revise.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch
  - Then continue loop: return to step 3 (research) then step 5 (validate)

- [ ] 7. **If validate returns PASS:** Runs lifecycle event append, execution strategy determination, and summary report
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [complete plan workflow](.opencode/skills/writing-plans/tasks/completion.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

### Revise an existing plan

- [ ] 1. **handoff** — Verifies authorization via approval-gate before plan revision pipeline begins
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [verify plan authorization handoff](.opencode/skills/writing-plans/tasks/handoff.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **revise** — Revises plan content from revision reason
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [revise implementation plan](.opencode/skills/writing-plans/tasks/revise.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 3. **research** — Re-decomposes SCs into phases, builds dependency DAG, selects skill+task
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [research plan phase structure](.opencode/skills/writing-plans/tasks/research.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 4. **validate** — Runs structural validation, skill+task validity, SC coverage check, and holistic quality gate
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [validate plan structure](.opencode/skills/writing-plans/tasks/validate.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 5. **If validate returns FAIL:** Return to step 2 (revise) — max 3 iterations, then HALT
  - **Execution mode:** inline

- [ ] 6. **If validate returns PASS:** Runs lifecycle event append, execution strategy determination, and summary report
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [complete plan workflow](.opencode/skills/writing-plans/tasks/completion.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

### Retroactive plan (spec exists, no artifacts)

- [ ] 1. **handoff** — Verifies authorization via approval-gate before plan creation pipeline begins
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [verify plan authorization handoff](.opencode/skills/writing-plans/tasks/handoff.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **backfill** — Generates missing analytical artifacts from spec body when spec-creation did not produce them
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [backfill analytical artifacts](.opencode/skills/writing-plans/tasks/backfill.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 3. **research** — Decomposes SCs into phases, builds dependency DAG, selects skill+task, runs Z3 constraint solving
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [research plan phase structure](.opencode/skills/writing-plans/tasks/research.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 4. **create** — Writes self-contained plan with full implementation-workflow reference card per-task cycle
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [create implementation plan](.opencode/skills/writing-plans/tasks/create.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 5. **validate** — Runs structural validation, skill+task validity, SC coverage check, and holistic quality gate
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [validate plan structure](.opencode/skills/writing-plans/tasks/validate.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

- [ ] 6. **If validate returns FAIL:** Revises plan from validation findings (max 3 iterations, then HALT)
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [revise implementation plan](.opencode/skills/writing-plans/tasks/revise.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch
  - Then continue loop: return to step 3 (research) then step 5 (validate)

- [ ] 7. **If validate returns PASS:** Runs lifecycle event append, execution strategy determination, and summary report
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [complete plan workflow](.opencode/skills/writing-plans/tasks/completion.md). issue_number: ", issue_number, ", project_root: ", project_root, ", issues_prefix: ", issues_prefix))`
  - **Context passed:** `{issue_number, project_root, issues_prefix}`
  - **Returns:** `{status, artifact_path, finding_summary}`
  - **Execution mode:** sub-agent dispatch

## Task Cards

| File | Purpose |
|------|---------|
| `tasks/handoff.md` | Verify authorization via approval-gate before plan creation pipeline begins |
| `tasks/analyze.md` | Verify spec exists locally, check approval from issue.yaml labels, validate analytical artifacts exist |
| `tasks/backfill.md` | Generate missing analytical artifacts from spec body when spec-creation did not produce them |
| `tasks/research.md` | Decompose SCs into phases, build dependency DAG, select skill+task from implementation-workflow reference card Trigger Dispatch Table, run Z3 constraint solving |
| `tasks/create.md` | Write self-contained plan with full implementation-workflow reference card per-task cycle. Plan is structured markdown with English instructions. Every task enumerates every step from the implementation-workflow reference card's per-task cycle. No skipping, no combining, no grouping |
| `tasks/validate.md` | Structural validation, skill+task validity, SC coverage check, holistic quality gate |
| `tasks/revise.md` | Plan revision from validation findings with change tracking |
| `tasks/verify-plan-pipeline.md` | Verify plan pipeline completeness — validates that all writing-plans pipeline artifacts exist and are consistent |
| `tasks/completion.md` | Lifecycle event append, execution strategy determination, summary report |

## File Structure

```
writing-plans/
  SKILL.md
  tasks/
    handoff.md
    analyze.md
    backfill.md
    research.md
    create.md
    validate.md
    revise.md
    verify-plan-pipeline.md
    completion.md
  contracts/
    (18 templates — 9 input/output pairs)
  reference/
    plan-artifact-format.md
```

## Cross-References

Skills: `spec-creation` (upstream — produces the spec consumed by analyze), `approval-gate` (authorization gate before plan creation), `audit` (plan-audit), `solve` (Z3 constraint solver). Guidelines: `000-critical-rules.md` (clean-room discipline, monolithic implementation prohibition), `080-code-standards.md` (evidence type taxonomy, plan structure), `091-incremental-build.md` (per-item TDD cycle).
