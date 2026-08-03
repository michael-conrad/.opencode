# Phase 4 — Preservation Verification

**Concern:** Verify all keep sections remain with unchanged content (SC-6a), same position relative to each other (SC-6b), and same heading level (SC-6c).

**Files:**
- `.opencode/guidelines/067-context-completeness.md`

**SCs:** SC-6a, SC-6b, SC-6c

**Dependencies:** Phase 1, Phase 2, Phase 3

**Entry Conditions:**
- Phase 1 complete: Core Principle merged into Zero Tolerance
- Phase 2 complete: teaching material removed
- Phase 3 complete: When This Applies table replaced
- All prior phases committed

**Exit Conditions:**
- All keep sections have same content as original (verified by diff)
- All keep sections in same position relative to each other (verified by grep order)
- All keep sections at `##` heading level (verified by grep)

---

- [ ] 32. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-6a, SC-6b, SC-6c**
- [ ] 33. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-6a, SC-6b, SC-6c**
- [ ] 34. **RED — SC-6a (**sub-agent**).** Write diff test that fails — diff each keep section against original shows content changes. **→ SC-6a**
- [ ] 35. **GREEN — SC-6a (**sub-agent**).** No code change — verify-only SC. GREEN is the verification itself. **→ SC-6a**
- [ ] 36. **Verify — SC-6a (**clean-room**).** Verify diff each keep section against original; no content changes. **→ SC-6a**
- [ ] 37. **RED — SC-6b (**sub-agent**).** Write grep test that fails — section order differs from original. **→ SC-6b**
- [ ] 38. **GREEN — SC-6b (**sub-agent**).** No code change — verify-only SC. GREEN is the verification itself. **→ SC-6b**
- [ ] 39. **Verify — SC-6b (**clean-room**).** Verify grep for each section header; order matches original. **→ SC-6b**
- [ ] 40. **RED — SC-6c (**sub-agent**).** Write grep test that fails — heading level differs from original. **→ SC-6c**
- [ ] 41. **GREEN — SC-6c (**sub-agent**).** No code change — verify-only SC. GREEN is the verification itself. **→ SC-6c**
- [ ] 42. **Verify — SC-6c (**clean-room**).** Verify grep for each section header at `##` level; all at `##`. **→ SC-6c**
- [ ] 43. **Commit (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-4: verify preservation (SC-6a, SC-6b, SC-6c)"` **→ SC-6a, SC-6b, SC-6c**

#### Phase 4 VbC

- [ ] 44. **VbC (**clean-room**).** Verify all three preservation SCs pass: content unchanged (SC-6a), position preserved (SC-6b), heading level preserved (SC-6c). **→ SC-6a, SC-6b, SC-6c**
