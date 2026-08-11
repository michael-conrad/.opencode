# Phase 7 — Bug-only override uses removed

**Concern:** No `SKIP_STALE_POINTER_CHECK=1` invocation in the `.opencode` repository is attributable solely to this bug.

**Files:**
- `.opencode/` (repository-wide override-use search)

**SCs:** SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: per-submodule trunk lookup present
- Phase 1 VbC passed

**Exit Conditions:**
- Every `SKIP_STALE_POINTER_CHECK=1` invocation is either absent, or accompanied in the same file by a comment naming a non-bug rationale
- No invocation references the false-positive trunk-mismatch bug

---

- [ ] 31. **RED (**sub-agent**).** Write a failing enforcement test grepping for `SKIP_STALE_POINTER_CHECK=1` invocations whose adjacent comment references the false-positive trunk-mismatch bug; assert at least one such use exists or the enumeration is not yet verified (fails — change doesn't exist yet). **→ SC-7**
- [ ] 32. **GREEN (**sub-agent**).** Remove any `SKIP_STALE_POINTER_CHECK=1` use attributable solely to this bug, or add a comment naming a non-bug rationale where the use is legitimate. **→ SC-7**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Re-grep the `.opencode` repository; assert no invocation remains attributable solely to this bug. **→ SC-7**
- [ ] 34. **Checkpoint commit (**inline**).** Commit the override-use remediation.

#### Phase 7 VbC

- [ ] 35. **VbC (**clean-room**).** Re-grep the `.opencode` repository; assert no invocation remains attributable solely to this bug. **→ SC-7**

**Concern transition:** Leaving override-use remediation → entering post-implementation gates (structural checks, verification, audit, review-prep, PR creation).
