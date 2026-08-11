# Phase 6 — Two-submodule behavioral verification

**Concern:** The stale-pointer check is verified against at least 2 submodules with known-different trunks (`SharedPojos` uses `main`, `Patents` uses `master`).

**Files:**
- `.opencode/hooks/pre-commit`

**SCs:** SC-6

**Dependencies:** Phase 3, Phase 4

**Entry Conditions:**
- Phase 3 complete: different-trunk behavioral test passes
- Phase 4 complete: shared-trunk regression test passes
- Phase 3 and Phase 4 VbC passed

**Exit Conditions:**
- Behavioral test against both `SharedPojos` (trunk=`main`) and a shared-trunk submodule (`master`) passes
- Both submodules pass without false positives

---

- [ ] 26. **RED (**sub-agent**).** Write a behavioral test running the stale-pointer check against both `SharedPojos` (trunk=`main`) and a shared-trunk submodule (`master`); assert current behavior blocks `SharedPojos` (fails — bug present). **→ SC-6**
- [ ] 27. **GREEN (**sub-agent**).** Apply the per-submodule lookup so both submodules pass without false positives. **→ SC-6**
- [ ] 28. **GREEN doublecheck (**clean-room**).** Re-run the two-submodule behavioral test; assert both pass. **→ SC-6**
- [ ] 29. **Checkpoint commit (**inline**).** Commit the two-submodule verification test.

#### Phase 6 VbC

- [ ] 30. **VbC (**clean-room**).** Re-run the two-submodule behavioral test; assert both pass. **→ SC-6**

**Concern transition:** Leaving two-submodule verification → entering override-use remediation. Phase 7 depends on Phase 1's per-submodule lookup.
