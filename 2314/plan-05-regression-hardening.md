# Phase 5 — regression-hardening

**Concern:** Closure of the two SC-5 attempt-5 regressions: absolute §14-monitor termination bound (root cause 6) and fixture issue-store sandbox (root cause 7).

**Files:**
- `.opencode/tests-v2/helpers.sh` (monitor loop termination condition)
- `.opencode/tests-v2/AGENTS.md` (§14 mandate documentation)
- `.opencode/tests-v2/behaviors/2314-sc2-plan-absent-dispatch-red.sh` (fixture setup)
- `.opencode/tests-v2/behaviors/` (sibling 2314 scenario fixture setup, if any)

**SCs:** SC-18, SC-19

**Dependencies:** Phase 3, Phase 4

**Entry Conditions:**
- Phase 3 complete (supervised-run infrastructure in place — the bound is proven against a monitored run)
- Phase 4 complete (bypass-path gates committed and pushed)
- Evidence reviewed: `tmp/behavior-test-20261002-062454/2314-sc2-plan-absent-dispatch-red/monitor-attempt1.log` (root cause 6) and the poll event stream showing the real-issue task dispatch (root cause 7)

**Exit Conditions:**
- The §14 monitor enforces an absolute termination bound (wall-clock deadline and/or hard max-polls ceiling via a documented env knob) that terminates a progressing-directionally-classified run with a `terminate-with-root-cause` terminal classification; suppression rules cannot defeat the bound (SC-18)
- The bound and env knob are documented in `tests-v2/AGENTS.md` §14 (SC-18 supporting method step)
- The 2314 scenario fixtures sandbox issue-store access — the run agent reaches only the injected fixture issue data and never real `{issues_prefix}/{N}/` data (SC-19)

**Code Path Coverage:** `helpers.sh` monitor loop termination logic (max-polls / wall-clock checks currently subordinate to the R-2 classification), the §14 mandate text consumed by run-monitoring agents, and the fixture setup consumed by the 2314 scenario legs.

**Cross-Cutting SCs:** None — SC-18 and SC-19 are scoped to the §14 monitor bound and this issue's fixture setup.

**Interface Boundaries:** The env knob is additive (documented default is bounded, never unbounded); suppression-rule semantics (R-2 deferral) are unchanged — the bound composes AFTER suppression, not instead of it. The fixture sandbox changes no leg-script interface; it constrains what the run agent inside the test can reach.

**State Transitions:** Monitor runs move from "polling may continue indefinitely for progressing runs (no terminal bound)" to "absolute bound terminates any run past the deadline/polls ceiling with a terminal classification". Behavioral runs move from "run agent can reach the real issue store" to "run agent is confined to the injected fixture store".

**Cost frame:** One monitor-loop change plus one env-knob documentation edit, plus fixture sandboxing and a behavioral run whose session evidence is inspected. Skipping it recreates the attempt-5 regression: ~5-hour supervision burns with no terminal verdict and fixture-escaped pseudo-progress contaminating the evidence.

---

## Item SC-18 — Absolute monitor termination bound (behavioral)

- [ ] 89. **Baseline (direct).** Confirm Phase 3 and Phase 4 deliverables are committed and pushed; confirm the effective commit is contained in a remote ref.
- [ ] 90. **RED (task-card).** Dispatch the red task from test-driven-development: behavioral check demonstrating the current monitor has no absolute bound — a supervised run whose classification is `progressing-directionally` past the max-polls budget continues polling and completes without a terminal classification (reproduces the attempt-5 monitor-log behavior at reduced scale). **→ SC-18**
- [ ] 91. **GREEN (task-card).** Dispatch the green task from test-driven-development: add the absolute termination bound to the `helpers.sh` monitor loop — wall-clock deadline and hard max-polls ceiling via documented env knob(s); when the bound is exceeded the monitor terminates the run and records the `terminate-with-root-cause` terminal classification in the monitor artifacts regardless of the run's latest classification; document the bound and knob in `tests-v2/AGENTS.md` §14. **→ SC-18**
- [ ] 92. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-18 with behavioral evidence — a controlled test invocation drives a supervised run past the bound while classifying `progressing-directionally`; monitor.log/determination.yaml record the termination with the `terminate-with-root-cause` classification; §14 documents the env knob. **→ SC-18**
- [ ] 93. **Commit (direct).** Stage the monitor change, §14 documentation, and test; commit as one atomic slice. **→ SC-18**

## Item SC-19 — Fixture issue-store sandbox (behavioral)

- [ ] 94. **RED (task-card).** Dispatch the red task from test-driven-development: behavioral check demonstrating the current fixture does not sandbox issue-store access — the run agent in a 2314 leg can read real issue-store data (reproduces the attempt-5 escape at reduced scale). **→ SC-19**
- [ ] 95. **GREEN (task-card).** Dispatch the green task from test-driven-development: sandbox issue-store access in the 2314 scenario fixture setup — the run agent can reach only the injected fixture issue data; real `{issues_prefix}/{N}/` paths outside the fixture are isolated from the run agent. **→ SC-19**
- [ ] 96. **Verify (task-card).** Dispatch the verify task from verification-before-completion: verify SC-19 with behavioral evidence — fixture-setup inspection asserts isolation is established, and the run's session evidence (session.yaml / monitor event stream) shows no read/write of real issue-store paths outside the fixture. **→ SC-19**
- [ ] 97. **Post-regression (task-card).** Dispatch the phase-4 task from test-driven-development: run regression test patterns across the enforcement suite to confirm the monitor bound and fixture sandbox did not break leg execution. **→ SC-18, SC-19**
- [ ] 98. **Commit (direct).** Stage the fixture sandbox and test; commit as one atomic slice. **→ SC-19**
- [ ] 99. **Phase VbC (task-card).** Dispatch the verify task from verification-before-completion: assert SC-18 and SC-19 verdicts are PASS with evidence-type-matched artifacts and phase exit conditions hold.
- [ ] 100. **Push (direct).** Push the phase commits; fresh-fetch and verify the effective commit is contained in a remote ref before any subsequent behavioral run.

**Concern transition:** Leaving regression-hardening → all nineteen SCs covered; the pipeline proceeds to post-implementation gates (audit, PR).

**Read-link mandate:** Any agent executing a behavioral run step in this plan MUST read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../../tests-v2/AGENTS.md) before dispatching the run.
