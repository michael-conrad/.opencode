---
issue: .opencode#2146
title: "[SPEC] Add session timestamp to session-init output"
status: approved
approved: 2026-07-25
created: 2026-07-25
license: MIT
provenance: AI-generated
phase: 1
phase_name: Session Timestamp
authors:
  - OpenCode (deepseek-v4-flash)
---

> **Full spec and artifacts: [`.opencode/.issues/2146/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2146)**

## Problem

The session-init script outputs developer identity, repo information, and branch state, but does not include a timestamp. The AI agent has no awareness of what time period it is operating in.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | session-init emits a human-readable datetime stamp including date, day of week, time, and timezone | behavioral | Run session-init, verify output contains human-readable datetime with all required components |
| SC-2 | The timestamp appears after the Git branch line and before the ## CLI Auth Status section | string | grep for the line position relative to Git branch and CLI Auth Status |
| SC-3 | The format is natural English prose, not structured key:value | string | grep for the exact format pattern |
| SC-4 | The timestamp is generated at runtime (not hardcoded) using Python's datetime module | structural | Inspect source code for datetime.now() or equivalent call |
| SC-5 | The timezone is the local timezone abbreviation (e.g. EDT, IST, CET) — not UTC offset notation | string | grep for timezone abbreviation (not UTC offset) in the output |

## Approach

Add a single print line to the session-init script's main() function that emits the current local datetime in human-readable format with the local timezone abbreviation.

## Affected Files

- tools/session-init
