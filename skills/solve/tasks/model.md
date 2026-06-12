# Task: model

## Purpose

Evaluate a SAT query against the contract. The model operation checks whether a given query expression is satisfiable under the contract's preconditions and invariants. Returns a satisfying assignment (model) on SAT.

## Entry Criteria

- Contract YAML exists at `--contract-path`
- `solve check` has been run and returned SAT (state is valid)
- Query expression is defined in the contract or provided

## Exit Criteria

- SAT: satisfying assignment returned with variable bindings
- UNSAT: query is unsatisfiable under preconditions + invariants — report unsat core

## Procedure

### Step 1: Verify state consistency

Confirm `solve check` returned SAT for the current state before running the query.

### Step 2: Run model

```
solve model --contract-path .issues/{issue-N}/spec-artifacts/dependency-ordering-contract.yaml --query "z3.And(phase_1 < phase_2, phase_1 < phase_3)"
```

The query evaluates with all preconditions and invariants enforced. If preconditions are not met, the solver returns UNSAT.

### Step 3: Evaluate result

**SAT** — the query is satisfiable. A satisfying assignment is returned showing concrete variable values:

```
SAT
phase_1: 1
phase_2: 2
phase_3: 3
preconditions: satisfied
invariants: maintained
```

**UNSAT** — the query cannot be satisfied under current constraints. Extract unsat core per `check` task Step 3.

### Step 4: Report

Return the model result contract:

```yaml
status: SAT|UNSAT
query: "<query expression>"
assignment:
  <var>: <value>
  <var>: <value>
unsat_core: ["<constraint-1>", "<constraint-2>"]  # if UNSAT
```

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)