# Phase 7 — Critical Rule References the Guard

**Concern:** Anchor the pre-flight guard to its normative basis by referencing it in the critical rule.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-7

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: the canonical guard definition is finalized in the four reference documents
- Phase 2 VbC passed

**Exit Conditions:**
- The critical-rules-XXX section in `000-critical-rules.md` references the pre-flight guard as the defensive backstop (SC-7)

---

**Code Path Coverage:** SC-7 reads the critical-rules-XXX section in `000-critical-rules.md` and asserts the guard reference is present.

**Cross-Cutting SCs:** SC-7 spans concerns normative-basis and skill-card-content — critical-rules-XXX is the normative basis for the guard applied to the SC-1 cards.

**Interface Boundaries:** 000-critical-rules.md -> skill cards normative-basis contract. The critical-rules-XXX section references the guard as the defensive backstop for the SC-1 cards.

**State Transitions:** The critical rule anchors the card_received boundary behavior — a sub-agent receiving a skill card halts BLOCKED with ORCHESTRATOR_ONLY_SKILL_CARD before consuming routing metadata.

**Cost frame:** Reading the critical rule to confirm the guard reference costs one read. Skipping means the guard is orphaned from its normative basis and its defensive intent is lost.

---

- [ ] 47. **RED (**sub-agent**).** Write an enforcement check that asserts the critical-rules-XXX section references the guard and expects FAIL. **→ SC-7**
- [ ] 48. **GREEN (**sub-agent**).** Update the critical-rules-XXX section in `000-critical-rules.md` to reference the pre-flight guard as the defensive backstop. **→ SC-7**
- [ ] 49. **GREEN doublecheck (**clean-room**).** Re-run the RED check — it must now PASS (guard reference present). **→ SC-7**
- [ ] 50. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-7**
- [ ] 51. **Verify (**sub-agent**).** Read the critical-rules-XXX section and confirm the guard reference is present. **→ SC-7**
- [ ] 52. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-7 — critical rule references guard backstop` **→ SC-7**

#### Phase 7 VbC

- [ ] 53. **VbC (**clean-room**).** Verify the critical-rules-XXX section references the pre-flight guard as the defensive backstop. **→ SC-7**

**Concern transition:** Leaving critical rule reference → entering post-implementation. All phases complete; post-implementation steps begin.
