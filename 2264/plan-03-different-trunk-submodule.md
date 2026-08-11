# Phase 3 — Different-trunk submodule not falsely flagged

**Concern:** A submodule whose trunk differs from the parent's trunk is no longer falsely flagged as stale when its staged pointer is at its own trunk tip.

**Files:**
- `.opencode/hooks/pre-commit`

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: per-submodule trunk lookup present
- Phase 1 VbC passed

**Exit Conditions:**
- Behavioral test against a submodule with trunk=`main` while parent trunk=`master` passes
- The hook allows the commit when the staged pointer is at the submodule's actual trunk tip

---

- [ ] 11. **RED (**sub-agent**).** Write a behavioral test running the stale-pointer check against a submodule with trunk=`main` while parent trunk=`master`; assert the hook currently blocks (fails — bug present). **→ SC-3**
- [ ] 12. **GREEN (**sub-agent**).** Apply the per-submodule lookup so the staged `origin/main` pointer matches the submodule's own trunk tip. **→ SC-3**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Re-run the behavioral test against the different-trunk submodule; assert the hook allows the commit. **→ SC-3**
- [ ] 14. **Checkpoint commit (**inline**).** Commit the behavioral test and the per-submodule lookup change.

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Re-run the behavioral test against the different-trunk submodule; assert the hook allows the commit. **→ SC-3**

**Concern transition:** Leaving different-trunk verification → entering shared-trunk regression. Phase 4 depends on Phase 1's per-submodule lookup.
