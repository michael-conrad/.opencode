# Phase 3 — Producer-consumer schema agreement verification

**Concern:** Verify that the `dependency_contract` section structure emitted by the spec-creation pipeline (Phase 1) matches the contract schema templates expected by `solve`/`plan` tools.

**Files:**
- `.opencode/skills/writing-plans/contracts/` (contract templates for comparison)
- `.opencode/skills/spec-creation/` (producer side for comparison)
- `.opencode/skills/writing-plans/tasks/research.md` (consumer side for comparison)

**SCs:** SC-2

**Dependencies:** Phase 1 (needs Phase 1's modified artifact structure to compare against contract templates)

**Entry Conditions:**
- Phase 1 complete: spec-creation emits `dependency_contract` section in `interface-compatibility.yaml`
- Phase 1 VbC passed
- Contract templates at `writing-plans/contracts/` are readable

**Exit Conditions:**
- The `dependency_contract` section structure emitted by spec-creation (Phase 1) matches the contract schema templates at `writing-plans/contracts/`
- The `dependency_contract` section structure consumed by research.md step 9 matches the same contract templates
- No structural divergence between producer and consumer expectations

---

- [ ] 15. **Pre-regression (**sub-agent**).** Run regression test patterns to establish baseline. **→ SC-2**
- [ ] 16. **RED (**sub-agent**).** Write a behavioral test that compares the Phase 1-generated `dependency_contract` section against the writing-plans contract templates. The test fails if any structural mismatch is found (key names, nesting, required vs optional fields). **→ SC-2**
- [ ] 17. **GREEN (**sub-agent**).** If RED test reveals mismatches, align the producer (spec-creation) or consumer (research.md) to match the contract templates. If no mismatches found, add a cross-reference verification step documenting the schema alignment. **→ SC-2**
- [ ] 18. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-2**
- [ ] 19. **Verify (**clean-room**).** Run verification-before-completion: confirm all three sides (producer, consumer, contract templates) agree on the `dependency_contract` schema. **→ SC-2**
- [ ] 20. **Commit (**inline**).** `git add .opencode/skills/spec-creation/ .opencode/skills/writing-plans/ && git commit -m "phase 3: verify producer-consumer schema agreement for dependency_contract (#2413 SC-2)"`

#### Phase 3 VbC

- [ ] 21. **VbC (**clean-room**).** Verify Phase 3 deliverable meets all exit conditions. **→ SC-2**

**Concern transition:** All three SCs covered. Ready for post-implementation steps.
