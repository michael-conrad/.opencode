# Task: check

## Purpose

Validate current state against contract constraints. The check operation evaluates all preconditions, invariants, and postconditions with the current variable assignments. Returns SAT (valid) or UNSAT (conflict detected). On UNSAT, extract and report the unsat core — the minimal set of conflicting constraints.

## Entry Criteria

- State file exists at `--state-path`
- Contract YAML exists at `--contract-path`
- State variables are within their declared domains (pre-validated by update)

## Exit Criteria

- SAT: state is valid against contract — proceed to model or prove
- UNSAT: unsat core extracted and reported — diagnose and fix conflicting constraints before proceeding

## Procedure

### Step 1: Run check

```
solve check --state-path ./tmp/{issue-N}/state/ --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

### Step 2: Evaluate result

**SAT** — state is consistent with all contract constraints. The pipeline position is valid. Proceed to `model` or `prove`.

**UNSAT** — one or more constraints are violated. The solver found no satisfying assignment.

### Step 3: Unsat core extraction (on UNSAT)

When SOLVE returns UNSAT, extract the unsat core to identify the minimal conflicting constraints. The unsat core is the subset of preconditions, invariants, and postconditions that cannot be simultaneously satisfied.

Report the unsat core as:

```
UNSAT Core:
  - precondition-3: "z3.Implies(previous_step == StringVal('init'), current_step == StringVal('pre-red-baseline'))"
  - invariant-1: "z3.Not(previous_step == current_step)"
Conflicting variables: previous_step=init, current_step=init
```

### Step 4: Remediation

On UNSAT:
1. Identify which constraint(s) are violated from the unsat core
2. Determine if the state or the contract needs updating
3. Fix the state via `solve state update` or revise the contract
4. Re-run `solve check` to confirm SAT

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)