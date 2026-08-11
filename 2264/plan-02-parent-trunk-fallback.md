# Phase 2 — Parent-trunk fallback

**Concern:** An empty `SUBMODULE_TRUNK` resolves to `DEFAULT_BRANCH` on lookup failure.

**Files:**
- `.opencode/hooks/pre-commit`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `SUBMODULE_TRUNK` variable exists in Gate 2
- Phase 1 VbC passed

**Exit Conditions:**
- The fallback `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"` is present
- The fallback fires only when `SUBMODULE_TRUNK` is empty after extraction

---

- [ ] 6. **RED (**sub-agent**).** Write a failing enforcement test asserting the fallback `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"` is absent (fails — change doesn't exist yet). **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Add the fallback assignment so an empty `SUBMODULE_TRUNK` resolves to `DEFAULT_BRANCH`. **→ SC-2**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify the fallback fires only on empty `SUBMODULE_TRUNK`. **→ SC-2**
- [ ] 9. **Checkpoint commit (**inline**).** Commit the fallback change.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** grep `.opencode/hooks/pre-commit` for the exact fallback line; assert it fires only on empty `SUBMODULE_TRUNK`. **→ SC-2**

**Concern transition:** Leaving parent-trunk fallback → entering different-trunk behavioral verification. Phase 3 depends on Phase 1's per-submodule lookup.
