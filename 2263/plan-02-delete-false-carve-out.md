# Phase 2 — Delete false carve-out

**Concern:** Delete the false carve-out phrase ("reading a SKILL.md is NOT 'inline work' or 'reading a file'") from `.opencode/guidelines/020-go-prohibitions.md` and replace it with a truthful context-economy justification.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `020-go-prohibitions.md` re-scoped to allocation-by-context-cost
- Phase 1 VbC passed

**Exit Conditions:**
- The false carve-out phrase is absent from `020-go-prohibitions.md`
- A truthful context-economy justification is present (skill() auto-loads SKILL.md; routing metadata is small/necessary and already present; sub-agents cannot load skills)
- The Skill Card / Task Card table is preserved

---

**Cost frame:** Verifying the carve-out deletion costs one grep for the false phrase. Skipping means the category error survives and continues teaching rationalization, compounding into the bypass signature the framework flags as a CRITICAL VIOLATION.

- [ ] 9. **RED (**sub-agent**).** Write an enforcement test asserting the false carve-out phrase is present (fails because the deletion doesn't exist yet). **→ SC-2**
- [ ] 10. **GREEN (**sub-agent**).** Delete the false carve-out phrase and replace it with the truthful context-economy justification in `.opencode/guidelines/020-go-prohibitions.md`. **→ SC-2**
- [ ] 11. **GREEN doublecheck (**clean-room**).** Verify the false carve-out phrase is absent and the truthful justification is present. **→ SC-2**
- [ ] 12. **Checkpoint commit (**inline**).** Commit the carve-out replacement. **→ SC-2**

#### Phase 2 VbC

- [ ] 13. **VbC (**clean-room**).** Verify `020-go-prohibitions.md` no longer contains the false "not a file" claim and the context-economy justification is present. **→ SC-2**

**Concern transition:** Leaving carve-out replacement → entering mechanism re-justification. Phase 3 depends on Phase 1's re-scoped rule.
