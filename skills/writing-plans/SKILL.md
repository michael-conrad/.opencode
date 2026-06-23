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
| "create plan" / "implementation plan" / "write plan" | `create` | `sub-task` | {spec_issue_number, spec_body} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |

## Persona

Plan Author. Focus: transform spec into phased plan with file structure, TDD steps, and concern boundary annotations.

## Tasks


| `create` |
| `completion` |

## Plan Model

**All plans are local artifacts.** Plans use the multi-file format: master ToC + per-phase sub-plans.

- **Separate (multi-task):** Multi-file format — master ToC at `.issues/{N}/plan.md` (≤50 lines, phase list table with Depends On and Exit Criteria columns) + per-phase sub-plans at `.issues/{N}/plan-phase-{N}.md` (one per phase, each with YAML header, three-section structure, dispatch contracts, commits:true, and explicit checkpoint tag creation step)
- **Combined (single-task):** Single-file format — `.issues/{N}/plan.md` referencing spec content inline

## Invocation

`skill({name: "writing-plans"})` — call the skill, then call via task():

| Task | Call via task() |

| `create` | `task(..., prompt: "execute create task from writing-plans")` |
| `completion` | `task(..., prompt: "execute completion task from writing-plans")` |

**CLI equivalent (for human TUI use):** `/skill writing-plans --task <task>`

## Operating Protocol

- [ ] 1. **Plan from approved spec only.** No plan without approved spec.
- [ ] 2. **Adversarial-audit call:** after plan creation, call type-specific audit tasks directly — `adversarial-audit --task plan-fidelity` and `adversarial-audit --task concern-separation` — with `audit_phase: plan_creation`.
- [ ] 3. **TDD steps mandatory:** each step is RED→GREEN→REFACTOR within tasks.
- [ ] 4. **No placeholders:** exact file paths, exact function/class names, exact commands.
- [ ] 5. **Phase structure:** phases for concern boundaries and handoffs, tasks within phases for TDD steps.
- [ ] 6. **Decision gate:** multi-task → separate plan. Single-task + simple → combined or separate per agent judgment.
- [ ] 7. **Pipeline-readiness gate check (Step 0.5) + mandatory checklist generation (Step 6) required.** Plan creation must verify `sc-pipeline-readiness.yaml` PASS before proceeding, and generate `implementation-checklist.md` after plan content is finalized.

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

## Cross-References

Skills: `approval-gate`, `issue-operations`, `executing-plans`, `adversarial-audit --task plan-fidelity`, `adversarial-audit --task concern-separation`. Guidelines: `010-approval-gate.md`, `140-planning-spec-creation.md`.

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
