---
name: writing-plans
description: "Use when creating an implementation plan from an approved spec. Plans are the map — agents who skip them get lost."
type: discipline-enforcing
license: MIT
compatibility: opencode
---

# Skill: writing-plans

## Overview

Transforms approved specs into actionable implementation plans using hybrid structure: phases for concern boundaries, TDD steps within tasks for execution guidance. Every step is one action (2-5 min). No placeholders.



## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create plan" / "implementation plan" / "write plan" / "plan" / "draft plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

This skill produces plans by dispatching sub-agents. The orchestrator routes; sub-agents author. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW.

## Tasks


| `create` |
| `completion` |

## Plan Model

**All plans are local artifacts.** Plans are stored at `.issues/{N}/plan.md`. Phases are sections in the local plan file.

- **Separate (multi-task):** `.issues/{N}/plan.md` with stand-alone phase sections, each with concern boundary annotations
- **Combined (single-task):** `.issues/{N}/plan.md` referencing spec content inline

## Invocation

`skill({name: "writing-plans"})` — call the skill, then call via task():

| Task | Call via task() |

| `create` | `task(..., prompt: "execute create task from writing-plans")` |
| `completion` | `task(..., prompt: "execute completion task from writing-plans")` |

**CLI equivalent (for human TUI use):** `/skill writing-plans --task <task>`

## Operating Protocol

- [ ] 1. [inline] Verify spec is approved (check `approved-for-*` label) — chain: `none`
- [ ] 2. [sub-task: create] `task(..., prompt: "execute create task from writing-plans")` — input: `./tmp/{N}/contracts/create-input.yaml`, output: `./tmp/{N}/contracts/create-output.yaml`, template: `.opencode/skills/writing-plans/contracts/create-input-template.yaml`, chain: `none`
- [ ] 3. [inline] Invoke `solve model` for dependency-ordering constraints contract — chain: `step_2`
- [ ] 4. [inline] Invoke `solve check` to verify SAT — chain: `step_3`
- [ ] 5. [inline] Invoke `plan plan` for phase solvability validation — chain: `step_4`
- [ ] 6. [sub-task: write] `task(..., prompt: "execute write task from writing-plans")` — Write plan file to correct repo's `.issues/` worktree. Resolve target repo from session-init `## Repo Information` by matching issue's repo path prefix. Use `local-issues sync-file` for commit+push. URL uses resolved repo's `html_url`, `owner`, `repo`. chain: `step_5`
- [ ] 7. [sub-task: completion] `task(..., prompt: "execute completion task from writing-plans")` — input: `./tmp/{N}/contracts/completion-input.yaml`, output: `./tmp/{N}/contracts/completion-output.yaml`, template: `.opencode/skills/writing-plans/contracts/create-output-template.yaml` (shared), chain: `step_6`

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_issue_number, spec_body, worktree.path, github.owner, github.repo }`, excluding implementation context. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See adversarial-audit SKILL.md §DISPATCH_GATE. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`. See `020-go-prohibitions.md` §1.1.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync dev. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute create task from writing-plans" without task file path | "execute create task from writing-plans. Read `writing-plans/tasks/create.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

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

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `adversarial-audit --task plan-fidelity`, `adversarial-audit --task concern-separation`. References: `skill-card-change-types.md`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-01T00:00:00Z"
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
