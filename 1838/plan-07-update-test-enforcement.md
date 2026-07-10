# Phase 7 — Update test-enforcement.sh

**Concern:** Remove or rewrite the 8 "yaml-rule" content-verification scenarios in `test-enforcement.sh`. Replace with behavioral tests that verify agents follow the prose rules directly.

**Files:** `tests/test-enforcement.sh`, `tests/behaviors/` (new behavioral test files)

**SCs:** SC-8 (`string`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 6 complete

**Entry conditions:** Phase 6 checkpoint committed and tagged, working tree clean

**Exit conditions:** No "yaml-rule" scenarios remain in test-enforcement.sh, behavioral regression PASS

---

- [ ] 55. **RED (**sub-agent**).** Read `tests/test-enforcement.sh`. Identify all 8 "yaml-rule" content-verification scenarios. Record their names and what they test. **→ SC-8**
- [ ] 56. **GREEN (**sub-agent**).** Remove the 8 "yaml-rule" scenarios from `test-enforcement.sh`. For each removed scenario, create a behavioral test in `tests/behaviors/` that verifies agents follow the prose rule directly (using `opencode-cli run` with real-domain prompts). **→ SC-8, SC-11**
- [ ] 57. **GREEN doublecheck (**inline**).** Run `grep 'yaml-rule' tests/test-enforcement.sh` — must return empty. **→ SC-8**
- [ ] 58. **Behavioral regression test (**sub-agent**).** Run the new behavioral tests and all existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 59. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 60. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 7: Replace yaml-rule content-verification with behavioral tests"`
- [ ] 61. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-7-opencode`
- [ ] 62. **VbC (**clean-room**).** Verify: no yaml-rule scenarios remain (SC-8), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-8, SC-11, SC-12**

**Concern transition:** Leaving test-enforcement.sh update → entering documentation update. Phase 8 depends on Phase 7's test changes.
