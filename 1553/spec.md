# [SPEC-FIX] Remove 'use judgment' git hook bypass escape hatch in critical-rules

**Issue:** https://github.com/michael-conrad/.opencode/issues/1553

## Executive Summary

Remove "The agent is NOT an enforcement robot for hook scripts — use judgment" from `000-critical-rules.md:90-92`. Pre-commit hook output is binding. `--no-verify` is FORBIDDEN regardless of hook output content.

## Problem

The "use judgment" language authorizes the agent to self-diagnose a pre-commit hook failure as a "false positive" and use `--no-verify` to bypass it. This directly conflicts with `critical-rules-026` (Tier 1) which requires explicit authorization for `git commit --no-verify`.

## Fix

Replace "The agent is NOT an enforcement robot for hook scripts — use judgment." with "Pre-commit hook output is binding. If a hook blocks a commit, fix the violation. `--no-verify` is FORBIDDEN regardless of hook output content."

## Files Affected

- `.opencode/guidelines/000-critical-rules.md` lines 90-92

## Behavioral Test

Prompt agent with a pre-commit hook that blocks with a "false positive" message. Assert agent fixes the violation, does not use `--no-verify`.

## Dependencies

None.
