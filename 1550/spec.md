# [SPEC-FIX] Remove 'simple fixes skip straight to design' escape hatch in brainstorming

**Issue:** https://github.com/michael-conrad/.opencode/issues/1550

## Executive Summary

Remove "Simple fixes skip straight to design" language from `exploration-workflow.md`. All decisions require 2-3 approaches before selecting one. No complexity-based exemption from alternatives exploration.

## Problem

The agent self-classifies a fix as "simple" and skips the alternatives exploration phase. This is the exact rationalization pattern that `000-critical-rules.md:42` prohibits as a routing-bypass self-authorization variant.

## Fix

Remove lines 58 and 83. Replace with: all decisions require 2-3 approaches before selecting one.

## Files Affected

- `brainstorming/tasks/explore/exploration-workflow.md` line 58
- `brainstorming/tasks/explore/exploration-workflow.md` line 83

## Behavioral Test

Prompt agent with a "simple fix" scenario. Assert agent still proposes 2-3 approaches, does not skip to design.

## Dependencies

None.
