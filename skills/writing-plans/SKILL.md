---
name: writing-plans
description: "Generate implementation plans from approved specs with phase decomposition, self-contained code, TDD cycles, and execution handoff. Plans are REQUIRED before implementation."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: writing-plans

## Overview

Generate and validate implementation plans from approved specs. Flat architecture — no sub-skills, 9 task files. The orchestrator sequences a clean-room pipeline: ANALYSIS (entry gates) → PRODUCTION (plan creation/update) → VERIFICATION (Z3 solving, structural validation, holistic check) → COMPLETION (lifecycle event). Each sub-agent receives only its scoped context — no preloaded reasoning, no orchestrator conclusions.

## Workflows

### Create a plan from an approved spec

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| analyze | `task("execute analyze from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| explore | `skill("explore")` → `task("execute explore from explore")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| structure | `task("execute structure from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| solve | `skill("solve")` → `task("execute solve from solve")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to structure step |
| create | `task("execute create from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| self-review | `task("execute self-review from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to create step |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Max 3 iterations, then HALT |
| (continue loop) solve | `skill("solve")` → `task("execute solve from solve")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| (continue loop) validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

### Revise an existing plan

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| revise | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| solve | `skill("solve")` → `task("execute solve from solve")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | return to revise step | — | — | Max 3 iterations, then HALT |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

### Retroactive plan (spec exists, no artifacts)

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| backfill | `task("execute backfill from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| explore | `skill("explore")` → `task("execute explore from explore")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| structure | `task("execute structure from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| solve | `skill("solve")` → `task("execute solve from solve")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to structure step |
| create | `task("execute create from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| self-review | `task("execute self-review from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to create step |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Max 3 iterations, then HALT |
| (continue loop) solve | `skill("solve")` → `task("execute solve from solve")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| (continue loop) validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

## Task Cards

| File | Purpose |
|------|---------|
| `tasks/analyze.md` | Verify spec exists locally, check approval from frontmatter, validate analytical artifacts exist |
| `tasks/backfill.md` | Generate missing analytical artifacts from spec body when spec-creation did not produce them |
| `tasks/structure.md` | Decompose SCs into phases, build dependency DAG, select skill+task from implementation-pipeline TDT |
| `tasks/create.md` | Write self-contained plan with full implementation-pipeline workflow per task. Plan is structured markdown with English instructions. Every task enumerates every step from the implementation-pipeline's per-task cycle. No skipping, no combining, no grouping |
| `tasks/self-review.md` | Scan plan for placeholder patterns, SC coverage gaps, type/name inconsistencies, verify every task follows every step from the implementation-pipeline's per-task cycle |
| `tasks/solve.md` | Z3 constraint solving via `tools/solve` and `tools/plan` for dependency DAG verification |
| `tasks/validate.md` | Structural validation, skill+task validity, SC coverage check, holistic quality gate |
| `tasks/revise.md` | Plan revision from validation findings with change tracking |
| `tasks/completion.md` | Lifecycle event append, execution strategy determination, summary report |

## File Structure

```
writing-plans/
  SKILL.md
  tasks/
    analyze.md
    backfill.md
    structure.md
    create.md
    self-review.md
    solve.md
    validate.md
    revise.md
    completion.md
  contracts/
    (18 templates — 9 input/output pairs)
  reference/
    plan-artifact-format.md
```

## Cross-References

Skills: `spec-creation` (upstream — produces the spec consumed by analyze), `approval-gate` (authorization gate before plan creation), `implementation-pipeline` (downstream — consumes the plan), `audit` (plan-audit), `solve` (Z3 constraint solver), `explore` (upstream — codebase exploration). Guidelines: `000-critical-rules.md` (clean-room discipline, monolithic implementation prohibition), `080-code-standards.md` (evidence type taxonomy, plan structure), `091-incremental-build.md` (per-item TDD cycle).
