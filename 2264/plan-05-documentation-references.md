# Phase 5 — Documentation references updated

**Concern:** Documentation references to the trunk-detection logic describe the per-submodule lookup and parent-trunk fallback.

**Files:**
- `.opencode/commands/submodule-tag-prework.md`

**SCs:** SC-5

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: per-submodule trunk lookup present
- Phase 1 VbC passed

**Exit Conditions:**
- `.opencode/commands/submodule-tag-prework.md` describes the per-submodule lookup and parent-trunk fallback
- No trunk-detection reference describes the parent-trunk-only lookup

---

- [ ] 21. **RED (**sub-agent**).** Write a failing enforcement test grepping documentation referencing trunk detection; assert current docs do not describe the per-submodule lookup (fails — change doesn't exist yet). **→ SC-5**
- [ ] 22. **GREEN (**sub-agent**).** Update `.opencode/commands/submodule-tag-prework.md` and any other trunk-detection references to describe the per-submodule lookup and parent-trunk fallback. **→ SC-5**
- [ ] 23. **GREEN doublecheck (**clean-room**).** Verify the documentation describes the per-submodule lookup and fallback reference. **→ SC-5**
- [ ] 24. **Checkpoint commit (**inline**).** Commit the documentation update.

#### Phase 5 VbC

- [ ] 25. **VbC (**clean-room**).** grep the documentation for the per-submodule lookup description and fallback reference. **→ SC-5**

**Concern transition:** Leaving documentation update → entering two-submodule behavioral verification. Phase 6 depends on Phase 3 and Phase 4.
