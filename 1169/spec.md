## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | `solve model` includes preconditions as permanent solver constraints, blocking forward-state queries. A contract with `current_step == "pre-red-baseline"` as precondition makes the solver treat this as invariant — `solve model --query '(exec_summary == "done")'` returns UNSAT because `current_step` can never change. |
| Approach | Separate constraint types in `_action_model()`: preconditions → initial state facts (ground facts for current state only); invariants → background axioms (PDR mode); postconditions/transitions → rules (state evolution). Model queries only assert invariants + query, NOT preconditions. |
| Key Decisions | `solve check` keeps current behavior (preconditions + invariants + postconditions). `solve model` only asserts invariants + query. Preconditions become `add_fact` (anchoring initial state) not `assert_expr` (permanent constraint). |
| Alternatives | Add separate contract file without preconditions (workaround, not fix). Add `--include-preconditions` flag (adds complexity). |
| Scope | `.opencode/tools/solve` — `_action_model()` and `_action_check()` constraint handling |

## Problem

Z3 fixedpoint/SPACER treats all asserted expressions as permanent constraints across all states. Current `_action_model()` (lines 230-237):

```python
# Contract constraints: preconditions + invariants
for expr in _normalize_exprs(contract.get("preconditions")):
    solver.add(_eval_expr(expr, consts))

for expr in _normalize_exprs(contract.get("invariants")):
    solver.add(_eval_expr(expr, consts))
```

This makes preconditions (e.g., `current_step == "pre-red-baseline"`, `exec_summary == "pending"`) permanent invariants. Forward-state queries asking "can `exec_summary` ever reach `done`?" return UNSAT because the initial value is locked.

Correct Z3 fixedpoint pattern:
- **Preconditions** (initial state) → `fp.add_fact(State(initial_value))` — ground facts only for current state
- **Invariants** → `fp.assert_expr(invariant)` — background axioms (PDR mode only)
- **Transitions/Postconditions** → `fp.rule(State', [State, ...])` — Horn clauses for state evolution
- **Queries** → `fp.query(target_state)` — forward reachability

## Requirements

### R-1: Fix `solve model` — exclude preconditions from permanent constraints

In `_action_model()`:
1. Only assert invariants (not preconditions) as permanent constraints
2. Add query constraint
3. Check SAT

Preconditions should only be used in `solve check` for current-state validation.

### R-2: Fix `solve check` — keep preconditions for current-state validation

In `_action_check()`:
1. Assert state values as equalities (current state)
2. Assert preconditions (must match current state)
3. Assert invariants + postconditions
4. Check SAT

This validates the current state satisfies all contract constraints.

### R-3: Add forward-state query capability

Model queries should answer: "Under the transition rules (invariants), can a future state satisfy the query?" — independent of initial state.

## Out of Scope

- Changing contract YAML schema
- Adding transition rules to contract format (postconditions already serve this purpose)
- Behavioral tests (content-verification sufficient for string SCs; model queries are structural)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `solve model` with preconditions in contract returns SAT for reachable future states | `string` |
| SC-2 | `solve model --query '(exec_summary == "done")'` returns SAT when invariants allow transition to done | `string` |
| SC-3 | `solve check` still validates current state against preconditions + invariants + postconditions | `string` |
| SC-4 | Preconditions in contract do not constrain future states in model queries | `string` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan are at this local path. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)