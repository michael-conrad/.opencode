---
plan_schema_version: "1.0"
issue: 2213
title: "Consolidate plan-creation-pipeline into writing-plans"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2213 — Consolidate plan-creation-pipeline into writing-plans

**Goal:** Delete the `plan-creation-pipeline` skill directory, update all cross-references to point to `writing-plans`, add a `handoff` task to `writing-plans`, update the workflow order, enhance `completion.md`, and verify no behavioral change to Z3/planning steps.

**Architecture:** Four-phase approach: (1) cross-reference updates, (2) deletion of the obsolete skill, (3) workflow changes to writing-plans (handoff task, workflow reorder, TDT updates, completion enhancement), (4) no-change verification of Z3 steps. Each phase must complete before the next begins.

**Files:**
- `.opencode/skills/plan-creation-pipeline/` (delete)
- `.opencode/skills/plan/SKILL.md` (modify)
- `.opencode/skills/writing-plans/tasks/handoff.md` (create)
- `.opencode/skills/writing-plans/SKILL.md` (modify)
- `.opencode/skills/writing-plans/tasks/completion.md` (modify)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — cross-reference-updates | `test-driven-development` | `red` + `green` | `plan/SKILL.md` | SC-5 | — |
| 2 — deletion | `test-driven-development` | `red` + `green` | `plan-creation-pipeline/` | SC-1 | 1 |
| 3 — workflow-changes | `test-driven-development` | `green` | `writing-plans/tasks/handoff.md`, `writing-plans/SKILL.md`, `writing-plans/tasks/completion.md` | SC-2, SC-3, SC-6, SC-4 | 2 |
| 4 — no-change-verification | `(orchestrator)` | `z3-check` | `writing-plans/tasks/research.md` | SC-7 | 3 |

---

## Phase Details

### Phase 1 — cross-reference-updates

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` + `green` |
| Target | `plan/SKILL.md` |
| SCs | SC-5 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-5]
files_to_modify:
  - .opencode/skills/plan/SKILL.md
cross_reference_pattern: "plan-creation-pipeline"
cross_reference_replacement: "writing-plans"
```

**Procedure:**
1. RED: Write an enforcement test that verifies all cross-references to `plan-creation-pipeline` in `.opencode/` are updated to `writing-plans`
2. GREEN: Update all cross-references in `.opencode/skills/plan/SKILL.md` from `plan-creation-pipeline` to `writing-plans`
3. COMMIT: Stage and commit the test and changes together

### Phase 2 — deletion

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` + `green` |
| Target | `plan-creation-pipeline/` |
| SCs | SC-1 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-1]
files_to_delete:
  - .opencode/skills/plan-creation-pipeline/
```

**Procedure:**
1. RED: Write an enforcement test that verifies the `plan-creation-pipeline` skill directory no longer exists
2. GREEN: Delete `.opencode/skills/plan-creation-pipeline/` directory
3. COMMIT: Stage and commit the test and changes together

### Phase 3 — workflow-changes

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `writing-plans/tasks/handoff.md`, `writing-plans/SKILL.md`, `writing-plans/tasks/completion.md` |
| SCs | SC-2, SC-3, SC-6, SC-4 |
| Depends On | 2 |

**Context:**
```yaml
sc_ids: [SC-2, SC-3, SC-6, SC-4]
new_workflow_order:
  - handoff
  - analyze
  - research
  - create
  - validate
  - revise_loop
  - completion
handoff_task_path: .opencode/skills/writing-plans/tasks/handoff.md
completion_task_path: .opencode/skills/writing-plans/tasks/completion.md
skill_card_path: .opencode/skills/writing-plans/SKILL.md
```

**Procedure:**
For each SC in [SC-2, SC-3, SC-6, SC-4]:
1. RED: Write an enforcement test for the SC criterion
2. GREEN: Implement the change that makes the test pass
3. COMMIT: Stage and commit the test and changes together

SC-to-implementation mapping:
- SC-2: Create `writing-plans/tasks/handoff.md` that calls `approval-gate --task verify-authorization`
- SC-3: Update `writing-plans/SKILL.md` workflow order to: handoff → analyze → research → create → validate → (revise loop) → completion
- SC-6: Update `writing-plans/SKILL.md` Trigger Dispatch Table and Workflows section to reflect the new workflow
- SC-4: Enhance `writing-plans/tasks/completion.md` with `local-issues sync` and chat output including exec summary, URL, and AI byline

### Phase 4 — no-change-verification

| Field | Value |
|-------|-------|
| Skill | `(orchestrator)` |
| Task | `z3-check` |
| Target | `writing-plans/tasks/research.md` |
| SCs | SC-7 |
| Depends On | 3 |

**Context:**
```yaml
sc_ids: [SC-7]
research_task_path: .opencode/skills/writing-plans/tasks/research.md
z3_steps_to_verify:
  - solve-model
  - solve-check
  - plan-plan
```

**Procedure:**
1. Run Z3 constraint solver to verify solve-model, solve-check, and plan-plan steps remain unchanged in `research.md`
2. Verify no behavioral change detected in Z3/planning steps
3. Report verification results

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T23:35:00Z | `plan_created` | Plan file at `.opencode/.issues/2213/plan.md`, 4 phases |

## Exit Criteria

- [ ] C1. All cross-references to `plan-creation-pipeline` in `.opencode/` are updated to `writing-plans` (SC-5)
- [ ] C2. `plan-creation-pipeline` skill directory is deleted (SC-1)
- [ ] C3. `writing-plans/tasks/handoff.md` exists and calls `approval-gate --task verify-authorization` (SC-2)
- [ ] C4. `writing-plans/SKILL.md` workflow order is: handoff → analyze → research → create → validate → (revise loop) → completion (SC-3)
- [ ] C5. `writing-plans/SKILL.md` Trigger Dispatch Table and Workflows section reflect the new workflow (SC-6)
- [ ] C6. `writing-plans/tasks/completion.md` includes `local-issues sync` and chat output with exec summary + URL + AI byline (SC-4)
- [ ] C7. Z3/planning steps (solve-model, solve-check, plan-plan) remain unchanged in `research.md` (SC-7)
