> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/N/

## Problem

The `implementation-pipeline/SKILL.md` Trigger Dispatch Table currently allows **phase-level batching modes** (`per-phase` and `batched`) that route multiple implementation items through a single sub-agent dispatch. This violates the clean-room sub-agent architecture and the per-item TDD cycle mandate.

**Phase-level batching defects:**

1. **Sub-agent contamination** — When multiple items are dispatched together, the sub-agent receives aggregated context (multiple plan items, combined SCs, merged file lists). The sub-agent is no longer "blind" — it has cross-item knowledge that biases its reasoning and violates the clean-room isolation contract.

2. **Verification gap** — Phase-level batching collapses the mandatory per-item RED→GREEN→REFACTOR→COMMIT cycle into a single monolithic execution. Individual success criteria (SCs) cannot be verified independently. A failure in item 3 pollutes items 1 and 2.

3. **Checkpoint corruption** — The pipeline's checkpoint/rollback mechanism (`git reset --hard <checkpoint-tag>`) assumes one checkpoint per item. Phase-level batching creates ambiguous checkpoint boundaries — which item's state does the checkpoint represent?

4. **Work state file ambiguity** — The `work.md` state file tracks per-item progress. Phase-level dispatch writes a single entry for multiple items, making it impossible to resume individual items after interruption.

5. **SC-to-test traceability loss** — Each SC must have a corresponding behavioral test. Phase-level batching obscures which test covers which SC for which item.

**Root cause:** The Trigger Dispatch Table's `dispatch_mode` column includes `per-phase` and `batched` as valid modes, and the Invocation section documents them as acceptable patterns. These modes were introduced as "optimizations" but violate the foundational architecture.

## Root Cause

The implementation-pipeline was designed with a phase-centric mental model where "a phase contains items" and the optimizer thought "dispatch once per phase instead of once per item." This ignored the architectural requirement that **every implementation item gets its own clean-room sub-agent with its own TDD cycle**.

The `dispatch_mode` enum in the Trigger Dispatch Table and the Invocation documentation codified this violation as "supported behavior" instead of treating it as an architectural boundary that must not be crossed.

## Solution

**Eliminate phase-level batching modes entirely.** The `implementation-pipeline/SKILL.md` must mandate **step-level (per-item) dispatch only**:

1. **Remove `per-phase` and `batched` from `dispatch_mode` enum** — Only `per-step` (or `clean-room`/`per-item`) remains valid.

2. **Rewrite Trigger Dispatch Table** — Every row must dispatch at the granularity of one implementation item → one clean-room sub-agent.

3. **Update Invocation section** — Document that the orchestrator MUST dispatch one clean-room sub-agent per implementation item. No phase-level dispatch, no batched dispatch.

4. **Update `pipeline-executor.md` (internal step dispatch)** — Ensure it iterates items sequentially, dispatching `task()` for each item's RED, GREEN, REFACTOR, CHECKPOINT sequence independently.

5. **Update `assemble-work.md` (orchestrator entry point)** — Must create work state entries per-item and dispatch sub-agents per-item.

6. **Update `executing-plans` skill** — Must generate plans that produce per-item dispatch instructions (already moving this direction via writing-plans checklist format).

7. **Verification gate** — Add a pipeline stage that verifies the dispatch mode is never `per-phase` or `batched` in any generated plan or runtime dispatch.

## Alternatives Considered

| Alternative | Why Rejected |
|-------------|--------------|
| Keep batching but add per-item verification inside sub-agent | Sub-agent would need internal loop over items — violates clean-room (no internal iteration over work items), creates monolithic sub-agent that cannot be independently verified |
| Phase-level dispatch with post-hoc per-item SC verification | Verification after the fact is too late — the sub-agent's reasoning was already contaminated by multi-item context; also breaks checkpoint/rollback |
| Configurable batching with opt-in | Any configuration option for batching is a defect factory — the architecture must forbid it by design, not by config |
| "Smart" sub-agent that handles multiple items with internal isolation | Adds complexity without benefit; the orchestrator already iterates items sequentially — no need to push iteration into sub-agents |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implementation-pipeline/SKILL.md` Trigger Dispatch Table has no rows with `dispatch_mode` = `per-phase` or `batched` | structural | `grep` for `per-phase` or `batched` in Trigger Dispatch Table — absent |
| SC-2 | `implementation-pipeline/SKILL.md` Invocation section does not document `per-phase` or `batched` as valid dispatch modes | structural | `grep` for `per-phase` or `batched` in Invocation section — absent |
| SC-3 | `implementation-pipeline/SKILL.md` Trigger Dispatch Table `dispatch_mode` column only contains `per-step` (or `clean-room`/`per-item`) | structural | All rows in dispatch table show only `per-step` mode |
| SC-4 | `tasks/pipeline-executor.md` iterates items and dispatches `task()` per-item for RED/GREEN/REFACTOR/CHECKPOINT | structural | `grep` for per-item loop pattern with `task()` calls in pipeline-executor.md — present |
| SC-5 | `tasks/assemble-work.md` creates work state entries per-item and dispatches sub-agents per-item | structural | `grep` for per-item work state creation and per-item `task()` dispatch in assemble-work.md — present |
| SC-6 | `writing-plans` skill generates plans with per-item dispatch instructions (checklist format) | structural | `grep` for per-item checklist steps in writing-plans output — present |
| SC-7 | Pipeline verification gate rejects any plan or dispatch with `per-phase` or `batched` mode | behavioral | `opencode-cli run` with a test prompt that attempts batched dispatch → agent rejects with FAIL |
| SC-8 | Checkpoint tags follow pattern `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` per item (not per phase) | structural | `grep` for checkpoint tag pattern in pipeline-executor.md — per-item |
| SC-9 | Work state file (`work.md`) has one entry per implementation item, not per phase | structural | `grep` for work state schema in assemble-work.md — per-item entries |

## Change Control

**Files to modify:**
1. `.opencode/skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table, Invocation, Overview
2. `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — Per-item dispatch loop
3. `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` — Per-item work state and dispatch
4. `.opencode/skills/implementation-pipeline/enforcement/*.md` — Add dispatch mode verification gate

**Files to verify (no modification expected):**
- `.opencode/skills/writing-plans/` — Already migrating to per-item checklist format
- `.opencode/skills/executing-plans/` — Must align with per-item dispatch

**Validation sequence:**
1. Modify SKILL.md dispatch table and documentation
2. Modify pipeline-executor.md per-item loop
3. Modify assemble-work.md per-item work state
4. Add dispatch mode verification gate to enforcement
5. Run behavioral test: attempt batched dispatch → verify agent rejects it
6. Run structural checks: grep for eliminated modes in all modified files

## Risk

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Existing plans with batched dispatch break | Medium | High | Migration script to expand batched items into per-item steps; validation gate catches old format |
| Sub-agent dispatch overhead increases | Low | Medium | Per-item dispatch is the architecture — overhead is the cost of correctness; optimize sub-agent startup if needed |
| Pipeline-executor logic becomes more complex | Low | Low | Per-item loop is simpler than batched logic with partial failure handling |

## Phases

| Phase | Concern | Steps |
|-------|---------|-------|
| 1 | SKILL.md dispatch contract | Rewrite Trigger Dispatch Table, Invocation, Overview to mandate per-item dispatch only |
| 2 | Pipeline executor | Implement per-item dispatch loop in `pipeline-executor.md` |
| 3 | Assemble work | Implement per-item work state creation and dispatch in `assemble-work.md` |
| 4 | Enforcement gate | Add dispatch mode verification gate to `implementation-pipeline/enforcement/` |
| 5 | Validation | Behavioral test: attempt batched dispatch → verify rejection; structural grep verification |

## Design Decisions

1. **Per-item dispatch is non-negotiable** — No config flags, no opt-in, no "legacy mode." The architecture requires it.

2. **Dispatch mode indicator in plans** — Plans must use `(**clean-room**)` indicator per step (already mandated by writing-plans spec). The pipeline executor reads this to confirm per-item dispatch.

3. **Checkpoint per item** — Each item gets its own checkpoint tag. Phase-level checkpoints are eliminated.

4. **Work state granularity** — One work state entry per implementation item. The work state file schema reflects this.

5. **Verification gate location** — Added as a pre-execution gate in `implementation-pipeline/enforcement/dispatch-mode-verification.md` that runs after `assemble-work` creates the dispatch plan but before `pipeline-executor` runs.

---

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/N/.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/nemotron-3-ultra-free)