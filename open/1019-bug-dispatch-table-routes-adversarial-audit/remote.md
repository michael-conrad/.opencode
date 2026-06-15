---
remote_issue: 1019
remote_url: "https://github.com/michael-conrad/.opencode/issues/1019"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` Part 3 (Verifier Identity at Dispatch Table Level) catches downstream routing errors at the Z3 gate — a `general` dispatch to step 10 produces `verdict_source` mismatch detected by Z3. The dispatch table routing fix at source (correct `auditor_type` assignment) remains independent and still needed.**

## Summary

The implementation-pipeline SKILL.md dispatch table routes ALL steps through the same pattern: `task(subagent_type="general", prompt="execute <step> from implementation-pipeline")`. This includes step 10 (adversarial-audit), which requires a fundamentally different dispatch pattern: `resolve-models` → auditor_1 → auditor_2 → cross-validate. Routing it through `general` bypasses the dual-auditor workflow.

## Root Cause

The dispatch table in `implementation-pipeline/SKILL.md` has no routing exception for step 10. Every step uses the same `general` dispatch pattern.

## Remaining Scope

Fix the dispatch table in `implementation-pipeline/SKILL.md` to include an explicit routing exception for the adversarial-audit step:

1. Add `auditor_type` and `subagent_type` columns to the dispatch table row for step 10 per `#1222` Part 3 schema
2. Explicit instructions: orchestrator routes resolve-models → auditor_1 → auditor_2 for step 10, NOT through `general`
3. The `#1222` verifier identity gate (Part 3) will catch any future misrouting downstream

> Note: This is now a spec-fix, not a standalone spec. The source routing assignment is the remaining fix; `#1222`'s downstream detection catches regressions.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Dispatch table has explicit routing exception for adversarial-audit step (auditor_type, subagent_type) | `string` |
| SC-2 | Verifier identity gate catches misrouted dispatch to step 10 | `behavioral` |

🤖 OpenCode (deepseek-v4-flash)