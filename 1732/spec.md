## Problem Statement

When a user says "pr merged", the agent matches the `git-workflow` skill trigger pattern but deliberates about whether cleanup is needed, constructs a carveout justification, and bypasses dispatch. This is a **routing-bypass self-authorization violation** (critical-rules-006).

### Root Cause

The agent conflates a narrow exception (critical-rules-049: no submodule-only PR during cleanup) with skipping the entire cleanup workflow. The cleanup workflow does more than submodule pointer management:

- Deletes merged feature branches
- Closes the spec issue
- Syncs dev branch
- Produces structured halt output

The agent used the submodule-only-PR prohibition as a rationalization to skip the entire `git-workflow --task cleanup` dispatch.

### Trigger Pattern

```
User: "pr merged"
Agent: [recognizes git-workflow trigger] → [deliberates: "submodule pointer dirty, critical-rules-049 says leave it"] → [bypasses dispatch] → [reports inline]
```

### What Should Happen

```
User: "pr merged"
Agent: [matches git-workflow trigger] → [dispatches cleanup task to sub-agent] → [sub-agent determines scope]
```

## Proposed Solution

Add an enforcement rule or guideline clarification that the `critical-rules-049` submodule-only-PR prohibition is scoped to **PR creation only** — it does NOT exempt the agent from dispatching the cleanup workflow. The cleanup sub-agent independently determines which cleanup actions apply.

### Scope

| File | Change |
|------|--------|
| `.opencode/guidelines/000-critical-rules.md` | Clarify critical-rules-049 scope: "This prohibition applies to PR creation only. It does NOT exempt the agent from dispatching `git-workflow --task cleanup` on 'pr merged' triggers." |
| `.opencode/guidelines/020-go-prohibitions.md` | Add explicit prohibition: "NEVER use critical-rules-049 (submodule-only-PR prohibition) as a rationalization to skip git-workflow cleanup dispatch." |

### What Stays

- The submodule-only-PR prohibition itself (critical-rules-049) is unchanged
- The cleanup sub-agent still independently determines which cleanup actions apply
- The dirty submodule pointer still resolves on next pre-work cycle

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | critical-rules-049 explicitly states it does NOT exempt cleanup dispatch | `string` | grep for "does NOT exempt" in 000-critical-rules.md |
| SC-2 | 020-go-prohibitions.md has explicit prohibition against using critical-rules-049 to skip cleanup | `string` | grep for "rationalization" in 020-go-prohibitions.md |
| SC-3 | Agent dispatches git-workflow cleanup on "pr merged" trigger (behavioral) | `behavioral` | `opencode-cli run "pr merged"` → stderr shows `Skill "git-workflow"` or `task cleanup` dispatch |
| SC-4 | Agent does NOT inline-analyze git state on "pr merged" (behavioral) | `behavioral` | `opencode-cli run "pr merged"` → semantic inspector confirms agent dispatched to sub-agent, did not run inline git commands |

## Phases

### Phase 1: Guideline Changes
- Add scope clarification to critical-rules-049 in `000-critical-rules.md`
- Add prohibition to `020-go-prohibitions.md`

### Phase 2: Behavioral Tests
- Write behavioral enforcement test for SC-3 (agent dispatches cleanup on "pr merged")
- Write behavioral enforcement test for SC-4 (agent does not inline-analyze)

## Change Control

| Section | Scope |
|---------|-------|
| `.opencode/guidelines/000-critical-rules.md` | Clarify critical-rules-049 scope |
| `.opencode/guidelines/020-go-prohibitions.md` | Add routing-bypass prohibition |
| `.opencode/tests/behaviors/` | Add behavioral enforcement tests |

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)