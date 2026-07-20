## Problem

`critical-rules-044` in `000-critical-rules.md` has an overbroad condition that treats verification sub-agents the same as execution sub-agents:

```yaml
- "verification_sub_agent_dispatched_with_file_list == true"
```

This triggers a HALT when a verification sub-agent receives a file list. But VbC (verification-before-completion) sub-agents are **verification** sub-agents, not **execution** sub-agents. Their job is to verify that changes were made correctly — they need to know what files were changed to do their job. The `file_paths`/`target_files` in VbC dispatch context is operational context (what was actually modified), not preloaded bias (what the orchestrator guesses should be changed).

The prose section of critical-rules-044 already correctly scopes to "execution" — only the symbolic condition is overbroad.

## Root Cause Analysis

PR #292 added `critical-rules-044` as part of implementing issue #274 (VbC scope discovery). The original PR included this overbroad condition:

```
- 🚫 FORBIDDEN: Pre-selecting files for verification sub-agents to check (verifiers must independently determine scope)
- ✅ REQUIRED: Verification sub-agents receive `{ success_criteria, github.owner, github.repo }` — no file lists, no scope restrictions
```

The condition was written based on #274's premise that all file lists in dispatch context are preloaded bias. This conflates two fundamentally different sub-agent types:
- **Execution sub-agents**: The orchestrator guessing what files to change and preloading that guess (harmful)
- **Verification sub-agents**: The pipeline already knows what files were changed; the verifier needs that information to verify correctness (legitimate operational context)

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Remove `"verification_sub_agent_dispatched_with_file_list == true"` condition from critical-rules-044 symbolic rule conditions array | `structural` | grep for absence of the condition in `guidelines/000-critical-rules.md` |

## Affected Files

- `.opencode/guidelines/000-critical-rules.md` (symbolic rules section only)

## Related Issues

- **#274** (closed, not_planned): Proposed removing file_paths from VbC dispatch context — this fix is the targeted remediation of #292's overbroad implementation
- **#292**: PR that added critical-rules-044 with the overbroad condition

## Authorization

This spec was auto-approved via `approved-for-pr` label on issue #274 (reopened). The fix addresses a specific, narrow bug in the symbolic rule conditions.