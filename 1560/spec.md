# [SPEC-FIX] Restructure spec-creation skill: fix Trigger Dispatch Table routing and per-step markers

**Issue:** https://github.com/michael-conrad/.opencode/issues/1560

## Executive Summary

Audit the spec-creation SKILL.md Trigger Dispatch Table to verify each task is routed correctly (`orchestrator` or `sub-task`). Audit each task file to verify `[inline]`/`[sub-agent]` per-step markers are correct for who reads it. Fix misrouted tasks. Then remove the "unless" clause from checklist item 3.

## Problem

The spec-creation SKILL.md marks 4 steps as `[inline]` (pre-spec inspection, solve model, solve check, plan plan). If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute. The "unless" clause is the escape hatch masking this routing problem.

Note: The `create` task may already be written correctly for sub-agent execution. The issue may be the SKILL.md dispatching it as orchestrator-level when it should be sub-agent dispatched. Audit required to confirm.

## Fix

1. Audit the Trigger Dispatch Table in `spec-creation/SKILL.md` — verify each task is routed as `orchestrator` or `sub-task` correctly.
2. Audit each task file — verify the `[inline]`/`[sub-agent]` per-step markers are correct for who reads it. Specific task file contents to be determined at implementation time.
3. Fix misrouted tasks in the Trigger Dispatch Table.
4. Remove "unless explicitly marked as inline/orchestrator in this skill" from checklist item 3. Replace with: "Each step MUST be dispatched to a sub-agent via `task()` unless the step is explicitly marked `[inline]` in the task file and the task is routed as `orchestrator` in the Trigger Dispatch Table."

## Files Affected

- `spec-creation/SKILL.md` — fix Trigger Dispatch Table routing, remove "unless" clause
- `spec-creation/tasks/write.md` — verify/fix per-step markers
- `spec-creation/tasks/risk.md` — verify/fix per-step markers
- `spec-creation/tasks/traceability.md` — verify/fix per-step markers

## Dependencies

None.
