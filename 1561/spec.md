# [SPEC-FIX] Remove dead 'unless explicitly marked as inline' clause from 37 SKILL.md files

**Issue:** https://github.com/michael-conrad/.opencode/issues/1561

## Executive Summary

Remove the boilerplate "unless explicitly marked as inline/orchestrator in this skill" clause from checklist item 3 in 37 SKILL.md files where it is dead code (no steps are ever marked inline). Replace with forward-compatible text that works for both current state (no orchestrator tasks) and future split card design: "Each step MUST be dispatched to a sub-agent via `task()` unless the step is explicitly marked `[inline]` in a task file routed as `orchestrator` in the Trigger Dispatch Table."

## Problem

37 SKILL.md files contain the boilerplate clause but never mark any step as inline or orchestrator. The clause is structurally present but semantically inert. Its presence creates ambiguity — agents reading the clause may infer that inline execution is sometimes acceptable.

## Fix

Remove "unless explicitly marked as inline/orchestrator in this skill" from checklist item 3 in all 37 files. Replace with forward-compatible text: "Each step MUST be dispatched to a sub-agent via `task()` unless the step is explicitly marked `[inline]` in a task file routed as `orchestrator` in the Trigger Dispatch Table."

## Files Affected (37 SKILL.md files)

adversarial-audit, approval-gate, brainstorming, changelog-generator, completeness-gate, completion-core, conflict-resolution, correspondence, engineering-approach, executing-plans, finishing-a-development-branch, git-workflow, issue-operations, issue-operations/platforms/local, issue-operations/platforms/github-mcp, issue-operations/platforms/gitbucket-api, issue-review, mcp-tool-usage, multimodal-dispatch, plan, plan-creation-pipeline, playwright-cli, pre-analysis, pr-creation-workflow, programming-principles, receiving-code-review, requesting-code-review, research, researcher, skill-creator, solve, sre-runbook, sync-guidelines, systematic-debugging, test-driven-development, using-git-worktrees, verification, verification-before-completion, verification-enforcement

## Excluded (3 skills with active inline markings)

- writing-plans (#1558)
- implementation-pipeline (#1559)
- spec-creation (#1560)

## Behavioral Test

Prompt agent to execute a skill task. Assert agent dispatches to sub-agent via `task()`, does not execute steps inline.

## Dependencies

None — these 37 skills have no inline markings, so removal is safe without restructuring.
