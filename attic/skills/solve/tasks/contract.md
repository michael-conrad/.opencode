# Task: contract — Contract YAML Schema Reference

## Purpose

Define and document the Z3 contract YAML schema that the `solve` tool consumes. Contract files declare typed variables, constraints (preconditions, invariants, postconditions), and theorems for formal verification.

## Entry Criteria

- A contract file needs to be created or reviewed
- Contract path is known or will be determined

## Procedure

### 1. Contract YAML Structure

```yaml
variables:
  step_completed:
    type: bool
    nullable: false
  pipeline_phase:
    type: string
    domain: ["analysis", "planning", "implementation", "verification"]
  retry_count:
    type: int
    nullable: true
  items_processed:
    type: int
preconditions:
  - "z3.Not(z3.BoolVal(step_completed))"
  - "z3.Or(pipeline_phase == z3.StringVal('analysis'), pipeline_phase == z3.StringVal('planning'))"
invariants:
  - "z3.Implies(items_processed >= z3.IntVal(0), items_processed <= z3.IntVal(100))"
postconditions:
  - "z3.BoolVal(step_completed)"
theorem:
  - "z3.Implies(z3.And(z3.BoolVal(step_completed), pipeline_phase == z3.StringVal('verification')), items_processed >= z3.IntVal(1))"
```

### 2. Variables Section

Each variable declaration supports:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `type` | Yes | `string` | One of: `bool`, `int`, `string`, `real` |
| `domain` | No | `list[str]` | Allowed values (string type only) |
| `nullable` | No | `bool` | If true, `null`/empty skips the constraint |

Supported Z3 sorts per type:
- `bool` → `z3.BoolSort()`
- `int` → `z3.IntSort()`
- `string` → `z3.StringSort()`
- `real` → `z3.RealSort()`

### 3. Constraint Sections

All constraint sections are lists of Z3 expression strings evaluated with `z3` module available as `z3` and variable constants available by name.

#### preconditions

Constraints that must hold before an action. Asserted first in check/model/prove. Used to establish the validity context.

#### invariants

Constraints that must hold throughout. Asserted alongside postconditions in check; used as assumptions in prove.

#### postconditions

Constraints that must hold after an action. Asserted after preconditions in check.

#### theorem

Expression to prove (used by `prove` subcommand). Negated and checked for unsatisfiability under preconditions + invariants.

### 4. Z3 Expression Syntax

All expressions are Python strings evaluated in a context where:
- Variable names resolve to Z3 constants
- `z3` module is available
- `z3.` prefix required for Z3 functions

#### Logical Operators

| Expression | Z3 API | Example |
|------------|--------|---------|
| Implication | `z3.Implies(a, b)` | `z3.Implies(z3.BoolVal(step_completed), items_processed >= z3.IntVal(1))` |
| Conjunction | `z3.And(a, b, ...)` | `z3.And(z3.BoolVal(phase_ok), z3.BoolVal(retry_not_exceeded))` |
| Disjunction | `z3.Or(a, b, ...)` | `z3.Or(pipeline_phase == z3.StringVal('planning'), pipeline_phase == z3.StringVal('analysis'))` |
| Negation | `z3.Not(a)` | `z3.Not(z3.BoolVal(step_completed))` |

#### Value Constructors

| Constructor | Usage | Example |
|-------------|-------|---------|
| `z3.BoolVal(v)` | Boolean literal | `z3.BoolVal(True)`, `z3.BoolVal(False)` |
| `z3.IntVal(v)` | Integer literal | `z3.IntVal(42)` |
| `z3.StringVal(v)` | String literal | `z3.StringVal('verification')` |
| `z3.RealVal(v)` | Real literal | `z3.RealVal(3.14)` |

#### Comparison Operators

Standard Python operators work with Z3 constants: `==`, `!=`, `>=`, `<=`, `>`, `<`.

```python
items_processed >= z3.IntVal(0)
pipeline_phase != z3.StringVal('')
```

#### Distinct Values

```python
z3.Distinct(z3.IntVal(1), z3.IntVal(2), z3.IntVal(3))
```

#### Full Example

```yaml
variables:
  all_prs_merged:
    type: bool
  branch_deleted:
    type: bool
  cleanup_phase:
    type: string
    domain: ["pre_merge", "post_merge", "complete"]
    nullable: true
preconditions:
  - "z3.Or(cleanup_phase == z3.StringVal('post_merge'), cleanup_phase == z3.StringVal('complete'))"
invariants:
  - "z3.Not(z3.And(z3.BoolVal(branch_deleted), z3.Not(z3.BoolVal(all_prs_merged))))"
postconditions:
  - "z3.BoolVal(all_prs_merged)"
  - "z3.BoolVal(branch_deleted)"
theorem:
  - "z3.Implies(z3.BoolVal(all_prs_merged), z3.BoolVal(branch_deleted))"
```

### 5. Validation Rules

- Every variable name in constraints must be declared in the variables section
- String variables with `domain` set must use `z3.StringVal()` with values within the domain
- `nullable: true` allows `null` or empty string values that skip constraint generation
- Constraint expressions must evaluate to `z3.BoolRef`

## Exit Criteria

- Contract YAML file is valid and loadable by `solve`
- Variables section declares all referenced variables
- Every constraint expression is syntactically valid Python Z3 expressions
- Z3 expression keywords (Implies, And, Or, Not, StringVal, BoolVal, IntVal, Distinct) are used where appropriate

## Cross-References

- `tools/solve` lines 66-107: Z3 factory and expression evaluator
- `tasks/check.md` — State validation using contract
- `tasks/model.md` — SAT query with contract constraints
- `tasks/prove.md` — Theorem proving with contract constraints
- `tasks/fallback.md` — Manual validation when Z3 unavailable