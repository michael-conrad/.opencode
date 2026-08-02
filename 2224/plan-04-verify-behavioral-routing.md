# Phase 4 — Verify Behavioral Routing

**Concern:** Verify that an agent receiving the prompt "verify plan pipeline" dispatches `writing-plans` skill (not `approval-gate`).

**Files:**
- Behavioral test script (`.opencode/tests-v2/behaviors/`)

**SCs:** SC-12

**Dependencies:** Phase 2, Phase 3

**Entry Conditions:**
- Phase 2 complete: approval-gate SKILL.md files cleaned
- Phase 3 complete: writing-plans SKILL.md updated
- Phase 2 and Phase 3 VbC passed

**Exit Conditions:**
- Behavioral test passes: agent routes "verify plan pipeline" to `writing-plans`, not `approval-gate`

---

- [ ] 22. **RED (**sub-agent**).** Write behavioral test that sends "verify plan pipeline" prompt and asserts `Skill "writing-plans"` appears in stderr and `Skill "approval-gate"` does not. **→ SC-12**
- [ ] 23. **GREEN (**sub-agent**).** Run behavioral test — verify it passes. **→ SC-12**
- [ ] 24. **GREEN doublecheck (**clean-room**).** Verify test output shows correct dispatch. **→ SC-12**
- [ ] 25. **Checkpoint commit (**inline**).** Commit behavioral test.

#### Phase 4 VbC

- [ ] 26. **VbC (**clean-room**).** Verify behavioral test passes with expected dispatch to `writing-plans` and no dispatch to `approval-gate`. **→ SC-12**
