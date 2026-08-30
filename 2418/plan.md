---
plan_schema_version: "1.0"
issue: 2418
title: "[SPEC-FIX] git-workflow-cleanup: orchestrator pre-investigation reverses submodule-first ordering"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — [#2418](https://github.com/michael-conrad/.opencode/issues/2418) — Fix git-workflow-cleanup orchestrator pre-investigation and submodule-first ordering

**Goal:** Eliminate orchestrator inline git/gh investigation before cleanup sub-agent dispatch, add guard notes against the pattern, and reinforce submodule-first result contract ordering.

**Architecture:** Three independent-but-sequential phases each with a full RED/GREEN/verify/commit TDD cycle. Phase 1 replaces the `concat()` dispatch prompt with a `pr_merged_event: true` flag in SKILL.md. Phase 2 adds a guard note in cleanup.md Step 0 plus a behavioral enforcement test. Phase 3 reinforces submodule-first ordering in the result contract reporting sections.

**Phase files:**
- `plan-01-dispatch-protocol.md`
- `plan-02-orchestrator-guard.md`
- `plan-03-result-ordering.md`

**Files:**
- `.opencode/skills/git-workflow-cleanup/SKILL.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`
- `.opencode/tests-v2/behaviors/` (new behavioral test file)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — DISPATCH_PROTOCOL | `test-driven-development` | `red` | `plan-01-dispatch-protocol.md` | SC-1 | — |
| 2 — ORCHESTRATOR_GUARD | `test-driven-development` | `red` | `plan-02-orchestrator-guard.md` | SC-2, SC-4 | 1 |
| 3 — RESULT_ORDERING | `test-driven-development` | `red` | `plan-03-result-ordering.md` | SC-3 | 2 |

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-30T19:53:00Z | plan_created | Plan file created at `.opencode/.issues/2418/plan.md` with 3 phases |

---

## Exit Criteria

- [ ] C1. SC-1: SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()` with pre-resolved values — verified by grep
- [ ] C2. SC-2: Behavioral test passes — verified by `opencode run` + stderr inspection showing no git/gh calls before dispatch
- [ ] C3. SC-3: Cleanup.md result contract sections list submodules before parent repo — verified by reading cleanup.md
- [ ] C4. SC-4: cleanup.md Step 0 contains explicit guard note against orchestrator pre-investigation — verified by grep
