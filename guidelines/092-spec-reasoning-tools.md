---
trigger_on: constrain, rule, SAT, UNSAT, Z3, consistency, dependency, deadlock
tier: 2
load_when: sub-agent
---

# Spec Reasoning Tools

## Overview

Two dispatcher families provide constraint analysis and symbolic reasoning over guidelines and specs:

1. **`rules` dispatcher** (`.opencode/tools/rules`) — Symbolic rule analysis: conflict detection, activation flow, state machine extraction, coverage checking, drift detection, trigger analysis.
2. **`solve` dispatcher** (`.opencode/tools/solve`) — Constraint solving: SAT/UNSAT checking, dependency validation, deadlock detection, consistency verification.

Both dispatchers sit under `.opencode/tools/` and delegate to `impl/` scripts.

## `rules` Dispatcher

### Trigger Keywords

| Action | Triggers On |
|--------|-------------|
| `rules conflicts` | contradictory guidelines, rule conflict, HALT vs PROCEED |
| `rules flow` | activation chain, rule propagation |
| `rules states` | state machine extraction, state transitions |
| `rules analyze` | analyze rule blocks |
| `rules complete` | coverage check, entailment |
| `rules drift` | detect drift |
| `rules extract` | extract symbolic rules |
| `rules report` | generate report |
| `rules triggers` | trigger analysis |

### Usage

```bash
# Conflict detection
./.opencode/tools/rules conflicts

# Rule activation flow
./.opencode/tools/rules flow

# Coverage check
./.opencode/tools/rules complete

# State machine extraction
./.opencode/tools/rules states

# Trigger analysis
./.opencode/tools/rules triggers
```

## `solve` Dispatcher

### Trigger Keywords

| Action | Triggers On |
|--------|-------------|
| `solve` (default) | constraint solving, SAT, UNSAT, consistency check, dependency validation, deadlock, interdependency |
| `solve --track-unsat` | unsat core, contradictory constraints |
| `solve --no-global` | skip global constraints |
| `solve --file <path>` | explicit constraint file |

### Usage

```bash
# Default solve (scans guidelines + skills)
./.opencode/tools/solve

# Track UNSAT core
./.opencode/tools/solve --track-unsat

# Solve with explicit constraint file
./.opencode/tools/solve --file ./tmp/constraints.cnf

# Skip global constraints
./.opencode/tools/solve --no-global
```

## Artifact Layout

Constraint files live in the `.issues/` directory alongside issue specs:

```
.opencode/.issues/
  artifacts/
    global-constraints.yaml      # Project-wide invariants, auto-loaded on every solve run
  open/
    <issue>-<slug>/
      spec.md                    # Prose spec
      constraints.yaml           # Issue-scoped constraint block
```

**Project-wide invariants** go in `.issues/artifacts/global-constraints.yaml`. The solver auto-loads this file for every `solve` run unless `--no-global` is passed. This catches cross-spec contradictions at spec time, not at integration time.

**Issue-scoped constraints** go in the issue's `constraints.yaml`. Constraints with `scope: global` are automatically extracted into `global-constraints.yaml` by the toolset — the agent never manages that file manually.

**Conflict resolution:** If `global-constraints.yaml` and an issue's `constraints.yaml` contain contradictory constraints, `solve` returns UNSAT with an unsat core identifying the conflicting sources. `global-constraints.yaml` takes normative precedence for project-wide invariants.

## Discovery

Agents discover these tools by:
- Consulting `.opencode/tools/rules --help` for actions
- Consulting `.opencode/tools/solve --help` for options
- Matching trigger keywords against the current task

## References

- `.opencode/tools/rules` — Rules dispatcher script
- `.opencode/tools/solve` — Solve dispatcher script
- `.opencode/tools/impl/rules-*` — Rules impl scripts
- `.opencode/.issues/artifacts/global-constraints.yaml` — Project-wide constraints
- `.opencode/.issues/open/*/constraints.yaml` — Issue-scoped constraints
