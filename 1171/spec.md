## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem | `plan plan` exits with error on `UNSOLVABLE_INCOMPLETELY` without actionable guidance. Developer must manually discover the `plan ground` → manual plan → `plan validate` workaround. |
| Approach | Add auto-fallback in `_action_plan()`: when status is `UNSOLVABLE_INCOMPLETELY`, automatically run grounding, extract grounded actions, generate best-effort sequential plan, lift back via `grounding_result.map_back_action_instance`, and print actionable message with grounded actions if auto-generation fails. |
| Key Decisions | Auto-fallback enabled by default (no flag). Uses existing Grounder + SequentialPlanValidator. If lifted plan validation fails, fall back to printing grounded actions with guidance message. |
| Alternatives | Add `--fallback` flag (rejected: adds friction). Switch default engine to fast-downward (rejected: Tamer needed for temporal/numeric). |
| Scope | `.opencode/tools/plan` — `_action_plan()` function only |

## Problem

The Tamer planner uses Weighted A* search (weight=0.8, hadd heuristic) with an implicit bounded search depth. For a simple 14-step serial chain (13 `next` links), Tamer returns `UNSOLVABLE_INCOMPLETELY` in ~1ms because the search bound is hit before finding the plan.

Meanwhile, the workaround is straightforward and always works:
1. `plan ground --problem pipeline-problem.yaml` generates 13 grounded actions
2. Manual YAML plan from those actions validates successfully
3. `plan validate` confirms validity

The current behavior exits with `_die("no plan found (incomplete search)", 1)` providing zero guidance. Developer confusion and re-discovery cost is high.

## Requirements

### R-1: Auto-fallback on UNSOLVABLE_INCOMPLETELY

When `result.status == PlanGenerationResultStatus.UNSOLVABLE_INCOMPLETELY`:
1. Run `Grounder().compile(problem, CompilationKind.GROUNDING)` to get grounded problem
2. Extract grounded action names in declaration order
3. Build `SequentialPlan` from `ActionInstance` for each grounded action (no parameters for grounded actions)
4. Lift plan via `grounding_result.map_back_action_instance`
5. Validate lifted plan with `SequentialPlanValidator`
6. If valid: print plan as normal success output
7. If invalid: print grounded actions with message: "Planner bounded search limit reached. Grounded actions available — write a manual plan from these actions and use `plan validate`."

### R-2: Preserve existing behavior for other failure modes

- `UNSOLVABLE_PROVEN` → "problem is unsolvable (proven)" exit 1
- `TIMEOUT` → "planning timed out" exit 1
- `MEMOUT` → "planning ran out of memory" exit 1
- Other statuses → "planning failed: {status.name}" exit 1

### R-3: Maintain engine parameter

The auto-fallback must work for any engine that returns `UNSOLVABLE_INCOMPLETELY`, not just Tamer.

## Out of Scope

- Changing default engine from Tamer
- Adding `--fallback` flag
- Modifying Tamer search parameters (weight, heuristic)
- Behavioral tests (content-verification sufficient for string SCs)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | On `UNSOLVABLE_INCOMPLETELY`, `_action_plan` attempts grounding and plan generation before exiting | `string` |
| SC-2 | If lifted plan validates, outputs plan in standard YAML format with success exit code | `string` |
| SC-3 | If lifted plan fails validation, prints grounded actions with actionable guidance message | `string` |
| SC-4 | Other failure statuses (`UNSOLVABLE_PROVEN`, `TIMEOUT`, `MEMOUT`, etc.) unchanged | `string` |
| SC-5 | Engine parameter respected — fallback works for any engine returning incomplete status | `string` |

## AI Agent Instructions

This issue is an executive summary for human stakeholders. The authoritative spec and plan are at this local path. AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)