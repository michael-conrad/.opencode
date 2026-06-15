# Task: check — State Validation Against Contract

## Purpose

Validate a state YAML file against a contract YAML file using Z3. Determines whether the state assignments satisfy the contract's preconditions, postconditions, and invariants. When unsatisfiable, extracts and reports the unsat core.

## Entry Criteria

- Contract YAML file exists with variables and constraints
- State YAML file exists with variable assignments
- Z3 is available (if not, use `tasks/fallback.md`)

## Procedure

### 1. Invocation

```
./.opencode/tools/solve check --state-path <state.yaml> --contract-path <contract.yaml>
```

### 2. Check Sequence

The tool performs a two-phase check:

**Phase 1 — Preconditions only:**
- [ ] 1. Load state variables as equality assertions (e.g., `step_completed == BoolVal(true)`)
- [ ] 2. Assert all preconditions from the contract
- [ ] 3. Check satisfiability

Result:
- **SAT**: Preconditions are satisfiable. Print the model (variable assignments).
- **UNSAT**: Preconditions conflict with state. Print unsat core labels. HALT — state is invalid.

**Phase 2 — Postconditions + Invariants:**
- [ ] 4. Keep all assertions from Phase 1
- [ ] 5. Assert all postconditions and invariants
- [ ] 6. Check satisfiability

Result:
- **SAT**: All constraints satisfiable. Print model. State is valid.
- **UNSAT**: State + postconditions + invariants conflict. Print unsat core labels. Exit code 1.

### 3. Unsat Core Extraction

When `check()` returns `z3.unsat`, the solver extracts the unsat core:

```
UNSAT (+ postconditions + invariants)
  label: step_completed
  label: cleanup_phase == StringVal('post_merge')
```

Each label corresponds to a constraint assertion. The core identifies the minimal conflicting set.

### 4. Interpreting Results

| Result | Meaning | Action |
|--------|---------|--------|
| SAT | State satisfies all contract constraints | State is valid |
| UNSAT (preconditions) | State conflicts with preconditions | Fix state or contract |
| UNSAT (+post+inv) | Postconditions/invariants conflict | Fix constraints or state |

### 5. Common Failure Patterns

| Unsat Core Pattern | Root Cause |
|--------------------|------------|
| Single precondition label | State violates a precondition |
| Postcondition + invariant labels together | Postcondition contradicts invariant |
| State variable + constraint label | State assignment directly conflicts with constraint |

## Exit Criteria

- State file is validated against contract
- SAT result with model output confirms validity
- UNSAT result with unsat core identifies conflicting constraints
- Validation result reported (PASS/FAIL) with evidence

## Cross-References

- `tools/solve` lines 137-192: `_action_check` implementation
- `tasks/contract.md` — Contract schema with preconditions, postconditions, invariants
- `tasks/state.md` — State file format and lifecycle
- `tasks/fallback.md` — Manual validation when Z3 unavailable