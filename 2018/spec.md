## Observed Behavior

The `spec-creation` SKILL.md Invocation section says:

```
| `create` | `task(..., prompt: "execute create from spec-creation-validation...")` |
```

This dispatches the entire 25-step `create` pipeline to a sub-agent. But the pipeline contains `[sub-task]` steps — steps that require calling `task()` to dispatch further sub-agents. A sub-agent **cannot** call `task()`. So the dispatched sub-agent receives a pipeline it cannot execute.

## Expected Behavior

The Invocation section should either:

1. **Not dispatch the pipeline to a sub-agent** — the orchestrator should execute the pipeline steps itself, dispatching each `[sub-task]` step individually via `task()`.

2. **Or the pipeline should not contain `[sub-task]` steps** — if the intent is to dispatch the whole thing to a sub-agent, the pipeline must be self-contained (no sub-agent dispatches).

## Root Cause

The skill card is structurally defective: its Invocation section tells the orchestrator to dispatch a pipeline that contains sub-agent dispatches to a sub-agent. The orchestrator cannot delegate a pipeline that requires orchestrator-level capabilities (calling `task()`) to a sub-agent.

## Impact

Every agent that follows the Invocation section literally will:

1. Call `skill({name: "spec-creation"})`
2. Read the Invocation table
3. Dispatch the `create` task to a sub-agent
4. The sub-agent receives a 25-step pipeline it cannot execute
5. The sub-agent either fails, skips steps, or produces a defective spec

This is what happened in the hermes-ingest-pubmed session today — the agent followed the Invocation section literally, dispatched the pipeline to a sub-agent, and the sub-agent could not execute the `[sub-task]` steps. The result was a spec written inline by the orchestrator (bypassing the entire pipeline), which was a CRITICAL VIOLATION.

## Affected Component

`.opencode/skills/spec-creation/SKILL.md` — Invocation section and Trigger Dispatch Table

## Suggested Fix

The Invocation section should not dispatch the pipeline to a sub-agent. Instead, the orchestrator should execute the pipeline steps directly, dispatching each `[sub-task]` step to a clean-room sub-agent. The Trigger Dispatch Table entry for `create` should be marked as `inline` (orchestrator executes the pipeline), not `sub-task`.

Alternatively, if the pipeline is meant to be dispatched, remove all `[sub-task]` markers and make the pipeline self-contained within a single sub-agent context.

## Related

This is a category error: dispatching orchestrator-level routing instructions to a sub-agent. See critical-rules-XXX (skill card dispatched to sub-agent) in the .opencode guidelines.
