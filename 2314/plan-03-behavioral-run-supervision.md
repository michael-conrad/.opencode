# Phase 3 — behavioral-run-supervision

**Concern:** Semantic monitoring of this issue's behavioral run legs per tests-v2 §14.

**Files:**
- `.opencode/tests-v2/behaviors/2314-sc2-plan-absent-dispatch-red.sh`
- `.opencode/tests-v2/behaviors/` (sibling 2314 scenario legs, if any)
- `.opencode/.issues/2314/plan-01-dispatch-gate-logic.md` (run-step instruction text)
- `.opencode/.issues/2314/plan-02-behavioral-enforcement.md` (run-step instruction text)

**SCs:** SC-9, SC-10

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 and Phase 2 complete (gate outputs and scenario legs committed and pushed)
- SC-5/SC-6/SC-7/SC-8 behavioral-run regression diagnosed (unmonitored ~59-minute synchronous run) per the spec Root Cause section (root cause 4)

**Exit Conditions:**
- All 2314 scenario leg scripts set `BEHAVIOR_SEMANTIC_MONITOR=1` before `behavior_run` (SC-9)
- Plan run-step instruction text carries a Read-link to tests-v2 §14 (SC-9)
- A supervised run produces §14 monitor evidence recorded alongside session.yaml (SC-10)

**Code Path Coverage:** `helpers.sh` `__semantic_monitor` flag-gated path (`BEHAVIOR_SEMANTIC_MONITOR=1`), the `behavior_run` invocations in the 2314 scenario legs, and the plan-step instruction text consumed by dispatched run sub-agents.

**Cross-Cutting SCs:** None — SC-9/SC-10 are scoped to run supervision for this issue's scenario legs.

**Interface Boundaries:** The supervised-run contract is the `BEHAVIOR_SEMANTIC_MONITOR=1` environment gate in helpers.sh (already implemented for #2456) and the §14 poll protocol consumed by the run-monitoring agent. No new tool surface.

**State Transitions:** Behavioral runs for this issue's legs move from synchronous unmonitored execution (blind full-timeout burns) to supervised execution with ≤300s poll intervals, full semantic checks between polls, and §14 hard-abort handling.

**Cost frame:** Enabling the monitor costs one environment variable per leg plus cheap SQLite reads per poll. Skipping it means a hung or looping run burns 59+ minutes unmonitored with zero diagnostic yield — the exact regression that triggered this phase.

---

## Item SC-9 — Supervision configuration mandated (structural)

- [ ] 55. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting the 2314 scenario leg scripts do NOT set `BEHAVIOR_SEMANTIC_MONITOR=1` before `behavior_run`, and that the plan run-step text lacks the §14 Read-link — the check FAILS the assertion — RED. **→ SC-9**
- [ ] 56. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: set `BEHAVIOR_SEMANTIC_MONITOR=1` before every `behavior_run` invocation in the 2314 scenario leg scripts, and carry the §14 Read-link + poll-protocol text in the plan run-step instructions (steps 25, 31, 39, 45 — already amended by this plan revision). **→ SC-9**
- [ ] 57. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-9 with structural evidence — leg scripts set the monitor flag; plan step text carries the §14 Read-link. **→ SC-9**
- [ ] 58. **Commit (**direct**).** Stage the leg scripts and commit test + change as one atomic slice. **→ SC-9**

## Item SC-10 — Supervised run produces §14 evidence (behavioral)

- [ ] 59. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite to confirm the env-var addition did not break leg execution. **→ SC-10**
- [ ] 60. **Verify monitored run (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-10 with behavioral evidence — a supervised run of a 2314 leg produces monitor evidence (poll log / `monitor.log` / `determination.yaml`) recorded alongside session.yaml per §14 step 6, with poll intervals ≤300s and any hard-abort handled per §14 (kill + §10.5 export + recorded semantic diagnosis). **→ SC-10**
- [ ] 61. **Commit (**direct**).** Stage any evidence-tracking updates and commit as one atomic slice. **→ SC-10**
- [ ] 62. **Phase VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-9 and SC-10 verdicts are PASS with evidence-type-matched artifacts and phase exit conditions hold.

**Concern transition:** Leaving behavioral-run supervision → all ten SCs covered; the pipeline proceeds to post-implementation gates (audit, PR).

**Read-link mandate:** Any agent executing a behavioral run step in this plan MUST read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching the run.
