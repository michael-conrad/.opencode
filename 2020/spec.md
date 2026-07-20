---
title: "[BUG] Systemic: dispatch boundary violations across skill deck — Invocation pipelines, task card task() calls, and orchestrator entry points"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2020
authors:
  - OpenCode (deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2020/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2020)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2020/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Supersession

This spec **supersedes and subsumes** the following open issues:

| Issue | Title | Subsumption Rationale |
|-------|-------|----------------------|
| **#2018** | `[BUG] spec-creation SKILL.md Invocation dispatches pipeline with [sub-task] steps` | **FULLY SUBSUMED** — specific instance of the systemic Invocation dispatch pattern. The 25-step `create` pipeline is one of many. |
| **#1372** | `[SPEC-FIX] writing-plans: Trigger Dispatch Table classifies orchestrator tasks as sub-task` | **FULLY SUBSUMED** — specific instance of the same category error in writing-plans. `create`, `retroactive`, `completion` misclassified as `sub-task`. |
| **#1992** | `[SPEC] Sub-agents MUST NOT dispatch sub-agents` | **PARTIALLY SUBSUMED** — the architectural invariant (task cards MUST NOT contain `task()` calls) is the mirror of #2020's concern (SKILL.md Invocation dispatching pipelines to sub-agents). Both are the same boundary violation: orchestrator-level content in sub-agent-facing files, and vice versa. The 9 violating task cards across spec-creation and writing-plans are in scope. The `analytical-artifacts.md` category error (sub-agent card with orchestrator instructions) is also in scope. |
| **#1376** | `[SPEC-FIX] implementation-pipeline SKILL.md missing orchestrator entry point` | **PARTIALLY SUBSUMED** — the missing `assemble-work` task file, missing orchestrator entry point in Trigger Dispatch Table, and stale step counts are instances of the same dispatch boundary confusion. The PR #965 rename (assemble-work → pipeline-executor) is a category error in the same class. |
| **#1987** | `[SPEC] Fix audit skill DiMo chain` | **PARTIALLY SUBSUMED** — Pattern 2 (orchestrator dispatches SKILL.md to sub-agent) is the same category error. The audit-specific DiMo chain fixes (arbiter fragmentation, cross-chain dependency) remain in #1987's scope. |

**The following related issues are NOT subsumed and remain independent:**

| Issue | Title | Rationale |
|-------|-------|-----------|
| **#1994** | `[SPEC-FIX] Plan writer produces structurally defective plans` | Downstream of the dispatch boundary issue. Plan output format (flat file, dispatch instructions, clean-room context) is a separate concern. |
| **#1784** | `[SPEC] Structural dispatch-gate enforcement + DISPATCH_GATE completeness` | SKILL.md content structure (routing-only vs procedure text) and DISPATCH_GATE completeness is a different dimension from the Invocation dispatch pattern. |
| **#1961** | `[SPEC] Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern` | Description frontmatter field pattern ("Dispatch when" → "Load via skill() when") is a content-only change to 60 SKILL.md files. Independent concern. |

## Problem

Three related dispatch boundary violations exist across the skill deck:

### Violation A: SKILL.md Invocation dispatches pipelines with `[sub-task]` steps to sub-agents

Multiple skill cards have Invocation sections that dispatch entire pipelines (containing `[sub-task]` steps) to sub-agents via `task()`. A sub-agent **cannot** call `task()` — that is an orchestrator-level capability. The dispatched sub-agent receives a pipeline it cannot execute.

**Affected skills (non-exhaustive):**
- `spec-creation/SKILL.md` — `create` pipeline has 25 steps, many marked `[sub-task]`
- `spec-creation-decomposition/` — sub-skill with multiple task files
- `spec-creation-validation/` — sub-skill with multiple task files
- `writing-plans/SKILL.md` — `create`, `retroactive`, `completion` misclassified
- Any other skill whose Invocation section dispatches a pipeline to a sub-agent

### Violation B: Task cards contain `task()` calls (sub-agent → sub-sub-agent)

Multiple task cards across the skill deck contain `task()` calls that instruct the dispatched sub-agent to dispatch further sub-agents. This creates nested dispatch chains (orchestrator → sub-agent → sub-sub-agent) that cannot execute — sub-agents do not have access to the `task()` tool.

**Violating task cards (9 identified):**

| Task Card | File | task() Calls |
|-----------|------|-------------|
| `create.md` | `spec-creation-validation/tasks/create.md` | 8+ |
| `completion.md` | `spec-creation-validation/tasks/completion.md` | 2 |
| `change-control.md` | `spec-creation-change-control/tasks/change-control.md` | 1 |
| `analytical-artifacts.md` | `spec-creation-decomposition/tasks/analytical-artifacts.md` | 7 (orchestrator-level) |
| `operating-protocol.md` | `spec-creation-operating-protocol/tasks/operating-protocol.md` | 17 |
| `create.md` | `writing-plans-creation/tasks/create.md` | 1 |
| `completion.md` | `writing-plans-creation/tasks/completion.md` | 1 |
| `retroactive.md` | `writing-plans-creation/tasks/retroactive.md` | 9 |
| `update.md` | `writing-plans-creation/tasks/update.md` | 1 |

### Violation C: Missing orchestrator entry points in Trigger Dispatch Tables

Some skills have Trigger Dispatch Tables that only list step-level sub-task triggers, with no orchestrator entry point. The orchestrator has no trigger to match when it needs to enter the skill.

**Affected skills:**
- `implementation-pipeline/SKILL.md` — no orchestrator entry point for "execute plan" / "implement spec". The `assemble-work` task file does not exist (referenced from 4+ files but never created). PR #965 renamed `assemble-work` → `pipeline-executor` — a category error conflating the orchestrator entry point with the internal step dispatch table.

## Root Cause

The skill card template/pattern was designed with the assumption that a sub-agent can execute a multi-step pipeline that includes sub-agent dispatches. This is a category error: dispatching orchestrator-level routing instructions (which include `task()` calls) to a sub-agent.

The artifact type distinction (Skill Card vs Task Card) was established in #1932 but never systemically enforced:

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The Invocation section should tell the orchestrator what to dispatch (a task card), not tell it to dispatch the entire pipeline to a sub-agent. Task cards should contain sub-agent-executable procedures, not orchestrator-level routing instructions.

## Scope

### In scope

| Area | Files | Work Required |
|------|-------|--------------|
| SKILL.md Invocation sections | All `skills/*/SKILL.md` | Audit for pipelines with `[sub-task]` steps dispatched to sub-agents. Fix: orchestrator executes pipeline, dispatches each step individually. |
| Task cards with `task()` calls | 9 files in `spec-creation-*/tasks/` and `writing-plans-*/tasks/` | Remove `task()` calls. Move dispatch logic to parent SKILL.md Trigger Dispatch Table. Task cards become pure sub-agent procedures. |
| `analytical-artifacts.md` category error | `spec-creation-decomposition/tasks/analytical-artifacts.md` | Convert from orchestrator-level instructions to sub-agent-executable procedure, or move orchestrator-level content to SKILL.md. |
| `implementation-pipeline/SKILL.md` | SKILL.md + `tasks/assemble-work.md` (create) | Add orchestrator entry point. Create `assemble-work.md` task file. Fix PR #965 rename defect. |
| `writing-plans/SKILL.md` | SKILL.md | Fix `create`, `retroactive`, `completion` dispatch classification from `sub-task` to `orchestrator`. |
| `000-critical-rules.md` | guidelines | Add critical violation entry for sub-agent task() dispatch. |
| Behavioral enforcement tests | `tests-v2/behaviors/` | Tests for each violation type. |

### Out of scope

- Plan output format (covered by #1994)
- DISPATCH_GATE completeness on 3 cards (covered by #1784)
- SKILL.md description pattern rewrite (covered by #1961)
- Audit skill DiMo chain beyond Pattern 2 (covered by #1987)

## Approach

### Phase 1: Audit and classify all SKILL.md Invocation sections

For each SKILL.md in `.opencode/skills/*/SKILL.md`:
1. Read the Invocation section
2. Classify each entry: does it dispatch a pipeline (multiple steps) or a single task card?
3. If pipeline with `[sub-task]` steps: mark for fix (orchestrator executes pipeline)
4. If single task card: no change needed
5. If missing orchestrator entry point: mark for addition

### Phase 2: Fix SKILL.md Invocation sections

For each marked SKILL.md:
1. Change Invocation entries that dispatch pipelines to `inline` (orchestrator executes)
2. Ensure each `[sub-task]` step in the pipeline has its own dispatch entry in the Trigger Dispatch Table
3. Add missing orchestrator entry points

### Phase 3: Fix task cards with `task()` calls

For each of the 9 violating task cards:
1. Remove all `task()` calls
2. Move the dispatch logic to the parent SKILL.md Trigger Dispatch Table
3. The task card becomes a pure sub-agent procedure (no `task()` calls, no orchestrator-level instructions)

### Phase 4: Fix `analytical-artifacts.md` category error

Convert from orchestrator-level instructions to sub-agent-executable procedure, or move orchestrator-level content to the SKILL.md.

### Phase 5: Create `assemble-work.md` and fix `implementation-pipeline/SKILL.md`

1. Create `tasks/assemble-work.md` with orchestrator entry point behaviors
2. Add orchestrator entry point to Trigger Dispatch Table
3. Fix `pipeline-executor.md` — remove stale step count, clarify it is the internal step dispatch table (not the orchestrator entry point)
4. Fix SKILL.md description, Overview, Invocation, and Sub-Agent Routing sections

### Phase 6: Fix `writing-plans/SKILL.md` dispatch classification

1. Change `create`, `retroactive`, `completion` from `sub-task` to `orchestrator`
2. Update Invocation table accordingly
3. Fix `audit-fidelity.md` and `audit-concern.md` — remove "with auditor sub-agent type context"
4. Fix `create.md` operating protocol — add missing steps
5. Fix `completion.md` — remove all `task()` calls and skill invocations
6. Fix `retroactive.md` — align with 21-step pipeline, remove sub-task dispatches
7. Purge deprecated `tasks/create/` subdirectory

### Phase 7: Add critical violation to guidelines

Add entry to `000-critical-rules.md` for sub-agent task() dispatch.

### Phase 8: Behavioral enforcement tests

Create behavioral tests that verify:
1. After `skill("spec-creation")`, orchestrator does NOT dispatch the `create` pipeline to a sub-agent
2. Task cards in spec-creation and writing-plans do not contain `task()` calls
3. `implementation-pipeline/SKILL.md` has an orchestrator entry point
4. `writing-plans/SKILL.md` classifies `create` as `orchestrator`, not `sub-task`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No SKILL.md Invocation section dispatches a pipeline with `[sub-task]` steps to a sub-agent | `string` | grep for `[sub-task]` in Invocation sections — 0 matches |
| SC-2 | All 9 violating task cards have no `task()` calls | `string` | grep for `task(` in each violating task card — 0 matches |
| SC-3 | `analytical-artifacts.md` does not contain orchestrator-level instructions | `semantic` | Sub-agent reads file — confirms sub-agent-executable procedure |
| SC-4 | `implementation-pipeline/SKILL.md` has orchestrator entry point in Trigger Dispatch Table | `string` | grep for "execute plan" or "implement spec" in Trigger Dispatch Table — present |
| SC-5 | `tasks/assemble-work.md` exists | `structural` | `ls tasks/assemble-work.md` — file exists |
| SC-6 | `writing-plans/SKILL.md` classifies `create` as `orchestrator` | `string` | grep for `create.*orchestrator` in SKILL.md — present |
| SC-7 | `writing-plans/SKILL.md` classifies `retroactive` as `orchestrator` | `string` | grep for `retroactive.*orchestrator` in SKILL.md — present |
| SC-8 | `writing-plans/SKILL.md` classifies `completion` as `orchestrator` | `string` | grep for `completion.*orchestrator` in SKILL.md — present |
| SC-9 | `completion.md` contains no `task()` calls | `string` | grep for `task(` in completion.md — 0 matches |
| SC-10 | `retroactive.md` contains no sub-task dispatches | `string` | grep for `task(` in retroactive.md — 0 matches |
| SC-11 | `tasks/create/` subdirectory does not exist | `structural` | `ls tasks/create/` returns no such file |
| SC-12 | `pipeline-executor.md` does not contain a stale step count | `string` | grep for `[0-9]+-step` in pipeline-executor.md — absent |
| SC-13 | `000-critical-rules.md` has entry for sub-agent task() dispatch | `string` | grep for "sub-agent.*task()" or "task().*sub-agent" in critical-rules.md — present |
| SC-14 | Behavioral test verifies orchestrator does not dispatch pipeline to sub-agent | `behavioral` | `opencode run` → stderr shows no pipeline dispatch to sub-agent |
| SC-15 | Behavioral test verifies task cards have no `task()` calls | `behavioral` | `opencode run` → stderr shows no task() from task card context |

## Dependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| #1994 | Downstream — plan format depends on dispatch boundary being correct | Implement #2020 first |
| #1784 | Independent — DISPATCH_GATE completeness is separate dimension | Can proceed in parallel |
| #1961 | Independent — description pattern is separate concern | Can proceed in parallel |
| #1987 | Partial overlap — Pattern 2 subsumed, rest independent | Coordinate on Pattern 2 fix |

## Labels

`[BUG]`, `skill`, `dispatch`, `sub-agent`
