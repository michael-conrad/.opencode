---
plan_schema_version: "1.0"
issue: 2224
title: "Move verify-plan-pipeline from approval-gate-scope to writing-plans"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2224 — Move verify-plan-pipeline to writing-plans

**Goal:** Move the `verify-plan-pipeline` task from `approval-gate-scope` to `writing-plans`, update all cross-references, and ensure agent intent matching routes "verify plan pipeline" to `writing-plans`.

**Architecture:** File move + cross-reference update. No runtime behavior changes to the task procedure. The task file is copied to the new location and deleted from the old. SKILL.md files in `approval-gate` and `approval-gate-scope` have TDT/Invocation rows removed. `writing-plans/SKILL.md` gains TDT, Invocation, task card entry, file structure entry, workflow step, and updated description. A behavioral test verifies agent routing.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/approval-gate-scope/SKILL.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md`
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Move task file | `test-driven-development` | `red`/`green` | `writing-plans/tasks/verify-plan-pipeline.md` | SC-1 | — |
| 2 — Remove from approval-gate SKILL.md files | `test-driven-development` | `red`/`green` | `approval-gate/SKILL.md`, `approval-gate-scope/SKILL.md` | SC-2, SC-3, SC-7, SC-8 | 1 |
| 3 — Update writing-plans/SKILL.md | `test-driven-development` | `red`/`green` | `writing-plans/SKILL.md` | SC-4, SC-5, SC-6, SC-9, SC-10, SC-11 | 1 |
| 4 — Verify behavioral routing | `test-driven-development` | `red`/`green` | Behavioral test | SC-12 | 2, 3 |

---

## Phase Details

### Phase 1 — Move Task File

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `writing-plans/tasks/verify-plan-pipeline.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
source: ".opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md"
target: ".opencode/skills/writing-plans/tasks/verify-plan-pipeline.md"
sc_ids: [SC-1]
```

### Phase 2 — Remove from approval-gate SKILL.md files

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `approval-gate/SKILL.md`, `approval-gate-scope/SKILL.md` |
| SCs | SC-2, SC-3, SC-7, SC-8 |
| Depends On | 1 |

**Context:**
```yaml
files:
  - ".opencode/skills/approval-gate/SKILL.md"
  - ".opencode/skills/approval-gate-scope/SKILL.md"
sc_ids: [SC-2, SC-3, SC-7, SC-8]
removals:
  - TDT rows for verify-plan-pipeline
  - Invocation entries for verify-plan-pipeline
  - Description trigger phrases "verify plan pipeline" and "check pipeline completeness"
```

### Phase 3 — Update writing-plans/SKILL.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `writing-plans/SKILL.md` |
| SCs | SC-4, SC-5, SC-6, SC-9, SC-10, SC-11 |
| Depends On | 1 |

**Context:**
```yaml
file: ".opencode/skills/writing-plans/SKILL.md"
sc_ids: [SC-4, SC-5, SC-6, SC-9, SC-10, SC-11]
additions:
  - Task Cards table entry for verify-plan-pipeline
  - File Structure listing for tasks/verify-plan-pipeline.md
  - Description trigger phrases "verify plan pipeline" and "check pipeline completeness"
  - TDT row mapping "verify plan pipeline" / "check pipeline completeness" to verify-plan-pipeline task
  - Invocation section entry for verify-plan-pipeline with canonical dispatch string
  - Workflows section step referencing verify-plan-pipeline dispatch
```

### Phase 4 — Verify Behavioral Routing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | Behavioral test |
| SCs | SC-12 |
| Depends On | 2, 3 |

**Context:**
```yaml
sc_ids: [SC-12]
test_prompt: "verify plan pipeline"
expected_dispatch: 'Skill "writing-plans"'
forbidden_dispatch: 'Skill "approval-gate"'
```

---

## Exit Criteria

- [ ] C1. `verify-plan-pipeline.md` exists at `writing-plans/tasks/verify-plan-pipeline.md` and no longer exists at `approval-gate-scope/tasks/`
- [ ] C2. Both `approval-gate/SKILL.md` and `approval-gate-scope/SKILL.md` have no references to `verify-plan-pipeline` (TDT, Invocation, description)
- [ ] C3. `writing-plans/SKILL.md` has all required references: Task Cards, File Structure, TDT, Invocation, Workflows, description
- [ ] C4. Behavioral test passes: agent routes "verify plan pipeline" to `writing-plans`, not `approval-gate`

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T04:30:00Z | `plan_created` | Plan file at `.opencode/.issues/2224/plan.md`, 4 phases, stacked PR strategy |
