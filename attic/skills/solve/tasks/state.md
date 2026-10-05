# Task: state — State File Lifecycle Management

## Purpose

Manage state YAML files used by the `solve` tool. State files hold variable assignments that are validated against contracts. Lifecycle: init → update → status.

## Entry Criteria

- A state file needs to be created, modified, or inspected
- Contract path may be provided for type validation on update

## Procedure

### 1. State File Format

```yaml
variables:
  step_completed: true
  pipeline_phase: "analysis"
  retry_count: 3
  items_processed: 25
timestamp: "2026-06-12T10:00:00+00:00"
```

### 2. State Subcommands

#### init

Create a new state file at the specified path:

```
./.opencode/tools/solve state init <path>
```

- If `path` has no suffix, `state.yaml` is appended (directory mode)
- Creates parent directories as needed
- Initializes with empty `variables: {}` and current UTC timestamp
- Parent directories created automatically

#### update

Update one variable in an existing state file:

```
./.opencode/tools/solve state update <path> --var-name <name> --var-value <value> [--contract-path <contract>]
```

- When `--contract-path` is provided, the value is validated against the contract schema:
  - `bool`: accepts `true`/`false`/`1`/`0`/`yes`/`no`
  - `int`: parsed as integer
  - `string`: validated against `domain` if declared
  - `nullable`: accepts `null` or empty string
- Without `--contract-path`, values are stored as raw strings
- Timestamp is updated on every write

#### status

Print current state:

```
./.opencode/tools/solve state status <path>
```

Output format:
```
timestamp: 2026-06-12T10:00:00+00:00
variables:
  step_completed: true
  pipeline_phase: "analysis"
```

### 3. Variable Scoping

- Variables are flat key-value pairs in the `variables` mapping
- Each variable corresponds to a contract declaration by name
- Variables not declared in the contract are stored as-is (pass-through)
- Missing variables in state are excluded from constraint assertions during `check`

## Exit Criteria

- State file exists at the target path
- Variables reflect the desired assignments
- Timestamp is current
- Values are properly typed per contract schema (when contract path provided)

## Cross-References

- `tools/solve` lines 268-378: State implementation
- `tools/solve` lines 124-129: Path resolution (directory/file suffix handling)
- `tasks/contract.md` — Variable declaration schema
- `tasks/check.md` — State validation against contract