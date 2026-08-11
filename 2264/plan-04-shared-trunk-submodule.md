# Phase 4 — Shared-trunk submodule no regression

**Concern:** A submodule sharing the parent's trunk continues to pass the stale-pointer check without regression.

**Files:**
- `.opencode/hooks/pre-commit`

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: per-submodule trunk lookup present
- Phase 1 VbC passed

**Exit Conditions:**
- Behavioral test against a submodule sharing the parent's trunk (`master`) passes
- The hook allows the commit when the staged pointer is at the shared trunk tip

---

- [ ] 16. **RED (**sub-agent**).** Write a behavioral test running the stale-pointer check against a submodule sharing the parent trunk; assert the hook currently allows the commit (passes before change — establishes baseline). **→ SC-4**
- [ ] 17. **GREEN (**sub-agent**).** Apply the per-submodule lookup and confirm the shared-trunk submodule still passes. **→ SC-4**
- [ ] 18. **GREEN doublecheck (**clean-room**).** Re-run the behavioral test against the shared-trunk submodule; assert no regression. **→ SC-4**
- [ ] 19. **Checkpoint commit (**inline**).** Commit the shared-trunk regression test.

#### Phase 4 VbC

- [ ] 20. **VbC (**clean-room**).** Re-run the behavioral test against the shared-trunk submodule; assert no regression. **→ SC-4**

**Concern transition:** Leaving shared-trunk regression → entering documentation update. Phase 5 depends on Phase 1's per-submodule lookup.
