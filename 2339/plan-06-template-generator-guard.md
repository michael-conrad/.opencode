# Phase 6 — Template Generator Guard

**Concern:** Ensure newly generated skill cards are born with the pre-flight guard.

**Files:**
- `.opencode/skills/skill-creator/scripts/init_skill.py`

**SCs:** SC-6

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: the canonical guard definition is finalized in the four reference documents
- Phase 2 VbC passed

**Exit Conditions:**
- The `SKILL_TEMPLATE` in `init_skill.py` includes the pre-flight guard (SC-6)

---

**Code Path Coverage:** SC-6 runs the template generator on `init_skill.py`, inspects its output, and generates a card from the template to assert the guard is present.

**Cross-Cutting SCs:** SC-6 is not cross-cutting — it is confined to the template generator concern.

**Interface Boundaries:** init_skill.py <-> generated SKILL.md contract. The generated SKILL_TEMPLATE MUST include the pre-flight guard so new cards are born guarded; the template change is additive and the generated card passes lint/validation.

**State Transitions:** At generation_invoked -> template_output -> card_with_guard. A card created without the guard (template bypass or manual edit) is caught by the lint/validation backstop (SC-2/SC-3).

**Cost frame:** Running the template generator and inspecting its output costs a single run. Skipping means newly generated cards ship without the guard, silently reintroducing the gap.

---

- [ ] 40. **RED (**sub-agent**).** Write an enforcement test asserting the generated card from the template contains the guard and expects FAIL. **→ SC-6**
- [ ] 41. **GREEN (**sub-agent**).** Add the pre-flight guard section to the `SKILL_TEMPLATE` in `init_skill.py`. **→ SC-6**
- [ ] 42. **GREEN doublecheck (**clean-room**).** Re-run the RED test — it must now PASS (generated card contains the guard). **→ SC-6**
- [ ] 43. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-6**
- [ ] 44. **Verify (**sub-agent**).** Unit-test the template string; generate a card from the template and confirm the guard is present. **→ SC-6**
- [ ] 45. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-6 — template generator emits guard` **→ SC-6**

#### Phase 6 VbC

- [ ] 46. **VbC (**clean-room**).** Verify the `SKILL_TEMPLATE` includes the pre-flight guard and a generated card contains it. **→ SC-6**

**Concern transition:** Leaving template generator guard → entering critical rule reference. Phase 7 depends on Phase 2's canonical definition (independent of Phases 3-6).
