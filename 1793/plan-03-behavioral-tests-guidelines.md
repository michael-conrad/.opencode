# Phase 3 — Behavioral tests + guidelines update

**Concern:** Add behavioral enforcement tests for SC-4 (audit sub-agent produces only binary PASS/FAIL) and SC-5 (VbC sub-agent produces only binary PASS/FAIL). Verify the guideline reference update from Phase 2.

**Files:**
- `.opencode/tests/behaviors/` (new behavioral test files)
- `guidelines/000-critical-rules.md` (line 422 — already updated in Phase 2, verify)

**SCs:** SC-4, SC-5

**Dependencies:** Phase 2 complete (all task files migrated)

**Entry conditions:** Phase 2 exit criteria met, all task files migrated to binary classification

**Exit conditions:** Behavioral tests pass for SC-4 and SC-5, guideline reference verified

---

- [ ] 10. (**sub-agent**) Write behavioral test for SC-4 — verify audit sub-agent produces only binary PASS/FAIL (no `flag-for-review` findings)
  - Create test in `.opencode/tests/behaviors/` that sends a prompt to an audit sub-agent and asserts the response contains only PASS/FAIL verdicts
  - Use `assert_semantic` for clean-room evaluation of agent output
  - **RED:** Write test that FAILS (agent still produces `flag-for-review`)
  - **GREEN:** Test passes after Phase 1+2 migration
  - **VbC:** Verify SC-4: behavioral test passes with clean-room evaluation

- [ ] 11. (**sub-agent**) Write behavioral test for SC-5 — verify VbC sub-agent produces only binary PASS/FAIL (no `conditional` findings)
  - Create test in `.opencode/tests/behaviors/` that sends a prompt to a VbC sub-agent and asserts the response contains only PASS/FAIL verdicts
  - Use `assert_semantic` for clean-room evaluation of agent output
  - **RED:** Write test that FAILS (agent still produces `conditional`)
  - **GREEN:** Test passes after Phase 1+2 migration
  - **VbC:** Verify SC-5: behavioral test passes with clean-room evaluation

- [ ] 12. (**sub-agent**) Verify `guidelines/000-critical-rules.md:422` update — confirm stale three-tier reference has been replaced
  - **RED:** Read line 422, verify no `auto-fix/conditional/flag-for-review` remains
  - **GREEN:** Line 422 updated correctly
  - **VbC:** Verify SC-3: stale reference confirmed replaced

- [ ] 13. (**inline**) Z3 check — verify Phase 3 output satisfies SC-4 and SC-5 per contract
  - **RED:** Run solve check
  - **GREEN:** SAT and SOLVED status
  - **VbC:** Verify solve output

- [ ] 14. (**sub-agent**) Run behavioral tests — execute both SC-4 and SC-5 behavioral tests via `bash .opencode/tests/behaviors/<scenario>.sh`
  - **RED:** Run tests, expect PASS
  - **GREEN:** Both tests pass
  - **VbC:** Verify test output shows PASS for both SC-4 and SC-5

- [ ] 15. (**sub-agent**) Audit fidelity — verify all phases match spec SCs
  - **RED:** Run audit-fidelity against spec SC-1 through SC-5
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

- [ ] 16. (**sub-agent**) Audit concern — verify concern separation across phases
  - **RED:** Run audit-concern
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

---

**Phase 3 completion:** All SC-4 and SC-5 criteria verified PASS. Behavioral tests pass. All 5 SCs satisfied.

**Plan completion:** All 3 phases complete. All 5 success criteria verified. Plan ready for implementation.
