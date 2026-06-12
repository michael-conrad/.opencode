# Task: state

## Purpose

Manage state file lifecycle. State files track variable assignments that are validated against contract constraints. The lifecycle follows: init → update → status → clear.

## Entry Criteria

- State path provided
- Contract path available (for validation during update)

## State File Format

```yaml
schema_version: "1.0"
last_updated: "<ISO-8601>"
variables:
  <var_name>: <value>
  <var_name>: <value>
state_path: "<path>"
contract_path: "<path>"
```

## Exit Criteria

- State file created, updated, or queried successfully
- Variable values are within their declared domains per contract
- State mutations preserve schema version

## Procedure

### Step 1: Init

Create a new state file at the specified path with initial variable values:

```
solve state init ./tmp/{issue-N}/state/
```

Creates `state.yaml` with empty variables and default metadata.

### Step 2: Update

Update one variable at a time. Each update writes the new value and updates `last_updated`:

```
solve state update ./tmp/{issue-N}/state/ --var-name current_step --var-value exec-summary --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
```

One variable per call. Batch by calling sequentially if multiple updates are needed.

Variable updates MUST specify the contract path so the tool validates the new value against the variable's domain constraints.

### Step 3: Status

Read current state:

```
solve state status ./tmp/{issue-N}/state/
```

Returns all variable assignments, state path, contract path, and last updated timestamp.

### Step 4: Clear

Reset state variables to empty:

```
solve state clear ./tmp/{issue-N}/state/
```

Preserves path metadata. Removes all variable assignments.

### Variable Scoping

| Scope | Lifetime | Example |
|-------|----------|---------|
| Issue-local | Single issue workflow | `./tmp/{issue-N}/state/` |
| Phase-local | Single phase | `./tmp/{issue-N}/state/phase-2/` |
| Contract-bound | Tied to a specific contract | Uses `--contract-path` in update calls |

### Usage in Pipeline

The implementation pipeline uses three sequential `solve state update` calls per step:

1. `--var-name previous_step --var-value <current-step-label>`
2. `--var-name current_step --var-value <next-step-label>`
3. `--var-name pipeline_state --var-value running`

Each call includes `--contract-path` pointing to `pipeline-state-machine.yaml` for domain validation.

Solve state tracks pipeline **position** only. Step results go to YAML disk artifacts — never into solve state.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)