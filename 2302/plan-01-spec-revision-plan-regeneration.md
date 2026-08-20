# Phase 1 — Spec-revision → plan-regeneration linkage

**Concern:** Introduce the missing spec-revision → plan-regeneration linkage so a revised spec always regenerates its linked plan against the revised SC set, automatically.

**Files:**
- `.opencode/skills/spec-creation/` (spec revision pipeline)
- `.opencode/skills/writing-plans/` (plan regeneration linkage)

**SCs:** SC-1, SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2302 is approved (`approved-for-for_pr` label present)
- Feature branch exists
- Structure artifact exists at `.issues/2302/artifacts/structure.yaml`
- Z3 solve confirmed SAT for phase_1 → phase_2 ordering

**Exit Conditions:**
- When a spec is revised, the linked plan (if it exists) is regenerated to match the revised spec's SC set (SC-1)
- Plan regeneration is an automatic consequence of spec revision, not a manual corrective step (SC-2)

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC-1, SC-2**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-1, SC-2**
- [ ] 3. **RED (**sub-agent**).** Write a failing enforcement test asserting that when a spec is revised, the linked plan (if it exists) is regenerated to match the revised spec's SC set. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — add the spec-revision → plan-regeneration linkage in the spec-creation revision pipeline. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC-1**
- [ ] 6. **Verify (**clean-room**).** Verify implementation against SC-1. **→ SC-1**
- [ ] 7. **Commit (**inline**).** Stage and commit the SC-1 test + change together as one atomic slice.
- [ ] 8. **RED (**sub-agent**).** Write a failing enforcement test asserting that plan regeneration is an automatic consequence of spec revision, not a manual corrective step. **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Implement the change that makes the RED test pass — make regeneration automatic within the revision pipeline. **→ SC-2**
- [ ] 10. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC-2**
- [ ] 11. **Verify (**clean-room**).** Verify implementation against SC-2. **→ SC-2**
- [ ] 12. **Commit (**inline**).** Stage and commit the SC-2 test + change together as one atomic slice.

#### Phase 1 VbC

- [ ] 13. **VbC (**clean-room**).** Verify SC-1 and SC-2 are both implemented: spec revision regenerates the linked plan automatically against the revised SC set. **→ SC-1, SC-2**

**Concern transition:** Leaving spec-revision → plan-regeneration linkage → entering for_pr scope continuation. Phase 2 depends on Phase 1's regeneration linkage (SC-1/SC-2) being in place.
