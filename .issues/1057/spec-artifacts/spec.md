# [BUG] plan tool silently accepts unknown YAML keys, produces confusing errors — needs schema validation + plan help subcommand

**Source:** https://github.com/michael-conrad/.opencode/issues/1050

## Problem

The AI agent repeatedly writes plan files (YAML domain/problem files consumed by `.opencode/tools/plan`) that the tool rejects. The tool silently accepts unknown/incorrect keys without validation, and when it does error, the messages are cryptic — no guidance on what key was wrong or what the correct key should be.

The agent has no way to look up the expected schema before writing plan files.

## Three Concrete Failure Modes

### 1. `precondition:` / `effect:` (singular) instead of `preconditions:` / `effects:` (plural)

**Input:**
```yaml
actions:
  - name: push-branch
    precondition: ["committed", "clean"]
    effect: ["pushed"]
```

**Actual error:**
```
status: UNSOLVABLE_INCOMPLETELY
error: no plan found (incomplete search)
```

**Expected:** A clear validation error showing that `precondition` is not a recognized key, and the correct key is `preconditions` (plural). Brief example of correct YAML.

### 2. `parameters:` on a fluent (correct for objects, wrong for fluents)

**Input:**
```yaml
fluents:
  - name: issue_comment_posted
    parameters:
      - name: i
        type: issue
```

**Actual error:** A Python stack trace ending in:
```
unified_planning.exceptions.UPExpressionDefinitionError:
  In FluentExp, fluent: issue_comment_posted has arity 0 but 1 parameters were passed.
```

**Expected:** A clean error: `fluent 'issue_comment_posted' uses key 'parameters' but fluents expect 'params'. Objects use 'parameters'.`

## Fix

### Part 1: Schema validation

Add a YAML schema validation step in `_action_plan()` (or `_build_problem()`) that:

1. Checks each action has only recognized keys: `name`, `params`, `preconditions`, `effects`
2. Checks each fluent has only recognized keys: `name`, `params`, `type`
3. Checks each object has only recognized keys: `name`, `type`
4. Checks each type has only recognized key: `name`
5. If an unrecognized key is found, prints: `ERROR: action 'push-branch' has unknown key 'precondition'. Did you mean 'preconditions'?`
6. If a key is missing when expected, suggests the closest match
7. Appends a short format snippet showing correct structure
8. Exits with error code 1

### Part 2: `plan help` subcommand

Add a `plan help` subcommand that prints the complete YAML schema reference.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Unknown keys produce clear error with "Did you mean" suggestion + format snippet | `behavioral` |
| SC-2 | `precondition` (singular) suggests `preconditions` | `behavioral` |
| SC-3 | `parameters` on a fluent suggests `params` | `behavioral` |
| SC-4 | Multiple unknown keys all reported | `behavioral` |
| SC-5 | `.opencode/tools/plan help` prints complete schema reference | `behavioral` |
| SC-6 | Reference covers all 7 topics | `string` |