## Summary

The `verification-before-completion` skill's Step 0.5 (Dispatch Chain Compliance) checks a lifecycle log for `skill()` call records and flags `DISPATCH_CHAIN_VIOLATION` when none are found. However, agents have no mechanism to log `skill()` calls to a lifecycle manifest — the `skill()` tool is an orchestrator-level MCP call that returns content inline, with no side-effect logging capability. This produces a false-positive violation on every verification pass.

## Observed Behavior

Every VbC run on issue #53 (Butter repo) produces:

> DISPATCH_CHAIN_VIOLATION — no `skill()` calls in lifecycle log

Despite all 5 SCs passing cleanly with verified evidence. The gate is terminal per `verify.md` Step 0.5 §4, requiring restart from `verify-authorization`, but restarting produces the same result because the logging mechanism doesn't exist.

## Root Cause

The lifecycle log at `{project_root}/tmp/{issue-N}/lifecycle.yaml` is an append-only YAML file that pipeline steps SHOULD append events to. But:

1. The `skill()` MCP tool does not produce a side-effect log entry — it returns content inline
2. There is no documented mechanism for agents to record `skill()` calls to a lifecycle manifest
3. The VbC gate checks for a record that cannot be produced, making it a permanent blocker

## Evidence

From the VbC run on issue #53:

```
| 0.5 Dispatch Chain Compliance | ⚠️ DISPATCH_CHAIN_VIOLATION — no `skill()` calls in lifecycle log |
```

The lifecycle manifest at `{project_root}/tmp/{issue-N}/lifecycle.yaml` either doesn't exist or has no `skill()` call entries. The agent has no tool to append such entries.

## Expected Behavior

Either:
1. Remove the DISPATCH_CHAIN_VIOLATION gate from VbC Step 0.5 if `skill()` call logging is not feasible
2. Or provide a documented mechanism for agents to record `skill()` calls (e.g., a `lifecycle-append` tool or a `todowrite`-style API)
3. Or change the check to verify that the implementation followed the correct dispatch chain through observable evidence (e.g., stderr patterns from behavioral tests) rather than a lifecycle log that cannot be populated

## Severity

**Medium** — The gate produces a false-positive violation on every VbC pass. It does not block the pipeline (the SC verification still passes), but it creates noise and the terminal language ("restart from verify-authorization") is misleading since restarting produces the same result.

🤖 OpenCode (deepseek-v4-flash)