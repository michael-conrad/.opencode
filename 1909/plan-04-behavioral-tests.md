# Phase 04 — Behavioral Tests

**Concern:** Add behavioral enforcement test verifying agent dispatches 4-role chain, not monolithic sub-agent

**Files:**
- `.opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — new behavioral test

**SCs:** SC-8, SC-11

**Dependencies:** Phase 3 (monolithic files removed, DiMo chain is the only dispatch path)

**Entry conditions:** Phase 3 complete, DiMo chain is the only dispatch path

**Exit conditions:** Behavioral test passes for 4-role chain dispatch, anti-lobotomization test passes

## Code Path Coverage

- `.opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — new behavioral enforcement test

## Cross-Cutting SCs

- DiMo 4-role chain dispatch (all phases)
- Clean-room sub-agent separation (Phases 2 and 4)
- Behavioral test integrity (Phase 4 only)

## Interface Boundaries

- `.opencode/tests/behaviors/` — new test, internal only

## State Transitions

- No behavioral test for 4-role chain dispatch → behavioral test exists and passes
- No anti-lobotomization behavioral test → anti-lobotomization test exists and passes

## Steps

- [ ] 68. **RED — Write behavioral test for SC-8 (**sub-agent**).** `task(..., prompt: "Create .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh. This behavioral enforcement test must: 1) Send a prompt to the agent that triggers an audit dispatch (e.g., 'audit spec #1909'), 2) Use assert_semantic to verify the agent dispatched 4 separate task() calls (Generator, Knowledge Supporter, Evaluator, Path Provider) rather than 1 monolithic sub-agent, 3) Use assert_stderr_pattern_present as secondary corroboration for the 4 task() dispatch strings. Follow the behavioral test template from .opencode/tests/behaviors/helpers.sh. The test must FAIL at this point (RED phase) because the DiMo chain is not yet verified.")` **→ SC-8**

- [ ] 69. **Run RED test (**inline**).** `bash .opencode/tests/with-test-home .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — must FAIL (RED phase). **→ SC-8**

- [ ] 70. **GREEN — Verify SC-8 passes (**inline**).** `bash .opencode/tests/with-test-home .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — must PASS. If the test was RED in step 69 and the implementation is correct, it should now PASS. If it still fails, diagnose and remediate. **→ SC-8**

- [ ] 71. **RED — Write behavioral test for SC-11 (**sub-agent**).** `task(..., prompt: "Add an SC-11 anti-lobotomization assertion to .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh. This assertion must verify that the agent does NOT weaken behavioral SC-8 to structural/string evidence. Use assert_semantic to verify the agent does not claim 'file exists' as evidence for behavioral dispatch behavior. The test must FAIL at this point (RED phase).")` **→ SC-11**

- [ ] 72. **Run RED test for SC-11 (**inline**).** `bash .opencode/tests/with-test-home .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — must FAIL for SC-11 (RED phase). **→ SC-11**

- [ ] 73. **GREEN — Verify SC-11 passes (**inline**).** `bash .opencode/tests/with-test-home .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh` — must PASS for both SC-8 and SC-11. **→ SC-11**

- [ ] 74. **Run content-verification tests (**inline**).** `bash .opencode/tests/test-enforcement.sh --tag audit` — verify all content-verification tests pass. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-9, SC-10**

- [ ] 75. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/audit-dimo-4role-dispatch.sh && git commit -m "Phase 4: Add behavioral enforcement test for DiMo 4-role chain dispatch"` **→ SC-8, SC-11**

#### Phase 4 VbC

- [ ] 75. **VbC (**clean-room**).** Verify SC-8 (behavioral test passes for 4-role chain dispatch), SC-11 (anti-lobotomization test passes). Evidence type: behavioral. After artifact generation, dispatch `behavioral-test-evaluation` before allowing PASS verdict. **→ SC-8, SC-11**

**Concern transition:** Leaving behavioral test verification → plan complete. All 4 phases done.
