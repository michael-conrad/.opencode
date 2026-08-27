# Phase 1 — Requirements Documentation Guard Mandate

**Concern:** Add the pre-flight guard mandate to the four requirements documentation documents.

**Files:**
- `.opencode/reference/skill-card-schema.md`
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/skills/skill-creator/reference/skill-card-spec.md`
- `.opencode/skills/skill-creator/reference/routing-only-template.md`

**SCs:** SC-4

**Dependencies:** None

**Entry Conditions:**
- Spec #2339 is approved (`approved-for-pr` label present)
- Feature branch exists
- Pre-implementation coherence gate, baseline check, and pre-regression passed

**Exit Conditions:**
- The four reference documents contain the guard mandate (SC-4)

---

**Code Path Coverage:** SC-4 reads the four reference documents and asserts the guard mandate is present in all of them.

**Cross-Cutting SCs:** SC-4 spans concerns documentation-mandate and canonical-definition — the mandate (SC-4) and the canonical definition (SC-5) touch the same four documents and must coexist consistently; sequenced mandate-first.

**Interface Boundaries:** Reference-doc -> content contract. `skill-card-schema.md` and `skill-card-description-standards.md` mandate the guard for skill cards (SC-1); `skill-card-spec.md` and `routing-only-template.md` additionally feed the template generator (SC-6).

**State Transitions:** At the card_received boundary, the guard runs sub-agent context detection; an orchestrator proceeds to consume_routing_metadata, a sub-agent transitions to blocked with ORCHESTRATOR_ONLY_SKILL_CARD. The mandate must state the guard fires before any routing metadata is consumed.

**Cost frame:** Verifying the guard mandate is present in all four documents costs one grep across the reference docs. Skipping means the guard mandate is absent and linting has no normative basis — a sub-agent that receives a skill card silently consumes routing metadata it cannot execute, producing a defect that costs a full redo cycle.

---

- [ ] 5. **RED (**sub-agent**).** Write an enforcement check that greps the four reference documents for the guard mandate marker and expects FAIL (mandate not yet present). **→ SC-4**
- [ ] 6. **GREEN (**sub-agent**).** Add the guard mandate to all four reference documents. **→ SC-4**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Re-run the RED check — it must now PASS (mandate present in all four documents). **→ SC-4**
- [ ] 8. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-4**
- [ ] 9. **Verify (**sub-agent**).** Dispatch `verification-before-completion` verify task; assert the guard mandate is present in all four documents. **→ SC-4**
- [ ] 10. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-4 — guard mandate added to four reference docs` **→ SC-4**

#### Phase 1 VbC

- [ ] 11. **VbC (**clean-room**).** Verify the guard mandate is present in all four reference documents. **→ SC-4**

**Concern transition:** Leaving requirements documentation guard mandate → entering canonical guard definition. Phase 2 depends on Phase 1's mandate being present in the four documents.
