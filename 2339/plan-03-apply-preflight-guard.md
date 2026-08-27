# Phase 3 — Apply Pre-Flight Guard to All Skill Cards

**Concern:** Apply the canonical pre-flight guard to every skill card so a sub-agent receiving a SKILL.md halts before consuming routing metadata.

**Files:**
- `.opencode/skills/*/SKILL.md` (51 cards)
- `.opencode/skills/*/platforms/*/SKILL.md` (included in the 51)

**SCs:** SC-1

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: the canonical guard definition is finalized in the four reference documents
- Phase 2 VbC passed

**Exit Conditions:**
- Every SKILL.md under `.opencode/skills/` contains the pre-flight guard (SC-1)
- `skildeck lint` passes with no guard findings

---

**Code Path Coverage:** SC-1 greps all 51 SKILL.md files for the guard marker and runs `skildeck lint` to confirm no guard finding.

**Cross-Cutting SCs:** SC-1 spans concerns skill-card-content and canonical-definition — the per-card guard wording must match the canonical definition from SC-5. SC-1 is also the content that SC-2 (`skildeck-lint`) and SC-3 (`validate_skill_cards.py`) flag.

**Interface Boundaries:** SKILL.md <-> sub-agent dispatch contract. A sub-agent receiving a skill card MUST halt BLOCKED with ORCHESTRATOR_ONLY_SKILL_CARD before consuming routing metadata; the guard MUST fire before any routing metadata (Trigger Dispatch Table, DISPATCH_GATE, Invocation) is consumed.

**State Transitions:** At the card_received boundary the guard runs sub-agent context detection — orchestrator proceeds to consume_routing_metadata, sub-agent transitions to blocked with ORCHESTRATOR_ONLY_SKILL_CARD. The guard fires before any routing metadata is consumed.

**Cost frame:** Verifying every card carries the guard costs one grep plus a lint run. Skipping means a sub-agent that receives a skill card silently consumes routing metadata it cannot execute, producing defective work that costs a full redo cycle.

---

- [ ] 19. **RED (**sub-agent**).** Write an enforcement check that asserts a skill card without the guard produces a guard finding (grep-based or lint-based) and expects FAIL (cards not yet guarded). **→ SC-1**
- [ ] 20. **GREEN (**sub-agent**).** Add the canonical pre-flight guard section to all 51 SKILL.md files using the canonical wording from the requirements docs. **→ SC-1**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Re-run the RED check — it must now PASS (guard present in all 51 cards). **→ SC-1**
- [ ] 22. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-1**
- [ ] 23. **Verify (**sub-agent**).** Grep all 51 SKILL.md files for the guard marker; run `skildeck lint` and confirm no guard finding. **→ SC-1**
- [ ] 24. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-1 — pre-flight guard applied to 51 skill cards` **→ SC-1**

#### Phase 3 VbC

- [ ] 25. **VbC (**clean-room**).** Verify every SKILL.md under `.opencode/skills/` contains the pre-flight guard and `skildeck lint` reports no guard finding. **→ SC-1**

**Concern transition:** Leaving content guard application → entering lint/validation enforcement. Phases 4 and 5 depend on Phase 3's guarded deck.
