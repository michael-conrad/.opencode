# Phase 3 — behavioral-run-supervision

**Concern:** Semantic monitoring of this issue's behavioral run legs per tests-v2 §14.

**Files:**
- `.opencode/tests-v2/behaviors/2314-sc2-plan-absent-dispatch-red.sh`
- `.opencode/tests-v2/behaviors/` (sibling 2314 scenario legs, if any)
- `.opencode/.issues/2314/plan-01-dispatch-gate-logic.md` (run-step instruction text)
- `.opencode/.issues/2314/plan-02-behavioral-enforcement.md` (run-step instruction text)

**SCs:** SC-9, SC-10, SC-11, SC-12, SC-13

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 and Phase 2 complete (gate outputs and scenario legs committed and pushed)
- SC-5/SC-6/SC-7/SC-8 behavioral-run regression diagnosed (unmonitored ~59-minute synchronous run) per the spec Root Cause section (root cause 4)

**Exit Conditions:**
- All 2314 scenario leg scripts set `BEHAVIOR_SEMANTIC_MONITOR=1` before `behavior_run` (SC-9)
- Plan run-step instruction text carries a Read-link to tests-v2 §14 (SC-10)
- A supervised run produces §14 monitor evidence recorded alongside session.yaml (SC-11)
- The supervised run's poll intervals are ≤300s with full semantic checks between polls (SC-12)
- Any §14 hard-abort during the supervised run is handled per §14 (SC-13)

**Code Path Coverage:** `helpers.sh` `__semantic_monitor` flag-gated path (`BEHAVIOR_SEMANTIC_MONITOR=1`), the `behavior_run` invocations in the 2314 scenario legs, and the plan-step instruction text consumed by dispatched run sub-agents.

**Cross-Cutting SCs:** None — SC-9 through SC-13 are scoped to run supervision for this issue's scenario legs.

**Interface Boundaries:** The supervised-run contract is the `BEHAVIOR_SEMANTIC_MONITOR=1` environment gate in helpers.sh (already implemented for #2456) and the §14 poll protocol consumed by the run-monitoring agent. No new tool surface.

**State Transitions:** Behavioral runs for this issue's legs move from synchronous unmonitored execution (blind full-timeout burns) to supervised execution with ≤300s poll intervals, full semantic checks between polls, and §14 hard-abort handling.

**Cost frame:** Enabling the monitor costs one environment variable per leg plus cheap SQLite reads per poll. Skipping it means a hung or looping run burns 59+ minutes unmonitored with zero diagnostic yield — the exact regression that triggered this phase.

---

## Item SC-9 — Leg scripts set the monitor flag (structural)

- [ ] 55. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting the 2314 scenario leg scripts do NOT set `BEHAVIOR_SEMANTIC_MONITOR=1` before `behavior_run` — the check FAILS the assertion — RED. **→ SC-9**
- [ ] 56. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: set `BEHAVIOR_SEMANTIC_MONITOR=1` before every `behavior_run` invocation in the 2314 scenario leg scripts. **→ SC-9**
- [ ] 57. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-9 with structural evidence — every 2314 leg script sets the monitor flag before `behavior_run`. **→ SC-9**
- [ ] 58. **Commit (**direct**).** Stage the leg scripts and commit test + change as one atomic slice. **→ SC-9**

## Item SC-10 — Plan run-step text carries the §14 Read-link (structural)

- [ ] 59. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting the plan run-step instruction text (plan-01 steps 25/31, plan-02 steps 39/45) lacks the §14 Read-link — the check FAILS the assertion — RED. **→ SC-10**
- [ ] 60. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: carry the §14 Read-link + poll-protocol text in the plan run-step instructions (steps 25, 31, 39, 45 — already amended by this plan revision). **→ SC-10**
- [ ] 61. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-10 with structural evidence — plan step text carries the §14 Read-link. **→ SC-10**
- [ ] 62. **Commit (**direct**).** Stage the plan files and commit test + change as one atomic slice. **→ SC-10**

## Item SC-11 — Supervised run produces §14 evidence (behavioral)

- [ ] 63. **RED (**task-card**).** Dispatch the red task from test-driven-development: assert that the documented regression run's evidence directory contains NO monitor evidence (`monitor.log`/`determination.yaml`) — the assertion demonstrates the unmonitored path produces no §14 evidence — RED. **→ SC-11**
- [ ] 64. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: execute a supervised monitored run of a 2314 scenario leg (`BEHAVIOR_SEMANTIC_MONITOR=1`) and assert monitor evidence (poll log / `monitor.log` / `determination.yaml`) is recorded alongside `session.yaml` per §14 step 6. **→ SC-11**
- [ ] 65. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-11 with behavioral evidence from the supervised run — monitor artifacts exist in the run evidence directory. **→ SC-11**

## Item SC-12 — Poll-interval compliance (behavioral)

- [ ] 66. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-12 with behavioral evidence from the same supervised run — `monitor.log` poll timestamps show intervals no longer than 300s with full semantic checks of the live session-DB event stream between polls. **→ SC-12**

## Item SC-13 — §14 hard-abort handling (behavioral)

- [ ] 67. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-13 with behavioral evidence — any §14 hard-abort signal during the supervised run is handled per §14 (kill + §10.5 export + recorded semantic diagnosis); an aborted run is not silently retried as unmonitored. **→ SC-13**
- [ ] 68. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite to confirm the env-var addition did not break leg execution. **→ SC-11, SC-12, SC-13**
- [ ] 69. **Commit (**direct**).** Stage any evidence-tracking updates and commit as one atomic slice. **→ SC-11, SC-12, SC-13**
- [ ] 70. **Phase VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-9 through SC-13 verdicts are PASS with evidence-type-matched artifacts and phase exit conditions hold.

**Concern transition:** Leaving behavioral-run supervision → all thirteen SCs covered; the pipeline proceeds to post-implementation gates (audit, PR).

**Read-link mandate:** Any agent executing a behavioral run step in this plan MUST read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching the run.
