# Phase 1 — Re-scope 020 inline-work rule

**Concern:** Replace the role-purity "orchestrator NEVER performs inline work" absolute in `.opencode/guidelines/020-go-prohibitions.md` with the allocation-by-context-cost model.

**Files:**
- `.opencode/guidelines/020-go-prohibitions.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2263 approved (`approved-for-pr` label present)
- Feature branch exists per `git-workflow` pre-work
- Phase 0 pre-implementation gates (coherence gate, baseline check) passed

**Exit Conditions:**
- `020-go-prohibitions.md` contains the allocation-by-context-cost model (large/disposable → sub-agent; small/necessary → orchestrator)
- No "NEVER performs inline work" absolute remains
- Enforcement of large/disposable inline work preserved
- Cost-blind (verification) explicitly distinguished from context-cost (orchestrator context)

---

**Cost frame:** Verifying the re-scope costs one grep of `020-go-prohibitions.md`. Skipping means the role-purity absolute persists, forcing the orchestrator to rationalize a false carve-out on every skill load — the exact defect this spec eliminates.

- [ ] 3. **Pre-implementation (**inline**).** Run the coherence gate and baseline check steps from the pre-implementation section of the plan. **→ global pre-gate**

- [ ] 4. **RED (**sub-agent**).** Write an enforcement test asserting the "NEVER performs inline work" absolute is present (fails because the change doesn't exist yet). **→ SC-1**
- [ ] 5. **GREEN (**sub-agent**).** Replace the role-purity absolute with the allocation-by-context-cost model in `.opencode/guidelines/020-go-prohibitions.md`. **→ SC-1**
- [ ] 6. **GREEN doublecheck (**clean-room**).** Verify no "NEVER performs inline work" absolute remains and allocation-by-context-cost language is present. **→ SC-1**
- [ ] 7. **Checkpoint commit (**inline**).** Commit the re-scoped rule text. **→ SC-1**

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify `020-go-prohibitions.md` contains the allocation-by-context-cost model, no "NEVER performs inline work" absolute remains, and the enforcement guard on large/disposable work is preserved. **→ SC-1**

**Concern transition:** Leaving rule re-scoping → entering carve-out replacement. Phase 2 depends on Phase 1's re-scoped rule.
