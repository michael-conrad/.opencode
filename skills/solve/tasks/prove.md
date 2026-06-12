# Task: prove — Theorem Proving

## Purpose

Prove a theorem (logical expression) follows from the contract's preconditions and invariants. Uses Z3's SAT solver: negate the theorem and check unsatisfiability. If the negated theorem is UNSAT under the assumptions, the theorem is VALID.

## Entry Criteria

- Contract YAML file exists with variables, preconditions, and invariants
- Theorem expression is a valid Z3 Boolean expression string
- Z3 is available (if not, use `tasks/fallback.md`)

## Procedure

### 1. Invocation

```
./.opencode/tools/solve prove --contract-path <contract.yaml> --theorem "<expression>"
```

### 2. Proving Sequence

1. Load contract variables as Z3 constants
2. Assert all preconditions as assumptions
3. Assert all invariants as assumptions
4. Assert the negation of the theorem: `z3.Not(theorem_expression)`
5. Check satisfiability

This is the standard refutation-based proof technique: assume the axioms (preconditions + invariants) and check that the negated theorem cannot be satisfied.

### 3. Result Interpretation

| Result | Meaning | Action |
|--------|---------|--------|
| VALID (UNSAT) | Negated theorem is unsatisfiable → theorem holds under all valid states | Theorem is proven |
| INVALID (SAT) | Counterexample exists where preconditions+invariants hold but theorem is false | Counterexample model shows why theorem fails |

On INVALID, the solver prints a counterexample model:

```
INVALID
  items_processed = 0
  step_completed = True
```

This shows a concrete state satisfying preconditions+invariants where the theorem is false.

### 4. Example Theorems

```
# All completed steps have processed at least one item
./.opencode/tools/solve prove --contract-path contract.yaml --theorem "z3.Implies(z3.BoolVal(step_completed), items_processed >= z3.IntVal(1))"

# A phase cannot be both pre and post merge
./.opencode/tools/solve prove --contract-path contract.yaml --theorem "z3.Not(z3.And(cleanup_phase == z3.StringVal('pre_merge'), cleanup_phase == z3.StringVal('post_merge')))"

# Branch deletion implies all PRs merged
./.opencode/tools/solve prove --contract-path contract.yaml --theorem "z3.Implies(z3.BoolVal(branch_deleted), z3.BoolVal(all_prs_merged))"
```

### 5. Proof Strategy Tips

| Theorem Type | Approach |
|--------------|----------|
| Implication | Prove `Implies(A, B)` — negate to `A ∧ ¬B`, check UNSAT |
| Invariant property | Prove property follows from preconditions alone |
| Safety property | Prove no valid state reaches an undesirable condition |
| Equivalence | Prove both directions: `Implies(A, B)` ∧ `Implies(B, A)` |

## Exit Criteria

- Theorem VALID or INVALID result produced
- VALID: theorem is logically guaranteed under contract
- INVALID: counterexample model identifies why theorem fails
- Proof is refutation-based (negated theorem → check UNSAT)

## Cross-References

- `tools/solve` lines 233-259: `_action_prove` implementation
- `tasks/contract.md` — Theorem declaration and expression syntax
- `tasks/model.md` — SAT query (prove uses SAT solver differently)