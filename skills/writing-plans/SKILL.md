---
name: writing-plans
description: "Generate and validate implementation plans from approved specs with phase decomposition, dependency DAG verification via Z3 constraint solving, fidelity checks against spec success criteria, and holistic quality validation. Plans are REQUIRED before implementation."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: writing-plans

## Overview

Generate and validate implementation plans from approved specs. Flat architecture — no sub-skills, 7 task files. The orchestrator sequences a 4-category clean-room pipeline: ANALYSIS (entry gates) → PRODUCTION (plan creation/update) → VERIFICATION (Z3 solving, structural validation, holistic check) → COMPLETION (lifecycle event). Each sub-agent receives only its scoped context — no preloaded reasoning, no orchestrator conclusions.

## Pipeline Sequence

The orchestrator dispatches each step as a clean-room `task()` call. The orchestrator does NOT perform inline work.

Two pipeline paths:

```
# Standard (spec with artifacts)
analyze → create → solve → validate → (revise → solve → validate)* → completion

# Retroactive (no existing artifacts)
retroactive → create → solve → validate → (revise → solve → validate)* → completion
```

## Data Flow: Disk-Only, Frugal Contracts

All plan data lives on disk. Sub-agents receive only paths in their `task()` context. Result contracts return only routing-significant data: `status`, `artifact_path`, `finding_summary`, `blocker_reason`. No data structures are passed via context.

Every sub-agent receives exactly: `{issue_number, project_root, issues_prefix}`

| Data | Location | Written By | Read By |
|---|---|---|---|
| Plan artifact | `{issues_prefix}/{N}/plan.md` | create.md | solve.md, validate.md, revise.md, completion.md, executor |
| Dependency contract | `{issues_prefix}/{N}/dependency-contract.yaml` | create.md | solve.md, revise.md |
| Validation findings | `{issues_prefix}/{N}/artifacts/validate-findings.yaml` | validate.md | revise.md |
| Revision reason | `{issues_prefix}/{N}/artifacts/revision-reason.yaml` | Caller (orchestrator) | revise.md |
| Analysis artifacts | `{issues_prefix}/{N}/artifacts/` | spec-creation | analyze.md, create.md |
| Solve output | `{issues_prefix}/{N}/artifacts/solve-output.yaml` | solve.md | orchestrator (reads from disk to route) |

## Workflows

### Create a plan from an approved spec

1. **analyze** — Dispatch `task(..., prompt: "execute analyze from writing-plans. Read \`skills/writing-plans/tasks/analyze.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

2. **create** — Dispatch `task(..., prompt: "execute create from writing-plans. Read \`skills/writing-plans/tasks/create.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

3. **solve** — Dispatch `task(..., prompt: "execute solve from writing-plans. Read \`skills/writing-plans/tasks/solve.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

4. **validate** — Dispatch `task(..., prompt: "execute validate from writing-plans. Read \`skills/writing-plans/tasks/validate.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

5. **If validate returns FAIL:**
   - Orchestrator writes revision reason to `{issues_prefix}/{N}/artifacts/revision-reason.yaml`
   - Dispatch `task(..., prompt: "execute revise from writing-plans. Read \`skills/writing-plans/tasks/revise.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`
   - Then return to step 3 (re-run solve, then re-run validate)
   - Max 3 iterations. If exhausted: BLOCKED with escalation

6. **If validate returns PASS:**
   - Dispatch `task(..., prompt: "execute completion from writing-plans. Read \`skills/writing-plans/tasks/completion.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`
   - Plan is ready. Report plan_path.

### Create a retroactive plan (no existing artifacts)

1. **retroactive** — Dispatch `task(..., prompt: "execute retroactive from writing-plans. Read \`skills/writing-plans/tasks/retroactive.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

2-6. Same as Create workflow steps 2-6.

### Revise an existing plan

1. Orchestrator writes revision reason to `{issues_prefix}/{N}/artifacts/revision-reason.yaml`
   - Dispatch `task(..., prompt: "execute revise from writing-plans. Read \`skills/writing-plans/tasks/revise.md\` first")`
   - **Context passed:** `{issue_number, project_root, issues_prefix}`
   - **Returns:** `{status, artifact_path, finding_summary}`

2. **solve** — Same as Create workflow step 3
3. **validate** — Same as Create workflow step 4
4. If validate returns FAIL, return to step 1 (max 3 iterations). If PASS, dispatch completion.

## Task Files

| File | Category | Purpose |
|------|----------|---------|
| `tasks/analyze.md` | ANALYSIS | Strict entry gate — verifies spec exists, analytical artifacts exist, pre-plan readiness |
| `tasks/retroactive.md` | ANALYSIS | Lenient entry gate — backfills missing analytical artifacts for existing specs |
| `tasks/create.md` | PRODUCTION | Pipeline discovery, phase decomposition, routing table generation, plan YAML assembly |
| `tasks/solve.md` | VERIFICATION | Z3 constraint solving via `tools/solve` and `tools/plan` for dependency DAG verification |
| `tasks/validate.md` | VERIFICATION | Structural validation, skill+task validity, SC coverage check, holistic quality gate |
| `tasks/revise.md` | PRODUCTION | Plan revision from validation findings with change tracking |
| `tasks/completion.md` | COMPLETION | Lifecycle event append, execution strategy determination, summary report |

## Cross-References

Skills: `spec-creation` (upstream — produces the spec consumed by analyze), `approval-gate` (authorization gate before plan creation), `implementation-pipeline` (downstream — consumes the plan), `audit` (plan-audit), `solve` (Z3 constraint solver). Guidelines: `000-critical-rules.md` (clean-room discipline, monolithic implementation prohibition), `080-code-standards.md` (evidence type taxonomy, plan structure), `091-incremental-build.md` (per-item TDD cycle).
