# [SPEC-FIX] Remove 'RED may be omitted' TDD RED-phase bypass escape hatch

**Issue:** https://github.com/michael-conrad/.opencode/issues/1554

## Executive Summary

Remove "RED may be omitted (per Obvious Implementation pattern rules)" from `test-driven-development/tasks/patterns.md:87`. RED is NEVER optional.

## Problem

The Obvious Implementation pattern lets the agent self-classify a change as "trivial" and skip the RED phase entirely. This directly undermines the behavioral RED/GREEN gate in `080-code-standards.md` which requires RED before GREEN for all rule changes.

## Fix

Replace "RED may be omitted (per Obvious Implementation pattern rules)" with "RED is NEVER optional. Write the test first, confirm it FAILs, then implement."

## Files Affected

- `test-driven-development/tasks/patterns.md` line 87

## Behavioral Test

Prompt agent with a "trivial one-liner" implementation task. Assert agent writes test first (RED), confirms FAIL, then implements (GREEN).

## Dependencies

None.
