# Phase 2 — Update approval-gate/SKILL.md

**Concern:** Remove all references to `verify-plan-pipeline` from `approval-gate/SKILL.md`.

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`

**SCs:** SC-2, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task file moved to `writing-plans/tasks/`
- Phase 1 VbC passed
- `approval-gate/SKILL.md` currently has TDT row, Invocation row, and description trigger phrases for `verify-plan-pipeline`

**Exit Conditions:**
- No TDT row for `verify-plan-pipeline` in `approval-gate/SKILL.md`
- No Invocation row for `verify-plan-pipeline` in `approval-gate/SKILL.md`
- Description no longer contains "verify plan pipeline" or "check pipeline completeness"

---

- [ ] 8. **RED (**sub-agent**).** Write failing test asserting `grep verify-plan-pipeline approval-gate/SKILL.md` returns no matches. **→ SC-2, SC-7**
- [ ] 9. **GREEN (**sub-agent**).** Remove TDT row for "verify plan pipeline" / "check pipeline completeness" from `approval-gate/SKILL.md`. Remove Invocation row for `verify-plan-pipeline`. Remove "verify plan pipeline" and "check pipeline completeness" from the skill description. **→ SC-2, SC-7**
- [ ] 10. **GREEN doublecheck (**clean-room**).** Grep `approval-gate/SKILL.md` for `verify-plan-pipeline` — confirm zero matches. Grep description for "verify plan pipeline" and "check pipeline completeness" — confirm absent. **→ SC-2, SC-7**
- [ ] 11. **Checkpoint commit (**inline**).** Commit approval-gate reference removals.

#### Phase 2 VbC

- [ ] 12. **VbC (**clean-room**).** Run `grep -n 'verify-plan-pipeline' .opencode/skills/approval-gate/SKILL.md` — confirm no matches. Run `grep -nE 'verify plan pipeline|check pipeline completeness' .opencode/skills/approval-gate/SKILL.md` — confirm no matches in description. **→ SC-2, SC-7**

**Concern transition:** Leaving approval-gate cleanup → entering approval-gate-scope cleanup. Phase 5 depends on Phase 2 being complete.
