# Phase 2 — Remove from approval-gate SKILL.md files

**Concern:** Remove all `verify-plan-pipeline` references from both `approval-gate/SKILL.md` and `approval-gate-scope/SKILL.md` — TDT rows, Invocation entries, and description trigger phrases.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/approval-gate-scope/SKILL.md`

**SCs:** SC-2, SC-3, SC-7, SC-8

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task file moved
- Phase 1 VbC passed
- Both SKILL.md files exist and contain `verify-plan-pipeline` references

**Exit Conditions:**
- `approval-gate/SKILL.md` has no TDT row, Invocation entry, or description phrase referencing `verify-plan-pipeline`
- `approval-gate-scope/SKILL.md` has no TDT row or description phrase referencing `verify-plan-pipeline`

---

- [ ] 6. **RED (**sub-agent**).** Write failing test asserting `verify-plan-pipeline` references still exist in both SKILL.md files. **→ SC-2, SC-3, SC-7, SC-8**
- [ ] 7. **GREEN (**sub-agent**).** Remove TDT rows, Invocation entries, and description trigger phrases from `approval-gate/SKILL.md`. **→ SC-2, SC-7**
- [ ] 8. **GREEN (**sub-agent**).** Remove TDT rows and description trigger phrases from `approval-gate-scope/SKILL.md`. **→ SC-3, SC-8**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Verify no `verify-plan-pipeline` references remain in either file. **→ SC-2, SC-3, SC-7, SC-8**
- [ ] 10. **Checkpoint commit (**inline**).** Commit SKILL.md removals.

#### Phase 2 VbC

- [ ] 11. **VbC (**clean-room**).** Grep both files for `verify-plan-pipeline` — confirm zero matches. **→ SC-2, SC-3, SC-7, SC-8**

**Concern transition:** Leaving approval-gate removals → entering writing-plans additions. Phase 3 depends on Phase 1's file move (the target file must exist before writing-plans/SKILL.md references it).
