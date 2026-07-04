# Phase 2 — Behavioral Test + Verification + Review Prep

**Concern:** Write behavioral enforcement test for SC-6, re-verify zero remaining `/skill` references, run finishing checklist, and prepare PR.

**Files:**
- `.opencode/tests/behaviors/skill-invocation-syntax.sh` (new behavioral test)
- All `.opencode/` files (global grep re-verification)

**SCs:** SC-6, SC-1, SC-2, SC-3, SC-4, SC-5 (re-verify)

**Dependencies:** Phase 1 complete

**Entry condition:** Phase 1 VbC PASS

**Exit condition:** Behavioral test PASSes, zero `/skill` references confirmed, PR created

- [ ] 9. **RED: write behavioral test for SC-6 (**sub-agent**).** Write `.opencode/tests/behaviors/skill-invocation-syntax.sh` that sends a prompt asking the agent to describe how to invoke a skill, then asserts the agent uses `skill({name: "..."})` syntax and does NOT use `/skill` syntax. Use `assert_stderr_pattern_present` for `skill({name:` and `assert_stderr_pattern_absent` for `/skill`. Run the test — it must FAIL because the agent may still reference `/skill` from training data. **→ SC-6**

- [ ] 10. **GREEN: run behavioral test (**clean-room**).** Re-run the behavioral test. It should now PASS because the `/skill` references have been removed from all skill files. **→ SC-6**

- [ ] 11. **GREEN doublecheck: verify SC-6 (**clean-room**).** Run the behavioral test 3 times to verify non-flaky PASS. **→ SC-6**

- [ ] 12. **Global grep re-verification (**clean-room**).** Run `grep -rn '/skill' .opencode/` with no file-type filter — verify zero matches. **→ SC-5**

- [ ] 13. **Adversarial audit (**sub-agent**).** Dispatch adversarial audit of all changes against spec SCs. **→ All SCs**

- [ ] 14. **Review prep (**sub-agent**).** Run finishing checklist and prepare PR. **→ All SCs**

#### Phase 2 VbC

- [ ] 15. **VbC (**clean-room**).** Verify all exit criteria C1-C6 are met. **→ All SCs**

**Concern transition:** Plan complete. All 58 `/skill` references replaced, behavioral test verified, zero remaining references confirmed.
