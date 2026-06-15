---
remote_issue: 1027
remote_url: "https://github.com/michael-conrad/.opencode/issues/1027"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

Orchestrator reported auditor-mistral-large CONTEXT_TAINTED then immediately dispatched auditor-qwen3.5 in same turn, violating report-then-halt.

## Evidence

Single turn containing: failure report + dispatch + result + halt.

## Root Cause

No gate enforces turn boundary between sub-steps.

## Resolution

Pipeline sub-step model must enforce FAIL produces unconditional HALT.

🤖 OpenCode (deepseek-v4-flash)