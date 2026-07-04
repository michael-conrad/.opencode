# Implementation Plan — [#1650](https://github.com/michael-conrad/.opencode/issues/1650) — Replace `/skill` CLI Convention with `skill()` Syntax

**Goal:** Replace all 51 instances of the `/skill` CLI convention across `.opencode/` with proper `skill()` invocation syntax, eliminating the misleading pseudo-command pattern.

**Architecture:** Single sweep across 5 file categories: SKILL.md CLI equivalent lines (32), task file examples (8), prose mentions (1), `.issues/` spec references (2), `.guidelines/README.md` (3), `README.md` (3), `dispatch-table.yaml` (2). Each phase targets a category group with grep-verified exact replacements.

**Files:** All files under `.opencode/` matching the 51 locations identified by `grep -rn '/skill ' .opencode/ --include='*.md' --include='*.yaml'`

> **Compliance requirement:** This plan MUST be followed step by step. Each step MUST be completed and verified before the next step begins. No step may be skipped, combined, or reordered. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` — no inline execution. Each step produces a result contract; the orchestrator reads only the contract, not the full output.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step completes, verify the result before proceeding. Do NOT batch steps. Do NOT parallelize. Each step is a discrete unit of work.

> **Step Status:** Before each step, report: `Step N: <description> — Status: IN_PROGRESS`. After each step, report: `Step N: <description> — Status: COMPLETE` or `BLOCKED`.

## Phase Table

| Phase | Name | SCs | Dependencies | Step Range |
|-------|------|-----|--------------|------------|
| 1 | Replace `/skill` in SKILL.md CLI equivalent lines | SC-1 | None | 1-4 |
| 2 | Replace `/skill` in task file examples | SC-2, SC-3 | Phase 1 | 5-8 |
| 3 | Replace `/skill` in other references | SC-4 | Phase 2 | 9-12 |
| 4 | Behavioral test for SC-6 | SC-6 | Phase 3 | 13-15 |
| 5 | Global verification sweep | SC-5 | Phase 4 | 16-19 |

---

> **Compliance requirement:** This plan MUST be followed step by step. Each step MUST be completed and verified before the next step begins. No step may be skipped, combined, or reordered. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` — no inline execution. Each step produces a result contract; the orchestrator reads only the contract, not the full output.

> **Self-remediation protocol:** If a step fails, the orchestrator MUST NOT proceed. Diagnose the failure, remediate, re-run the step, and only proceed on PASS. If remediation fails twice, report BLOCKED with root cause and HALT.

## Exit Criteria

- [ ] C1: All 32 SKILL.md "CLI equivalent" lines use `skill({name: "..."})` instead of `/skill`
- [ ] C2: All 7 task file examples with `--task` use `skill()` + `task()` patterns
- [ ] C3: The 1 task file example without `--task` (squash-push.md) uses `skill()` instead of `/skill`
- [ ] C4: The 1 prose mention in brainstorming/tasks/enforcement.md uses `skill()` instead of `/skill`
- [ ] C5: Zero `/skill` references remain in `.opencode/` (all 51 locations resolved)
- [ ] C6: Behavioral test verifies agent uses `skill()` syntax, not `/skill`, when describing skill invocation
