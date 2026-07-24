---
remote_issue: 1269
remote_url: "https://github.com/michael-conrad/.opencode/issues/1269"
last_sync: "2026-06-17T22:03:53Z"
source: github
---

## Summary

When the agent proposes a fix spec for a routing problem, the proposed fix itself bypasses the `issue-operations` skill and hardcodes a platform-specific check. This is the same pattern the fix is supposed to prevent — the agent solves a routing problem by writing a non-routed, platform-locked solution.

## Impact

Fix proposals from the agent cannot be trusted to follow the project's own routing discipline. The agent proposes solutions that violate the same rules the project enforces (route through `issue-operations`, no hardcoded platform calls). This creates a meta-problem: the fix for bad routing is itself badly routed.

## Root Cause

The agent does not apply its own quality gates to its proposals. When proposing a fix, the agent writes what comes to mind rather than checking "does this proposal follow the project's own rules?" Specifically:

1. The proposed fix said "add a pre-flight check before `github_issue_write`" — this is a direct platform API call, bypassing `issue-operations`
2. The proposed fix hardcoded GitHub as the platform instead of using the platform-agnostic dispatcher
3. The agent did not check whether `issue-operations --task pre-creation` already handles this concern

## Reproduction

1. Agent identifies a routing bug
2. Agent proposes a fix that calls `github_issue_write` directly instead of routing through `issue-operations`
3. The fix violates the same routing rules it's trying to enforce

## Suggested Fix

Add a critical rule: when proposing fixes to routing or dispatch logic, the agent MUST verify the proposal follows the project's own routing discipline (route through `issue-operations`, use platform-agnostic dispatchers, no hardcoded platform API calls). The proposal itself must be subject to the same quality gates as implementation code.

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*