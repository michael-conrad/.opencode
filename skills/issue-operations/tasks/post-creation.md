# Task: post-creation

## Purpose

Invoke auditors after spec creation, ensuring spec quality before approval. Plan creation is handled by the approval-gate cascade post-user-approval — not invoked here.

## Operating Protocol

1. **Run after issue is created.**
2. **Invoke auditors BEFORE approval.**
3. **Do NOT trigger plan creation** — plans are created by the approval-gate cascade after user approval.

## Entry Criteria

- Issue created successfully
- Issue number available
- Creation byline added

## Exit Criteria

- Auditors invoked (spec-auditor orchestrator — determines subtasks automatically)
- Issue ready for approval workflow
- Plan creation NOT triggered — handled by approval-gate cascade post-approval

## Procedure

### Step 1: Invoke Spec-Auditor Orchestrator

**Run spec-auditor as the single audit entry point:**

```
1. spec-auditor --issue <number>
   - Orchestrator determines which subtasks to run
   - Baseline always runs: fresh-start, structure, fidelity
   - Agent decides conditional subtasks based on issue nature
   - All findings are reported (not auto-applied)
```

**The orchestrator replaces the old three-auditor chain.**
Previous workflow (DEPRECATED):
~~~
1. plan-fidelity-auditor --issue <number>
2. concern-separation-auditor --issue <number>
3. spec-auditor --issue <number>
~~~

**New workflow:**
```
1. spec-auditor --issue <number>
   (internally runs baseline + conditional subtasks)
```

**Auditors MUST run BEFORE approval.**

## Safety Checks

Before proceeding, verify ALL:

- Auditors invoked (spec-auditor orchestrator — determines subtasks automatically)

**If ANY check fails → HALT and report.**

## Context Required

- Related tasks: `creation` (runs first)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`
- Plan creation NOT handled here — handled by approval-gate cascade post-user-approval

## Live Verification: Post-Creation Evidence (MANDATORY)

**Each post-creation step MUST be verified via tool call. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call (routed) | Problem Class |
|-------|-------------------|-----------|---------------|
| "Issue #N was created" | Verify issue exists | `issue-operations → read-issue` → verify | MISSING-ELEMENT |
| "Spec-auditor was invoked" | Verify auditor ran | Session records or auditor output | MISSING-ELEMENT |
| "Auditors run BEFORE approval" | Verify no approval exists before auditor | `issue-operations → read-comments` → check for "approved"/"go" | CONFLICTING |

**Evidence artifact:** Auditor invocation result.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Issue not found | MISSING-ELEMENT | flag-for-review | HALT — creation may have failed |
| Auditor not invoked | MISSING-ELEMENT | auto-fix | Invoke spec-auditor immediately |
| Approval exists before audit | CONFLICTING | flag-for-review | HALT — auditors must run first |