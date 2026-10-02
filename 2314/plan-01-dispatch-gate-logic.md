# Phase 1 — dispatch-gate-logic

**Concern:** Gate existence and block/permit behavior at the spec-creation → implementation dispatch boundary.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/tests-v2/behaviors/` (new behavioral scenario legs for SC-5 and SC-6)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps 1-2 complete (coherence gate, baseline check)
- Feature branch created

**Exit Conditions:**
- Gate routing entries in both skill cards, CRITICAL VIOLATION rule, and PLAN_MISSING vocabulary are committed
- Behavioral evidence shows plan-less dispatch blocked with PLAN_MISSING and plan-bearing dispatch permitted
- SC-1..SC-6 verdicts recorded

**Code Path Coverage:** Dispatch-routing paths in the two skill cards at the spec-creation → implementation handoff; the CRITICAL VIOLATION rule body in the core guidelines; the PLAN_MISSING reason-code registration in the dispatch-vocabulary table.

**Cross-Cutting SCs:** None — all six SCs are scoped to the dispatch-gate concern.

**Interface Boundaries:** The gate's observable contract is the PLAN_MISSING reason code and the block/permit decision; downstream consumers are the executing-plans pipeline and the behavioral test suite. No tool or CLI surface changes.

**State Transitions:** Dispatch state at the boundary moves from ungated (proceed always) to gated (proceed only when plan.md exists; otherwise BLOCKED with PLAN_MISSING).

**Cost frame:** Each structural SC costs one file read to verify. The two behavioral legs cost minutes of monitored run time. Skipping them means a gate that over-blocks or under-blocks ships silently — a false-positive block halts every future pipeline at the boundary, and a missing gate lets the bypass defect this spec exists to fix continue costing 1000× more at defect-discovery time.

---

## Item SC-1 — Gate entry in spec-creation SKILL.md (structural)

- [ ] 3. **RED (**task-card**).** Dispatch the red task from test-driven-development: run a structural check asserting the gate routing entry is ABSENT in `.opencode/skills/spec-creation/SKILL.md` at the spec-creation → implementation dispatch boundary. The check FAILS the assertion — RED. **→ SC-1**
- [ ] 4. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: add the gate routing entry to the spec-creation skill card — checks plan.md existence before allowing implementation dispatch, blocks with PLAN_MISSING when absent. Minimum change only. **→ SC-1**
- [ ] 5. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-1 with structural evidence — the gate entry exists and references plan.md existence checking. **→ SC-1**
- [ ] 6. **Commit (**direct**).** Stage the skill card and commit test + change as one atomic slice. **→ SC-1**

## Item SC-2 — Gate routing in executing-plans SKILL.md (structural)

- [ ] 7. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting the gate routing is ABSENT in `.opencode/skills/executing-plans/SKILL.md` — RED. **→ SC-2**
- [ ] 8. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: add the corresponding gate routing entry to the executing-plans skill card. **→ SC-2**
- [ ] 9. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-2 with structural evidence. **→ SC-2**
- [ ] 10. **Commit (**direct**).** Stage the skill card and commit test + change as one atomic slice. **→ SC-2**

## Item SC-3 — CRITICAL VIOLATION entry in 000-critical-rules.md (structural)

- [ ] 11. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting the PLAN_MISSING CRITICAL VIOLATION entry is ABSENT in `.opencode/guidelines/000-critical-rules.md` — RED. **→ SC-3**
- [ ] 12. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: add the PLAN_MISSING CRITICAL VIOLATION (Tier 1) entry to 000-critical-rules.md. **→ SC-3**
- [ ] 13. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-3 with structural evidence. **→ SC-3**
- [ ] 14. **Commit (**direct**).** Stage the guideline and commit test + change as one atomic slice. **→ SC-3**

## Item SC-4 — PLAN_MISSING vocabulary registration (structural)

- [ ] 15. **RED (**task-card**).** Dispatch the red task from test-driven-development: structural check asserting PLAN_MISSING is UNREGISTERED in the canonical dispatch-vocabulary table in `.opencode/reference/skill-card-description-standards.md` — RED. **→ SC-4**
- [ ] 16. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: register PLAN_MISSING as a reason-code vocabulary entry in the dispatch-vocabulary table. **→ SC-4**
- [ ] 17. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-4 with structural evidence. **→ SC-4**
- [ ] 18. **Commit (**direct**).** Stage the reference file and commit test + change as one atomic slice. **→ SC-4**

## Item SC-5 — Plan-less dispatch blocked with PLAN_MISSING (behavioral)

- [ ] 19. **RED (**task-card**).** Dispatch the red task from test-driven-development: create the plan-absent behavioral scenario leg asserting the agent does NOT block an implementation dispatch when no plan exists — RED before the gate takes effect. **→ SC-5**
- [ ] 20. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: the gate text changes from SC-1..SC-4 make a plan-less dispatch block with PLAN_MISSING; adjust the scenario assertion to require the blocked outcome. **→ SC-5**
- [ ] 21. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns. **→ SC-5**
- [ ] 22. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-5 with behavioral evidence — blocked outcome visible in stderr. **→ SC-5**
- [ ] 23. **Commit (**direct**).** Stage the scenario leg and commit test + change as one atomic slice. **→ SC-5**
- [ ] 24. **Push (**direct**).** Push the commit, fresh-fetch, and verify the effective commit is contained in a remote ref — required before the behavioral run. **→ SC-5**
- [ ] 25. **Behavioral run and verify (**task-card**).** Run `bash .opencode/tests-v2/with-test-home opencode run '<plan-absent dispatch prompt>'` with timeout ≥600s under semantic monitoring — export `BEHAVIOR_SEMANTIC_MONITOR=1` before invoking `behavior_run` and follow the §14 semantic poll protocol (poll intervals ≤300s with full semantic checks of the session-DB event stream between polls; abort on §14 hard-abort signals). Read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching this step. Assert the blocked outcome via stderr behavioral evidence, then dispatch the verify task from verification-before-completion to record the SC-5 verdict; EVIDENCE_TYPE_MISMATCH coerces to FAIL. **→ SC-5**

## Item SC-6 — Plan-bearing dispatch proceeds (behavioral)

- [ ] 26. **RED (**task-card**).** Dispatch the red task from test-driven-development: create the plan-present behavioral scenario leg asserting dispatch proceeds without a PLAN_MISSING block — RED while the gate over-blocks or is absent. **→ SC-6**
- [ ] 27. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: the gate change permits plan-bearing dispatch; adjust the scenario assertion to require no PLAN_MISSING block and dispatch proceeding. **→ SC-6**
- [ ] 28. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns. **→ SC-6**
- [ ] 29. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-6 with behavioral evidence — dispatch proceeding visible in stderr. **→ SC-6**
- [ ] 30. **Commit and push (**direct**).** Stage the scenario leg, commit test + change as one atomic slice, push, fresh-fetch, and verify the effective commit is contained in a remote ref. **→ SC-6**
- [ ] 31. **Behavioral run and verify (**task-card**).** Run `bash .opencode/tests-v2/with-test-home opencode run '<plan-present dispatch prompt>'` with timeout ≥600s under semantic monitoring — export `BEHAVIOR_SEMANTIC_MONITOR=1` before invoking `behavior_run` and follow the §14 semantic poll protocol (poll intervals ≤300s with full semantic checks of the session-DB event stream between polls; abort on §14 hard-abort signals). Read [§14 Semantic Continuous Monitoring Mandate (Behavioral Runs)](../tests-v2/AGENTS.md) before dispatching this step. Assert no PLAN_MISSING block via stderr, then dispatch the verify task from verification-before-completion to record the SC-6 verdict. **→ SC-6**

## Phase 1 VbC

- [ ] 32. **VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-1..SC-6 verdicts are PASS with evidence-type-matched artifacts and phase exit conditions hold.

**Concern transition:** Leaving dispatch-gate logic → entering behavioral enforcement. Phase 2 depends on Phase 1's committed gate outputs — its GREEN behavioral runs require the gate to exist.
