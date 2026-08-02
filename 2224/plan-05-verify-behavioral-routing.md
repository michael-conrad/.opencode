# Phase 5 — Verify Behavioral Routing

**Concern:** Verify that agent intent matching routes "verify plan pipeline" to `writing-plans`, not `approval-gate`.

**Files:**
- Behavioral test script (new, under `.opencode/tests-v2/behaviors/`)

**SCs:** SC-12

**Dependencies:** Phase 2, Phase 3, Phase 4

**Entry Conditions:**
- Phase 2 complete: `approval-gate/SKILL.md` has no `verify-plan-pipeline` references
- Phase 3 complete: `approval-gate-scope/SKILL.md` has no `verify-plan-pipeline` references
- Phase 4 complete: `writing-plans/SKILL.md` has all required references
- All prior VbC checks passed

**Exit Conditions:**
- Behavioral test passes: agent routes "verify plan pipeline" to `writing-plans`
- Clean-room semantic inspector confirms `Skill "writing-plans"` dispatch in stderr
- Clean-room semantic inspector confirms absence of `Skill "approval-gate"` dispatch in stderr

---

- [ ] 23. **RED (**sub-agent**).** Write behavioral enforcement test that sends prompt "verify plan pipeline" to `opencode run` and asserts stderr contains `Skill "writing-plans"` and does NOT contain `Skill "approval-gate"`. Test should FAIL because the routing change is not yet active (or test infrastructure not yet set up). **→ SC-12**
- [ ] 24. **GREEN (**sub-agent**).** Ensure all SKILL.md changes are in place (Phases 2-4 complete). Run the behavioral test. If it fails, diagnose and fix routing issues. **→ SC-12**
- [ ] 25. **GREEN doublecheck (**clean-room**).** Verify behavioral test passes with clean-room semantic inspection of stderr output. **→ SC-12**
- [ ] 26. **Checkpoint commit (**inline**).** Commit behavioral test.

#### Phase 5 VbC

- [ ] 27. **VbC (**clean-room**).** Run behavioral test. Verify stderr contains `Skill "writing-plans"` dispatch and does NOT contain `Skill "approval-gate"` dispatch. **→ SC-12**

**Concern transition:** All phases complete. Proceeding to post-implementation steps.
