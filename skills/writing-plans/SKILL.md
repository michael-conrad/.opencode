---
name: writing-plans
description: "Generate implementation plans from approved specs with phase decomposition, self-contained code, TDD cycles, and execution handoff. Plans are REQUIRED before implementation."
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: writing-plans

## Overview

Generate and validate implementation plans from approved specs. Flat architecture — no sub-skills, 6 task files. The orchestrator sequences a clean-room pipeline: ANALYZE (entry gates) → RESEARCH (scope discovery, structure, Z3 solving) → CREATE (plan writing) → VALIDATE (structural validation, holistic check) → (revise loop) → COMPLETION (lifecycle event). Each sub-agent receives only its scoped context — no preloaded reasoning, no orchestrator conclusions.

## Workflows

### Create a plan from an approved spec

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| analyze | `task("execute analyze from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| research | `task("execute research from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| create | `task("execute create from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Max 3 iterations, then HALT |
| (continue loop) research | `task("execute research from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| (continue loop) validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

### Revise an existing plan

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| revise | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| research | `task("execute research from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | return to revise step | — | — | Max 3 iterations, then HALT |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

### Retroactive plan (spec exists, no artifacts)

| Step | Action | Context | Returns | On Failure |
|------|--------|---------|---------|------------|
| backfill | `task("execute backfill from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| research | `task("execute research from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| create | `task("execute create from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | HALT |
| validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| If validate returns FAIL | `task("execute revise from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Max 3 iterations, then HALT |
| (continue loop) research | `task("execute research from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |
| (continue loop) validate | `task("execute validate from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | Return to revise step |
| If validate returns PASS | `task("execute completion from writing-plans")` | `{issue_number, project_root, issues_prefix}` | `{status, artifact_path, finding_summary}` | — |

## Task Cards

| File | Purpose |
|------|---------|
| `tasks/analyze.md` | Verify spec exists locally, check approval from frontmatter, validate analytical artifacts exist |
| `tasks/backfill.md` | Generate missing analytical artifacts from spec body when spec-creation did not produce them |
| `tasks/research.md` | Decompose SCs into phases, build dependency DAG, select skill+task from implementation-workflow reference card Trigger Dispatch Table, run Z3 constraint solving |
| `tasks/create.md` | Write self-contained plan with full implementation-workflow reference card per-task cycle. Plan is structured markdown with English instructions. Every task enumerates every step from the implementation-workflow reference card's per-task cycle. No skipping, no combining, no grouping |
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
    research.md
    create.md
    validate.md
    revise.md
    completion.md
  contracts/
    (18 templates — 9 input/output pairs)
  reference/
    plan-artifact-format.md
```

## Cross-References

Skills: `spec-creation` (upstream — produces the spec consumed by analyze), `approval-gate` (authorization gate before plan creation), `audit` (plan-audit), `solve` (Z3 constraint solver). Guidelines: `000-critical-rules.md` (clean-room discipline, monolithic implementation prohibition), `080-code-standards.md` (evidence type taxonomy, plan structure), `091-incremental-build.md` (per-item TDD cycle).
