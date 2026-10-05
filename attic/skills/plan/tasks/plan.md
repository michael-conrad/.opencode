# Task: plan

## Purpose

Generate a plan from a problem YAML file. Produces a sequence of grounded actions that transform the initial state to satisfy all goal conditions.

## Entry Criteria

- Problem YAML file exists and validates against the schema

## Procedure

### Step 1: Build Problem YAML

Create a problem YAML file conforming to the schema documented in `problem.md`. Include at minimum: `domain`, `objects`, `init`, `goals`, and at least one `action` definition.

### Step 2: Run Planner

```bash
./.opencode/tools/plan plan --problem <path-to-problem.yaml>
```

Optional engine selection:

```bash
./.opencode/tools/plan plan --problem <path> --engine <engine>
```

Default engine is `tamer`.

### Step 3: Interpret Result

| Status | Meaning | Action |
|--------|---------|--------|
| `SOLVED_SATISFICING` | Feasible plan found | Accept plan |
| `SOLVED_OPTIMALLY` | Optimal plan found | Accept plan |
| `UNSOLVABLE_PROVEN` | No solution exists | Revise problem |
| `UNSOLVABLE_INCOMPLETELY` | No solution found (incomplete search) | Revise or retry |
| `TIMEOUT` | Planner timed out | Increase timeout or simplify |
| `MEMOUT` | Planner ran out of memory | Simplify problem |

### Step 4: Store Plan Output

The planner outputs YAML plan data to stdout after a separator (`---`). Capture and save it:

```bash
./.opencode/tools/plan plan --problem <path> > plan-output.yaml
```

## Exit Criteria

- Plan generation exits with code 0
- Status is `SOLVED_SATISFICING` or `SOLVED_OPTIMALLY`
- Plan output is stored as valid YAML with `actions` list