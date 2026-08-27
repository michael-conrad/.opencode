# Phase 5 — validate_skill_cards.py Guard Enforcement

**Concern:** Make the pre-flight guard a mechanically enforced requirement in `validate_skill_cards.py`.

**Files:**
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`

**SCs:** SC-3

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: the guarded deck is committed (all 51 cards carry the guard)
- Phase 3 VbC passed

**Exit Conditions:**
- `validate_skill_cards.py` flags a card lacking the guard and does not flag a card with the guard (SC-3)

---

**Code Path Coverage:** SC-3 runs `validate_skill_cards.py` against a guarded and an unguarded card and inspects its output.

**Cross-Cutting SCs:** SC-3 spans concerns validation and skill-card-content — the validation script independently flags the same SC-1 cards, providing a backstop parallel to `skildeck-lint`.

**Interface Boundaries:** validate_skill_cards.py <-> SKILL.md contract. The validation script MUST flag a card lacking the guard via a REQ rule; independent enforcement backstop parallel to `skildeck-lint`.

**State Transitions:** At validation_eval on card_present: guard present -> no_finding, guard absent -> finding_reported (REQ rule finding). Recovery from an unguarded_card_in_deck state resolves to guarded_card via the lint/validation finding (SC-2/SC-3 backstop) resolved by adding the canonical guard.

**Cost frame:** Running `validate_skill_cards.py` against a guarded and unguarded card and inspecting its output costs a bounded tool run. Skipping means an unguarded card passes validation and the guard silently regresses into the deck.

---

- [ ] 33. **RED (**sub-agent**).** Write an enforcement test asserting a card without the guard produces a validation finding and expects FAIL. **→ SC-3**
- [ ] 34. **GREEN (**sub-agent**).** Add the REQ rule to `validate_skill_cards.py`. **→ SC-3**
- [ ] 35. **GREEN doublecheck (**clean-room**).** Re-run the RED test — it must now PASS (validation flags unguarded card). **→ SC-3**
- [ ] 36. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-3**
- [ ] 37. **Verify (**sub-agent**).** Run `validate_skill_cards.py` against a guarded and an unguarded card; assert a finding is present when the guard is missing and absent when the guard is present. **→ SC-3**
- [ ] 38. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-3 — validate_skill_cards.py guard enforcement` **→ SC-3**

#### Phase 5 VbC

- [ ] 39. **VbC (**clean-room**).** Verify `validate_skill_cards.py` flags an unguarded card and passes a guarded card. **→ SC-3**

**Concern transition:** Leaving validate_skill_cards.py enforcement → entering template generator guard. Phase 6 depends on Phase 2's canonical definition (independent of Phases 3-5).
