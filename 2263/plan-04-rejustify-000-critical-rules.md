# Phase 4 — Re-justify 000-critical-rules.md

**Concern:** Re-justify the critical-rules-XXX "Dispatching SKILL.md to sub-agents — category error" rule in `.opencode/guidelines/000-critical-rules.md` under context-economy, preserving the category-error prohibition and removing any false "not a file" claim.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-4

**Dependencies:** Phase 1, Phase 2, Phase 3

**Entry Conditions:**
- Phases 1-3 complete: `020-go-prohibitions.md` re-scoped and mechanisms re-justified
- Phases 1-3 VbC passed

**Exit Conditions:**
- critical-rules-XXX re-justified under context-economy in `000-critical-rules.md`
- Category-error prohibition intact
- No false "not a file" claim remains
- The duplicate Skill Card / Task Card table is preserved

---

**Cost frame:** Verifying the 000-critical-rules.md alignment costs one grep. Skipping means the category-error rule diverges from the re-scoped 020, reintroducing the cross-file contradiction.

- [ ] 19. **RED (**sub-agent**).** Write an enforcement test asserting the category-error rule is not yet re-justified under context-economy (fails). **→ SC-4**
- [ ] 20. **GREEN (**sub-agent**).** Re-justify critical-rules-XXX under context-economy in `.opencode/guidelines/000-critical-rules.md`, preserving the category-error prohibition and removing any false "not a file" claim. **→ SC-4**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify critical-rules-XXX is re-justified, the category-error prohibition is intact, and no false "not a file" claim remains. **→ SC-4**
- [ ] 22. **Checkpoint commit (**inline**).** Commit the critical-rules-XXX update. **→ SC-4**

#### Phase 4 VbC

- [ ] 23. **VbC (**clean-room**).** Verify `000-critical-rules.md` critical-rules-XXX is re-justified under context-economy with the category-error prohibition intact and no false "not a file" claim. **→ SC-4**

**Concern transition:** Leaving 000-critical-rules.md alignment → entering skill card DISPATCH_GATE alignment. Phase 5 depends on Phase 4.
