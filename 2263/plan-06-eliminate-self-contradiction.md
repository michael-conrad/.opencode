# Phase 6 — Eliminate self-contradiction

**Concern:** Eliminate the self-contradiction so no affected file contains both the "never inline" absolute and inline-designated tasks without reconciliation under the context-economy model; the orchestrator can load a skill and dispatch without reconciling contradictory signals.

**Files:**
- All affected files (020, 000, 36 skill cards)
- Behavioral enforcement tests in `.opencode/tests-v2/behaviors/` that assert the "never inline" absolute

**SCs:** SC-6

**Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5

**Entry Conditions:**
- Phases 1-5 complete: all files re-scoped and re-justified
- Phases 1-5 VbC passed

**Exit Conditions:**
- No file contains both the "never inline" absolute and inline-designated tasks without reconciliation
- Behavioral enforcement tests asserting the "never inline" absolute updated to assert the context-economy model
- Skill-load scenario runs without contradiction (behavioral evidence)

---

**Cost frame:** Running the behavioral test costs minutes of execution time. Skipping means a residual contradiction ships, and the orchestrator is pushed toward rationalization in production — the behavioral defect this spec exists to prevent.

- [ ] 29. **RED (**sub-agent**).** Write an enforcement test asserting a residual contradiction exists when the orchestrator loads a skill (fails). Update any behavioral enforcement test in `.opencode/tests-v2/behaviors/` asserting the "never inline" absolute to assert the context-economy model. **→ SC-6**
- [ ] 30. **GREEN (**sub-agent**).** Ensure all affected files are consistent — no file contains both the "never inline" absolute and inline-designated tasks without reconciliation. **→ SC-6**
- [ ] 31. **GREEN doublecheck (**clean-room**).** Run the skill-load scenario via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` with a >=600s timeout; assert the orchestrator loads a skill and dispatches without triggering a contradiction. **→ SC-6 (behavioral)**
- [ ] 32. **Checkpoint commit (**inline**).** Commit cross-file consistency changes. **→ SC-6**

#### Phase 6 VbC

- [ ] 33. **VbC (**clean-room**).** Verify via behavioral evidence that the orchestrator loads a skill and dispatches without reconciling contradictory signals. **→ SC-6**

**Concern transition:** Leaving contradiction elimination → entering delegation preservation guard. Phase 7 depends on Phases 1-6.
