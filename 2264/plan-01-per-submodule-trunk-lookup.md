# Phase 1 — Per-submodule trunk lookup

**Concern:** Gate 2 derives `REMOTE_SHA` from each submodule's own `HEAD branch:` line instead of the parent repo's `DEFAULT_BRANCH`.

**Files:**
- `.opencode/hooks/pre-commit`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2264 is approved
- Feature branch exists
- `.opencode/hooks/pre-commit` Gate 2 currently uses `origin/$DEFAULT_BRANCH` at line 54

**Exit Conditions:**
- Line 54 derives `SUBMODULE_TRUNK` from `git -C "$sp" remote show origin` and uses it for the `REMOTE_SHA` rev-parse
- Line 54 no longer uses `origin/$DEFAULT_BRANCH`

---

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting `.opencode/hooks/pre-commit` line 54 currently derives `REMOTE_SHA` from the parent's `DEFAULT_BRANCH` (fails — change doesn't exist yet). **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Replace line 54 with the per-submodule `SUBMODULE_TRUNK` extraction from `git -C "$sp" remote show origin`. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify line 54 uses `SUBMODULE_TRUNK` and does not use `origin/$DEFAULT_BRANCH`. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the per-submodule trunk lookup change.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** grep `.opencode/hooks/pre-commit` for `SUBMODULE_TRUNK`; assert line 54 does not use `origin/$DEFAULT_BRANCH`. **→ SC-1**

**Concern transition:** Leaving per-submodule trunk lookup → entering parent-trunk fallback. Phase 2 depends on Phase 1's `SUBMODULE_TRUNK` variable.
