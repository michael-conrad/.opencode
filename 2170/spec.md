---
issue: 2170
repo: michael-conrad/.opencode
state: OPEN
labels: [bug, spec]
title: "[SPEC] Git workflow regression: three root causes in cleanup/authorization/pointer lifecycle"
---

## Problem

The original spec claimed "submodule-first processing order broken" but database evidence from 20+ cleanup/check-pr/PR-creation sessions disproves this — the agent does process submodules first. The real problems are three distinct issues discovered through SQLite analysis of the opencode session database:

1. **Dirty pointer deadlock**: Cleanup says "leave dirty, next pre-work fixes it." Pre-work's No-Op Branch Guard says "if only pointer changes, delete the branch." The pointer can never resolve because every path to commit it hits a HALT gate. 15+ files with conflicting submodule pointer rules create context-order-dependent behavior.

2. **check-pr authorization ambiguity**: Phase 3 says "Close depth-first" unconditionally, but approval-gate.md rule 10 says "Close issues only after PR merge confirmed." The agent doesn't know whether "confirmed" means "verified by Phase 2" or "requires developer to say yes." This produces non-deterministic behavior — sometimes issues are closed, sometimes refused.

3. **Excessive deliberation about cleanup authorization**: The agent spends cycles consulting authorization rules for post-merge cleanup operations that should be automatic. This wastes context, produces chat noise, and amplifies the other two issues by causing the agent to second-guess itself mid-workflow.

## Affected Files

- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (Phase 3 authorization clarity)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` (dirty pointer deadlock resolution)
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (No-Op Branch Guard cross-reference)
- `.opencode/guidelines/010-approval-gate.md` (rule 10 wording: "confirmed" ambiguity)
- `.git/hooks/pre-push` (Gate 2 message — remove instructional text, just state block + reason)
- `.opencode/guidelines/020-go-prohibitions.md` (critical-rules-049 "resolves on next pre-work" — this is false)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Dirty pointer deadlock resolved: cleanup leaves pointer dirty, pre-work No-Op Branch Guard cross-references cleanup rule, pointer only commits alongside real code changes | `string` | grep for cross-reference in pre-work.md to branch-cleanup.md |
| SC-2 | check-pr Phase 3 explicitly states that merge verification (Phase 2) satisfies the authorization requirement for issue closure | `string` | grep check-pr.md for authorization statement in Phase 3 |
| SC-3 | Post-merge cleanup operations are explicitly authorized by the merge event — agent MUST NOT deliberate about authorization for cleanup | `string` | grep branch-cleanup.md or check-pr.md for non-deliberation mandate |
| SC-4 | Pre-push hook Gate 2 message states only the block and reason — no instructions, no workarounds | `string` | grep pre-push hook for absence of instructional text in Gate 2 |
| SC-5 | approval-gate.md rule 10 wording clarified: "confirmed" means "verified by check-pr Phase 2" not "requires developer authorization" | `string` | grep approval-gate.md for clarified wording |
| SC-6 | "resolves on next pre-work cycle" language removed from 020-go-prohibitions.md and branch-cleanup.md — replaced with accurate description of pointer lifecycle | `string` | grep for absence of "resolves on next pre-work" in those files |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-28 | Complete spec rewrite: replaced "submodule-first processing order broken" with three root causes (dirty pointer deadlock, check-pr authorization ambiguity, excessive deliberation about cleanup authorization). Updated affected files and success criteria. | Database evidence from 20+ sessions disproved original problem statement. Real issues discovered through SQLite analysis. | AI agent (deepseek-v4-flash) |
