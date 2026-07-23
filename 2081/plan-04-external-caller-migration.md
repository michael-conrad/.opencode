# Phase 4: External caller migration

**Skill:** `writing-plans`
**Task:** `revise`
**Target:** 9 caller files
**SCs:** SC-14
**Depends On:** Phase 3

## Context

Update 9 caller files with new dispatch strings:

| File | Old Pattern | New Pattern |
|---|---|---|
| `approval-gate-scope/enforcement/auto-dispatch-table.md` | `writing-plans --task create` | `task("execute create from writing-plans")` |
| `approval-gate-scope/tasks/verify-authorization/auto-dispatch.md` | `writing-plans --task create` | `task("execute create from writing-plans")` |
| `approval-gate-scope/tasks/verify-authorization/spec-to-plan-cascade.md` | `writing-plans --task create`, `writing-plans --task update` | `task("execute create from writing-plans")`, `task("execute revise from writing-plans")` |
| `approval-gate-scope/tasks/verify-plan-pipeline.md` | `writing-plans 22-step pipeline` | `writing-plans pipeline` (cosmetic) |
| `brainstorming/tasks/completion.md` | `writing-plans` (Path B) | `skill({name: "writing-plans"})` → `task("execute create from writing-plans")` |
| `issue-operations-comments/tasks/comment.md` | `writing-plans --task update` | `task("execute revise from writing-plans")` |
| `plan-creation-pipeline/SKILL.md` | `writing-plans --task create` | `task("execute create from writing-plans")` |
| `reference/holistic-dimensions.yaml` | `writing-plans/tasks/update.md` | `writing-plans/tasks/revise.md` |
| `guidelines/010-approval-gate.md` | `writing-plans --task update` | `task("execute revise from writing-plans")` |

## Entry Criteria

- [ ] Phase 3 complete (new writing-plans tasks implemented)
- [ ] All 9 caller files exist

## Procedure

1. Update each caller file with new dispatch string
2. Verify grep for old patterns returns zero matches in caller files

## Exit Criteria

- [ ] All 9 caller files updated
- [ ] `grep -r "writing-plans --task"` returns zero matches in caller files
- [ ] `grep -r "writing-plans 22-step"` returns zero matches
