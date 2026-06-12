# Task: ground

## Purpose

Ground action schemas by binding all action parameters to concrete objects. Grounding produces a flat list of parameter-free action instances that can be directly planned over.

## Entry Criteria

- Problem YAML file exists with action schemas (parameterized actions)
- Objects are declared in the problem

## Procedure

### Step 1: Load Problem YAML

Ensure the problem YAML has action schemas with `params` and concrete `objects` that provide values for parameter types.

### Step 2: Run Grounding

```bash
./.opencode/tools/plan ground --problem <problem.yaml>
```

To write output to a file:

```bash
./.opencode/tools/plan ground --problem <problem.yaml> --output <grounded.yaml>
```

### Step 3: Interpret Output

The grounded output lists all possible groundings of each action schema. For example, an action `go(from: location, to: location)` with two location objects `home` and `work` produces groundings: `go(home, work)` and `go(work, home)`.

### Step 4: Filter Relevant Groundings (Optional)

Not all groundings may be relevant. Filter the grounded list to the subset applicable to the current problem state.

## Exit Criteria

- Grounding completes with exit code 0
- Grounded actions have all parameters bound to concrete objects
- Grounded output is valid YAML