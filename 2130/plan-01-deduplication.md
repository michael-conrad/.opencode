# Phase 1 — Deduplication

**Concern:** Merge the duplicate Core Principle section into the Zero Tolerance section so the phrase "read ALL comments" appears exactly once.

**Files:**
- `.opencode/guidelines/067-context-completeness.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2130 is approved
- Feature branch exists
- Baseline check confirms `grep -c 'read ALL comments'` returns 2

**Exit Conditions:**
- Core Principle section header and body removed
- Core Principle's scope language ("reviewing, auditing, or taking any action") incorporated into Zero Tolerance
- `grep -c 'read ALL comments'` returns 1

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-1**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-1**
- [ ] 3. **RED (**sub-agent**).** Write grep test that fails — `grep -c 'read ALL comments'` returns 2 (currently duplicated). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Merge Core Principle body into Zero Tolerance section: remove the `## Core Principle` section header and body. Incorporate the scope language "reviewing, auditing, or taking any action" into the `## Zero Tolerance Rule` section as elaboration. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-1**
- [ ] 6. **Verify (**clean-room**).** Verify `grep -c 'read ALL comments'` returns 1. **→ SC-1**
- [ ] 7. **Commit (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-1: merge Core Principle into Zero Tolerance (SC-1)"` **→ SC-1**

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify `grep -c 'read ALL comments'` returns exactly 1. Verify the merged Zero Tolerance section includes the broader scope language ("reviewing, auditing, or taking any action"). **→ SC-1**

**Concern transition:** Leaving deduplication → entering teaching material removal. Phase 2 operates on disjoint sections of the same file.
