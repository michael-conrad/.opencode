# Task: prove

## Purpose

Prove a theorem against the contract's invariants. The prove operation checks whether a theorem expression holds given the contract's invariants and preconditions. Unlike model (which finds any satisfying assignment), prove validates that the theorem is universally true under the contract.

## Entry Criteria

- Contract YAML exists at `--contract-path`
- `solve check` has been run and returned SAT (state is valid)
- Theorem expression is defined in the contract under `theorem:` field

## Exit Criteria

- SAT: theorem holds under all invariant-satisfying assignments
- UNSAT: theorem is contradicted by invariants — report unsat core

## Procedure

### Step 1: Verify state consistency

Confirm `solve check` returned SAT for the current state before proving the theorem.

### Step 2: Run prove

```
solve prove --contract-path .issues/{issue-N}/spec-artifacts/sc-dependency-contract.yaml --theorem "sc_dag_is_valid"
```

The theorem field in the contract defines the expression. The prove operation evaluates it under the contract's invariants and preconditions.

### Step 3: Evaluate result

**SAT** — the theorem holds. All invariants are consistent with the theorem:

```
SAT
theorem: sc_dag_is_valid
invariants: maintained
preconditions: satisfied
```

**UNSAT** — the theorem is contradicted by one or more invariants. Extract unsat core per `check` task Step 3.

### Step 4: Report

Return the prove result contract:

```yaml
status: SAT|UNSAT
theorem: "<theorem name or expression>"
invariant_satisfied: true|false
unsat_core: ["<constraint-1>", "<constraint-2>"]  # if UNSAT
```

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)