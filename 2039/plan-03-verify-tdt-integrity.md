# Phase 3 — Verify TDT-Reference Integrity Across the Skill Deck

**Concern:** Confirm deck-wide TDT-reference integrity — no Trigger Dispatch Table or Invocation in any SKILL.md references a non-existent task card — per SC-3.

**Files:**
- `.opencode/skills/**/SKILL.md` (verification only — no modification expected)

**SCs:** SC-3

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: the 10 STILL-MISSING task cards exist
- Phase 2 complete: the two special-case dangling references are resolved
- Phase 2 VbC passed
- Deliverables are already present in the working tree; this phase verifies the deck-wide integrity gate

**Exit Conditions:**
- Cross-referencing every TDT and Invocation against the filesystem finds no reference to a non-existent task card
- SC-3 verified PASS

---

- [ ] 27. **Pre-regression (**sub-agent**).** Execute the `pre-regression` step: run regression test patterns to establish the baseline for the SC-3 string-evidence verification. **→ establishes baseline before RED**

- [ ] 28. **Pre-regression verify (**clean-room**).** Execute the `pre-regression-verify` step: verify the pre-regression results. **→ baseline verified**

- [ ] 29. **RED — SC-3 (item 5) (**clean-room**).** Execute the `red` task from test-driven-development: write a failing enforcement test that cross-references all TDTs and Invocations in `.opencode/skills/**/SKILL.md` against the task card files on disk, asserting no TDT references a non-existent task card. The test FAILS while any dangling reference remains. **→ SC-3**

- [ ] 30. **GREEN — SC-3 (item 5) (**clean-room**).** Execute the `green` task from test-driven-development: reconcile any remaining dangling references surfaced by the RED test (expected to be none after Phases 1 and 2) so the RED test passes. **→ SC-3**

- [ ] 31. **Post-regression (**clean-room**).** Execute the `post-regression` step after the GREEN phase. **→ post-GREEN regression clean**

- [ ] 32. **Verify — SC-3 (item 5) (**clean-room**).** Execute the `verify` task from verification-before-completion: cross-reference all TDTs against the filesystem and confirm no TDT references a non-existent task card. **→ SC-3**

- [ ] 33. **Commit — SC-3 (**inline**).** Orchestrator stages and commits the integrity gate (and any reconciliation) with its enforcement test as one atomic slice. **→ SC-3 committed**

#### Phase 3 VbC

- [ ] 34. **VbC (**clean-room**).** Verify SC-3 PASS against the present deliverables: cross-referencing all TDTs and Invocations in `.opencode/skills/**/SKILL.md` against the filesystem finds no reference to a non-existent task card. Any non-clean verdict coerces to FAIL per the reference card's Coercion Rules. **→ SC-3**

**Concern transition:** Leaving deck-wide integrity verification → entering post-implementation gates (structural checks, audit, review-prep, PR creation, completion).
