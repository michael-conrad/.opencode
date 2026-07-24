---
number: 1232
title: "[SPEC-FIX] plan tool: init expression negation discarded — all fluents set True at init"
state: OPEN
---

## Bug

The `plan` tool's init expression parser discards the negation flag. When a problem file specifies `not phase_1_scan_complete` in the `init` section, the parser sets `phase_1_scan_complete = True` — the exact opposite of the intended state.

## Root Cause

In `tools/plan` `_build_problem()`, the init parsing loop:

```python
for init_str in schema.get("init", []):
    expr, _ = _parse_expression(init_str, problem, fluent_map)  # ← discards negated
    problem.set_initial_value(expr, True)  # ← always True
```

The `_parse_expression` function returns `(fluent_atom, is_negated)` but the init loop discards `is_negated` with `_` and always sets the value to `True`. This means every init expression — negated or not — sets the fluent to True.

## Impact

- All fluents default to True at init regardless of negation
- Goal is trivially satisfied with 0 actions
- Planner returns 0-length plan for any problem with negated init fluents
- All planning results from this tool are untrustworthy when init uses negation

## Fix

Change the init parsing loop to use the negation flag:

```python
for init_str in schema.get("init", []):
    expr, negated = _parse_expression(init_str, problem, fluent_map)
    problem.set_initial_value(expr, not negated)
```

## SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `not <fluent>` in init sets fluent to False | behavioral |
| SC-2 | `<fluent>` (no negation) in init sets fluent to True | behavioral |
| SC-3 | Planner returns correct-length plan for problem with negated init fluents | behavioral |
| SC-4 | Existing non-negated init problems still produce correct plans (regression) | behavioral |

## Evidence

Bug confirmed by running the planner against `tmp/check-pr-problem.yaml` (6 actions, 7 fluents, all init fluents negated):

- **Before fix**: plan length 0 (all fluents True at init → goal trivially satisfied)
- **After fix**: plan length 6 (correct dependency chain: scan → verify → cleanup + issues → submodule → final)

## Change Control

- Single-line fix in `tools/plan` `_build_problem()` init loop
- No schema changes, no new dependencies
- Fix already applied and verified in working session

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
