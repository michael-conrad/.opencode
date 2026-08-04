# Phase 8 — Documentation

**Concern:** Document the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new full-environment opt-in capability.

**Files:**
- `.opencode/tests-v2/AGENTS.md` (§5 Infrastructure Details, §12 GitBucket)

**SCs:** SC18

**Dependencies:** None

**Entry Conditions:**
- `tests-v2/AGENTS.md` §5 and §12 read to understand current documentation.

**Exit Conditions:**
- `tests-v2/AGENTS.md` documents the mutual-exclusion rule and the full-env opt-in capability.

---

- [ ] 36. **RED (**sub-agent**).** Write a failing enforcement test asserting `.opencode/tests-v2/AGENTS.md` does not document the mutual-exclusion rule or the new opt-in capability. **→ SC18**

- [ ] 37. **GREEN (**sub-agent**).** Add a section to `.opencode/tests-v2/AGENTS.md` documenting the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` / `BEHAVIOR_SET_BARE_REMOTE` mutual-exclusion rule and the new full-environment opt-in capability (multi-submodule fixtures + GitBucket origin wiring). **→ SC18**

- [ ] 38. **GREEN doublecheck (**clean-room**).** Inspect `.opencode/tests-v2/AGENTS.md` for the documenting section covering both the mutual-exclusion rule and the opt-in capability. **→ SC18**

- [ ] 39. **Checkpoint commit (**inline**).** Commit `tests-v2/AGENTS.md` documentation. (No co-author trailer — added at squash time.)

#### Phase 8 VbC

- [ ] 40. **VbC (**clean-room**).** Verify SC18: `.opencode/tests-v2/AGENTS.md` documents the mutual-exclusion rule and the full-env opt-in capability. **→ SC18**

**Concern transition:** Leaving documentation → entering final no-regression default gate.

---
