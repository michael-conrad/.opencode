# Phase 4 — Verify

**Concern:** Confirm all keep sections remain in 080 with no content removed or reworded (CONCERN-VERIFY).

**Files:**
- `.opencode/guidelines/080-code-standards.md`

**SCs:** SC-6

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: Behavioral RED/GREEN removed, Test Integrity Mandate verified intact
- Phase 3 VbC passed
- Lobotomization gate passed

**Exit Conditions:**
- All keep sections present in 080 with their original section headers
- No content removed or reworded in any keep section (whitespace-only differences acceptable)

---

- [ ] 19. **RED (**sub-agent**).** Write failing grep test asserting all keep section headers exist in 080 (pre-verification — will fail if any section was accidentally removed). **→ SC-6**
- [ ] 20. **GREEN (**sub-agent**).** For each keep section, compare before/after content. Confirm no content removed and no wording changed. Report any discrepancies. **→ SC-6**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify: (a) all keep section headers present, (b) no content removed or reworded in any keep section, (c) whitespace-only differences are acceptable. **→ SC-6**
- [ ] 22. **Checkpoint commit (**inline**).** Commit final verification.

#### Phase 4 VbC

- [ ] 23. **VbC (**clean-room**).** Verify SC-6 (grep for each keep section header + semantic: before/after content comparison — PASS only if every keep section's content has no content removed and no wording changed). **→ SC-6**

**Concern transition:** All phases complete. All 9 SCs must PASS for all-or-nothing gate.
