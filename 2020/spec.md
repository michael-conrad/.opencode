## Observed Behavior

Multiple skill cards in `.opencode/skills/` have Invocation sections that dispatch pipelines containing `[sub-task]` steps to sub-agents via `task()`. A sub-agent **cannot** call `task()` — that is an orchestrator-level capability. The dispatched sub-agent receives a pipeline it cannot execute.

## Affected Skills (likely non-exhaustive)

- `spec-creation/SKILL.md` — `create` pipeline has 25 steps, many marked `[sub-task]`
- `spec-creation-decomposition/` — sub-skill with multiple task files
- `spec-creation-validation/` — sub-skill with multiple task files
- `writing-plans/SKILL.md` — may have similar dispatch pattern
- Any other skill whose Invocation section dispatches a pipeline to a sub-agent

## Root Cause

The skill card template/pattern was designed with the assumption that a sub-agent can execute a multi-step pipeline that includes sub-agent dispatches. This is a category error: dispatching orchestrator-level routing instructions (which include `task()` calls) to a sub-agent.

See `critical-rules-XXX` (skill card dispatched to sub-agent) in guidelines/000-critical-rules.md:

| Artifact | File | Consumer | Content | Action |
|----------|------|----------|---------|--------|
| Skill Card | SKILL.md | Orchestrator | Routing metadata (Trigger Dispatch Table, Invocation, DISPATCH_GATE) | Load via skill(), read in own context, do NOT dispatch |
| Task Card | tasks/<name>.md | Sub-agent | Execution procedure (entry criteria, steps, exit criteria) | Dispatch via task() using canonical string from Invocation |

The Invocation section should tell the orchestrator what to dispatch (a task card), not tell it to dispatch the entire pipeline to a sub-agent.

## Expected Behavior

The Invocation section for each skill should dispatch only task cards (individual `.md` files) to sub-agents. Pipelines with multiple steps that include sub-agent dispatches should be executed by the orchestrator directly, with each `[sub-task]` step dispatched individually.

## Suggested Fix

Audit all SKILL.md files in `.opencode/skills/` for Invocation sections that dispatch pipelines containing `[sub-task]` steps. For each:

1. If the pipeline has `[sub-task]` steps: the orchestrator executes the pipeline, dispatching each step individually
2. If the pipeline is self-contained (no sub-agent dispatches): it can be dispatched to a sub-agent

The Invocation table should clearly distinguish between:
- `inline` (orchestrator executes the pipeline steps)
- `sub-task` (dispatch a single task card to a sub-agent)

## Related

- https://github.com/michael-conrad/.opencode/issues/2018 (spec-creation specific instance)
- critical-rules-XXX (skill card dispatched to sub-agent)
