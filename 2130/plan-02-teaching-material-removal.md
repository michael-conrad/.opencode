# Phase 2 — Teaching Material Removal

**Concern:** Remove three teaching material sections: Why This Matters (SC-2), Examples (SC-4), and Relationship to Other Critical Rules (SC-5).

**Files:**
- `.opencode/guidelines/067-context-completeness.md`

**SCs:** SC-2, SC-4, SC-5

**Dependencies:** None

**Entry Conditions:**
- Spec #2130 is approved
- Feature branch exists
- Baseline check confirms `grep -c 'Why This Matters'` returns 1, `grep -c 'Resource last read'` returns 1, `grep -c 'Relationship to Other Critical Rules'` returns 1

**Exit Conditions:**
- `## Why This Matters` section (header + table + blank lines) removed
- `### Examples` subsection (header + table + blank lines) removed
- `## Relationship to Other Critical Rules` section (header + prose + blank lines) removed
- `grep` for each removed section returns 0

---

- [ ] 9. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-2, SC-4, SC-5**
- [ ] 10. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-2, SC-4, SC-5**
- [ ] 11. **RED — SC-2 (**sub-agent**).** Write grep test that fails — `grep -c 'Why This Matters'` returns 1 (section exists). **→ SC-2**
- [ ] 12. **GREEN — SC-2 (**sub-agent**).** Delete `## Why This Matters` section (header + table + blank lines). **→ SC-2**
- [ ] 13. **Verify — SC-2 (**clean-room**).** Verify `grep -c 'Why This Matters'` returns 0. **→ SC-2**
- [ ] 14. **Commit — SC-2 (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-2a: remove Why This Matters (SC-2)"` **→ SC-2**
- [ ] 15. **RED — SC-4 (**sub-agent**).** Write grep test that fails — `grep -c 'Resource last read'` returns 1 (section exists). **→ SC-4**
- [ ] 16. **GREEN — SC-4 (**sub-agent**).** Delete `### Examples` subsection (header + table + blank lines). **→ SC-4**
- [ ] 17. **Verify — SC-4 (**clean-room**).** Verify `grep -c 'Resource last read'` returns 0. **→ SC-4**
- [ ] 18. **Commit — SC-4 (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-2b: remove Examples subsection (SC-4)"` **→ SC-4**
- [ ] 19. **RED — SC-5 (**sub-agent**).** Write grep test that fails — `grep -c 'Relationship to Other Critical Rules'` returns 1 (section exists). **→ SC-5**
- [ ] 20. **GREEN — SC-5 (**sub-agent**).** Delete `## Relationship to Other Critical Rules` section (header + prose + blank lines). **→ SC-5**
- [ ] 21. **Verify — SC-5 (**clean-room**).** Verify `grep -c 'Relationship to Other Critical Rules'` returns 0. **→ SC-5**
- [ ] 22. **Commit — SC-5 (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-2c: remove Relationship to Other Critical Rules (SC-5)"` **→ SC-5**

#### Phase 2 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all three removed sections are absent: `grep` for 'Why This Matters', 'Resource last read', 'Relationship to Other Critical Rules' all return 0. **→ SC-2, SC-4, SC-5**

**Concern transition:** Leaving teaching material removal → entering table compaction. Phase 3 operates on a disjoint section of the same file.
