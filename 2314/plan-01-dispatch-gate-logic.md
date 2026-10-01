# Phase 1 — dispatch-gate-logic

**Concern:** Gate existence and block/permit behavior at the spec-creation → implementation dispatch boundary.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/tests-v2/behaviors/` (new behavioral scenario legs for SC-2 and SC-3)

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Pre-implementation steps 1-2 complete (coherence gate, baseline check)
- Feature branch created

**Exit Conditions:**
- Gate routing entries, CRITICAL VIOLATION rule, and PLAN_MISSING vocabulary are committed
- Behavioral evidence shows plan-less dispatch blocked with PLAN_MISSING and plan-bearing dispatch permitted
- SC-1, SC-2, SC-3 verdicts recorded

**Code Path Coverage:** Dispatch-routing paths in the two skill cards at the spec-creation → implementation handoff; the CRITICAL VIOLATION rule body in the core guidelines; the PLAN_MISSING reason-code registration in the dispatch-vocabulary table.

**Cross-Cutting SCs:** None — all three SCs are scoped to the dispatch-gate concern.

**Interface Boundaries:** The gate's observable contract is the PLAN_MISSING reason code and the block/permit decision; downstream consumers are the executing-plans pipeline and the behavioral test suite. No tool or CLI surface changes.

**State Transitions:** Dispatch state at the boundary moves from ungated (proceed always) to gated (proceed only when plan.md exists; otherwise BLOCKED with PLAN_MISSING).

**Cost frame:** Running the behavioral gate tests costs minutes of execution time. Skipping them means a gate that over-blocks or under-blocks ships silently — a false-positive block halts every future pipeline at the boundary, and a missing gate lets the bypass defect this spec exists to fix continue costing 1000× more at defect-discovery time.

---

## Item SC-1 — Gate exists at the boundary (structural)

- [ ] 3. **RED (**task-card**).** Dispatch the red task from test-driven-development: run a structural check (grep/read) asserting the gate routing entries are ABSENT in the four deck surfaces — spec-creation SKILL.md, executing-plans SKILL.md, the 000-critical-rules.md CRITICAL VIOLATION section, and the PLAN_MISSING vocabulary registration. The check FAILS the assertion (gate absent) — RED. **→ SC-1**
- [ ] 4. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: add the gate routing entries — spec-creation → implementation dispatch boundary entry in the spec-creation skill card, the corresponding entry in the executing-plans skill card, the PLAN_MISSING CRITICAL VIOLATION entry in 000-critical-rules.md, and the PLAN_MISSING reason-code registration in the canonical dispatch-vocabulary table. Minimum change only — no scope creep. **→ SC-1**
- [ ] 5. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns to confirm no existing enforcement scenario regressed from the deck edits. **→ SC-1**
- [ ] 6. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-1 with structural evidence — the four gate surfaces exist and reference plan.md existence checking. **→ SC-1**
- [ ] 7. **Commit (**direct**).** Stage the four deck files and commit test + change as one atomic slice. No co-author trailers at implementation time. **→ SC-1**

## Item SC-2 — Plan-less dispatch blocked with PLAN_MISSING (behavioral)

- [ ] 8. **RED (**task-card**).** Dispatch the red task from test-driven-development: create the plan-absent behavioral scenario leg asserting the agent does NOT block an implementation dispatch when no plan exists — RED before the gate takes effect. **→ SC-2**
- [ ] 9. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: the gate text change from SC-1 makes a plan-less dispatch block with PLAN_MISSING; adjust the scenario assertion to require the blocked outcome. **→ SC-2**
- [ ] 10. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns. **→ SC-2**
- [ ] 11. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-2 with behavioral evidence — blocked outcome visible in stderr. **→ SC-2**
- [ ] 12. **Commit (**direct**).** Stage the scenario leg and commit test + change as one atomic slice. **→ SC-2**
- [ ] 13. **Push (**direct**).** Push the commit, fresh-fetch, and verify the effective commit is contained in a remote ref — required before the behavioral run. **→ SC-2**
- [ ] 14. **Behavioral run (**task-card**).** Run `bash .opencode/tests-v2/with-test-home opencode run '<plan-absent dispatch prompt>'` with timeout ≥600s; assert the blocked outcome via stderr behavioral evidence. **→ SC-2**
- [ ] 15. **Verify behavioral run (**task-card**).** Dispatch the verify task from verification-before-completion: record the SC-2 verdict from the behavioral run artifact; EVIDENCE_TYPE_MISMATCH coerces to FAIL. **→ SC-2**

## Item SC-3 — Plan-bearing dispatch proceeds (behavioral)

- [ ] 16. **RED (**task-card**).** Dispatch the red task from test-driven-development: create the plan-present behavioral scenario leg asserting dispatch proceeds without a PLAN_MISSING block — RED while the gate over-blocks or is absent. **→ SC-3**
- [ ] 17. **GREEN (**task-card**).** Dispatch the green task from test-driven-development: the gate change permits plan-bearing dispatch; adjust the scenario assertion to require no PLAN_MISSING block and dispatch proceeding. **→ SC-3**
- [ ] 18. **Post-regression (**task-card**).** Dispatch the phase-4 task from test-driven-development: run regression test patterns. **→ SC-3**
- [ ] 19. **Verify (**task-card**).** Dispatch the verify task from verification-before-completion: verify SC-3 with behavioral evidence — dispatch proceeding visible in stderr. **→ SC-3**
- [ ] 20. **Commit and push (**direct**).** Stage the scenario leg, commit test + change as one atomic slice, push, fresh-fetch, and verify the effective commit is contained in a remote ref. **→ SC-3**
- [ ] 21. **Behavioral run and verify (**task-card**).** Run `bash .opencode/tests-v2/with-test-home opencode run '<plan-present dispatch prompt>'` with timeout ≥600s, assert no PLAN_MISSING block via stderr, then dispatch the verify task from verification-before-completion to record the SC-3 verdict. **→ SC-3**

## Phase 1 VbC

- [ ] 22. **VbC (**task-card**).** Dispatch the verify task from verification-before-completion: assert SC-1/SC-2/SC-3 verdicts are PASS with evidence-type-matched artifacts and phase exit conditions hold.

**Concern transition:** Leaving dispatch-gate logic → entering behavioral enforcement. Phase 2 depends on Phase 1's committed gate outputs — its GREEN behavioral run requires the gate to exist.
