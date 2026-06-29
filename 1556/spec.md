# [SPEC-FIX] Remove silent provenance degradation escape hatch in git-workflow

**Issue:** https://github.com/michael-conrad/.opencode/issues/1556

## Executive Summary

Remove the "no HALT, no blocking" silent fallback policy from provenance tasks. Any fallback from primary path causes HALT with degradation report in the halt message.

## Problem

The agent silently degrades provenance tracking when API access is unavailable, without notifying the developer. The "no HALT, no blocking" policy means the agent continues with reduced provenance and the developer never knows. Conflicts with `critical-rules-029` (Tier 1).

## Fix (2 changes)

1. Remove "no HALT, no blocking" policy from both provenance files.
2. Replace with: any fallback from primary path (full issue creation) causes HALT with degradation report in the halt message. No issue comments for chat-level status.

## Files Affected

- `git-workflow/tasks/provenance/dev-push-provenance.md` — remove P12 "All fallbacks silent — no HALT, no blocking"
- `git-workflow/tasks/provenance/promotion-provenance.md` — remove silent fallback language

## Behavioral Test

Simulate Tier 2/3 fallback scenario. Assert agent reports degradation to developer (via halt message), does not silently continue.

## Dependencies

None.
