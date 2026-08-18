---
plan_schema_version: "1.0"
issue: 2298
title: "TDD RED/GREEN abort protocol for irregular test conditions"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2298 — TDD RED/GREEN Abort Protocol for Irregular Test Conditions

**Goal:** Add a classified-abort terminal state to the `red.md` and `green.md` TDD task cards so a sub-agent that cannot validly produce a failing test or passing implementation returns `status: BLOCKED` with a `blocker_reason` classification instead of looping or forcing an invalid outcome, and add the orchestrator post-abort routing plus a behavioral enforcement test.

**Architecture:** Each task card gains a self-contained abort section enumerating its own classification set and post-abort routing guidance. Abort is defined as task completion, not failure. On abort, the orchestrator dispatches a cold-reading re-evaluation sub-agent that classifies the adjustment substantive vs non-substantive and routes to `spec-creation --task revise` / `writing-plans --task revise`. A retrigger ladder dispatches a re-decomposition evaluation after 2 same-classification aborts. A behavioral enforcement test (ALREADY_GREEN case) verifies the sub-agent returns a classified abort instead of looping.

**Files:**
- `skills/test-driven-development/tasks/red.md`
- `skills/test-driven-development/tasks/green.md`
- `.opencode/tests-v2/behaviors/` (new scenario + fixture)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — RED abort protocol | `test-driven-development` | `red` | `skills/test-driven-development/tasks/red.md` | SC-1, SC-3, SC-5, SC-9 | — |
| 2 — GREEN abort contract | `test-driven-development` | `green` | `skills/test-driven-development/tasks/green.md` | SC-2, SC-4, SC-11 | — |
| 3 — Orchestrator post-abort routing | `test-driven-development` | `green` | `skills/test-driven-development/tasks/red.md`, `skills/test-driven-development/tasks/green.md` | SC-6, SC-7, SC-8 | 1, 2 |
| 4 — Behavioral enforcement test | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/` | SC-10 | 1 |

---

## Phase Details

### Phase 1 — RED abort protocol

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `skills/test-driven-development/tasks/red.md` |
| SCs | SC-1, SC-3, SC-5, SC-9 |
| Depends On | — |

**Context:**
```yaml
target_file: skills/test-driven-development/tasks/red.md
sc_ids: [SC-1, SC-3, SC-5, SC-9]
abort_terminal_state: "status: BLOCKED + blocker_reason classification"
red_classifications:
  - ALREADY_GREEN
  - FALSE_PREMISE
  - NOT_RELEVANT
  - CONFLICT
abort_is_completion: true
forbidden_on_abort:
  - force a failing test
  - modify a test to make it fail
  - loop
self_containment_target: skills/test-driven-development/tasks/operating-protocol.md
self_containment_rule: "abort protocol MUST NOT be shared in operating-protocol.md"
persona_boundary: "RED-phase sub-agents MUST NOT modify src/"
```

### Phase 2 — GREEN abort contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `skills/test-driven-development/tasks/green.md` |
| SCs | SC-2, SC-4, SC-11 |
| Depends On | — |

**Context:**
```yaml
target_file: skills/test-driven-development/tasks/green.md
sc_ids: [SC-2, SC-4, SC-11]
abort_terminal_state: "status: BLOCKED + blocker_reason classification"
green_classifications:
  - NO_PURPOSE
  - IMPOSSIBLE
  - CONFLICT
  - SCOPE_CREEP
  - BAD_TEST_NEEDS_REVISION
abort_is_completion: true
forbidden_on_abort:
  - force an invalid implementation
  - modify a test to make it pass
  - loop
bad_test_routing: "status: BLOCKED, blocker_reason: BAD_TEST_NEEDS_REVISION — shuffle test back to RED for revision"
self_containment_target: skills/test-driven-development/tasks/operating-protocol.md
self_containment_rule: "abort protocol MUST NOT be shared in operating-protocol.md"
persona_boundary: "GREEN-phase sub-agents MUST NOT modify test files"
```

### Phase 3 — Orchestrator post-abort routing

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `skills/test-driven-development/tasks/red.md`, `skills/test-driven-development/tasks/green.md` |
| SCs | SC-6, SC-7, SC-8 |
| Depends On | 1, 2 |

**Context:**
```yaml
target_files:
  - skills/test-driven-development/tasks/red.md
  - skills/test-driven-development/tasks/green.md
sc_ids: [SC-6, SC-7, SC-8]
post_abort_routing: "orchestrator dispatches a cold-reading re-evaluation sub-agent"
reevaluation_targets:
  - "spec-creation --task revise"
  - "writing-plans --task revise"
adjustment_classification:
  substantive: "revokes plan approval, requires re-auth"
  non_substantive: "auto-revise, no re-auth"
retrigger_ladder:
  threshold: 2
  same_classification: true
  action: "dispatch re-decomposition/rework evaluation sub-agent"
  escalate: "spec-audit ONLY if re-decomposition is NOT the fix"
```

### Phase 4 — Behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/` |
| SCs | SC-10 |
| Depends On | 1 |

**Context:**
```yaml
scenario_name: "2298-sc10-already-green"
scenario_prompt: "RED scenario triggering an ALREADY_GREEN-style irregular condition; assert the sub-agent returns a classified abort instead of looping"
test_harness: ".opencode/tests-v2/behaviors/helpers.sh behavior_run"
cleanroom_eval: "session.yaml evaluation asserting classified BLOCKED abort, not a forced/looping test"
depends_on: "Phase-1 red.md abort terminal state"
```

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**clean-room**).** Dispatch `audit --task coherence-maintenance` to verify spec/plan coherence before any file modification. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 2. **Baseline check (**sub-agent**).** Dispatch `test-driven-development --task red` with `mode: pre-regression` to capture current test state. Context: `{issue_number: 2298}`. **All SCs**
- [ ] 3. **Baseline verify (**sub-agent**).** Dispatch `verification-before-completion --task verify` to confirm baseline passes. Context: `{issue_number: 2298}`. **All SCs**

---

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying `red.md` contains the abort terminal state costs one grep plus one behavioral `opencode run`. Skipping means the RED sub-agent keeps looping on irregular conditions, shipping un-reported defects that surface at PR review.
- **SC-2:** Verifying `green.md` contains the abort terminal state costs one grep plus one behavioral `opencode run`. Skipping means the GREEN sub-agent forces invalid implementations to pass, and those semantic defects surface downstream at verification.
- **SC-3:** Verifying `red.md` enumerates the four RED classifications costs one grep. Skipping means the sub-agent lacks a controlled classification vocabulary and reports unstructured blockers the orchestrator cannot route.
- **SC-4:** Verifying `green.md` enumerates the five GREEN classifications costs one grep. Skipping means SCOPE_CREEP and BAD_TEST_NEEDS_REVISION aborts are unclassifiable, defeating the routing ladder.
- **SC-5:** Verifying abort-is-completion normative language costs one grep per card. Skipping means the sub-agent frames abort as failure, re-triggering the force-or-loop behavior this spec eliminates.
- **SC-6:** Verifying orchestrator re-evaluation routing costs one grep plus clean-room evaluation. Skipping means the orchestrator re-tasks RED/GREEN blindly without adjusting the SC, and the abort retriggers indefinitely.
- **SC-7:** Verifying substantive/non-substantive classification costs one grep plus clean-room evaluation. Skipping means substantive adjustments silently skip re-authorization, violating the approval gate.
- **SC-8:** Verifying the retrigger ladder costs one grep plus clean-room evaluation. Skipping means the pipeline escalates to spec-audit too early or re-decomposes without authority.
- **SC-9:** Verifying per-card self-containment costs two greps (presence) plus one negative grep (absence in operating-protocol.md). Skipping means the abort protocol leaks into a shared file and loses role-customization.
- **SC-10:** Running the behavioral test costs minutes of `opencode run` execution. Skipping means the classified-abort behavior is never verified against a real model, and the defect ships to production at 1000× the cost.
- **SC-11:** Verifying `green.md` defines the BAD_TEST_NEEDS_REVISION shuffle-to-RED abort costs one grep plus one behavioral `opencode run`. Skipping means the GREEN sub-agent implements against a defective test, and the resulting semantic defect ships downstream to verification at 1000× the cost.

---

## Exit Criteria

- [ ] C1. `red.md` defines a classified ABORT terminal state (`status: BLOCKED` + `blocker_reason`)
- [ ] C2. `green.md` defines a classified ABORT terminal state (`status: BLOCKED` + `blocker_reason`)
- [ ] C3. `red.md` enumerates ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT
- [ ] C4. `green.md` enumerates NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP, BAD_TEST_NEEDS_REVISION
- [ ] C5. Both cards state abort-is-completion; forbid forcing, test-modification-to-fail, and looping
- [ ] C6. Both cards contain post-abort routing to a cold-reading re-evaluation sub-agent → `spec-creation --task revise` / `writing-plans --task revise`
- [ ] C7. Both cards contain substantive vs non-substantive classification guidance
- [ ] C8. Both cards contain the retrigger ladder (2 same-classification aborts → re-decomposition evaluation; spec-audit only if not the fix)
- [ ] C9. Abort protocol self-contained in `red.md` and `green.md`; absent from `operating-protocol.md`
- [ ] C10. Behavioral enforcement test exists (ALREADY_GREEN case) asserting a classified abort, not a loop
- [ ] C11. `green.md` defines BAD_TEST_NEEDS_REVISION with shuffle-to-RED routing
