# Task: state

## Purpose

Manage pipeline state files. State files track variable values across workflow phases, enabling cross-phase data sharing with optional type validation via contract files.

## Entry Criteria

- State file path is determined

## Procedure

### Initialize State File

```bash
./.opencode/tools/plan state init <path>/
```

Creates a `state.yaml` file at the given directory with empty `variables` dict and a `timestamp`.

### Update a Variable

```bash
./.opencode/tools/plan state update <path>/ --var-name <name> --var-value <value>
```

Optional contract-based validation:

```bash
./.opencode/tools/plan state update <path>/ --var-name <name> --var-value <value> --contract-path <contract.yaml>
```

- `--contract-path` enables type/domain validation against a contract YAML's variable declarations
- `--var-type` enables type coercion (bool/int/real/string) without a full contract

### View State

```bash
./.opencode/tools/plan state status <path>/
```

Prints all variables and the last update timestamp.

## Exit Criteria

- State file exists at the specified path
- Variable values are correctly stored and typed