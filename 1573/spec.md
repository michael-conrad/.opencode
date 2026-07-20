## Observed Behavior

The `writing-plans` skill's `create.md` task file references sub-tasks that must be dispatched via `task()`:

- `research` → `writing-plans/tasks/research.md`
- `readiness` → `writing-plans/tasks/readiness.md`
- `structure` → `writing-plans/tasks/structure.md`
- `solve` → `writing-plans/tasks/solve.md`
- `write` → `writing-plans/tasks/write.md`
- `revisit` → `writing-plans/tasks/revisit.md`
- `audit-fidelity` → `writing-plans/tasks/audit-fidelity.md`
- `audit-concern` → `writing-plans/tasks/audit-concern.md`

Only `validate.md` exists in `.opencode/skills/writing-plans/tasks/`. The other 8 files are missing.

## Expected Behavior

All task files referenced by `create.md` should exist, or `create.md` should be updated to reference only existing tasks.

## Steps to Reproduce

1. `ls .opencode/skills/writing-plans/tasks/`
2. Compare against task references in `.opencode/skills/writing-plans/tasks/create.md`

## Component

`.opencode/skills/writing-plans/` — task file inventory

## Severity

High — agents executing the 21-step plan creation pipeline hit BLOCKED on missing task files, requiring manual workarounds.