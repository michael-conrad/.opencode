## Intent

Restructure the `writing-plans` 21-step pipeline so it actually works under the hard limit that sub-agents cannot dispatch sub-agents.

## Problem

The 21-step pipeline in `tasks/create.md` has 10 sub-agent steps (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern) marked as `(**sub-agent**)`. These are impossible to execute because:
- Each would need to dispatch further agents (solve → check, audit → auditor_1/auditor_2, etc.)
- Sub-agents cannot dispatch sub-agents — hard system limit

Additionally, steps like `research.md` and `audit-concern.md` load skills and execute procedures inline (`skill()` + `--task verify`) — impossible for a leaf node. The pipeline as designed is unexecutable from day one.

**Affected files:**
- `.opencode/skills/writing-plans/SKILL.md` §Operating Protocol (lines 65-89)
- `.opencode/skills/writing-plans/tasks/create.md` (21-step pipeline definition, lines 33-109)

## Fix Approach

Restructure the pipeline so all steps execute at the orchestrator level:

**Option A (preferred): Flatten to orchestrator-side execution**
- Convert all `(**sub-agent**)` steps in create.md to `(**inline**)` 
- Each step becomes a self-contained procedure the orchestrator executes directly
- Steps like research, solve, validate, audit-fidelity become inline sub-procedures within create.md

**Option B: Split into top-level dispatchable tasks**
- Create new top-level task entries in SKILL.md Trigger Dispatch Table for each pipeline phase (research-phase, structure-phase, etc.)
- Each is a standalone task that the orchestrator dispatches once
- Eliminates nested sub-agent requirements

**Required changes:**
1. Update `SKILL.md` §Operating Protocol to reflect new step execution model
2. Update `tasks/create.md` pipeline definition (all steps become inline or top-level)
3. Remove `(**sub-agent**)` markers from all 10 previously-sub-agent steps
4. Add explicit note in SKILL.md: "Under the hard limit that sub-agents cannot dispatch sub-agents, this skill's pipeline executes at the orchestrator level"

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | No step in create.md requires a sub-agent to dispatch another agent | `string` |
| SC-2 | All 22 steps have a valid execution path (inline or top-level dispatch) | `string` |
| SC-3 | SKILL.md Operating Protocol matches the new pipeline definition | `string` |
| SC-4 | Each step has clear entry/exit criteria and chain dependency | `string` |

## Dependencies

None — self-contained pipeline restructure.