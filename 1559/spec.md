# [SPEC-FIX] Restructure implementation-pipeline skill: fix Trigger Dispatch Table routing and per-step markers

**Issue:** https://github.com/michael-conrad/.opencode/issues/1559

## Executive Summary

Audit the implementation-pipeline SKILL.md Trigger Dispatch Table to verify each task is routed correctly (`orchestrator` or `sub-task`). Audit each task file to verify `[inline]`/`[sub-agent]` per-step markers are correct for who reads it. Fix misrouted tasks. Then remove the "unless" clause from checklist item 3.

## Problem

The implementation-pipeline SKILL.md marks 2 tasks (assemble-work, pipeline-executor) as `orchestrator` dispatch, 5 Z3 `solve check` steps as `inline`, and 3 adversarial-audit remediation steps as `inline`. If the Trigger Dispatch Table routes an orchestrator-level task file to a sub-agent, the sub-agent receives a task file with `[inline]` steps it cannot execute. The "unless" clause is the escape hatch masking this routing problem.

## Fix

1. Audit the Trigger Dispatch Table in `implementation-pipeline/SKILL.md` — verify each task is routed as `orchestrator` or `sub-task` correctly.
2. Audit each task file — verify the `[inline]`/`[sub-agent]` per-step markers are correct for who reads it. Specific task file contents to be determined at implementation time.
3. Fix misrouted tasks in the Trigger Dispatch Table.
4. Remove "unless explicitly marked as inline/orchestrator in this skill" from checklist item 3. Replace with: "Each step MUST be dispatched to a sub-agent via `task()` unless the step is explicitly marked `[inline]` in the task file and the task is routed as `orchestrator` in the Trigger Dispatch Table."

## Files Affected

- `implementation-pipeline/SKILL.md` — fix Trigger Dispatch Table routing, remove "unless" clause
- `implementation-pipeline/tasks/assemble-work.md` — verify/fix per-step markers
- `implementation-pipeline/tasks/pipeline-executor.md` — verify/fix per-step markers

## Dependencies

None.
