# Phase 3 — Re-justify mechanisms (§1.1)

**Concern:** Re-express result-contract frugality, the DISPATCH_GATE no-preloaded-context rule, and clean-room sub-agent discipline in `.opencode/guidelines/020-go-prohibitions.md` §1.1 as direct consequences of protecting the orchestrator's context resource, with their substance unchanged.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md` §1.1

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `020-go-prohibitions.md` re-scoped to allocation-by-context-cost
- Phase 1 VbC passed

**Exit Conditions:**
- Result-contract frugality, DISPATCH_GATE no-preloaded-context, and clean-room sub-agent discipline re-expressed under context-economy in §1.1
- Substance of all three mechanisms unchanged

---

**Cost frame:** Verifying the mechanism re-justification costs one grep of §1.1. Skipping means result-contract frugality and clean-room discipline remain justified by a false premise, undermining the entire delegation-integrity model.

- [ ] 14. **RED (**sub-agent**).** Write an enforcement test asserting the three mechanisms are not yet re-expressed under context-economy (fails). **→ SC-3**
- [ ] 15. **GREEN (**sub-agent**).** Re-express result-contract frugality, DISPATCH_GATE no-preloaded-context, and clean-room sub-agent discipline as direct consequences of protecting the orchestrator's context resource in `020-go-prohibitions.md` §1.1. **→ SC-3**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Verify the three mechanisms are re-expressed under context-economy and their substance is unchanged. **→ SC-3**
- [ ] 17. **Checkpoint commit (**inline**).** Commit the §1.1 re-justification. **→ SC-3**

#### Phase 3 VbC

- [ ] 18. **VbC (**clean-room**).** Verify §1.1 re-expresses the three mechanisms under context-economy with substance unchanged, and the cost-blind vs context-cost distinction is explicit. **→ SC-3**

**Concern transition:** Leaving §1.1 mechanism re-justification → entering 000-critical-rules.md alignment. Phase 4 depends on Phases 1-3.
