# Task: validate

## Purpose

Validate a generated plan against a problem domain. Confirms the plan's action sequence satisfies all goal conditions when executed from the initial state.

## Entry Criteria

- Problem YAML file exists and validates
- Plan YAML file exists with an `actions` list

## Procedure

### Step 1: Load Plan and Problem

Ensure both the problem YAML and the plan YAML are accessible. The plan file must contain an `actions` list where each entry has `name` and optionally `parameters`:

```yaml
actions:
  - name: go
    parameters: ["home", "work"]
```

### Step 2: Run Validation

```bash
./.opencode/tools/plan validate --plan <plan-path> --problem <problem-path>
```

### Step 3: Interpret Result

| Status | Meaning | Action |
|--------|---------|--------|
| `valid` (exit 0) | Plan satisfies all goals | Accept |
| `invalid` (exit 1) | Not all goals achieved | Revise plan or problem |

When validation fails, the output lists which goals remain unsatisfied in the final state.

## Exit Criteria

- Validation confirms plan satisfies all goals (exit 0)
- Every action in the plan exists in the problem's action schema
- Parameter counts and object references are correct