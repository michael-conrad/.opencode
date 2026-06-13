## Problem

`solve prove` crashes when the contract uses structured precondition format (dict with `name`/`expr` keys) instead of bare string expressions. `solve model` handles both formats, but `solve prove` assumes preconditions are bare strings.

## Root Cause

`_action_prove` in `.opencode/tools/solve` iterates over preconditions and directly includes each one's Z3 expression, but when preconditions are structured as:

yaml
preconditions:
  - name: a
    expr: a == True

Instead of the flat format:

yaml
preconditions:
  - a == True

The code fails because it doesn't handle the dict structure with `name`/`expr` keys.

## Reproduction

Run `solve prove` with a contract using dict-format preconditions. The tool crashes instead of proving the theorem.

## Severity

Medium — blocks `solve prove` usage with the structured YAML format that `solve model` and `solve check` both support.

## Related

Discovered during pre-red-baseline for #1107 (Phase 1: solve model precondition fix).

---

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)