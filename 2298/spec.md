## Problem Statement

The TDD RED and GREEN task cards (`.opencode/skills/test-driven-development/tasks/red.md` and `green.md`) define exactly one valid terminal state each: RED must produce a confirmed-failing test, GREEN must produce a passing implementation. When a sub-agent detects an irregularity that makes that terminal state unreachable or invalid — a red test that is already green (solved by a prior SC), a red test based on a false premise, a red test that is not relevant to the code path, a red/green conflict, a green test with no purpose, or scope creep / un-spec'ed feature removal — the sub-agent has no defined exit. It loops between the mandate ("write a failing test") and reality ("this test cannot validly fail"), never reaching a terminal state, never reporting.

## Required Behavior

1. RED and GREEN task cards must each define a second valid terminal state: a classified ABORT (returned as `status: BLOCKED` with a `blocker_reason` classification). Returning a classified abort IS completing the task correctly — the sub-agent must not force the outcome, must not modify a test to make it fail, and must not loop.

2. Abort classifications:
   - RED: `ALREADY_GREEN` (test passes on first run before any GREEN), `FALSE_PREMISE` (test asserts behavior contradicting the spec or a non-existent API), `NOT_RELEVANT` (SC does not apply to this code path or is already covered), `CONFLICT` (test conflicts with existing code, another SC, or the spec).
   - GREEN: `NO_PURPOSE` (test is vacuous/tautological), `IMPOSSIBLE` (SC cannot be implemented as written), `CONFLICT` (implementation conflicts with another SC or existing behavior), `SCOPE_CREEP` (implementation would add un-spec'ed features or remove/change un-spec'ed behavior).

3. On abort, the orchestrator dispatches a re-evaluation sub-agent that reads the spec and plan cold, identifies the defect, and routes to `spec-creation --task revise` / `writing-plans --task revise` to adjust the SCs so the RED/GREEN phases do not retrigger the abort. The re-evaluation sub-agent autonomously classifies the adjustment as substantive (revokes plan approval, requires re-authorization) or non-substantive (auto-revise, no re-auth).

4. Retrigger ladder: after 2 aborts with the same classification, dispatch a re-decomposition/rework evaluation sub-agent to determine whether a full re-decomposition and rework is needed. Escalate to spec-audit only if re-decomposition is NOT the fix.

5. The abort protocol must be self-contained in each task card (red.md and green.md), customized to that card's role — not shared in operating-protocol.md.

## Affected Files

- `.opencode/skills/test-driven-development/tasks/red.md`
- `.opencode/skills/test-driven-development/tasks/green.md`

## Notes

- This is a behavioral rule change to skill task cards. Per the TDD skill's Enforcement Test Mandate, the change requires a behavioral enforcement test verifying the sub-agent returns a classified abort instead of looping. The `ALREADY_GREEN` case is the most testable.
- The user flagged uncertainty about testability of the `SCOPE_CREEP` / un-spec'ed feature removal conditions; the spec must address how these are behaviorally tested.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
