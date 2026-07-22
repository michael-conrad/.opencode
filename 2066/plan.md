# Implementation Plan — [.opencode#2066](https://github.com/michael-conrad/.opencode/tree/issues-data/2066) — BEH-EV classification gate + evaluator clean-room dispatch

**Goal:** Fix two defects from #2011: (1) add mandatory BEH-EV classification sub-steps to `decompose.md` step 3, and (2) add `needs_clean_room` field to all 9 evaluator result contracts, orchestrator dispatch for `behavioral-sc-evaluator`, and clean-room result comparison in `cross-validate.md`.

**Architecture:** Pure task-file modifications — no new files, no behavioral test harness changes, no database/schema changes. Each phase modifies a distinct set of files with no overlap.

**Files:**
- `spec-creation-validation/tasks/decompose.md` — extend step 3 with BEH-EV sub-steps
- `audit/tasks/behavioral-sc-evaluator.md` — add orchestrator dispatch entry point (file exists from #2064)
- `audit/tasks/cross-validate.md` — add clean-room result reception and comparison logic
- 9 evaluator files under `audit/tasks/*-evaluator.md` — add `needs_clean_room` to result contract

**Dispatch:** `writing-plans-creation` → `writing-plans-holistic` → `approval-gate` → `implementation-pipeline`

> **Compliance:** This plan is a faithful implementation of the approved spec. Every step traces to a spec SC. No step adds scope beyond the spec. No step modifies files outside the spec's in-scope list.
>
> **One step at a time:** Execute steps sequentially. Do not skip steps. Do not reorder steps. Do not combine steps. Each step produces a verifiable change.
>
> **Step status:** Mark each step `[x]` when completed. Do not mark a step completed until its verification passes.
>
> **Self-remediation:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the step. Do not proceed past a failed step.

## Blast Radius

| File | Impact | Risk |
|------|--------|------|
| `spec-creation-validation/tasks/decompose.md` | Step 3 extended with BEH-EV sub-steps | Low — additive change, no existing logic modified |
| `audit/tasks/*-evaluator.md` (9 files) | Result contract gains `needs_clean_room` field | Low — additive field, no existing fields changed |
| `audit/tasks/behavioral-sc-evaluator.md` | Orchestrator dispatch entry point added | Low — file exists from #2064, no existing logic modified |
| `audit/tasks/cross-validate.md` | Clean-room result reception and comparison | Low — additive step, no existing logic modified |

## Concern Map Reference

| Concern | Phase | SCs |
|---------|-------|-----|
| BEH-EV classification gate in decompose.md | Phase 1 | SC-1 |
| Evaluator result contract + orchestrator dispatch + arbiter comparison | Phase 2 | SC-2, SC-3, SC-4 |

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|-------------|-------|----------|
| 1 | BEH-EV classification gate | Add BEH-EV classification sub-steps to decompose.md step 3 | SC-1 | None | 1-3 | `spec-creation-validation` |
| 2 | Evaluator result contract + dispatch + arbiter | Add `needs_clean_room` to evaluator contracts, orchestrator dispatch, arbiter comparison | SC-2, SC-3, SC-4 | Phase 1 | 4-10 | `audit` |

## Exit Criteria

- [ ] C1: `decompose.md` step 3 has mandatory BEH-EV classification sub-steps with presumptive runtime-behavioral file types (SC-1)
- [ ] C2: All 9 evaluator result contracts carry `needs_clean_room: [SC-IDs]` field (SC-2)
- [ ] C3: `behavioral-sc-evaluator.md` has orchestrator dispatch entry point (SC-3)
- [ ] C4: `cross-validate.md` receives both evaluator verdict and clean-room results (SC-4)
- [ ] C5: All modified files pass markdown lint (`pymarkdownlnt`)
- [ ] C6: All modified files pass markdown format check (`mdformat --check`)

> **Compliance:** This plan is a faithful implementation of the approved spec. Every step traces to a spec SC. No step adds scope beyond the spec. No step modifies files outside the spec's in-scope list.
>
> **Self-remediation:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do not skip the step. Do not proceed past a failed step.
