# Phase 2 — Move

**Concern:** Relocate the Enforcement Test Mandate section from 080 to test-driven-development/SKILL.md (CONCERN-MOVE).

**Files:**
- `.opencode/guidelines/080-code-standards.md`
- `.opencode/skills/test-driven-development/SKILL.md`

**SCs:** SC-3, SC-8

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: Parsing Logic Changes and Libraries & Packages sections generalized
- Phase 1 VbC passed
- `080-code-standards.md` has Enforcement Test Mandate section at verified line range
- `test-driven-development/SKILL.md` does not already have an Enforcement Test Mandate section

**Exit Conditions:**
- Enforcement Test Mandate section exists in `test-driven-development/SKILL.md`
- All normative rules from the source section are present in the destination
- Cross-references in 080 that pointed to the moved section are updated

---

- [ ] 8. **RED (**sub-agent**).** Write failing grep test asserting Enforcement Test Mandate does NOT exist in `test-driven-development/SKILL.md`. **→ SC-3**
- [ ] 9. **GREEN (**sub-agent**).** Copy Enforcement Test Mandate section (including Evidence Type Taxonomy, SC-to-Test Traceability, RED-Phase Ordering, Behavioral RED/GREEN gate subsections) from `080-code-standards.md` to `test-driven-development/SKILL.md`. Update cross-references in the moved content to point to correct locations. **→ SC-3, SC-8**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Verify: (a) every normative rule from source is present in destination, (b) no rules dropped during move, (c) cross-references updated. **→ SC-3, SC-8**
- [ ] 11. **Checkpoint commit (**inline**).** Commit move of Enforcement Test Mandate.

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Verify SC-3 (grep for "Enforcement Test Mandate" in destination), SC-8 (semantic: all normative rules preserved, cross-references updated). **→ SC-3, SC-8**

**Concern transition:** Leaving move → entering removal. Phase 3 depends on Phase 2's moved Enforcement Test Mandate.
