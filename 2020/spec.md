---
title: "[BUG] Systemic: dispatch boundary violations across skill deck — Invocation pipelines, task card task() calls, and orchestrator entry points"
status: draft
created: 2026-07-20
updated: 2026-07-22
license: MIT
provenance: AI-generated
issue: 2020
authors:
  - OpenCode (deepseek-v4-flash)
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2020/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2020)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2020/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

**STATUS:** DRAFT
**CREATED:** 2026-07-20
**REVISED:** 2026-07-22 — Reconciled local spec.md with issue.yaml body. Incorporated monolithic task card decomposition (7 phases, 28 SCs). Marked D1/D2/D3/D5/D7/D8/D9 as RESOLVED. Phase 5 (SC-24) and Phase 6 (SC-25) completed. Phase 7 (SC-26/27/28) behavioral test scripts created.

## Supersession

This spec **supersedes and subsumes** the following open issues:

| Issue | Title | Subsumption Rationale |
|-------|-------|----------------------|
| **#2018** | `[BUG] spec-creation SKILL.md Invocation dispatches pipeline with [sub-task] steps` | **FULLY SUBSUMED** — specific instance of the systemic Invocation dispatch pattern. |
| **#1372** | `[SPEC-FIX] writing-plans: Trigger Dispatch Table classifies orchestrator tasks as sub-task` | **FULLY SUBSUMED** — all 32 SCs transferred. |
| **#1992** | `[SPEC] Sub-agents MUST NOT dispatch sub-agents` | **FULLY SUBSUMED** — architectural invariant. |
| **#1376** | `[SPEC-FIX] implementation-pipeline SKILL.md missing orchestrator entry point` | **FULLY SUBSUMED** — all 15 SCs transferred. |
| **#1987** | `[SPEC] Fix audit skill DiMo chain` | **PARTIALLY SUBSUMED** — Pattern 2 (orchestrator dispatches SKILL.md to sub-agent) is the same category error. |
| **#2032** | `[SPEC-FIX] Task cards contain dispatch-level markers` | **FULLY SUBSUMED** — dispatch marker stripping completed. SC-4 (entry/exit criteria) and SC-7 (behavioral test) remain open under this issue. |

**The following related issues are NOT subsumed and remain independent:**

| Issue | Title | Rationale |
|-------|-------|-----------|
| **#1994** | `[SPEC-FIX] Plan writer produces structurally defective plans` | Downstream — plan output format is a separate concern. |
| **#1784** | `[SPEC] Structural dispatch-gate enforcement + DISPATCH_GATE completeness` | SKILL.md content structure is a different dimension. |
| **#1961** | `[SPEC] Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern` | Description frontmatter field pattern is a content-only change. |

## Core Principle

**A task card cannot dispatch other sub-agents. It is not physically possible.**

The skill card (SKILL.md) is the orchestrator's routing view. It contains the Pipeline section with dispatch markers (`[sub-task]`, `[inline]`) and the Invocation section mapping each `[sub-task]` to a task card. The orchestrator reads the Pipeline to know the sequence, then dispatches each step individually via `task()`.

Each task card describes exactly one sub-agent's work. The sub-agent reads its task card, executes the inline steps, and returns a result contract. It cannot call `task()` — that is an orchestrator-level capability.

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Pipeline (routing view with dispatch markers) + Invocation (dispatch table) | Orchestrator reads to know sequence, dispatches each step |
| Task Card | tasks/<name>.md | Sub-agent | One sub-agent's procedure (entry criteria, inline steps, exit criteria) | Sub-agent reads and executes inline |
| Invocation | SKILL.md §Invocation | Orchestrator | Dispatch table: one entry per `[sub-task]` with clean-room indicator | Orchestrator dispatches one at a time |

## Problem

Multiple SKILL.md files have a structural defect: their `tasks/` directory contains a single monolithic task card (e.g., `create.md`) that describes the work of multiple sub-agents. A sub-agent receiving this task card cannot execute it because:

1. The task card describes steps that require dispatching other sub-agents via `task()`
2. A sub-agent **cannot** call `task()` — that is an orchestrator-level capability
3. The task card is structurally a pipeline document, not a task card

### Violation A (ACTIVE): Monolithic task cards describing multiple sub-agents

| Skill | Monolithic Task Card | Steps Described |
|-------|---------------------|-----------------|
| `spec-creation-validation` | `tasks/create.md` | 19 `[sub-task]` steps |
| `writing-plans-creation` | `tasks/create.md` | 13 `[sub-task]` steps |

### Violation B (ACTIVE): SKILL.md TDT classifies orchestrator tasks as `sub-task`

Both `spec-creation/SKILL.md` and `writing-plans/SKILL.md` classify all tasks as `sub-task` in their Trigger Dispatch Tables. These are orchestrator-level dispatches — the orchestrator calls `task()` to dispatch a sub-agent. The TDT should classify them as `orchestrator`.

### Violation C (ACTIVE): SKILL.md Invocation dispatches pipeline to sub-agent

Both `spec-creation/SKILL.md` and `writing-plans/SKILL.md` have Invocation sections that dispatch the entire pipeline to a sub-agent via `task()`. The sub-agent receives a pipeline it cannot execute.

### Related defects from subsumed issues

| # | Defect | Source Issue | Location | Status |
|---|--------|-------------|----------|--------|
| D1 | `writing-plans/SKILL.md` TDT classifies `create`, `retroactive` as `sub-task` (should be `orchestrator`); `completion` not in TDT | #1372 | SKILL.md TDT | ✅ **RESOLVED** |
| D2 | `writing-plans/SKILL.md` Invocation dispatches `create` as `task()` call to sub-agent | #1372 | SKILL.md Invocation | ✅ **RESOLVED** |
| D3 | `audit-fidelity.md` and `audit-concern.md` contain "with auditor sub-agent type context" | #1372 | Both files | ✅ **RESOLVED** |
| D4 | `writing-plans/SKILL.md` uses `.issues/{N}/` without dual pattern explanation | #1372 | SKILL.md | ❌ **ACTIVE** |
| D5 | `assemble-work.md` lacks entry proof marker, OVERFLOW handling, work state verification, completion checkpoint | #1376 | `tasks/assemble-work.md` | ✅ **RESOLVED** |
| D6 | `writing-plans/SKILL.md` Sub-Agent Routing claims "All tasks run via `task()`" and "No inline work" | #1372 | SKILL.md | ✅ **N/A** (no such claims) |
| D7 | `completion.md` references wrong path (`completion-core/completion-core.md` instead of `completion-core/SKILL.md`) | #1372 | `writing-plans-creation/tasks/completion.md` | ✅ **RESOLVED** |
| D8 | `spec-creation/SKILL.md` TDT classifies all tasks as `sub-task` | #2018 | SKILL.md TDT | ✅ **RESOLVED** |
| D9 | `spec-creation/SKILL.md` Invocation dispatches `create` as `task()` call | #2018 | SKILL.md Invocation | ✅ **RESOLVED** |
| D10 | #2032 SC-4: 14 sub-role task cards missing entry/exit criteria | #2032 | audit task files | ❌ **ACTIVE** |
| D11 | #2032 SC-7: Behavioral test for sub-agent inline execution | #2032 | `tests-v2/behaviors/` | ❌ **ACTIVE** |

## Root Cause

The skill card template was designed with the assumption that a sub-agent can execute a multi-step pipeline that includes sub-agent dispatches. This is a category error: dispatching orchestrator-level routing instructions (which include `task()` calls) to a sub-agent.

The monolithic `create.md` task cards were written as pipeline documents describing what multiple sub-agents do. A sub-agent reading one can only execute the steps belonging to its own concern. The remaining steps describe other sub-agents' work that the reading sub-agent cannot dispatch.

## Scope

### In scope

| Area | Files | Work Required |
|------|-------|--------------|
| Decompose monolithic `create.md` | `writing-plans-creation/tasks/create.md`, `spec-creation-validation/tasks/create.md` | Split into individual task cards (13 + 19) |
| Update Invocation sections | `spec-creation/SKILL.md`, `writing-plans/SKILL.md` | One entry per task card with clean-room indicator |
| Add dual pattern explanation | `writing-plans/SKILL.md` | `.issues/{N}/` path explanation |
| Fix #2032 SC-4 | 12 sub-role files + `resolve-models.md` | Add entry/exit criteria |
| Fix #2032 SC-7 | `tests-v2/behaviors/` | Create behavioral test |
| Behavioral enforcement tests | `tests-v2/behaviors/` | Tests for each violation type |

### Out of scope

- Plan output format (covered by #1994)
- DISPATCH_GATE completeness on 3 cards (covered by #1784)
- SKILL.md description pattern rewrite (covered by #1961)
- Audit skill DiMo chain beyond Pattern 2 (covered by #1987)

## Approach

### Phase 1: Decompose monolithic task cards into individual task cards

For each affected skill, replace the monolithic `create.md` with individual task cards — one per `[sub-task]` step in the Pipeline section.

#### `writing-plans-creation/tasks/` — 13 task cards

| Step | Clean-Room? | Task Card |
|------|-------------|-----------|
| verify-spec-approved | ✅ | `tasks/verify-spec-approved.md` |
| research | ✅ | `tasks/research.md` |
| readiness | ❌ | `tasks/readiness.md` |
| artifact-validation | ❌ | `tasks/artifact-validation.md` |
| structure | ❌ | `tasks/structure.md` |
| solve | ❌ | `tasks/solve.md` |
| plan-creation-pipeline | ❌ | `tasks/plan-creation-pipeline.md` |
| write | ❌ | `tasks/write.md` |
| revisit | ❌ | `tasks/revisit.md` |
| validate | ❌ | `tasks/validate.md` |
| audit-fidelity | ❌ | `tasks/audit-fidelity.md` |
| audit-concern | ❌ | `tasks/audit-concern.md` |
| completion | ❌ | `tasks/completion.md` |

#### `spec-creation-validation/tasks/` — 19 task cards

| Step | Clean-Room? | Task Card |
|------|-------------|-----------|
| create-remote-stub | ✅ | `tasks/create-remote-stub.md` |
| pre-spec-inspection | ✅ | `tasks/pre-spec-inspection.md` |
| research-card-consultation | ❌ | `tasks/research-card-consultation.md` |
| requirements | ❌ | `tasks/requirements.md` |
| concern-analysis | ❌ | `tasks/concern-analysis.md` |
| decompose | ❌ | `tasks/decompose.md` |
| blast-radius | ❌ | `tasks/blast-radius.md` |
| cross-cutting | ❌ | `tasks/cross-cutting.md` |
| traceability | ❌ | `tasks/traceability.md` |
| code-path-analysis | ❌ | `tasks/code-path-analysis.md` |
| interface-compatibility | ❌ | `tasks/interface-compatibility.md` |
| state-analysis | ❌ | `tasks/state-analysis.md` |
| pipeline-readiness-gate | ❌ | `tasks/pipeline-readiness-gate.md` |
| testability-assessment | ❌ | `tasks/testability-assessment.md` |
| risk | ❌ | `tasks/risk.md` |
| interdependency-check | ❌ | `tasks/interdependency-check.md` |
| create-local | ❌ | `tasks/create-local.md` |
| revise-remote-body | ❌ | `tasks/revise-remote-body.md` |
| completion | ❌ | `tasks/completion.md` |

### Phase 2: Each task card structure

```markdown
# Task: <name>

## Purpose
One sentence — what this sub-agent does.

## Entry Criteria
- What must be true before this step
- What the orchestrator passes (clean-room: only issue_number; context-aware: prior artifact paths)

## Procedure
- [ ] 1. Inline steps only — no dispatch markers, no references to other sub-agents
- [ ] 2. Reads input from disk (spec.md, prior artifacts)
- [ ] 3. Writes output to disk (artifacts/<name>.yaml)

## Exit Criteria
- What the sub-agent produces
- Result contract fields

## Result Contract
| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/<name>.yaml" |
| blocker_reason | "..." |
```

### Phase 3: Update Invocation sections

Each SKILL.md Invocation section gets one entry per task card with clean-room indicator.

### Phase 4: Delete monolithic `create.md` files

Both `writing-plans-creation/tasks/create.md` and `spec-creation-validation/tasks/create.md` are deleted. They are pipeline documents, not task cards.

### Phase 5: Fix #2032 SC-4 — Add entry/exit criteria to sub-role task cards

Add `## Entry Criteria` and `## Exit Criteria` to:
- 12 sub-role files under `closure-verification/`, `coherence-extraction/`, `spec-summary/`
- `resolve-models.md`

### Phase 6: Fix #2032 SC-7 — Create behavioral test

Create `.opencode/tests-v2/behaviors/task-card-inline-execution.sh`.

### Phase 7: Behavioral enforcement tests

Create behavioral tests that verify:
1. After `skill("spec-creation")`, orchestrator dispatches individual task cards, not the pipeline
2. After `skill("writing-plans")`, orchestrator dispatches individual task cards, not the pipeline
3. `writing-plans/SKILL.md` classifies `create` as `orchestrator`, not `sub-task`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `writing-plans-creation/tasks/create.md` is deleted | `string` | `ls` confirms file does not exist |
| SC-2 | `spec-creation-validation/tasks/create.md` is deleted | `string` | `ls` confirms file does not exist |
| SC-3 | 13 individual task cards exist under `writing-plans-creation/tasks/` matching the decomposition table | `string` | `ls` confirms all 13 files exist |
| SC-4 | 19 individual task cards exist under `spec-creation-validation/tasks/` matching the decomposition table | `string` | `ls` confirms all 19 files exist |
| SC-5 | Each task card has `## Entry Criteria`, `## Procedure`, `## Exit Criteria`, `## Result Contract` sections | `string` | grep each task card for all 4 section headers |
| SC-6 | No task card contains dispatch markers (`[sub-task]`, `[inline]`, `(orchestrator)`, `(inline)`) | `string` | grep all task cards — 0 matches |
| SC-7 | No task card references other sub-agents or describes their work | `string` | grep for "dispatches", "sub-agent", "sub-task" in task cards — 0 matches |
| SC-8 | `writing-plans/SKILL.md` Invocation section lists all 13 task cards with clean-room indicators | `string` | grep Invocation section — 13 entries with ✅/❌ |
| SC-9 | `spec-creation/SKILL.md` Invocation section lists all 19 task cards with clean-room indicators | `string` | grep Invocation section — 19 entries with ✅/❌ |
| SC-10 | Pipeline sections in both SKILL.md files are removed (no `[sub-task]` or `[inline]` markers remain in Pipeline sections) | `string` | grep for `[sub-task]` and `[inline]` in Pipeline sections — 0 matches |
| SC-11 | `writing-plans/SKILL.md` TDT classifies `create` as `orchestrator` | `string` | grep for `create.*orchestrator` — present |
| SC-12 | `writing-plans/SKILL.md` TDT classifies `retroactive` as `orchestrator` | `string` | grep for `retroactive.*orchestrator` — present |
| SC-13 | `writing-plans/SKILL.md` TDT has `completion` entry as `orchestrator` | `string` | grep for `completion.*orchestrator` — present |
| SC-14 | `audit-fidelity.md` does not contain "with auditor sub-agent type context" | `string` | grep — 0 matches |
| SC-15 | `audit-concern.md` does not contain "with auditor sub-agent type context" | `string` | grep — 0 matches |
| SC-16 | `writing-plans/SKILL.md` Sub-Agent Routing does not claim "All tasks run via `task()`" | `string` | grep — 0 matches |
| SC-17 | `writing-plans/SKILL.md` Sub-Agent Routing does not claim "No inline work" | `string` | grep — 0 matches |
| SC-18 | `completion.md` references `completion-core/SKILL.md` (not `completion-core/completion-core.md`) | `string` | grep for `completion-core/SKILL.md` — present |
| SC-19 | `tasks/assemble-work.md` references entry proof marker | `string` | grep for "entry proof" or "Step 1.5" — present |
| SC-20 | `tasks/assemble-work.md` references OVERFLOW handling | `string` | grep for "OVERFLOW" — present |
| SC-21 | `tasks/assemble-work.md` references work state verification | `string` | grep for "work state" — present |
| SC-22 | `tasks/assemble-work.md` references post-sub-agent completion checkpoint | `string` | grep for "completion checkpoint" or "hash mismatch" — present |
| SC-23 | `000-critical-rules.md` has entry for sub-agent task() dispatch | `string` | grep for "sub-agent.*task()" or "task().*sub-agent" — present |
| SC-24 | 12 sub-role task cards + resolve-models.md have entry/exit criteria | `string` | grep each file for `## Entry Criteria` and `## Exit Criteria` |
| SC-25 | Behavioral test for sub-agent inline execution exists | `string` | `ls tests-v2/behaviors/task-card-inline-execution.sh` |
| SC-26 | Behavioral test: orchestrator dispatches spec-creation individual task cards | `behavioral` | `opencode run` → stderr shows individual task card dispatches |
| SC-27 | Behavioral test: orchestrator dispatches writing-plans individual task cards | `behavioral` | `opencode run` → stderr shows individual task card dispatches |
| SC-28 | Behavioral test: writing-plans TDT classifies create as orchestrator | `behavioral` | `opencode run` → stderr shows orchestrator dispatch, not sub-task |

## Dependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| #1994 | Downstream — plan format depends on dispatch boundary being correct | Implement #2020 first |
| #1784 | Independent — DISPATCH_GATE completeness is separate dimension | Can proceed in parallel |
| #1961 | Independent — description pattern is separate concern | Can proceed in parallel |
| #1987 | Partial overlap — Pattern 2 subsumed, rest independent | Coordinate on Pattern 2 fix |

## Labels

`[BUG]`, `skill`, `dispatch`, `sub-agent`
