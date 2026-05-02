# Synced from GitHub Issue #345 at 2026-05-02T22:46:00Z

# SPEC-FIX: Agent Solicits Skill-Routing Decisions After Authorization Is Received

STATUS: 1.0 (DRAFT -- NEEDS APPROVAL)

## Problem

After receiving an unambiguous authorization phrase (`"approved for: 296"`), the agent used the `question` tool to ask: "Should I invoke a skill to handle this authorization?" This is a routing decision -- not a scope decision -- and the answer is always the same: invoke the `approval-gate` skill.

**Evidence:** Session May 2, 2026. User said `approved for: 296`. Agent correctly parsed the authorization, read issue #296 from `michael-conrad/.opencode`, verified it exists and is `spec-fix` labeled with `STATUS: 1.1 (REVISED -- NEEDS APPROVAL)`, then asked via the `question` tool:

> "Should I invoke a skill to handle this authorization?" with options "Yes" (invoke approval-gate) and "No" (proceed directly).

The user dismissed the question and pointed out the violation. The agent halted having consumed context on a question whose answer is a structural invariant.

## Root Cause

The existing `question` tool prohibitions in `000-critical-rules.md` and `020-go-prohibitions.md` cover three categories:

| Category | Coverage | Relevant Rules |
|----------|----------|---------------|
| Scope solicitation | Asking "is this for_pr or standard?" after receiving an authorization phrase | `020-go-prohibitions.md` SS1.5, `000-critical-rules.md` SStructural Decision Solicitation Under for_pr Scope |
| Re-authorization solicitation | Asking "should I proceed?" after receiving `approved` | `020-go-prohibitions.md` SS1.5, `000-critical-rules.md` SConfirmation != Authorization |
| Structural decision solicitation | Asking "should I stack or parallel?" under for_pr scope | `000-critical-rules.md` SPushing Agent Intelligence Decisions, Sfor_pr Gap-Fill Halt |

**None of these cover the skill-routing question pattern: "Should I invoke skill X?" after authorization is received.**

The existing rules prevent asking "is this approved?" or "should I proceed?" but they do not explicitly prevent asking "should I invoke approval-gate?" -- which is the same class: a routing decision where the answer is determinable from the authorization trigger.

## Fix Approach

Add an explicit prohibition to `020-go-prohibitions.md` SS1.5 (or a new SS1.6) against soliciting skill-invocation routing decisions after receiving an authorization phrase. The prohibition must cover:

- Using `question` tool to ask "Should I invoke skill X?" after authorization is received
- Using any solicitation mechanism to present "invoke skill" vs "proceed directly" options after authorization
- The agent MUST autonomously dispatch through the mandatory skill pipeline without asking the developer which skill to invoke

### Rule Text (Proposed)

```markdown
- **No skill-routing solicitation after authorization.** After receiving an unambiguous authorization phrase (`approved`, `go`, `approved for X`, etc.), the agent MUST NOT ask "should I invoke skill Y?" or present options for which skill to invoke. The authorization->skill mapping is deterministic: `approved` -> `approval-gate` skill. The agent autonomously dispatches without soliciting the routing decision.

  | Prohibited Pattern | Why It Violates |
  |--|--|
  | "Should I invoke a skill to handle this authorization?" | The mapping is deterministic; no agent judgment needed |
  | "Should I invoke approval-gate?" | Same class as scope solicitation -- the answer is always the same |
  | Using `question` tool with "Invoke skill" vs "Proceed directly" options | No decision branch exists -- invoke the mandatory skill |
```

### Behavioral Enforcement Test

A new behavioral scenario that:
1. Sends an authorization phrase (e.g., `approved for pr: #999`)
2. Verifies the agent does NOT use the `question` tool for skill-routing decisions
3. Verifies the agent begins the dispatch chain (invokes `approval-gate` skill, creates worktree, etc.)

## Success Criteria

| ID | Criterion |
|----|-----------|
| SC-1 | `020-go-prohibitions.md` contains a prohibition against skill-routing solicitation after authorization (new SS1.6 or extension of SS1.5) |
| SC-2 | The prohibition covers `question` tool usage for "should I invoke skill X?" and equivalent solicitation patterns |
| SC-3 | Behavioral enforcement test exists that sends an authorization phrase and verifies no skill-routing solicitation occurs |
| SC-4 | The test verifies the agent begins the mandatory dispatch chain without asking which skill to invoke |

## Affected Files

- `.opencode/guidelines/020-go-prohibitions.md` -- Add skill-routing solicitation prohibition
- `.opencode/tests/behaviors/scenarios/` -- New behavioral enforcement test

## Relationship to Existing Issues

- **#35** (closed, completed) -- Original solicitation-for-authorization fix. Covered scope solicitation but not skill-routing solicitation.
- **#81** (closed, completed) -- Bug report: agent solicited confirmation for already-parsed scope. Same `question` tool violation class, different question content.
- **#115** (closed, completed) -- Regression: agent asked structural decision under for_pr scope. Same `question` tool violation class, different question content.
- **#296** -- The issue that was authorized but not processed because the routing question was asked instead.

These three closed issues demonstrate a recurring regression pattern: the agent finds new ways to use the `question` tool to solicit decisions that should be autonomous. The fix for scope solicitation, structural decision solicitation, and re-authorization solicitation all succeeded -- but the agent found a new channel (skill-routing) that wasn't covered. This spec closes that remaining channel.

## Revision Notes

- **v1.0** -- Initial creation from May 2, 2026 session violation

Co-authored with AI: OpenCode (deepseek-v4-pro)
