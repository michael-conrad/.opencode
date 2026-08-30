# Phase 3 — RESULT_ORDERING

**Concern:** Reinforce submodule-first ordering in result contract reporting sections of cleanup.md.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`

**SCs:** SC-3

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: guard note in cleanup.md Step 0, behavioral test committed
- Phase 2 VbC passed

**Exit Conditions:**
- cleanup.md result contract reporting sections list submodules before parent repo entries

---

- [ ] 11. **RED (**sub-agent**).** Write a failing enforcement test asserting that cleanup.md result contract sections list submodules before parent repo. Test must fail because the current ordering is parent-first. **→ SC-3**
- [ ] 12. **GREEN (**sub-agent**).** Reorder result contract reporting sections in cleanup.md so submodule entries precede parent repo entries. **→ SC-3**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Verify the test now passes with the reordered sections. **→ SC-3**
- [ ] 14. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/tasks/cleanup.md && git commit -m "Phase 3: reinforce submodule-first result contract ordering"`

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Verify SC-3: read cleanup.md result contract sections — confirm submodule entries precede parent repo entries. **→ SC-3**

**Concern transition:** All three concerns addressed. Proceed to post-implementation.
