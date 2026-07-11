---
name: spec-creation
description: "Specification authoring skill that decomposes problems into success criteria and documents requirements. Dispatch when creating a spec, writing a specification, drafting requirements, authoring a spec document, or specifying a feature. Also dispatch when decomposing a problem into success criteria, extracting requirements, or documenting change control. Spec creation is REQUIRED before implementation. User phrases: write spec, create spec, draft spec, write specification, create specification, draft specification, spec out, author spec, document requirements, specify feature, write requirements, create requirements doc, decompose problem, define success criteria, extract requirements, document change control, create a spec, write a spec, draft a spec, create a specification, write a specification, draft a specification, author a spec, make a spec, make specification, spec it out."
license: MIT
compatibility: opencode
---

# Skill: spec-creation

## Overview

Structured discipline for spec writing. Enforces requirements extraction, analytical discovery (concern analysis, blast radius, cross-cutting concerns, code path analysis, interface compatibility, state analysis, testability assessment), problem decomposition, interface-first thinking, constraints ledgers, risk analysis, traceability, and change control. Invoked after brainstorming exploration.

The pipeline now includes analytical discovery tasks that MUST complete before structural validation. Skipping analytical tasks produces structurally valid but analytically shallow specs — the spec passes format checks but misses semantic depth, cross-cutting impacts, and testability constraints.

Pipeline: `brainstorming → spec-creation → audit --task spec-audit → approval-gate → writing-plans`

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.
- [ ] 5. **Analytical discovery tasks MUST complete before structural validation.** The pipeline includes 7 analytical tasks (concern-analysis, blast-radius, cross-cutting, code-path-analysis, interface-compatibility, state-analysis, testability-assessment) that execute between requirements extraction and the pipeline-readiness-gate. These tasks surface semantic depth, cross-cutting impacts, and testability constraints that structural validation alone cannot detect. Skipping analytical tasks produces structurally valid but analytically shallow specs — the spec passes format checks but misses the analytical depth required for robust implementation.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "create spec" / "write spec" / "draft spec" / "create specification" / "write specification" / "draft specification" / "spec out" / "author spec" / "document requirements" / "specify feature" / "write requirements" / "create requirements doc" / "create a spec" / "write a spec" / "draft a spec" / "create a specification" / "write a specification" / "draft a specification" / "author a spec" / "make a spec" / "make specification" / "spec it out" | `create` | `sub-task` | {spec_context} |
| "extract requirements" / "requirements extraction" | `requirements` | `sub-task` | {spec_context} |
| "concern analysis" / "concern boundary" | `concern-analysis` | `sub-task` | {spec_context} |
| "decompose problem" / "problem decomposition" | `decompose` | `sub-task` | {spec_context} |
| "blast radius" / "impact analysis" | `blast-radius` | `sub-task` | {spec_context} |
| "cross-cutting" / "cross-cutting concerns" | `cross-cutting` | `sub-task` | {spec_context} |
| "traceability" / "trace requirements" | `traceability` | `sub-task` | {spec_context} |
| "code path analysis" / "code path" | `code-path-analysis` | `sub-task` | {spec_context} |
| "interface compatibility" / "interface check" | `interface-compatibility` | `sub-task` | {spec_context} |
| "state analysis" / "state transition" | `state-analysis` | `sub-task` | {spec_context} |
| "pipeline readiness" / "readiness gate" | `pipeline-readiness-gate` | `sub-task` | {spec_context} |
| "testability assessment" / "testability" | `testability-assessment` | `sub-task` | {spec_context} |
| "risk analysis" / "risk assessment" | `risk` | `sub-task` | {spec_context} |
| "completion" / "spec complete" | `completion` | `sub-task` | {spec_context} |
| "change control" / "revision" / "spec revision" | `change-control` | `sub-task` | {spec_context} |

## Persona

This skill produces specs by dispatching sub-agents. The orchestrator routes; sub-agents write. An orchestrator that writes a spec inline instead of dispatching to a sub-agent has stopped being a router and started being a contaminant — every inline-written spec carries the orchestrator's preloaded bias through every downstream verification gate, and the pipeline is poisoned from the first byte. Sub-agents are intelligent agents, not dumb terminals — they read specs and use skills autonomously. The orchestrator MUST NOT prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. Professional orchestrators route to sub-agents. Inlining the write task means the spec was never independently produced — it was authored by the same context that will later verify it, making every subsequent gate a self-review.

> **Micro-management prohibition:** The sub-agents that implement this spec/plan are intelligent agents, not dumb terminals. They read specs and use skills autonomously. Do not prescribe exact file paths, line numbers, step sequences, or expected outcomes. Specify WHAT and WHY — not HOW. The implementing agent discovers scope independently and produces its own result contract.

## Tasks

| Task                      |
| ------------------------- |
| `requirements`            |
| `concern-analysis`        |
| `decompose`               |
| `blast-radius`            |
| `cross-cutting`           |
| `traceability`            |
| `code-path-analysis`      |
| `interface-compatibility` |
| `state-analysis`          |
| `pipeline-readiness-gate` |
| `testability-assessment`  |
| `risk`                    |
| `create`                  |
| `completion`              |
| `change-control`          |

## Invocation

`skill({name: "spec-creation"})` — call the skill, then call via task().

**DISPATCH GATE — Inline execution is FORBIDDEN.** Every task in this table MUST be dispatched to a clean-room sub-agent via `task()`. Reading a task file and executing its steps inline in the orchestrator context means every quality gate in that task was silently bypassed — the task's entry criteria, exit criteria, verification steps, and audit gates all fire inside the sub-agent's context, not the orchestrator's. An orchestrator that inlines a task has produced a deliverable that was never independently verified. Professional orchestrators route to sub-agents. Amateurs inline.

| Task                      | Call via task()                                                                       |
| ------------------------- | ------------------------------------------------------------------------------------- |
| `requirements`            | `task(..., prompt: "execute requirements task from spec-creation")`                    |
| `concern-analysis`        | `task(..., prompt: "execute concern-analysis task from spec-creation")`                |
| `decompose`               | `task(..., prompt: "execute decompose task from spec-creation")`                       |
| `blast-radius`            | `task(..., prompt: "execute blast-radius task from spec-creation")`                    |
| `cross-cutting`           | `task(..., prompt: "execute cross-cutting task from spec-creation")`                    |
| `traceability`            | `task(..., prompt: "execute traceability task from spec-creation")`                    |
| `code-path-analysis`      | `task(..., prompt: "execute code-path-analysis task from spec-creation")`              |
| `interface-compatibility` | `task(..., prompt: "execute interface-compatibility task from spec-creation")`          |
| `state-analysis`          | `task(..., prompt: "execute state-analysis task from spec-creation")`                  |
| `pipeline-readiness-gate` | `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")`         |
| `testability-assessment`  | `task(..., prompt: "execute testability-assessment task from spec-creation")`          |
| `risk`                    | `task(..., prompt: "execute risk task from spec-creation")`                             |
| `create`                  | `task(..., prompt: "execute create task from spec-creation")`                           |
| `completion`              | `task(..., prompt: "execute completion task from spec-creation")`                      |
| `change-control`          | `task(..., prompt: "execute change-control task from spec-creation")`                  |

**CLI equivalent (for human TUI use):** `` `skill({name: "spec-creation"})` ``

## Operating Protocol

See `spec-creation/tasks/operating-protocol.md` for the full 22-step pipeline with chain dependencies and contract paths.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")` with `{ spec_context, worktree.path, github.owner, github.repo }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. Exclusions: implementation context, agent memory. `pre-analysis` receives only `{ issue_number, task_description, github.owner, github.repo }`. No inline work.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation                        | Forbidden Pattern                                    | Correct Pattern                              |
| -------------------------------- | ---------------------------------------------------- | -------------------------------------------- |
| Preloaded file paths             | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow"     |
| Preloaded step sequences         | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch."           | "execute cleanup task from git-workflow"     |
| Preloaded expected outcomes      | "Return { cleanup_status, branch_deleted }"          | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..."      | Pure objective, no narrative                 |

#### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
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

## Operating Protocol

- [ ] 1. **Pre-spec investigation:** Codebase investigation mandatory before requirements extraction when spec touches existing code
- [ ] 2. **Verification-enforcement gate:** Call `verification-enforcement --task verify` before spec generation
- [ ] 3. **Concern enumeration guard:** Single Concern Principle — enumerate concerns before write task
- [ ] 4. **Pipeline-readiness gate:** Run `pipeline-readiness-gate` between traceability and risk steps

## Cross-References

Skills: `brainstorming`, `verification-enforcement`, `issue-operations`, `audit --task spec-audit`. References: `skill-card-change-types.md`. Guidelines: `015-pre-spec-inspection.md`, `000-critical-rules.md`.


```
