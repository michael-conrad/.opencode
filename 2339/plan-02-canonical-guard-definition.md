# Phase 2 — Canonical Guard Definition

**Concern:** Define a single canonical guard definition consistent across the four requirements documentation documents.

**Files:**
- `.opencode/reference/skill-card-schema.md`
- `.opencode/reference/skill-card-description-standards.md`
- `.opencode/skills/skill-creator/reference/skill-card-spec.md`
- `.opencode/skills/skill-creator/reference/routing-only-template.md`

**SCs:** SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the guard mandate is present in all four documents
- Phase 1 VbC passed

**Exit Conditions:**
- A single canonical guard definition is present and consistent across all four documents (SC-5)

---

**Code Path Coverage:** SC-5 reads the four reference documents and asserts a single consistent canonical guard definition is present across them.

**Cross-Cutting SCs:** SC-5 spans concerns documentation-mandate and canonical-definition, and is consumed by SC-4's mandate, SC-1's per-card wording, SC-6's template, and SC-7's critical rule — coupling documentation and content. The canonical definition must be consistent to avoid divergent variants.

**Interface Boundaries:** Reference-doc -> content/template contract. `skill-card-schema.md` and `skill-card-description-standards.md` feed the skill cards (SC-1); `skill-card-spec.md` and `routing-only-template.md` additionally feed the template generator (SC-6). The canonical definition is the single source consumed by all downstream phases.

**State Transitions:** The canonical definition encodes the card_received boundary behavior — orchestrator proceeds to consume_routing_metadata, sub-agent transitions to blocked with ORCHESTRATOR_ONLY_SKILL_CARD. Consistency across documents prevents divergent guard variants.

**Cost frame:** Verifying a single consistent canonical definition across all four documents costs one grep for consistency. Skipping means inconsistent guard wording across 51 skill cards propagates a multi-definition defect that the lint backstop cannot resolve.

---

- [ ] 12. **RED (**sub-agent**).** Write an enforcement check that asserts the four reference documents contain a single consistent canonical guard definition and expects FAIL (not yet present or inconsistent). **→ SC-5**
- [ ] 13. **GREEN (**sub-agent**).** Define the single canonical guard definition in all four reference documents. **→ SC-5**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Re-run the RED check — it must now PASS (single consistent canonical definition present). **→ SC-5**
- [ ] 15. **Post-regression (**sub-agent**).** Run the `test-driven-development` phase-4 regression task. **→ SC-5**
- [ ] 16. **Verify (**sub-agent**).** Dispatch `verification-before-completion` verify task; assert a single consistent canonical definition is present across all four documents. **→ SC-5**
- [ ] 17. **Checkpoint commit (**inline**).** `checkpoint(#2339): item-5 — canonical guard definition finalized` **→ SC-5**

#### Phase 2 VbC

- [ ] 18. **VbC (**clean-room**).** Verify a single consistent canonical guard definition is present across all four reference documents. **→ SC-5**

**Concern transition:** Leaving canonical guard definition → entering content application and enforcement. Phases 3, 6, and 7 depend on Phase 2's canonical definition.
