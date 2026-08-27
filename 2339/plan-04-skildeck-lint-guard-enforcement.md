# Phase 4 — skildeck-lint Guard Enforcement

**Concern:** Make the pre-flight guard a mechanically enforced requirement in `skildeck-lint`.

**Files:**
- `.opencode/tools/impl/skildeck/skildeck-lint`

**SCs:** SC-2

**Dependencies:** Phase 3

**Entry Conditions:**
- Phase 3 complete: the guarded deck is committed (all 51 cards carry the guard)
- Phase 3 VbC passed

**Exit Conditions:**
- `skildeck-lint` flags a card lacking the guard and does not flag a card with the guard (SC-2)

---

**Code Path Coverage:** SC-2 runs `skildeck-lint` against a guarded and an unguarded card and inspects its output.

**Cross-Cutting SCs:** SC-2 spans concerns linting and skill-card-content — the lint rule flags the SC-1 cards that lack the guard, coupling the lint rule with the content change.

**Interface Boundaries:** skildeck-lint <-> SKILL.md contract. The lint MUST flag a card lacking the guard and NOT flag a card with the guard (idempotent, no double-guard finding); the lint rule reads the guard marker and is additive, not altering frontmatter or the Workflows dispatch contract.

**State Transitions:** At lint_eval on card_present: guard present -> no_finding, guard absent -> finding_reported (lint_skill_preflight_guard finding). Idempotent — a card already containing the guard must not be double-guarded.

**Cost frame:** Running `skildeck-lint` against a guarded and unguarded card and inspecting its output costs a bounded tool run. Skipping means an unguarded card passes lint and the guard silently regresses into the deck.

---

- [ ] 26. **RED (**sub-agent**).** Write an enforcement test asserting a card without the guard produces a lint finding and expects FAIL. **→ SC-2**
- [ ] 27. **GREEN (**sub-agent**).** Add the `lint_skill_preflight_guard` rule to `skildeck-lint`. **→ SC-2**
- [ ] 28. **GREEN doublecheck (**clean-room**).** Re-run the RED test — it must now PASS (lint flags unguarded card). **→ SC-2**
- [ ] 29. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-2**
- [ ] 30. **Verify (**sub-agent**).** Run `skildeck-lint` against a guarded and an unguarded card; assert a finding is present when the guard is missing and absent when the guard is present. **→ SC-2**
- [ ] 31. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-2 — skildeck-lint guard enforcement` **→ SC-2**

#### Phase 4 VbC

- [ ] 32. **VbC (**clean-room**).** Verify `skildeck-lint` flags an unguarded card and passes a guarded card. **→ SC-2**

**Concern transition:** Leaving skildeck-lint enforcement → entering validate_skill_cards.py enforcement. Phase 5 depends on Phase 3's guarded deck (independent of Phase 4).
