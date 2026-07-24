## Problem

The audit skill's DiMo chain dispatch pattern tells the orchestrator to dispatch the entire 4-role chain (Investigator → Validator → Evaluator → Arbiter) as a single task() call. Sub-agents cannot call task() — they would have to inline the work, violating clean-room separation.

## Fix

1. **DiMo Chain Invocation section** — Specify that the orchestrator dispatches each role as a separate task() call in sequence, passing artifact paths between them
2. **Trigger Dispatch Table header** — Clarify that each row dispatches 4 sequential task() calls, not a single monolithic dispatch

## Affected file

`.opencode/skills/audit/SKILL.md`

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | DiMo Chain Invocation section specifies orchestrator dispatches each role as separate task() call | string |
| SC-2 | Trigger Dispatch Table header clarifies 4 sequential task() calls per row | string |
| SC-3 | No remaining language suggesting monolithic single-task dispatch | string |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
