# Task: contract

## Purpose

Define and validate contract YAML files used by the solve tool. A contract declares typed variables, preconditions, invariants, postconditions, theorems, and query expressions. All solve operations (check, model, prove) depend on a valid contract.

## Entry Criteria

- Contract YAML path provided or discoverable
- Variable types and domains are defined

## Contract Schema

```yaml
name: <contract-name>
schema_version: "1.0"
last_updated: "<ISO-8601>"
variables:
  <var_name>:
    type: <string|int|bool>
    domain: [<value1>, <value2>, ...]  # optional: restricts values
preconditions:
  - "<z3 expression string>"
  - "<z3 expression string>"
invariants:
  - "<z3 expression string>"
postconditions:
  - "<z3 expression string>"
theorem: "<z3 expression string>"
query: "<z3 expression string>"
```

### Variable Types

| Type | Z3 Sort | Example |
|------|---------|---------|
| `string` | `z3.StringVal()` | `z3.StringVal('red-phase')` |
| `int` | `z3.IntVal()` | `z3.IntVal(42)` |
| `bool` | `z3.BoolVal()` | `z3.BoolVal(True)` |

### Keyword Expressions

All constraints are z3-native Python expressions evaluated against the contract's variables.

| Function | Meaning | Example |
|----------|---------|---------|
| `z3.Implies(A, B)` | If A then B | `z3.Implies(step == z3.StringVal('init'), next == z3.StringVal('pre-red'))` |
| `z3.And(A, B)` | Both A and B | `z3.And(a > 0, a < 100)` |
| `z3.Or(A, B)` | Either A or B | `z3.Or(state == z3.StringVal('running'), state == z3.StringVal('failed'))` |
| `z3.Not(A)` | Not A | `z3.Not(prev == curr)` |
| `z3.StringVal(x)` | String literal | `z3.StringVal('complete')` |
| `z3.BoolVal(x)` | Boolean literal | `z3.BoolVal(True)` |
| `z3.IntVal(x)` | Integer literal | `z3.IntVal(5)` |
| `z3.Distinct(A, B, C)` | All values are different | `z3.Distinct(a, b, c)` |

### Expression Examples

**Pipeline state transition (Implies + StringVal):**
```yaml
preconditions:
  - "z3.Implies(previous_step == z3.StringVal('init'), current_step == z3.StringVal('pre-red-baseline'))"
  - "z3.Implies(previous_step == z3.StringVal('pre-red-baseline'), z3.Or(current_step == z3.StringVal('red-phase'), current_step == z3.StringVal('sc-coherence-gate')))"
```

**Completion constraint (And + Not + StringVal):**
```yaml
postconditions:
  - "z3.Not(z3.And(pipeline_state == z3.StringVal('complete'), z3.Not(current_step == z3.StringVal('exec-summary'))))"
```

**Distinct values:**
```yaml
invariants:
  - "z3.Distinct(phase_a, phase_b, phase_c)"
```

## Exit Criteria

- Contract YAML validated against schema
- All referenced Z3 functions are correctly imported as `z3.<Function>`
- Variable types match their domain constraints
- Expressions are syntactically valid z3 Python strings

## Procedure

### Step 1: Define Variables

List all variables with their types and optional domain constraints:

```yaml
variables:
  current_step:
    type: string
    domain: [init, running, complete, failed]
  counter:
    type: int
  is_valid:
    type: bool
```

### Step 2: Define Preconditions

Preconditions must hold before the constraint is evaluated. Use `z3.Implies` for conditional constraints:

```yaml
preconditions:
  - "z3.Implies(pipeline_state == z3.StringVal('init'), current_step == z3.StringVal('pre-red-baseline'))"
```

### Step 3: Define Invariants

Invariants must hold at all times. Use `z3.Distinct` for uniqueness constraints:

```yaml
invariants:
  - "z3.Not(previous_step == current_step)"
  - "z3.Distinct(phase_a, phase_b, phase_c)"
```

### Step 4: Define Postconditions

Postconditions must hold after evaluation:

```yaml
postconditions:
  - "z3.Implies(current_step == z3.StringVal('exec-summary'), pipeline_state == z3.StringVal('complete'))"
```

### Step 5: Define Theorem or Query (Optional)

For prove tasks, define a theorem. For model tasks, define a query:

```yaml
theorem: "z3.Implies(z3.And(a > 0, b > 0), a + b > 0)"
query: "z3.And(previous_step == z3.StringVal('init'), current_step == z3.StringVal('pre-red-baseline'))"
```

### Step 6: Validate Contract

Read the contract YAML, verify:
- All `z3.*` function references use the canonical `z3.<Function>()` form
- Variable names in expressions match declared variables
- Value literals use correct type constructors (`StringVal`, `IntVal`, `BoolVal`)
- Domain constraints are consistent with variable types

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)