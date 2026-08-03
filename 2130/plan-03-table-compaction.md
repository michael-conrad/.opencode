# Phase 3 — Table Compaction

**Concern:** Replace the 8-row When This Applies decision table with a one-sentence exception containing "passive reading".

**Files:**
- `.opencode/guidelines/067-context-completeness.md`

**SCs:** SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2130 is approved
- Feature branch exists
- Baseline check confirms `grep -c 'passive reading'` returns 0

**Exit Conditions:**
- `## When This Applies` section (header + 8-row table) replaced with: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading."
- `grep -c 'passive reading'` returns 1

---

- [ ] 24. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-3**
- [ ] 25. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-3**
- [ ] 26. **RED (**sub-agent**).** Write grep test that fails — `grep -c 'passive reading'` returns 0 (phrase doesn't exist yet). **→ SC-3**
- [ ] 27. **GREEN (**sub-agent**).** Replace `## When This Applies` section (header + 8-row table) with: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading." **→ SC-3**
- [ ] 28. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3**
- [ ] 29. **Verify (**clean-room**).** Verify `grep -c 'passive reading'` returns 1. **→ SC-3**
- [ ] 30. **Commit (**inline**).** `git add .opencode/guidelines/067-context-completeness.md && git commit -m "phase-3: replace When This Applies table (SC-3)"` **→ SC-3**

#### Phase 3 VbC

- [ ] 31. **VbC (**clean-room**).** Verify `grep -c 'passive reading'` returns exactly 1. Verify the replacement text is present and correct. **→ SC-3**

**Concern transition:** Leaving table compaction → entering preservation verification. Phase 4 depends on all prior phases being complete.
