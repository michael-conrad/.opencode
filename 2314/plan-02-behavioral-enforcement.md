# Phase 2 — behavioral-enforcement

**Concern:** End-to-end behavioral enforcement scenario for the gate.

**Files:**
- `.opencode/tests-v2/test-enforcement.sh` (scenario registration)
- `.opencode/tests-v2/behaviors/` (scenario script)

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: gate routing entries, CRITICAL VIOLATION rule, and PLAN_MISSING vocabulary committed and pushed
- Phase 1 VbC passed

**Exit Conditions:**
- A registered behavioral enforcement scenario demonstrates the gate blocks plan-less dispatch and permits plan-bearing dispatch
- SC-4 verdict recorded with behavioral evidence

**Code Path Coverage:** The enforcement-test harness scenario path — scenario registration in `test-enforcement.sh` and the scenario script under `tests-v2/behaviors/` exercising both legs of the gate contract.

**Cross-Cutting SCs:** None — SC-4 is the consolidated end-to-end demonstration of the SC-2/SC-3 pair.

**Interface Boundaries:** The scenario is consumed by the enforcement test suite CLI (`--scenario <name>`); the gate contract under test is the PLAN_MISSING block/permit decision from Phase 1. No new tool surface.

**State Transitions:** The gate contract moves from "untested end-to-end" to "behaviorally demonstrated" — the scenario asserts the block leg and the permit leg against a real agent run.

**Cost frame:** Running the end-to-end behavioral scenario costs minutes of execution time per leg. Skipping it means the gate's block and permit behavior is verified only by the Phase 1 unit-level runs, and an integration defect between the scenario harness and the gate contract ships undetected — costing the full rework cycle when a future enforcement run silently passes on a broken gate.

---

## Item SC-4 — Behavioral enforcement scenario demonstrates gate (behavioral)

- [ ] 23. **RED (**task-card**).** Dispatch the red task from test-driven-development: run the full RED leg — a real-domain dispatch prompt in which the agent is sent a spec to implement without a plan, with the gate absent or undemonstrated end-to-end; the scenario asserts the blocked outcome and FAILS. **→ SC-4**
- [ ] 24. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: register the scenario in `test-enforcement.sh`; the GREEN run asserts the block-and-permit pair via stderr behavioral evidence — blocked outcome for plan-less dispatch, no block for plan-bearing dispatch. **→ SC-4**
- [ ] 25. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite. **→ SC-4**
- [ ] 26. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-4 with behavioral evidence from the scenario run. **→ SC-4**
- [ ] 27. **Commit (**direct**).** Stage the scenario registration and script, commit test + change as one atomic slice. **→ SC-4**
- [ ] 28. **Push (**direct**).** Push the commit, fresh-fetch, and verify the effective commit is contained in a remote ref — required before the behavioral run. **→ SC-4**
- [ ] 29. **Behavioral run (**task-card**).** Run `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` with timeout ≥600s; assert the block-and-permit pair via stderr behavioral evidence. Structural/grep substitution is prohibited — behavioral evidence only. **→ SC-4**
- [ ] 30. **Verify behavioral run (**task-card**).** Dispatch the verify task from verification-before-completion: record the SC-4 verdict from the behavioral run artifact. **→ SC-4**

## Post-Implementation

- [ ] 31. **Audit (**task-card**).** Dispatch the verification-audit DiMo investigator from audit, reading `audit/tasks/verification-audit-investigator.md` first, followed by validator, evaluator, and arbiter in sequence. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 32. **Z3 check (**direct**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` for phase solvability and dependency-order validation. **→ SC-4**
- [ ] 33. **Structural checks (**task-card**).** Dispatch the checklist task from finishing-a-development-branch: run the finishing checklist (lint, typecheck, markdown checks). **→ SC-1**
- [ ] 34. **Pre-PR gate (**task-card**).** Dispatch the verify task from verification-before-completion: read all SC verdicts; BLOCK if any FAIL — DONE_WITH_CONCERNS coerces to FAIL. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 35. **Regression check (**task-card**).** Dispatch the phase-4 task from test-driven-development: final regression check before PR. **→ SC-4**
- [ ] 36. **Review-prep (**task-card**).** Dispatch review-prep from git-workflow-pr, reading `git-workflow-pr/tasks/review-prep.md` first. **→ SC-4**
- [ ] 37. **Create PR (**task-card**).** Dispatch the create task from git-workflow-pr: create the pull request (stacked strategy, one branch). HALT after creation — the merge is human-only. **→ SC-4**
- [ ] 38. **Executive summary (**task-card**).** Dispatch the completion task from completion-core: generate the completion executive summary. **→ SC-4**

## Phase 2 VbC

- [ ] 39. **VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-4 verdict is PASS with a behavioral evidence artifact and all exit conditions hold.

**Concern transition:** Leaving behavioral enforcement → post-implementation gates. All SCs are covered; the pipeline proceeds to audit and PR creation.
