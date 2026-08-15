# Phase 3 — Remove Non-Actionable Historical Records and Stale Cross-References

**Concern:** Remove non-actionable historical records and stale cross-references from the guideline.

**Files:**
- `.opencode/guidelines/117-session-trigger-behavior.md`

**SCs:** SC-6, SC-7, SC-8

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: existing sections narrowed
- Phase 2 VbC passed

**Exit Conditions:**
- No non-actionable historical records (SC-6)
- No stale cross-references (SC-7)
- No standalone 000-critical-rules.md reference (SC-8)

---

- [ ] 33. **RED (**sub-agent**).** Verifier runs the V-SC-6 checklist and expects FAIL (historical records present). **→ SC-6**
- [ ] 34. **GREEN (**sub-agent**).** Remove the purged triggers list, the spec #426 reference, the per-turn guard reference, and any non-actionable content. **→ SC-6**
- [ ] 35. **GREEN doublecheck (**clean-room**).** Re-run V-SC-6 — all four checks must PASS. **→ SC-6**
- [ ] 36. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-6 — non-actionable records removed`

- [ ] 37. **RED (**sub-agent**).** Verifier runs the V-SC-7 checklist and expects FAIL (stale cross-references present). **→ SC-7**
- [ ] 38. **GREEN (**sub-agent**).** Remove cross-references to `session_context_triggers.py`, `session-enforcement.ts`, and non-preloaded files. **→ SC-7**
- [ ] 39. **GREEN doublecheck (**clean-room**).** Re-run V-SC-7 — all three checks must PASS. **→ SC-7**
- [ ] 40. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-7 — stale cross-references removed`

- [ ] 41. **RED (**sub-agent**).** Verifier runs the V-SC-8 checklist and expects FAIL (standalone reference present). **→ SC-8**
- [ ] 42. **GREEN (**sub-agent**).** Remove the standalone cross-reference to `000-critical-rules.md`. **→ SC-8**
- [ ] 43. **GREEN doublecheck (**clean-room**).** Re-run V-SC-8 — the check must PASS. **→ SC-8**
- [ ] 44. **Checkpoint commit (**inline**).** `checkpoint(#2134): item-8 — standalone reference removed`

#### Phase 3 VbC

- [ ] 45. **VbC (**clean-room**).** Verify no non-actionable historical records, no stale cross-references, and no standalone 000-critical-rules.md reference. **→ SC-6, SC-7, SC-8**

**Concern transition:** Leaving removal of stale content → entering integration verification. Phase 4 depends on Phases 1, 2, and 3.
