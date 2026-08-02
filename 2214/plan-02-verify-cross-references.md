# Phase 2 — Verify Cross-Reference Integrity

**Concern:** Confirm all consuming task files still resolve the reference file at the same path after the rewrite.

**Files:**
- `skills/writing-plans/tasks/create.md`
- `skills/writing-plans/tasks/research.md`
- `skills/writing-plans/tasks/validate.md`
- `skills/audit/tasks/` (spec auditor, plan auditor)

**SCs:** SC-9, SC-10

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: file rewritten
- Phase 1 VbC passed

**Exit Conditions:**
- All cross-references to `implementation-workflow.md` in consuming task files still resolve
- Plan writer task files (create.md, research.md, validate.md) still read the file at the same path

**Cost frame:** Verification-only phase. All SCs verified by grep — no behavioral tests needed. Low risk, low revert cost.

---

- [ ] 6. **RED (**sub-agent**).** Write enforcement test that greps for broken read paths in consuming task files. Test FAILS if any reference to `implementation-workflow.md` does not resolve. **→ SC-9, SC-10**
- [ ] 7. **GREEN (**sub-agent**).** Verify cross-references:
  - Grep `skills/writing-plans/tasks/create.md` for `implementation-workflow.md` — confirm path resolves
  - Grep `skills/writing-plans/tasks/research.md` for `implementation-workflow.md` — confirm path resolves
  - Grep `skills/writing-plans/tasks/validate.md` for `implementation-workflow.md` — confirm path resolves
  - Grep `skills/audit/tasks/` for `implementation-workflow.md` — confirm all paths resolve
  - No changes needed — the file path has not changed (REQ-1 guarantees path stability)
  - **→ SC-9, SC-10**
- [ ] 8. **GREEN doublecheck (**clean-room**).** Verify all consuming task files reference the correct path and no broken references exist. **→ SC-9, SC-10**
- [ ] 9. **Checkpoint commit (**inline**).** Commit cross-reference verification.

#### Phase 2 VbC

- [ ] 10. **VbC (**clean-room**).** Verify SC-9 and SC-10 pass with string evidence (grep). **→ SC-9, SC-10**

**Concern transition:** Leaving cross-reference verification → entering post-implementation. All SCs covered.
