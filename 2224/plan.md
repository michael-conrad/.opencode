---
plan_schema_version: "1.0"
issue: 2224
title: "Move verify-plan-pipeline from approval-gate-scope to writing-plans"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
---

# Implementation Plan — #2224 — Move verify-plan-pipeline to writing-plans

**Goal:** Move the `verify-plan-pipeline` task from `approval-gate-scope` to `writing-plans`, update all cross-references, and ensure agent intent matching routes "verify plan pipeline" to `writing-plans`.

**Architecture:** File move + cross-reference update. No runtime behavior changes to the task procedure. The task file is copied to the new location and deleted from the old. SKILL.md files in `approval-gate` and `approval-gate-scope` have TDT/Invocation rows removed. `writing-plans/SKILL.md` gains TDT, Invocation, task card entry, file structure entry, workflow step, and updated description. A behavioral test verifies agent routing.

**Cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. This is a file move and cross-reference update. No runtime behavior changes to the task procedure itself.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/approval-gate-scope/SKILL.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md`
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` (new)

---

## Pre-implementation

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec #2224 is internally consistent: all SCs are testable, no conflicting requirements, evidence types match verification methods. **→ All SCs**
- [ ] 2. **Baseline check (**clean-room**).** Verify current state: `verify-plan-pipeline.md` exists at source, does NOT exist at target. Grep for `verify-plan-pipeline` in `approval-gate/SKILL.md` and `approval-gate-scope/SKILL.md` — confirm matches exist. Grep `writing-plans/SKILL.md` — confirm no matches. **→ All SCs**

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Move task file | `test-driven-development` | `red`/`green` | `writing-plans/tasks/verify-plan-pipeline.md` | SC-1 | — |
| 2 — Update approval-gate/SKILL.md | `test-driven-development` | `red`/`green` | `approval-gate/SKILL.md` | SC-2, SC-7 | 1 |
| 3 — Update approval-gate-scope/SKILL.md | `test-driven-development` | `red`/`green` | `approval-gate-scope/SKILL.md` | SC-3, SC-8 | 1 |
| 4 — Update writing-plans/SKILL.md | `test-driven-development` | `red`/`green` | `writing-plans/SKILL.md` | SC-4, SC-5, SC-6, SC-9, SC-10, SC-11 | 1 |
| 5 — Verify behavioral routing | `test-driven-development` | `red`/`green` | Behavioral test | SC-12 | 2, 3, 4 |

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

### Phase 2 — Update approval-gate/SKILL.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `approval-gate/SKILL.md` |
| SCs | SC-2, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
file: ".opencode/skills/approval-gate/SKILL.md"
sc_ids: [SC-2, SC-7]
removals:
  - TDT row for "verify plan pipeline" / "check pipeline completeness"
  - Invocation row for verify-plan-pipeline
  - Description trigger phrases "verify plan pipeline" and "check pipeline completeness"
```

### Phase 3 — Update approval-gate-scope/SKILL.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | `approval-gate-scope/SKILL.md` |
| SCs | SC-3, SC-8 |
| Depends On | 1 |

**Context:**
```yaml
file: ".opencode/skills/approval-gate-scope/SKILL.md"
sc_ids: [SC-3, SC-8]
removals:
  - TDT row for verify-plan-pipeline
  - Description trigger phrases "verify plan pipeline" and "check pipeline completeness"
```

### Phase 4 — Update writing-plans/SKILL.md

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

### Phase 5 — Verify Behavioral Routing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`/`green` |
| Target | Behavioral test |
| SCs | SC-12 |
| Depends On | 2, 3, 4 |

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
- [ ] C2. `approval-gate/SKILL.md` has no references to `verify-plan-pipeline` (TDT, Invocation, description)
- [ ] C3. `approval-gate-scope/SKILL.md` has no references to `verify-plan-pipeline` (TDT, description)
- [ ] C4. `writing-plans/SKILL.md` has all required references: Task Cards, File Structure, TDT, Invocation, Workflows, description
- [ ] C5. Behavioral test passes: agent routes "verify plan pipeline" to `writing-plans`, not `approval-gate`
