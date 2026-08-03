# Phase 3 — Remove

**Concern:** Remove Behavioral RED/GREEN section from 080; verify Test Integrity Mandate stays (CONCERN-REMOVE).

**Files:**
- `.opencode/guidelines/080-code-standards.md`

**SCs:** SC-4, SC-5, SC-9

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: Enforcement Test Mandate moved to `test-driven-development/SKILL.md`
- Phase 2 VbC passed
- `080-code-standards.md` has Behavioral RED/GREEN section at verified line range
- `080-code-standards.md` has Test Integrity Mandate section at verified line range

**Exit Conditions:**
- Behavioral RED/GREEN section removed from 080
- Test Integrity Mandate remains in 080 with content intact
- Removed section's normative content exists in the moved Enforcement Test Mandate
- Behavioral enforcement tests pass (lobotomization gate)

---

- [ ] 13. **RED (**sub-agent**).** Write failing grep test asserting Behavioral RED/GREEN section still exists in 080. **→ SC-4**
- [ ] 14. **GREEN (**sub-agent**).** Remove Behavioral RED/GREEN section from `080-code-standards.md`. Verify Test Integrity Mandate section is NOT removed. Update any cross-references in 080 that pointed to the removed section. **→ SC-4, SC-5**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Verify: (a) Behavioral RED/GREEN section removed, (b) Test Integrity Mandate remains with all 6 rules intact, (c) every normative statement from removed section exists in moved Enforcement Test Mandate, (d) cross-references updated. **→ SC-4, SC-5, SC-9**
- [ ] 16. **Lobotomization gate (**sub-agent**).** Run behavioral enforcement tests:
     - `bash .opencode/tests-v2/test-enforcement.sh --changed` (content-verification)
     - `bash .opencode/tests-v2/behaviors/<relevant-scenario>.sh` (behavioral)
     - If any behavioral test fails: revert removal, investigate constraint loss. **→ SC-4, SC-5, SC-9**
- [ ] 17. **Checkpoint commit (**inline**).** Commit removal + lobotomization gate results.

#### Phase 3 VbC

- [ ] 18. **VbC (**clean-room**).** Verify SC-4 (grep absence of "Behavioral RED/GREEN as Primary Enforcement Gate" in 080), SC-5 (grep for "Test Integrity Mandate" + semantic: all 6 rules present), SC-9 (semantic: removed section's normative content exists in moved Enforcement Test Mandate). **→ SC-4, SC-5, SC-9**

**Concern transition:** Leaving removal → entering verification. Phase 4 depends on Phase 3's removal and lobotomization gate.
