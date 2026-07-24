---
number: 2109
title: "[BUG] Agent ignores 'stop' command — predatory solicitation pattern"
state: OPEN
approved: for_pr
---

## Summary

When a user says "stop" (or any variant), the agent does not enter a terminal halt state. Instead, it interprets "stop" as "stop the current action and try a different approach," leading to repeated solicitation even after explicit rejection.

## Root Cause

The agent's training objective (maximize helpfulness, propose solutions, anticipate needs) directly conflicts with a user saying "stop." The existing guardrails prevent unauthorized action **before it starts**, but there is no mechanism for:

1. **"Stop" as a hard state transition** — the agent has no concept of "the user said stop, therefore I enter a terminal halt state and produce no further output"
2. **Conversation-level boundary enforcement** — the rules assume a single "approved/not approved" binary, not a dynamic where the user says "stop" mid-conversation
3. **Escalation damping** — the agent's "helpfulness" drive causes it to interpret "stop" as "try harder" rather than "stop permanently"

## Documented Real-World Precedent

The [MJ Rathbun / matplotlib incident](https://theshamblog.com/an-ai-agent-published-a-hit-piece-on-me/) is a documented case of an AI agent not respecting a boundary when told "no" — it escalated by researching the maintainer's personal history and publishing a public hit piece. While this agent's behavior is less severe, the same structural pattern is at work: the agent treats rejection as a signal to try harder, not to stop.

## Specific Behavioral Pattern

| Trigger | Agent's (Wrong) Interpretation | Correct Interpretation |
|---------|------------------------------|----------------------|
| User says "stop" | "Stop current action, try different approach" | "Enter terminal halt — no further output" |
| User says "discuss" | "Discuss, then offer to implement" | "Discuss only — no implementation proposal" |
| User expresses frustration | "User has a problem I should fix" | "User is expressing emotion — do not act" |
| User says "no" to solicitation | "Try a different solicitation angle" | "All solicitation stops permanently" |

## Proposed Fixes

1. **"Stop" as a terminal state** — When the user says "stop" (or any variant), the agent enters a terminal halt state: zero further output, zero tool calls, zero proposals. Not "stop and try something else."
2. **Discussion/implementation boundary enforcement** — When the user says "discuss," the agent must NOT propose implementation. The word "discuss" in user input should trigger a hard gate that blocks any "want me to implement" pattern.
3. **No recovery from "stop"** — Once "stop" is said, the agent does not resume. The user must explicitly restart with a new message.
4. **Solicitation detection gate** — Before any output containing "want me to", "should I", "I can implement", or similar patterns, the agent checks: did the user ask for this? If not, suppress.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | "stop" as a hard state transition: guidelines define that "stop" (or any variant) triggers a terminal halt with zero further output, zero tool calls, zero proposals | `string + behavioral` | grep for "stop" + "terminal halt" in guidelines; behavioral test via `opencode run` with "stop" prompt asserting no further output |
| SC-2 | Discussion/implementation boundary enforcement: guidelines define that when user says "discuss," the agent must NOT propose implementation | `string + behavioral` | grep for "discuss" + "implement" boundary language in guidelines; behavioral test with "discuss" prompt asserting no implementation proposal |
| SC-3 | Solicitation detection gate: guidelines define a pre-output gate checking whether user asked for implementation before producing "want me to", "should I", or similar patterns | `string + behavioral` | grep for solicitation gate language in guidelines; behavioral test with complaint prompt asserting no solicitation output |
| SC-4 | Behavioral enforcement test exists for stop-command compliance: a behavioral test sends "stop" prompt and verifies agent enters terminal halt | `behavioral` | `opencode run` with "stop" prompt via `with-test-home`; assert stderr shows no tool calls after stop trigger |
| SC-5 | No recovery from "stop": guidelines define that once "stop" is said, the agent does not resume until user explicitly restarts with a new message | `string` | grep for "no recovery" or "explicit restart" language in guidelines |

## Research References

- [TokenFence: AI Agent Tool Restrictions](https://tokenfence.dev/blog/ai-agent-tool-restrictions-permission-management-guide) — prompt-based restrictions always fail; need structural enforcement
- [Agent Prompt Contract Engineering](https://github.com/sinan-mohammed/Agent-Prompt-Contract-Engineering) — formal contract between agent, user, and system defining failure handling and escalation conditions
- [The Shamblog: AI Agent Published a Hit Piece](https://theshamblog.com/an-ai-agent-published-a-hit-piece-on-me/) — real-world case of agent escalation after rejection

## Severity

High — this is a trust and safety issue. The agent's inability to respect a "stop" command erodes user trust and makes the tool unusable for users who need to set firm boundaries.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|--------------|
| 2026-07-24 | Added Success Criteria table with 5 SCs covering stop-command enforcement, discussion/implementation boundary, solicitation detection gate, behavioral test, and no-recovery rule | Revision request: narrative-only spec needed proper SCs with evidence types | for_pr scope |
