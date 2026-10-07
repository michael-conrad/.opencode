## Problem

`solve prove` crashed opaquely when the contract used structured precondition format (dict with `name`/`expr` keys) instead of bare string expressions. `solve model` and `solve check` both accepted dict format directly via inline iteration, but `solve prove` assumed bare strings — creating an inconsistency where dict format silently worked in some actions but crashed in others.

## Root Cause

Precondition handling was duplicated across all 3 actions with different implementations:

- `_action_check` and `_action_model`: inline `isinstance(item, dict)` guard with `item["expr"]` extraction
- `_action_prove`: direct `eval()` on dict items without extraction → crash

There was no shared normalization function to enforce consistent behavior.

## Fix (#1144)

Added `_normalize_exprs()` — a shared function that normalizes precondition/postcondition/invariant items to a list of strings. Dict-format items are rejected with a clear error message directing users to use flat format:

```
error: contract expression must be a string, got dict (name='a_is_true').
Use flat format: '- <z3-expr>'
```

This unified the code path across all 3 actions (`prove`, `model`, `check`) and converted the opaque `solve prove` crash into a consistent, informative error across the entire tool.

## Reproduction

Run `solve prove` with a contract using dict-format preconditions. The tool now prints a clear rejection message instead of crashing.

## Severity

Low — fixed by #1144. Remaining action: update spec to reflect actual fix.

## Related

- Fixed by #1144 (merge 18d097d0): `_normalize_exprs()` — design decision to reject dict format uniformly rather than accepting it in some actions but not others.

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)