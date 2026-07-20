## Observed Behavior

The `writing-plans` skill pipeline (in `create.md`) references `solve check` and `solve model` commands at multiple Z3 check steps. However, `.opencode/tools/solve` does not exist:

```
$ ls .opencode/tools/solve
ls: cannot access '.opencode/tools/solve': No such file or directory
```

## Expected Behavior

Either:
- A `solve` tool should exist at `.opencode/tools/solve` that implements `solve check` and `solve model`
- Or the `writing-plans` skill should be updated to remove references to the non-existent tool

## Steps to Reproduce

1. `ls .opencode/tools/solve`
2. Observe: file not found
3. Search `create.md` for `solve check` / `solve model` references

## Component

`.opencode/tools/solve` (missing) + `.opencode/skills/writing-plans/tasks/create.md`

## Severity

High — every Z3 check step in the plan creation pipeline is a no-op, breaking the verification chain.