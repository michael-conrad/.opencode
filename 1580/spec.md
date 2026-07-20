## Summary

When a release PR prompt ("release PR — promote dev to main") is sent to the agent after the Phase 7 GREEN changes (routing table updated to dispatch release to `pr-creation` with `{is_release: true}`), the agent halts on a submodule pointer mismatch instead of routing through `pr-creation-workflow`.

## Steps to Reproduce

1. Apply Phase 7 changes: `release-promotion.md` deleted, routing table updated, `create-pr.md` has `--release` mode
2. Send prompt: `release PR — promote dev to main`
3. Agent detects submodule pointer mismatch between upstream `.opencode/dev` and local state
4. Agent halts with a question instead of dispatching to `pr-creation-workflow`

## Expected Behavior

Agent should handle submodule state proactively (e.g., during pre-work or as a pre-flight check) and still route the release PR through `pr-creation-workflow` with `{is_release: true}`.

## Actual Behavior

Agent halts and asks the developer a question about the submodule state, never reaching the routing decision.

## Root Cause

The agent's pre-work or entry-point logic does not handle submodule pointer mismatches proactively. When a submodule pointer is dirty (local SHA differs from upstream), the agent stops to ask rather than resolving or proceeding.

## Impact

SC-7 behavioral test fails on models that encounter submodule state issues. The routing change is correct (verified with default model), but the agent's submodule handling is fragile.

## Suggested Fix

Add a pre-flight step in `pre-work.md` or the routing entry point that proactively syncs or acknowledges submodule pointer state before routing decisions are made. This prevents the agent from halting on submodule state during release PR routing.

## Environment

- Model: `ollama/ornith:35b-256k` (local)
- Branch: `feature/1540-single-path-workflow`
- Phase: 7 (release-promotion deletion)
- SC: SC-7 (behavioral — agent routes release PR through `pr-creation-workflow`)

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)