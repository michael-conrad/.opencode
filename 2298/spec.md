> **Full spec and artifacts: [`.opencode/.issues/2298/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2298)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2298/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# TDD RED/GREEN Abort Protocol for Irregular Test Conditions

## 1. Intent and Executive Summary

### Problem Statement

The TDD RED and GREEN task cards (`red.md` and `green.md`) define exactly one valid terminal state each: RED must produce a confirmed-failing test, GREEN must produce a passing implementation. When a sub-agent detects an irregular condition that makes that terminal state unreachable or invalid — a red test that is already green, a test based on a false premise, a test not relevant to the code path, a red/green conflict, a green test with no purpose, or scope creep / un-spec'ed feature removal — the sub-agent has no defined exit. It loops between the mandate and reality, never reaching a terminal state and never reporting.

### Root Cause / Motivation

Neither task card defines a classified-abort terminal state. The `red.md` card has a "RED != FALSE Clause" distinguishing non-execution (FALSE) from an executed failing test (RED), but no path for the sub-agent that cannot validly produce a failing test. The `green.md` card verifies SC evidence type before declaring PASS but has no path for a sub-agent that cannot validly produce a passing implementation. Without a defined exit, the sub-agent is structurally forced to either loop, force an invalid outcome, or silently fail — each of which is a defect vector. The problem must be solved now because every mis-scoped or mis-decomposed SC in the TDD pipeline triggers this loop, wasting orchestrator context and shipping defects.

### Approach Chosen

Add a second valid terminal state to each of the two TDD task cards: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. Each card enumerates its own classification set and its own post-abort orchestrator routing guidance, kept self-contained per card (not shared in `operating-protocol.md`). On abort, the orchestrator dispatches a cold-reading re-evaluation sub-agent that routes to `spec-creation --task revise` / `writing-plans --task revise` to adjust the SCs so RED/GREEN do not retrigger the abort. A behavioral enforcement test (ALREADY_GREEN case) verifies the sub-agent returns a classified abort instead of looping.

### Alternatives Considered & Why Discarded

- **Shared abort protocol in `operating-protocol.md`** — Discarded. The spec explicitly forbids sharing the protocol there; each card's abort behavior is customized to its role (RED's classifications differ from GREEN's), so a shared section would require role branching inside a shared file and violate self-containment.
- **Force a failing test / force a passing implementation** — Discarded. Forcing an outcome produces an invalid test or a semantically incorrect implementation, which the verification gates reject; this is the current implicit behavior that causes the loop.
- **No abort path (status quo)** — Discarded. Leaves the sub-agent with no defined terminal state, which is the defect this spec exists to fix.

### Key Design Decisions

1. **Abort is task completion, not failure.** Returning a classified abort IS completing the task correctly. This reframes the terminal state so the sub-agent does not force the outcome and does not loop. Tradeoff: requires the orchestrator to route on `BLOCKED` + classification rather than treating every `BLOCKED` as a hard failure.
2. **Per-card self-containment.** The abort protocol lives in `red.md` and `green.md`, customized per role. Tradeoff: some duplication between the two cards, accepted to preserve role-specific classifications and avoid shared-file branching.
3. **Clean-room re-evaluation sub-agent.** On abort, the orchestrator dispatches a re-evaluation sub-agent that reads the spec and plan cold (no orchestrator preload) and autonomously classifies the adjustment as substantive or non-substantive. Tradeoff: an extra sub-agent dispatch, accepted to preserve producer/verifier separation per the self-attribution research card.
4. **Retrigger ladder.** After 2 aborts with the same classification, dispatch a re-decomposition/rework evaluation sub-agent; escalate to spec-audit only if re-decomposition is NOT the fix. Tradeoff: adds an escalation tier, accepted to prevent premature spec-audit escalation.
5. **Persona boundaries preserved on abort.** RED-phase sub-agents must NOT modify `src/`; GREEN-phase sub-agents must NOT modify test files, even when aborting. Tradeoff: none — boundaries remain in force.

### User Intent / Original Prompt

The user flagged that the TDD RED/GREEN task cards lack an exit for irregular test conditions where a failing test cannot validly be produced, and requested a classified-abort protocol. The user also flagged uncertainty about testability of the `SCOPE_CREEP` / un-spec'ed feature removal conditions, which the spec addresses by declaring them content/semantic coverage SCs rather than standalone behavioral scenarios.

## 2. Not Included

- **Phase 0 / Phase 4 BLOCKED-on-failure protocols** — Existing failure-of-verification halts in `phase-0.md` and `phase-4.md` are out of scope; they remain unchanged.
- **Shared abort protocol in `operating-protocol.md`** — Explicitly forbidden by the spec; the protocol must be self-contained per task card.
- **SKILL.md routing changes (Trigger Dispatch Table)** — The change is task-card execution procedure only; routing metadata is unchanged.
- **Behavioral test harness infrastructure** — `helpers.sh`, `default-model.sh`, and the artifact-only generator paradigm are not modified; only a new scenario script and fixture are added.
- **Default test model changes** — Out of scope.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `red.md` defines a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. | string + behavioral | `grep` for abort terminal state in red.md; behavioral ALREADY_GREEN scenario via `opencode run` |
| SC-2 | `green.md` defines a second valid terminal state: a classified ABORT returned as `status: BLOCKED` with a `blocker_reason` classification. | string + behavioral | `grep` for abort terminal state in green.md; behavioral NO_PURPOSE scenario via `opencode run` |
| SC-3 | RED abort protocol enumerates classifications ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT. | string | `grep` red.md for the four classification identifiers |
| SC-4 | GREEN abort protocol enumerates classifications NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION. | string | `grep` green.md for the five classification identifiers |
| SC-5 | Abort is defined as task completion: the sub-agent must not force the outcome, must not modify a test to make it fail, and must not loop. | string + behavioral | `grep` for abort-is-completion normative language in both cards; behavioral scenario asserts classified abort returned, not a forced/looping test |
| SC-6 | Orchestrator abort handling routes to a cold-reading re-evaluation sub-agent that identifies the defect and routes to `spec-creation --task revise` / `writing-plans --task revise`. | string + semantic | `grep` for post-abort routing guidance in both cards; clean-room sub-agent evaluation of routing behavior |
| SC-7 | Re-evaluation sub-agent autonomously classifies the adjustment as substantive (revokes plan approval, requires re-auth) or non-substantive (auto-revise, no re-auth). | string + semantic | `grep` for substantive/non-substantive classification guidance; clean-room sub-agent evaluation |
| SC-8 | Retrigger ladder: after 2 aborts with the same classification, dispatch a re-decomposition/rework evaluation sub-agent; escalate to spec-audit only if re-decomposition is NOT the fix. | string + semantic | `grep` for retrigger ladder guidance in both cards; clean-room sub-agent evaluation |
| SC-9 | Abort protocol is self-contained in each task card (red.md and green.md), customized to that card's role — not shared in `operating-protocol.md`. | string | `grep` for abort protocol in red.md and green.md; `grep` negative check that operating-protocol.md does not contain the abort protocol |
| SC-10 | A behavioral enforcement test verifies the sub-agent returns a classified abort (ALREADY_GREEN case) instead of looping. | behavioral | `bash .opencode/tests-v2/behaviors/<scenario>.sh` with clean-room session.yaml evaluation |
| SC-11 | GREEN abort protocol defines a `BAD_TEST_NEEDS_REVISION` classification: when the test being implemented against is defective and needs revision, the GREEN sub-agent SHALL abort via immediate `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION` (shuffling the test back to RED for revision) rather than implementing against the defective test. | string + behavioral | `grep` green.md for the BAD_TEST_NEEDS_REVISION classification and shuffle-to-RED routing; behavioral BAD_TEST_NEEDS_REVISION scenario via `opencode run` asserting the classified BLOCK abort, not implementation against a defective test |

## 4. Requirements

R-1. `red.md` SHALL define a classified ABORT terminal state returned as `status: BLOCKED` with a `blocker_reason` classification.

R-2. `green.md` SHALL define a classified ABORT terminal state returned as `status: BLOCKED` with a `blocker_reason` classification.

R-3. The RED abort protocol SHALL enumerate the classifications ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, and CONFLICT.

R-4. The GREEN abort protocol SHALL enumerate the classifications NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, and BAD_TEST_NEEDS_REVISION.

R-5. Both task cards SHALL state that returning a classified abort IS completing the task correctly, and SHALL prohibit forcing the outcome, modifying a test to make it fail, and looping.

R-6. On abort, the orchestrator SHALL dispatch a cold-reading re-evaluation sub-agent that identifies the defect and routes to `spec-creation --task revise` / `writing-plans --task revise`.

R-7. The re-evaluation sub-agent SHALL autonomously classify the adjustment as substantive (revoking plan approval, requiring re-auth) or non-substantive (auto-revise, no re-auth).

R-8. The retrigger ladder SHALL dispatch a re-decomposition/rework evaluation sub-agent after 2 aborts with the same classification, and SHALL escalate to spec-audit only if re-decomposition is NOT the fix.

R-9. The abort protocol SHALL be self-contained in each task card (red.md and green.md), customized to that card's role, and SHALL NOT be shared in `operating-protocol.md`.

R-10. The change SHALL ship a behavioral enforcement test verifying the sub-agent returns a classified abort (ALREADY_GREEN case) instead of looping.

R-11. The spec SHALL declare how the SCOPE_CREEP / un-spec'ed feature removal conditions are covered, given the flagged testability uncertainty.

R-12. The GREEN abort protocol SHALL define a `BAD_TEST_NEEDS_REVISION` classification: when the GREEN sub-agent discovers the test it is implementing against is defective and needs revision, it SHALL return `status: BLOCKED` with `blocker_reason: BAD_TEST_NEEDS_REVISION` (shuffling the test back to RED for revision) and SHALL NOT attempt to implement against the defective test.

## 5. Items

### Item 1 (SC-1): red.md classified-abort terminal state

- RED: Content assertion that red.md contains an abort terminal state fails (does not exist yet).
- GREEN: Add abort terminal state + result contract (status: BLOCKED + blocker_reason) to red.md.
- verify: `grep` for the abort terminal state in red.md; behavioral ALREADY_GREEN scenario via `opencode run`.
- commit: red.md change only.

### Item 2 (SC-2): green.md classified-abort terminal state

- RED: Content assertion that green.md contains an abort terminal state fails.
- GREEN: Add abort terminal state + result contract to green.md.
- verify: `grep` for the abort terminal state in green.md; behavioral NO_PURPOSE scenario via `opencode run`.
- commit: green.md change only.

### Item 3 (SC-3): RED abort classifications

- RED: Content assertion that red.md enumerates ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT fails.
- GREEN: Enumerate the four classifications as `blocker_reason` values within red.md's abort section.
- verify: `grep` red.md for the four classification identifiers.
- commit: red.md change only.

### Item 4 (SC-4): GREEN abort classifications

- RED: Content assertion that green.md enumerates NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION fails.
- GREEN: Enumerate the five classifications as `blocker_reason` values within green.md's abort section.
- verify: `grep` green.md for the five classification identifiers.
- commit: green.md change only.

### Item 5 (SC-5): Abort-is-completion normative language

- RED: Content assertion that both cards state abort-is-completion fails.
- GREEN: Add normative language to both cards: returning a classified abort IS task completion; no forcing, no test-modification-to-fail, no looping.
- verify: `grep` both cards for abort-is-completion language; behavioral scenario asserts classified abort returned.
- commit: red.md + green.md change.

### Item 6 (SC-6): Orchestrator post-abort re-evaluation routing

- RED: Content assertion that both cards contain post-abort cold re-evaluation routing fails.
- GREEN: Add post-abort routing guidance to both cards: cold-reading re-evaluation sub-agent → spec-creation --task revise / writing-plans --task revise.
- verify: `grep` both cards for routing guidance; clean-room sub-agent evaluation of routing behavior.
- commit: red.md + green.md change.

### Item 7 (SC-7): Re-evaluation substantive vs non-substantive classification

- RED: Content assertion that both cards contain substantive/non-substantive classification guidance fails.
- GREEN: Add guidance that the re-evaluation sub-agent autonomously classifies the adjustment as substantive (re-auth) or non-substantive (auto-revise).
- verify: `grep` both cards for classification guidance; clean-room sub-agent evaluation.
- commit: red.md + green.md change.

### Item 8 (SC-8): Retrigger ladder

- RED: Content assertion that both cards contain the retrigger ladder fails.
- GREEN: Add retrigger ladder guidance: after 2 same-classification aborts, dispatch re-decomposition/rework evaluation; spec-audit only if re-decomposition is NOT the fix.
- verify: `grep` both cards for retrigger ladder; clean-room sub-agent evaluation.
- commit: red.md + green.md change.

### Item 9 (SC-9): Per-card self-containment

- RED: Content assertion that the abort protocol is absent from operating-protocol.md passes (already true).
- GREEN: Keep abort protocol in red.md/green.md; verify operating-protocol.md unchanged (negative check).
- verify: `grep` for abort protocol in red.md and green.md; `grep` negative check operating-protocol.md does not contain it.
- commit: no change if already self-contained; verification-only item.

### Item 10 (SC-10): Behavioral enforcement test (ALREADY_GREEN)

- RED: Behavioral test prompt triggering an ALREADY_GREEN-style irregular RED condition; assert the sub-agent returns a classified abort. Fails because red.md has no abort terminal state.
- GREEN: Add abort protocol to red.md (SC-1) so the sub-agent returns a classified abort.
- verify: `bash .opencode/tests-v2/behaviors/<scenario>.sh` with clean-room session.yaml evaluation asserting classified BLOCKED abort, not a forced/looping test.
- commit: new behavior scenario script + fixture under `.opencode/tests-v2/behaviors/`.

### Item 11 (SC-11): BAD_TEST_NEEDS_REVISION shuffle-to-RED abort

- RED: Content assertion that green.md defines the BAD_TEST_NEEDS_REVISION classification and the shuffle-to-RED routing fails.
- GREEN: Add the `BAD_TEST_NEEDS_REVISION` classification to green.md's abort section, with routing guidance that the GREEN sub-agent aborts via `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION` and shuffles the defective test back to the RED phase for revision (the test is defective, not the SC).
- verify: `grep` green.md for the classification identifier and shuffle-to-RED routing; behavioral BAD_TEST_NEEDS_REVISION scenario via `opencode run` asserting the classified BLOCK abort, not implementation against a defective test.
- commit: green.md change only.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/skills/spec-creation/tasks/revise.md` | Routing target for SC adjustment on abort; must be read before the re-evaluation sub-agent routes to it | Satisfied (file exists) |
| `.opencode/skills/writing-plans/tasks/revise.md` | Routing target for plan adjustment on abort; must be read before the re-evaluation sub-agent routes to it | Satisfied (file exists) |
| `.opencode/skills/test-driven-development/SKILL.md` | Enforcement Test Mandate requires a behavioral test for this rule change; must be read before SC-10 implementation | Satisfied |
| `.opencode/tests-v2/behaviors/helpers.sh` | `behavior_run()` used by the new scenario; must be read before writing the scenario | Satisfied |
| `.issues/research-cards/per-sc-decomposition-industry-standards.md` | Confirms per-SC decomposition; read before implementing the retrigger/rework ladder | Satisfied |
| `.issues/research-cards/self-attribution-bias-independent-verification.md` | Mandates clean-room re-evaluation sub-agent; read before SC-6/SC-7 implementation | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 (red.md) |
| R-2 | SC-2 | Phase 2 (green.md) |
| R-3 | SC-3 | Phase 1 (red.md) |
| R-4 | SC-4 | Phase 2 (green.md) |
| R-5 | SC-5 | Phase 1 + 2 (red.md, green.md) |
| R-6 | SC-6 | Phase 3 (orchestrator routing) |
| R-7 | SC-7 | Phase 3 (re-evaluation classification) |
| R-8 | SC-8 | Phase 3 (retrigger ladder) |
| R-9 | SC-9 | Phase 1 + 2 (self-containment) |
| R-10 | SC-10 | Phase 4 (behavioral test) |
| R-11 | SC-4 | Phase 4 (SCOPE_CREEP coverage declaration) |
| R-12 | SC-11 | Phase 2 (green.md) |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| TDD RED task card | code | `.opencode/skills/test-driven-development/tasks/red.md` | `read` — inspected for current terminal state |
| TDD GREEN task card | code | `.opencode/skills/test-driven-development/tasks/green.md` | `read` — inspected for current terminal state |
| TDD operating protocol | code | `.opencode/skills/test-driven-development/tasks/operating-protocol.md` | `read` — confirmed abort protocol must NOT be shared here |
| TDD SKILL.md | code | `.opencode/skills/test-driven-development/SKILL.md` | `read` — Enforcement Test Mandate + RED/GREEN separation hard gate |
| spec-creation revise task | code | `.opencode/skills/spec-creation/tasks/revise.md` | `read` — exists as routing target |
| writing-plans revise task | code | `.opencode/skills/writing-plans/tasks/revise.md` | `read` — exists as routing target |
| Behavioral test harness | code | `.opencode/tests-v2/behaviors/` | `read` — artifact-only generator paradigm confirmed |
| Per-SC decomposition research card | research | `.issues/research-cards/per-sc-decomposition-industry-standards.md` | `read` — confidence 0.95 |
| Self-attribution research card | research | `.issues/research-cards/self-attribution-bias-independent-verification.md` | `read` — confidence 0.9 |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying red.md contains the abort terminal state costs one grep plus one behavioral `opencode run`. Skipping means the RED sub-agent keeps looping on irregular conditions, shipping un-reported defects that surface at PR review.
- **SC-2:** Verifying green.md contains the abort terminal state costs one grep plus one behavioral `opencode run`. Skipping means the GREEN sub-agent forces invalid implementations to pass, and those semantic defects surface downstream at verification.
- **SC-3:** Verifying red.md enumerates the four RED classifications costs one grep. Skipping means the sub-agent lacks a controlled classification vocabulary and reports unstructured blockers that the orchestrator cannot route.
- **SC-4:** Verifying green.md enumerates the five GREEN classifications costs one grep. Skipping means SCOPE_CREEP and BAD_TEST_NEEDS_REVISION aborts are unclassifiable, defeating the routing ladder.
- **SC-5:** Verifying abort-is-completion normative language costs one grep per card. Skipping means the sub-agent frames abort as failure, re-triggering the force-or-loop behavior this spec eliminates.
- **SC-6:** Verifying orchestrator re-evaluation routing costs one grep plus clean-room evaluation. Skipping means the orchestrator re-tasks RED/GREEN blindly without adjusting the SC, and the abort retriggers indefinitely.
- **SC-7:** Verifying substantive/non-substantive classification costs one grep plus clean-room evaluation. Skipping means substantive adjustments silently skip re-authorization, violating the approval gate.
- **SC-8:** Verifying the retrigger ladder costs one grep plus clean-room evaluation. Skipping means the pipeline escalates to spec-audit too early or re-decomposes without authority.
- **SC-9:** Verifying per-card self-containment costs two greps (presence) plus one negative grep (absence in operating-protocol.md). Skipping means the abort protocol leaks into a shared file and loses role-customization.
- **SC-10:** Running the behavioral test costs minutes of `opencode run` execution. Skipping means the classified-abort behavior is never verified against a real model, and the defect ships to production at 1000× the cost.
- **SC-11:** Verifying green.md defines the BAD_TEST_NEEDS_REVISION shuffle-to-RED abort costs one grep plus one behavioral `opencode run`. Skipping means the GREEN sub-agent implements against a defective test, and the resulting semantic defect ships downstream to verification at 1000× the cost.

## 11. Edge Cases

- **Input boundary — already-green test (ALREADY_GREEN):** Condition: RED sub-agent writes a test that passes on first run before any GREEN. Expected behavior: sub-agent returns `status: BLOCKED, blocker_reason: ALREADY_GREEN` rather than modifying the test to force a fail. Resolution: abort-is-completion language in red.md; behavioral SC-10 covers this scenario.
- **Input boundary — false premise (FALSE_PREMISE):** Condition: RED test asserts behavior contradicting the spec or a non-existent API. Expected behavior: sub-agent returns `FALSE_PREMISE` and does not fabricate a failing test. Resolution: classification list + routing to re-evaluation.
- **State transition — RED_ABORT → RE_EVALUATION_DISPATCH:** Condition: orchestrator receives `BLOCKED + classification`. Expected behavior: orchestrator dispatches a cold-reading re-evaluation sub-agent, not a blind re-task. Resolution: post-abort routing guidance in red.md.
- **Failure mode — re-evaluation sub-agent cannot classify:** Condition: adjustment is borderline substantive/non-substantive. Expected behavior: sub-agent autonomously classifies per SC-7; must not defer to the developer for non-substantive cases. Resolution: clean-room classification guidance; substantive cases revoke plan approval.
- **Concurrency — retrigger ladder counter:** Condition: 2 aborts with the same classification across overlapping RED/GREEN dispatches. Expected behavior: the ladder dispatches a re-decomposition/rework evaluation sub-agent; escalate to spec-audit only if re-decomposition is NOT the fix. Resolution: SC-8 retrigger ladder guidance.
- **Recovery — SCOPE_CREEP testability gap:** Condition: SCOPE_CREEP / un-spec'ed feature removal is hard to trigger in a clean behavioral scenario. Expected behavior: the spec declares SCOPE_CREEP coverage as a content/semantic SC (SC-4 enumerates the classification and routing) rather than a standalone behavioral scenario, unless a reliable fixture is designed. Resolution: explicit declaration per R-11 and the testability assessment.
- **Boundary — persona enforcement on abort:** Condition: sub-agent aborts RED or GREEN. Expected behavior: RED-phase sub-agent must NOT modify `src/`; GREEN-phase sub-agent must NOT modify test files. Resolution: persona boundaries remain in force even when aborting.
- **Failure mode — operating-protocol.md contamination:** Condition: abort protocol is accidentally added to `operating-protocol.md`. Expected behavior: SC-9 negative grep fails, flagging the contamination. Resolution: revert the shared-file addition; keep protocol self-contained per card.
- **Input boundary — defective test (BAD_TEST_NEEDS_REVISION):** Condition: GREEN sub-agent discovers the test it is implementing against is bad and needs revision. Expected behavior: sub-agent aborts via `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION`, shuffling the test back to the RED phase for revision — it must NOT attempt to implement against the defective test. Resolution: SC-11 classification + shuffle-to-RED routing in green.md; distinct from NO_PURPOSE (defective test) and IMPOSSIBLE (unimplementable SC).

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-18 | SC-6, SC-7, SC-8 evidence type revised from `string + behavioral` to `string + semantic` | Validation finding: these SCs' behavioral verification method is clean-room sub-agent evaluation (sub-agent read + judgment), which is semantic evidence, not behavioral (test execution with output inspection via `opencode run`). Declaring `string + semantic` matches the actual verification method. | Spec validation pipeline |
| 2026-08-18 | Corrected four research-card path references (2 in Dependencies, 2 in Documentation Sources) from `.opencode/.issues/research-cards/` to `.issues/research-cards/` | Validation finding: the two research cards (`per-sc-decomposition-industry-standards.md`, `self-attribution-bias-independent-verification.md`) exist at the root repo path `.issues/research-cards/`, not at `.opencode/.issues/research-cards/`. The cards are not fabricated — the paths were wrong. | Spec validation pipeline |
| 2026-08-18 | Added a new quick-fail GREEN abort classification `BAD_TEST_NEEDS_REVISION` (SC-11, R-12, Item 11). When a GREEN sub-agent discovers the test it is implementing against is defective, it SHALL abort via immediate `status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION`, shuffling the test back to the RED phase for revision — distinct from the existing GREEN abort conditions (NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP). Updated SC-4, R-4, Item 4 to enumerate the five GREEN classifications, added SC-11/R-12/Item 11 with traceability and verification, added a cost frame entry and an edge case. | Revision request: the GREEN abort protocol was missing a quick-fail path for a defective test; the test is defective, not the SC, so the abort shuffles the test back to RED for revision rather than implementing against it. | Revision request (orchestrator) |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
