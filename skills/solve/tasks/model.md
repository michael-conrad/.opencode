# Task: model — SAT Query with Satisfying Assignment

## Purpose

Query the Z3 solver for satisfiability of a user-provided expression under the contract's preconditions and invariants. If satisfiable, return a satisfying assignment (model) showing concrete values for all variables.

## Entry Criteria

- Contract YAML file exists with variables, preconditions, and invariants
- Query expression is a valid Z3 Boolean expression string
- Z3 is available (if not, use `tasks/fallback.md`)

## Procedure

### 1. Invocation

```
./.opencode/tools/solve model --contract-path <contract.yaml> --query "<expression>"
```

### 2. Model Query Sequence

The tool enforces preconditions and invariants before the query:

1. Load contract variables as Z3 constants
2. Assert all preconditions from the contract
3. Assert all invariants from the contract
4. Assert the user's query expression
5. Check satisfiability

This ordering ensures the query is evaluated only in valid contexts — preconditions establish validity, invariants enforce consistency.

### 3. Result Interpretation

| Result | Meaning | Action |
|--------|---------|--------|
| SAT | Query is satisfiable under contract constraints | Read the model to see concrete variable assignments |
| UNSAT | Query contradicts preconditions + invariants | The query is impossible under the given contract |

On SAT, the model prints all variable assignments:

```
SAT
  items_processed = 25
  pipeline_phase = "verification"
  step_completed = True
```

### 4. Example Queries

```
# Is there a state where items_processed > 0?
./.opencode/tools/solve model --contract-path contract.yaml --query "items_processed >= z3.IntVal(1)"

# Can pipeline_phase be both planning and verification?
./.opencode/tools/solve model --contract-path contract.yaml --query "z3.And(pipeline_phase == z3.StringVal('planning'), pipeline_phase == z3.StringVal('verification'))"

# Is it possible for step to be completed without items?
./.opencode/tools/solve model --contract-path contract.yaml --query "z3.And(z3.BoolVal(step_completed), items_processed == z3.IntVal(0))"
```

### 5. Common Pitfalls

| Pitfall | Explanation |
|---------|-------------|
| Missing precondition | Query may be satisfiable in an invalid state context |
| Overly constrained query | Adding too many And clauses produces UNSAT |
| String domain mismatch | Query uses StringVal outside contract domain → model never assigns it |

## Exit Criteria

- SAT/UNSAT result produced
- Model printed on SAT with all variable assignments
- Query expression verified as valid Z3 syntax
- Preconditions+invariants enforced before query

## Cross-References

- `tools/solve` lines 200-225: `_action_model` implementation
- `tasks/contract.md` — Preconditions and invariants declaration
- `tasks/check.md` — Full state validation (model with state assignments)