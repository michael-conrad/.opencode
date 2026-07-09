---
phase: 3
name: Behavioral tests + guidelines update
concern: Add behavioral enforcement tests for SC-4 and SC-5, verify guideline reference update
scs: SC-4, SC-5
dependencies: Phase 2 complete
entry_condition: Phase 2 exit criteria met, all task files migrated to binary classification
exit_condition: Behavioral tests pass for SC-4 and SC-5, guideline reference verified
---

# Phase 3 — Behavioral tests + guidelines update

**Concern:** Add behavioral enforcement tests for SC-4 (audit sub-agent produces only binary PASS/FAIL) and SC-5 (VbC sub-agent produces only binary PASS/FAIL). Verify the guideline reference update from Phase 2.

**Files:**
- `.opencode/tests/behaviors/` (new behavioral test files)
- `guidelines/000-critical-rules.md` (line 422 — already updated in Phase 2, verify)

**SCs:** SC-4, SC-5

**Dependencies:** Phase 2 complete (all task files migrated)

**Entry conditions:** Phase 2 exit criteria met, all task files migrated to binary classification

**Exit conditions:** Behavioral tests pass for SC-4 and SC-5, guideline reference verified

> **Compliance requirement:** Every step is mandatory. Skipping, combining, or reordering steps produces defective deliverables. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. No inline execution of sub-agent steps.
>
> **One-step-at-a-time protocol:** Execute exactly one step per dispatch. After each step, report the result before proceeding. Do not batch steps.
>
> **Self-remediation protocol:** On any FAIL signal, remediate before halting. Remediate → re-verify → proceed on PASS → HALT only on double-failure.

---

- [ ] 10. **(sub-agent) Write behavioral test for SC-4.** Create test in `.opencode/tests/behaviors/` that sends a prompt to an audit sub-agent and asserts the response contains only PASS/FAIL verdicts (no `flag-for-review`). Use `assert_semantic` for clean-room evaluation of agent output.
  - **RED:** Write test that FAILS (agent still produces `flag-for-review`)
  - **GREEN:** Test passes after Phase 1+2 migration
  - **VbC:** Verify SC-4: behavioral test passes with clean-room evaluation

- [ ] 11. **(sub-agent) Write behavioral test for SC-5.** Create test in `.opencode/tests/behaviors/` that sends a prompt to a VbC sub-agent and asserts the response contains only PASS/FAIL verdicts (no `conditional` findings). Use `assert_semantic` for clean-room evaluation of agent output.
  - **RED:** Write test that FAILS (agent still produces `conditional`)
  - **GREEN:** Test passes after Phase 1+2 migration
  - **VbC:** Verify SC-5: behavioral test passes with clean-room evaluation

- [ ] 12. **(sub-agent) Verify guidelines/000-critical-rules.md:422 update.** Confirm stale three-tier reference has been replaced with binary classification language.
  - **RED:** Read line 422, verify no `auto-fix/conditional/flag-for-review` remains
  - **GREEN:** Line 422 updated correctly
  - **VbC:** Verify SC-3: stale reference confirmed replaced

- [ ] 13. **(inline) Z3 check.** Verify Phase 3 output satisfies SC-4 and SC-5 per contract. Run solve check.
  - **RED:** Run solve check
  - **GREEN:** SAT and SOLVED status
  - **VbC:** Verify solve output

- [ ] 14. **(sub-agent) Run behavioral tests.** Execute both SC-4 and SC-5 behavioral tests via `bash .opencode/tests/behaviors/<scenario>.sh`.
  - **RED:** Run tests, expect PASS
  - **GREEN:** Both tests pass
  - **VbC:** Verify test output shows PASS for both SC-4 and SC-5

- [ ] 15. **(sub-agent) Audit fidelity.** Run audit-fidelity against spec SC-1 through SC-5 to verify all phases match spec.
  - **RED:** Run audit-fidelity against spec SC-1 through SC-5
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

- [ ] 16. **(sub-agent) Audit concern.** Run audit-concern to verify concern separation across phases.
  - **RED:** Run audit-concern
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

---

**Phase 3 completion:** All SC-4 and SC-5 criteria verified PASS. Behavioral tests pass. All 5 SCs satisfied.

**Plan completion:** All 3 phases complete. All 5 success criteria verified. Plan ready for implementation.
