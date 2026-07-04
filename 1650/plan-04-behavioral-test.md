# Phase 4 — Behavioral Test for SC-6

**Concern:** SC-6 requires a behavioral test verifying the agent uses `skill()` syntax, not `/skill`, when describing skill invocation.

**Files:** `.opencode/tests/behaviors/` (new test file)

**SCs:** SC-6

**Dependencies:** Phase 3 complete

**Entry:** Zero `/skill` references remain in `.opencode/`

**Exit:** Behavioral test exists and passes

- [ ] 13. **RED (**sub-agent**).** Write a behavioral enforcement test that sends a prompt asking the agent to describe how to invoke a skill, and asserts the agent uses `skill()` syntax (not `/skill`). The test should FAIL initially because the agent may still reference `/skill` from training data. Use `assert_forbidden_pattern_absent` for `/skill` and `assert_required_pattern_present` for `skill(`. Save to `.opencode/tests/behaviors/skill-invocation-syntax.sh`. **→ SC-6**
- [ ] 14. **GREEN (**sub-agent**).** Run the behavioral test via `bash .opencode/tests/with-test-home opencode-cli run '<prompt>'`. If it fails, investigate and remediate. The test must PASS. **→ SC-6**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Re-run the behavioral test to confirm consistent PASS. **→ SC-6**

#### Phase 4 VbC

- [ ] 15a. **VbC (**clean-room**).** Verify: behavioral test written, test passes consistently, no `/skill` references in agent output. **→ SC-6**

**Concern transition:** Leaving behavioral testing → entering global verification. Phase 5 depends on Phase 4's behavioral test passing.
