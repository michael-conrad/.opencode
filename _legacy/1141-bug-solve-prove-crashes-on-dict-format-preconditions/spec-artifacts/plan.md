# Plan: #1141 — solve prove crashes on dict-format preconditions

## Authorization

| Field | Value |
|-------|-------|
| authorization_scope | for_pr |
| halt_at | pr_created |
| pr_strategy | stacked |
| pipeline_phase | implementation |

## Items

| # | Item | SCs | Depends On |
|---|------|-----|------------|
| 1 | Fix `_normalize_exprs()` to handle dict-format preconditions (extract `expr` key) | SC-1, SC-2, SC-3, SC-4, SC-5 | — |
| 2 | Create behavioral enforcement test for dict-format preconditions | SC-1, SC-2, SC-3 | — |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Pipeline Step | Re-Entry Step | Verification Gate |
|----|-----------|---------------|---------------------|---------------|---------------|-------------------|
| SC-1 | `solve prove` works with dict-format preconditions (`name`/`expr` keys) | behavioral | `opencode-cli run` with dict-format test contract, assert VALID output | green-phase | green-phase | pre-commit |
| SC-2 | `solve check` works with dict-format preconditions | behavioral | `solve check --state-path ... --contract-path ...` with dict-format contract | green-doublecheck | green-phase | pre-commit |
| SC-3 | `solve model` works with dict-format preconditions | behavioral | `solve model --contract-path ... --query ...` with dict-format contract | green-doublecheck | green-phase | pre-commit |
| SC-4 | Flat string format still works (no regression) | behavioral | Run `solve prove/check/model` with flat-format contracts, assert same behavior as pre-fix | regression-check | green-phase | pre-commit |
| SC-5 | Fix is minimal — only `_normalize_exprs()` modified | structural | `git diff` shows changes only within `_normalize_expr()` | green-doublecheck | green-phase | ci |

## Implementation Plan

### Item 1: Fix `_normalize_exprs()` in `.opencode/tools/solve`

Current behavior (lines 65-72):
```python
if isinstance(item, dict):
    name = item.get("name", "<unnamed>")
    _die(
        f"contract expression must be a string, got dict "
        f"(name={name!r}). "
        f"Use flat format: '- <z3-expr>'"
    )
```

New behavior: When `item` is a dict, extract `item["expr"]` as the expression string. Keep `item.get("name")` unused (available for future use but ignored by normalization).

The fix changes the dict-handling branch to:
```python
if isinstance(item, dict):
    expr_val = item.get("expr")
    if expr_val is None:
        _die(f"dict-format precondition missing 'expr' key: {item}")
    if not isinstance(expr_val, str):
        _die(f"dict-format 'expr' must be a string, got {type(expr_val).__name__}")
    result.append(expr_val)
    continue
```

### Item 2: Create behavioral test

Create a test contract in `./tmp/1141/test-contract-dict.yaml` with dict-format preconditions and verify all three actions work:
- `solve prove` returns VALID
- `solve check` returns SAT/UNSAT
- `solve model` returns SAT

## Blockers

None identified.