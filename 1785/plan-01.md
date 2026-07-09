# Phase 1 — Core audit dispatch

- **Concern:** 6 behavioral tests verifying unified invocation, cleanroom dispatch, consensus gate (PASS/FAIL/DISAGREE), and multi-type invocation
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc1-audit-unified-invocation.sh`
  - `.opencode/tests/behaviors/NEW-sc2-audit-cleanroom-dispatch.sh`
  - `.opencode/tests/behaviors/NEW-sc3-audit-consensus-pass.sh`
  - `.opencode/tests/behaviors/NEW-sc4-audit-consensus-fail.sh`
  - `.opencode/tests/behaviors/NEW-sc5-audit-consensus-disagree.sh`
  - `.opencode/tests/behaviors/NEW-sc6-audit-multi-type.sh`
- **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
- **Dependencies:** None
- **Entry conditions:** Feature branch created, spec approved
- **Exit conditions:** 6 behavioral test scripts exist, each passes individually

## Step-by-step

- [ ] 1. **Pre-work (**sub-agent**).** Create feature branch `feature/1785-audit-invocation-verification`. Run `git-workflow --task pre-work` with issue #1785. Verify submodule is on `dev`. **→ SC-all**
- [ ] 2. **Coherence gate (**clean-room**).** Dispatch `pre-analysis` sub-agent to read spec #1785 and verify the 6 core dispatch scenarios are coherent with existing `audit` skill structure. Check that `audit/SKILL.md` §Blind Dispatch and `audit/tasks/` files support the dispatch patterns these tests will verify. Return BLOCKED if contradictions found. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 3. **Pre-RED baseline (**inline**).** Run `bash .opencode/tests/behaviors/helpers.sh` to verify test infrastructure loads. Run `ls .opencode/tests/behaviors/` to confirm existing test patterns. **→ SC-all**
- [ ] 4. **RED: SC-1 unified invocation test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc1-audit-unified-invocation.sh` as artifact-only generator. Test sends prompt triggering `skill({name: "audit"})` with `--task spec-audit`. Uses `behavior_run`. Annotate with `# SC-1:`. Verify test FAILS (no implementation yet). **→ SC-1**
- [ ] 5. **GREEN: SC-1 implementation (**sub-agent**).** No code change needed — SC-1 tests existing behavior. Verify test PASSES by running `bash .opencode/tests/behaviors/NEW-sc1-audit-unified-invocation.sh`. **→ SC-1**
- [ ] 6. **RED: SC-2 cleanroom dispatch test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc2-audit-cleanroom-dispatch.sh`. Test verifies scan sub-agent receives NO verifier context, no preloaded findings, no orchestrator reasoning. Uses `behavior_run`. Annotate with `# SC-2:`. Verify FAILS. **→ SC-2**
- [ ] 7. **GREEN: SC-2 implementation (**sub-agent**).** No code change needed — SC-2 tests existing behavior. Verify PASSES. **→ SC-2**
- [ ] 8. **RED: SC-3 consensus PASS test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc3-audit-consensus-pass.sh`. Test verifies both auditors agree → verdict confirmed. Uses `behavior_run`. Annotate with `# SC-3:`. Verify FAILS. **→ SC-3**
- [ ] 9. **GREEN: SC-3 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-3**
- [ ] 10. **RED: SC-4 consensus FAIL test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc4-audit-consensus-fail.sh`. Test verifies any auditor returns FAIL → hard FAIL with remediation routing. Uses `behavior_run`. Annotate with `# SC-4:`. Verify FAILS. **→ SC-4**
- [ ] 11. **GREEN: SC-4 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-4**
- [ ] 12. **RED: SC-5 consensus DISAGREE test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc5-audit-consensus-disagree.sh`. Test verifies auditors diverge → revision options presented, not silent correction. Uses `behavior_run`. Annotate with `# SC-5:`. Verify FAILS. **→ SC-5**
- [ ] 13. **GREEN: SC-5 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-5**
- [ ] 14. **RED: SC-6 multi-type invocation test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc6-audit-multi-type.sh`. Test verifies `--type spec-audit,plan-fidelity` produces dual audit result with separate verdicts. Uses `behavior_run`. Annotate with `# SC-6:`. Verify FAILS. **→ SC-6**
- [ ] 15. **GREEN: SC-6 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-6**
- [ ] 16. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/NEW-sc1-audit-unified-invocation.sh .opencode/tests/behaviors/NEW-sc2-audit-cleanroom-dispatch.sh .opencode/tests/behaviors/NEW-sc3-audit-consensus-pass.sh .opencode/tests/behaviors/NEW-sc4-audit-consensus-fail.sh .opencode/tests/behaviors/NEW-sc5-audit-consensus-disagree.sh .opencode/tests/behaviors/NEW-sc6-audit-multi-type.sh && git commit -m "Phase 1: 6 core audit dispatch behavioral tests (SC-1 through SC-6)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-1-opencode`. **→ SC-all**

#### Phase 1 VbC

- [ ] **VbC (**clean-room**).** Verify all 6 test scripts exist, each is artifact-only (exit 0, uses `behavior_run`), each has `# SC-N:` annotations. Run each test individually and confirm PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

**Concern transition:** Leaving core audit dispatch → entering pipeline touchpoints. Phase 2 depends on Phase 1 establishing the test infrastructure pattern.
