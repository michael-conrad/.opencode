---
name: plan-creation-pipeline
description: "Use when creating a plan from an approved spec through a formal 6-step pipeline with Z3-verified state transitions. Also use when validating phase solvability, grounding action schemas, or verifying dependency ordering. Invoke for: plan creation, pipeline execution, phase solvability validation, action grounding, dependency verification, state transition verification. Plan creation MUST use the structured pipeline — always required. — distinct from plan (formal AI planning) and writing-plans (orchestrator-level plan creation). Trigger phrases: create plan pipeline, run plan pipeline, validate phases, ground actions, verify dependencies, Z3 plan."
license: MIT
compatibility: opencode
---

# Skill: plan-creation-pipeline

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Overview

Pure orchestrator routing table with 6 serial dispatch steps for plan creation. The orchestrator holds only routing metadata — each step dispatches to an existing skill's task file via `task()`. Step transitions are validated by Z3 via `solve check` against `pipeline-state-machine.yaml`. YAML contract artifacts at `{project_root}/tmp/{issue-N}/artifacts/plan-pipeline-{step_label}-{STATUS}-{timestamp}.yaml`.

The orchestrator is a pure router — never reads task file content, never performs inline analysis. Sub-agents do the work.

## Persona

Plan creator. Routes each plan-creation step to a sub-agent that independently reads the spec and produces phase definitions. An orchestrator that creates plan content inline instead of dispatching to plan-authoring sub-agents has produced a self-authored plan, not an independently derived implementation structure — every phase definition carries the orchestrator's interpretation rather than an independent spec analysis. Professional plan creators dispatch to authoring sub-agents. Inlining means the plan was never independently derived from the spec.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Sub-agents must not dispatch sub-agents
- [ ] 5. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "plan-creation" / "create plan pipeline" | `plan-creation` | `sub-task` | {issue_number} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Dispatch Routing Table

| Step Label | Dispatches To | Artifact Produced |
|------------|---------------|-------------------|
| `spec-to-plan-handoff` | `approval-gate --task verify-authorization` | handoff artifact at `{project_root}/tmp/{issue-N}/artifacts/plan-pipeline-handoff-{STATUS}-{timestamp}.yaml` |
| `plan-create` | `writing-plans --task create` | plan index at `{N}/plan.md` + phase files at `{N}/plan-{NN}-*.md` |
| `solve-model` | `solve model` | dependency-ordering constraints contract at `{project_root}/tmp/{issue-N}/artifacts/plan-pipeline-solve-model-{STATUS}-{timestamp}.yaml` |
| `solve-check` | `solve check` | SAT verification at `{project_root}/tmp/{issue-N}/artifacts/plan-pipeline-solve-check-{STATUS}-{timestamp}.yaml` |
| `plan-plan` | `plan plan` | phase solvability validation at `{project_root}/tmp/{issue-N}/artifacts/plan-pipeline-plan-plan-{STATUS}-{timestamp}.yaml` |
| `plan-completion` | `local-issues sync` | commits plan to `.issues/` worktree (root repo) or `{project_root}/{path}/.issues/` worktree (submodule/sub-repo). Then produce chat output: detailed and formatted exec summary + URL to blob for spec folder on remote API (if remote API exists) + AI byline. No push, no issue comment, no approval cascade. |

## Step Labels

`spec-to-plan-handoff`, `plan-create`, `solve-model`, `solve-check`, `plan-plan`, `plan-completion`

## Invocation

`skill({name: "plan-creation-pipeline"})` — call the skill, then dispatch each step via task():

| Step | Call via task() |
|------|----------------|
| Any dispatch step | `task(..., prompt: "execute <step_label> from plan-creation-pipeline")` |

Every task context MUST include the authorization context block:

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

## Sub-Agent Routing

All substantive work runs via `task(subagent_type="general")`. The orchestrator is a pure router — no creative work, no file edits, no inline analysis. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include `audit_phase` in task context when routing auditors. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`.

Exclusions: implementation context, agent memory, cached verification results.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read plan-structure.md then execute step 1" | "execute plan-create from plan-creation-pipeline" |
| Preloaded step sequences | "Step 1: handoff. Step 2: create." | "execute plan-create from plan-creation-pipeline" |
| Preloaded expected outcomes | "Return { plan_path, status }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The spec was just approved so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute plan-create from plan-creation-pipeline" without task file path | "execute plan-create from plan-creation-pipeline. Read `writing-plans/tasks/create.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pr_strategy`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `writing-plans`, `approval-gate`, `completion-core`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`.

```yaml+symbolic
schema_version: "1.0"
last_updated: "2026-06-19T00:00:00Z"
rules:
  - id: plan-creation-pipeline-001
    title: "Plan creation requires approved spec"
    conditions:
      all: ["plan_creation_attempted == true", "spec_approved == false"]
    actions: [HALT]
    source: "plan-creation-pipeline/SKILL.md"
```
