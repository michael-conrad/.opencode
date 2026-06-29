# [SPEC-FIX] Restructure writing-plans skill: fix Trigger Dispatch Table routing and per-step markers

**Issue:** https://github.com/michael-conrad/.opencode/issues/1558

## Executive Summary

Audit the writing-plans SKILL.md Trigger Dispatch Table to verify each task is routed correctly (`orchestrator` or `sub-task`). Audit each task file to verify `[inline]`/`[sub-agent]` per-step markers are correct for who reads it. Fix misrouted tasks. Then remove the "unless" clause from checklist item 3.

## Problem

The writing-plans SKILL.md marks 3 tasks (create, retroactive, completion) as `orchestrator` dispatch and 11 Z3 `solve check` steps as `(**inline**)`. If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute (sub-agents cannot use `task()`). The "unless" clause is the escape hatch masking this routing problem.

## Fix

1. Audit the Trigger Dispatch Table in `writing-plans/SKILL.md` — verify each task is routed as `orchestrator` or `sub-task` correctly.
2. Audit each task file — verify the `[inline]`/`[sub-agent]` per-step markers are correct for who reads it.
3. Fix misrouted tasks in the Trigger Dispatch Table.
4. Remove "unless explicitly marked as inline/orchestrator in this skill" from checklist item 3. Replace with: "Each step MUST be dispatched to a sub-agent via `task()` unless the step is explicitly marked `[inline]` in the task file and the task is routed as `orchestrator` in the Trigger Dispatch Table."

## Files Affected

- `writing-plans/SKILL.md` — fix Trigger Dispatch Table routing, remove "unless" clause
- `writing-plans/tasks/create.md` — verify/fix per-step markers
- `writing-plans/tasks/retroactive.md` — verify/fix per-step markers
- `writing-plans/tasks/completion.md` — verify/fix per-step markers

## Dependencies

None.
