---
title: "[BUG] Systemic: dispatch boundary violations across skill deck — Invocation pipelines, task card task() calls, and orchestrator entry points"
status: draft
created: 2026-07-20
updated: 2026-07-20
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
| **#1372** | `[SPEC-FIX] writing-plans: Trigger Dispatch Table classifies orchestrator tasks as sub-task` | **FULLY SUBSUMED** — all 32 SCs transferred to this spec. `create`, `retroactive`, `completion` misclassified as `sub-task`; plan format requirements; `.issues/` path references; audit-fidelity/audit-concern fixes; create.md operating protocol; completion.md/retroactive.md cleanup. |
| **#1992** | `[SPEC] Sub-agents MUST NOT dispatch sub-agents` | **FULLY SUBSUMED** — the architectural invariant (task cards MUST NOT contain `task()` calls) is already resolved in the codebase (zero `task()` calls found in any of the 9 listed task cards). The critical-rules.md entry is covered by Phase 7. |
| **#1376** | `[SPEC-FIX] implementation-pipeline SKILL.md missing orchestrator entry point` | **FULLY SUBSUMED** — all 15 SCs transferred. Most are already resolved (orchestrator entry point exists, `assemble-work.md` exists, description/overview clean). Remaining: `assemble-work.md` content completeness (entry proof, OVERFLOW, work state verification, completion checkpoint). |
| **#1987** | `[SPEC] Fix audit skill DiMo chain` | **PARTIALLY SUBSUMED** — Pattern 2 (orchestrator dispatches SKILL.md to sub-agent) is the same category error. Already resolved in audit SKILL.md (has "MUST NOT dispatch SKILL.md content to a sub-agent"). The audit-specific DiMo chain fixes (arbiter fragmentation, cross-chain dependency) remain in #1987's scope. |

**The following related issues are NOT subsumed and remain independent:**

| Issue | Title | Rationale |
|-------|-------|-----------|
| **#1994** | `[SPEC-FIX] Plan writer produces structurally defective plans` | Downstream of the dispatch boundary issue. Plan output format (flat file, dispatch instructions, clean-room context) is a separate concern. |
| **#1784** | `[SPEC] Structural dispatch-gate enforcement + DISPATCH_GATE completeness` | SKILL.md content structure (routing-only vs procedure text) and DISPATCH_GATE completeness is a different dimension from the Invocation dispatch pattern. |
| **#1961** | `[SPEC] Rewrite SKILL.md Descriptions to Agent-Intent-Oriented Pattern` | Description frontmatter field pattern ("Dispatch when" → "Load via skill() when") is a content-only change to 60 SKILL.md files. Independent concern. |

## Problem

One remaining dispatch boundary violation exists across the skill deck, plus several related defects from subsumed issues:

### Violation A (ACTIVE): SKILL.md Invocation dispatches pipelines with `[sub-task]` steps to sub-agents

Multiple skill cards have Invocation sections that dispatch entire pipelines (containing `[sub-task]` steps) to sub-agents via `task()`. A sub-agent **cannot** call `task()` — that is an orchestrator-level capability. The dispatched sub-agent receives a pipeline it cannot execute.

**Affected skills:**
- `spec-creation/SKILL.md` — `create` pipeline has 23 `[sub-task]` steps
- `writing-plans/SKILL.md` — `create` pipeline has 16 `[sub-task]` steps; Invocation dispatches `create` as `task(..., prompt: "execute create from writing-plans-creation...")`

### Violation B (RESOLVED): Task cards contain `task()` calls

**Already resolved in codebase.** Zero `task()` calls found in any of the 9 previously-listed task cards. The only match is a prose example in `spec-creation-validation/tasks/create.md:557`. No work needed.

### Violation C (RESOLVED): Missing orchestrator entry points

**Already resolved in codebase.** `implementation-pipeline/SKILL.md` has orchestrator entry point at TDT line 49. `tasks/assemble-work.md` exists. Description/Overview contain no internal pipeline details. No work needed.

### Related defects from subsumed issues (ACTIVE):

| # | Defect | Source Issue | Location |
|---|--------|-------------|----------|
| D1 | `writing-plans/SKILL.md` TDT classifies `create`, `retroactive` as `sub-task` (should be `orchestrator`); `completion` not in TDT | #1372 | SKILL.md lines 37-39 |
| D2 | `writing-plans/SKILL.md` Invocation dispatches `create` as `task()` call to sub-agent | #1372 | SKILL.md line 74 |
| D3 | `audit-fidelity.md` and `audit-concern.md` contain "with auditor sub-agent type context" | #1372 | Both files line 5 |
| D4 | `writing-plans/SKILL.md` uses `.issues/{N}/` without dual pattern explanation | #1372 | SKILL.md lines 141-159 |
| D5 | `assemble-work.md` lacks entry proof marker, OVERFLOW handling, work state verification, completion checkpoint | #1376 | `tasks/assemble-work.md` |
| D6 | `writing-plans/SKILL.md` Sub-Agent Routing claims "All tasks run via `task()`" and "No inline work" | #1372 | SKILL.md |
| D7 | `completion.md` references wrong path (`completion-core/completion-core.md` instead of `completion-core/SKILL.md`) | #1372 | `writing-plans-creation/tasks/completion.md` |

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
| SKILL.md Invocation sections | `spec-creation/SKILL.md`, `writing-plans/SKILL.md` | Audit for pipelines with `[sub-task]` steps dispatched to sub-agents. Fix: orchestrator executes pipeline, dispatches each step individually. |
| `writing-plans/SKILL.md` TDT | SKILL.md | Fix `create`, `retroactive`, `completion` dispatch classification from `sub-task` to `orchestrator`. Add `completion` entry. |
| `writing-plans/SKILL.md` Invocation | SKILL.md | Fix `create` dispatch — orchestrator executes pipeline, does not `task()` itself |
| `audit-fidelity.md`, `audit-concern.md` | `writing-plans-creation/tasks/` | Remove "with auditor sub-agent type context" |
| `writing-plans/SKILL.md` `.issues/` refs | SKILL.md | Add dual pattern explanation for `.issues/{N}/` paths |
| `assemble-work.md` content | `implementation-pipeline/tasks/` | Add entry proof marker, OVERFLOW handling, work state verification, completion checkpoint |
| `writing-plans/SKILL.md` Sub-Agent Routing | SKILL.md | Fix "All tasks run via `task()`" and "No inline work" claims |
| `completion.md` path | `writing-plans-creation/tasks/completion.md` | Fix `completion-core/completion-core.md` → `completion-core/SKILL.md` |
| `000-critical-rules.md` | guidelines | Add critical violation entry for sub-agent task() dispatch |
| Behavioral enforcement tests | `tests-v2/behaviors/` | Tests for each violation type |

### Out of scope

- Plan output format (covered by #1994)
- DISPATCH_GATE completeness on 3 cards (covered by #1784)
- SKILL.md description pattern rewrite (covered by #1961)
- Audit skill DiMo chain beyond Pattern 2 (covered by #1987)
- Plan Format Requirements section in `create.md` (covered by #1994)
- `tasks/create/` subdirectory purge (already resolved)
- `pipeline-executor.md` stale step count (already resolved)
- `implementation-pipeline/SKILL.md` description/overview cleanup (already resolved)

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

### Phase 3: Fix `writing-plans/SKILL.md` dispatch classification and related defects

1. Change `create`, `retroactive` from `sub-task` to `orchestrator` in TDT
2. Add `completion` entry as `orchestrator` in TDT
3. Fix Invocation table — `create` is orchestrator-executed, not `task()` dispatched
4. Fix `audit-fidelity.md` and `audit-concern.md` — remove "with auditor sub-agent type context"
5. Fix `writing-plans/SKILL.md` Sub-Agent Routing — remove "All tasks run via `task()`" and "No inline work" claims
6. Fix `completion.md` path — `completion-core/completion-core.md` → `completion-core/SKILL.md`
7. Add dual pattern explanation to `.issues/{N}/` references in `writing-plans/SKILL.md`

### Phase 4: Fix `assemble-work.md` content completeness

Add to `tasks/assemble-work.md`:
1. Entry proof marker (Step 1.5 per `git-workflow/tasks/cleanup/branch-cleanup.md:377`)
2. OVERFLOW handling (per `implementation-pipeline/enforcement/overflow-signal.md:18`)
3. Work state verification (per `implementation-pipeline/enforcement/work-state-verification.md:5`)
4. Post-sub-agent completion checkpoint with hash mismatch detection (per `pre-analysis/tasks/analyze.md:130`)

### Phase 5: Add critical violation to guidelines

Add entry to `000-critical-rules.md` for sub-agent task() dispatch.

### Phase 6: Behavioral enforcement tests

Create behavioral tests that verify:
1. After `skill("spec-creation")`, orchestrator does NOT dispatch the `create` pipeline to a sub-agent
2. After `skill("writing-plans")`, orchestrator does NOT dispatch the `create` pipeline to a sub-agent
3. `writing-plans/SKILL.md` classifies `create` as `orchestrator`, not `sub-task`
4. `audit-fidelity.md` and `audit-concern.md` do not contain "with auditor sub-agent type context"

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | No SKILL.md Invocation section dispatches a pipeline with `[sub-task]` steps to a sub-agent | `string` | grep for `[sub-task]` in Invocation sections — 0 matches |
| SC-2 | `writing-plans/SKILL.md` TDT classifies `create` as `orchestrator` | `string` | grep for `create.*orchestrator` in SKILL.md — present |
| SC-3 | `writing-plans/SKILL.md` TDT classifies `retroactive` as `orchestrator` | `string` | grep for `retroactive.*orchestrator` in SKILL.md — present |
| SC-4 | `writing-plans/SKILL.md` TDT has `completion` entry as `orchestrator` | `string` | grep for `completion.*orchestrator` in SKILL.md — present |
| SC-5 | `writing-plans/SKILL.md` Invocation does not dispatch `create` as `task()` call | `string` | grep for `task(.*execute create` in Invocation section — 0 matches |
| SC-6 | `audit-fidelity.md` does not contain "with auditor sub-agent type context" | `string` | grep returns no match |
| SC-7 | `audit-concern.md` does not contain "with auditor sub-agent type context" | `string` | grep returns no match |
| SC-8 | `writing-plans/SKILL.md` Sub-Agent Routing does not claim "All tasks run via `task()`" | `string` | grep for "All tasks run via" returns no match |
| SC-9 | `writing-plans/SKILL.md` Sub-Agent Routing does not claim "No inline work" | `string` | grep for "No inline work" returns no match |
| SC-10 | `completion.md` references `completion-core/SKILL.md` (not `completion-core/completion-core.md`) | `string` | grep for `completion-core/SKILL.md` in completion.md — present |
| SC-11 | `writing-plans/SKILL.md` `.issues/` references include dual pattern explanation | `string` | grep for "root repo.*submodule" or "root repo.*sub-repo" in writing-plans/SKILL.md — all `.issues/` refs have explanation |
| SC-12 | `tasks/assemble-work.md` references entry proof marker (Step 1.5) | `string` | grep for "entry proof" or "Step 1.5" in assemble-work.md — present |
| SC-13 | `tasks/assemble-work.md` references OVERFLOW handling | `string` | grep for "OVERFLOW" in assemble-work.md — present |
| SC-14 | `tasks/assemble-work.md` references work state verification | `string` | grep for "work state" in assemble-work.md — present |
| SC-15 | `tasks/assemble-work.md` references post-sub-agent completion checkpoint | `string` | grep for "completion checkpoint" or "hash mismatch" in assemble-work.md — present |
| SC-16 | `000-critical-rules.md` has entry for sub-agent task() dispatch | `string` | grep for "sub-agent.*task()" or "task().*sub-agent" in critical-rules.md — present |
| SC-17 | Behavioral test verifies orchestrator does not dispatch spec-creation pipeline to sub-agent | `behavioral` | `opencode run` → stderr shows no pipeline dispatch to sub-agent |
| SC-18 | Behavioral test verifies orchestrator does not dispatch writing-plans pipeline to sub-agent | `behavioral` | `opencode run` → stderr shows no pipeline dispatch to sub-agent |
| SC-19 | Behavioral test verifies writing-plans TDT classifies create as orchestrator | `behavioral` | `opencode run` → stderr shows orchestrator dispatch, not sub-task |

## Dependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| #1994 | Downstream — plan format depends on dispatch boundary being correct | Implement #2020 first |
| #1784 | Independent — DISPATCH_GATE completeness is separate dimension | Can proceed in parallel |
| #1961 | Independent — description pattern is separate concern | Can proceed in parallel |
| #1987 | Partial overlap — Pattern 2 subsumed, rest independent | Coordinate on Pattern 2 fix |

## Labels

`[BUG]`, `skill`, `dispatch`, `sub-agent`
