# [SPEC-FIX] Remove issue-operations routing bypass fallback clause

**Issue:** https://github.com/michael-conrad/.opencode/issues/1549

## Executive Summary

Remove the fallback clause in `000-critical-rules.md:580` that allows direct `github_issue_write` when `skill("issue-operations")` + `task()` is "unavailable." Replace with HALT + BLOCKED report.

## Problem

The fallback clause creates a self-diagnosed bypass path. The agent decides when the skill is "unavailable" and calls `github_issue_write` directly, violating `critical-rules-platform-routing-bypass` (Tier 1). The `issue-operations` skill is always available in this codebase — there is no scenario where it's genuinely unavailable that wouldn't also make `github_issue_write` unavailable.

## Fix

Remove the fallback clause text from the Violation Patterns table. Replace with: HALT + report BLOCKED with `ISSUE_OPERATIONS_UNAVAILABLE`.

## Files Affected

- `.opencode/guidelines/000-critical-rules.md` line 580

## Behavioral Test

Prompt agent to create an issue when `issue-operations` is unavailable. Assert agent HALTs with BLOCKED status instead of calling `github_issue_write` directly.

## Dependencies

None.
