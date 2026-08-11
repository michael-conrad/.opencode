# Phase 7 — Preserve delegation / distinguish costs

**Concern:** Verify the delegation mechanism (task(), skill(), clean-room sub-agents) is preserved exactly and that "cost-blind" (verification cost) is explicitly distinguished from "context-cost" (orchestrator context resource). This is a verification-only phase — no behavioral file change to delegation.

**Files:**
- All affected files (verification only)

**SCs:** SC-7

**Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6

**Entry Conditions:**
- Phases 1-6 complete: all files updated and contradiction eliminated
- Phases 1-6 VbC passed

**Exit Conditions:**
- Delegation mechanism unchanged (no change to which tasks are delegated vs inline)
- Cost-blind vs context-cost distinction explicit in affected files
- Enforcement of actual inline work (large/disposable) preserved

---

**Cost frame:** Verifying delegation preservation costs one grep. Skipping means the re-scope could be read as changing which tasks are delegated, a behavioral regression that breaks the pipeline's integrity.

- [ ] 34. **RED (**sub-agent**).** Write an enforcement test asserting the delegation mechanism or cost-dimension distinction is not yet verified (fails). **→ SC-7**
- [ ] 35. **GREEN (**sub-agent**).** Verify the delegation mechanism is unchanged and the cost-blind vs context-cost distinction is explicit (verification-only; no behavioral file change to delegation). **→ SC-7**
- [ ] 36. **GREEN doublecheck (**clean-room**).** Verify delegation mechanism unchanged, cost-blind vs context-cost distinction explicit, and enforcement of large/disposable inline work preserved. **→ SC-7**
- [ ] 37. **Checkpoint commit (**inline**).** Commit any documentation clarifying the cost-dimension distinction. **→ SC-7**

#### Phase 7 VbC

- [ ] 38. **VbC (**clean-room**).** Verify the delegation mechanism is unchanged and the cost-blind vs context-cost distinction is explicit in all affected files. **→ SC-7**

**Concern transition:** Delegation preservation guard complete. All phases done — proceeding to global post-implementation steps (steps 39-46).
