# Phase 2 — behavioral-enforcement

**Concern:** End-to-end behavioral enforcement scenario for the gate — block leg and permit leg demonstrated separately.

**Files:**
- `.opencode/tests-v2/test-enforcement.sh` (scenario registration)
- `.opencode/tests-v2/behaviors/` (scenario script)

**SCs:** SC-7, SC-8

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: gate routing entries, CRITICAL VIOLATION rule, and PLAN_MISSING vocabulary committed and pushed
- Phase 1 VbC passed

**Exit Conditions:**
- A registered behavioral enforcement scenario demonstrates the gate blocks plan-less dispatch end-to-end (SC-7) and permits plan-bearing dispatch end-to-end (SC-8)
- SC-7 and SC-8 verdicts recorded with behavioral evidence

**Code Path Coverage:** The enforcement-test harness scenario path — scenario registration in `test-enforcement.sh` and the scenario script under `tests-v2/behaviors/` exercising both legs of the gate contract.

**Cross-Cutting SCs:** None — SC-7 and SC-8 are the end-to-end demonstrations of the SC-5/SC-6 pair.

**Interface Boundaries:** The scenario is consumed by the enforcement test suite CLI (`--scenario <name>`); the gate contract under test is the PLAN_MISSING block/permit decision from Phase 1. No new tool surface.

**State Transitions:** The gate contract moves from "untested end-to-end" to "behaviorally demonstrated" — the scenario asserts the block leg and the permit leg against a real agent run, with each leg asserted independently.

**Cost frame:** Running each end-to-end leg costs minutes of monitored execution time. Skipping them means the gate's block and permit behavior is verified only by the Phase 1 unit-level runs, and an integration defect between the scenario harness and the gate contract ships undetected — costing the full rework cycle when a future enforcement run silently passes on a broken gate.

---

## Item SC-7 — Scenario block leg end-to-end (behavioral)

- [ ] 33. **RED (**task-card**).** Dispatch the red task from test-driven-development: run the block-leg RED run — a real-domain dispatch prompt in which the agent is sent a spec to implement without a plan, with the gate absent or undemonstrated end-to-end; the scenario asserts the blocked outcome and FAILS. **→ SC-7**
- [ ] 34. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: register the scenario in `test-enforcement.sh`; the GREEN run asserts the block leg via stderr behavioral evidence — blocked outcome for plan-less dispatch. **→ SC-7**
- [ ] 35. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite. **→ SC-7**
- [ ] 36. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-7 with behavioral evidence from the block-leg scenario run. **→ SC-7**
- [ ] 37. **Commit (**direct**).** Stage the scenario registration and script, commit test + change as one atomic slice. **→ SC-7**
- [ ] 38. **Push (**direct**).** Push the commit, fresh-fetch, and verify the effective commit is contained in a remote ref — required before the behavioral run. **→ SC-7**
- [ ] 39. **Behavioral run and verify (**task-card**).** Run `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` (block leg) with timeout ≥600s under semantic monitoring — export `BEHAVIOR_SEMANTIC_MONITOR=1` before the run and follow the §14 semantic poll protocol (poll intervals ≤300s with full semantic checks of the session-DB event stream between polls; abort on §14 hard-abort signals). Read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching this step. Assert the blocked outcome via stderr behavioral evidence, then dispatch the verify task from verification-before-completion to record the SC-7 verdict. Structural/grep substitution is prohibited — behavioral evidence only. **→ SC-7**

## Item SC-8 — Scenario permit leg end-to-end (behavioral)

- [ ] 40. **RED (**task-card**).** Dispatch the red task from test-driven-development: run the permit-leg RED run — a plan-bearing dispatch assertion with the gate absent or undemonstrated end-to-end; the scenario asserts dispatch proceeds and FAILS while undemonstrated. **→ SC-8**
- [ ] 41. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: extend the registered scenario's GREEN run to assert the permit leg via stderr behavioral evidence — no block for plan-bearing dispatch. **→ SC-8**
- [ ] 42. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite. **→ SC-8**
- [ ] 43. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-8 with behavioral evidence from the permit-leg scenario run. **→ SC-8**
- [ ] 44. **Commit and push (**direct**).** Stage the scenario updates, commit test + change as one atomic slice, push, fresh-fetch, and verify the effective commit is contained in a remote ref. **→ SC-8**
- [ ] 45. **Behavioral run and verify (**task-card**).** Run `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` (permit leg) with timeout ≥600s under semantic monitoring — export `BEHAVIOR_SEMANTIC_MONITOR=1` before the run and follow the §14 semantic poll protocol. Read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching this step. Assert no PLAN_MISSING block via stderr behavioral evidence, then dispatch the verify task from verification-before-completion to record the SC-8 verdict. **→ SC-8**

## Post-Implementation

- [ ] 46. **Audit (**task-card**).** Dispatch the verification-audit DiMo investigator from audit, reading `audit/tasks/verification-audit-investigator.md` first, followed by validator, evaluator, and arbiter in sequence. **→ SC-1..SC-8**
- [ ] 47. **Z3 check (**direct**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` for phase solvability and dependency-order validation. **→ SC-8**
- [ ] 48. **Structural checks (**task-card**).** Dispatch the checklist task from finishing-a-development-branch: run the finishing checklist (lint, typecheck, markdown checks). **→ SC-1**
- [ ] 49. **Pre-PR gate (**task-card**).** Dispatch the verify task from verification-before-completion: read all SC verdicts; BLOCK if any FAIL — DONE_WITH_CONCERNS coerces to FAIL. **→ SC-1..SC-8**
- [ ] 50. **Regression check (**task-card**).** Dispatch the phase-4 task from test-driven-development: final regression check before PR. **→ SC-8**
- [ ] 51. **Review-prep (**task-card**).** Dispatch review-prep from git-workflow-pr, reading `git-workflow-pr/tasks/review-prep.md` first. **→ SC-8**
- [ ] 52. **Create PR (**task-card**).** Dispatch the create task from git-workflow-pr: create the pull request (stacked strategy, one branch). HALT after creation — the merge is human-only. **→ SC-8**
- [ ] 53. **Executive summary (**task-card**).** Dispatch the completion task from completion-core: generate the completion executive summary. **→ SC-8**

## Phase 2 VbC

- [ ] 54. **VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-7 and SC-8 verdicts are PASS with behavioral evidence artifacts and all exit conditions hold.

**Concern transition:** Leaving behavioral enforcement → post-implementation gates. All SCs are covered; the pipeline proceeds to audit and PR creation.
