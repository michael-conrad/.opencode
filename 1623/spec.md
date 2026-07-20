## Problem

PR #1622 introduced a `gap-fill-path` entry to `auto-dispatch-table.md` with the criteria:

```
scope ∈ {for_pr, for_implementation, for_plan, for_analysis}
```

This uses mathematical set notation (`∈` and `{}`) which LLMs do not natively parse. Some models will read it correctly, others will treat it as a literal string or misinterpret the braces. The notation is not used anywhere else in the codebase.

## Fix

Replace the set notation with plain English: `scope is one of: for_pr, for_implementation, for_plan, for_analysis`

## Files

- `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `auto-dispatch-table.md` gap-fill-path criteria uses plain English, not set notation | `string` | grep confirms no `∈` or `{for_` in the file |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)