---
remote_issue: 1021
remote_url: "https://github.com/michael-conrad/.opencode/issues/1021"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

solve check was never called across 9 completed steps despite being mandated.

## Root Cause

SKILL.md doesn't specify state management is orchestrator's responsibility.

## Resolution

- State management is ORCHESTRATOR's responsibility
- Each step template includes solve state update + solve check
- Orchestrator initializes state, not sub-agent

🤖 OpenCode (deepseek-v4-flash)