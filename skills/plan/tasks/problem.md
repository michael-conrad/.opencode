# Task: problem

## Purpose

Reference for the Problem YAML schema used by the `plan` tool. All planning subcommands consume a problem YAML file conforming to this schema.

## Entry Criteria

- Knowledge of the domain and objects to model

## Schema Structure

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `domain` | string | yes | Domain name |
| `types` | list[{name}] | no | Type definitions for object classification |
| `objects` | list[{name, type}] | no | Concrete objects in the problem |
| `fluents` | list[{name, params?, type?}] | no | Predicate/fluent definitions |
| `actions` | list[{name, params?, preconditions?, effects?}] | no | Action schemas |
| `init` | list[string] | no | Initial state (fluent expressions true at start) |
| `goals` | list[string] | no | Goal conditions to satisfy |

### Action Schema

Each action has: `name` (string), `params` (list of {name, type}), `preconditions` (list of fluent expressions), `effects` (list of fluent expressions). Negation uses the `not` prefix.

### Expression Syntax

Boolean expressions: `fluent-name`, `fluent-name(arg1, arg2)`, `not fluent-name(...)`.

## Example

```yaml
domain: robot-move
types:
  - name: location
objects:
  - name: home
    type: location
  - name: work
    type: location
fluents:
  - name: at
    params:
      - name: x
        type: location
actions:
  - name: go
    params:
      - name: from
        type: location
      - name: to
        type: location
    preconditions:
      - at(from)
    effects:
      - at(to)
      - not at(from)
init:
  - at(home)
goals:
  - at(work)
```

## Exit Criteria

- Problem YAML validates against schema with no unknown keys
- All object types reference declared types
- All fluent expressions reference declared fluents or objects