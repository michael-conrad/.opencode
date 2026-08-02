# Phase 3 — Update approval-gate-scope/SKILL.md

**Concern:** Remove all references to `verify-plan-pipeline` from `approval-gate-scope/SKILL.md`.

**Files:**
- `.opencode/skills/approval-gate-scope/SKILL.md`

**SCs:** SC-3, SC-8

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task file moved to `writing-plans/tasks/`
- Phase 1 VbC passed
- `approval-gate-scope/SKILL.md` currently has TDT row for `verify-plan-pipeline`

**Exit Conditions:**
- No TDT row for `verify-plan-pipeline` in `approval-gate-scope/SKILL.md`
- Description no longer contains "verify plan pipeline" or "check pipeline completeness"

---

- [ ] 13. **RED (**sub-agent**).** Write failing test asserting `grep verify-plan-pipeline approval-gate-scope/SKILL.md` returns no matches. **→ SC-3, SC-8**
- [ ] 14. **GREEN (**sub-agent**).** Remove TDT row for `verify-plan-pipeline` from `approval-gate-scope/SKILL.md`. Remove "verify plan pipeline" and "check pipeline completeness" from the skill description if present. **→ SC-3, SC-8**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Grep `approval-gate-scope/SKILL.md` for `verify-plan-pipeline` — confirm zero matches. Grep description for trigger phrases — confirm absent. **→ SC-3, SC-8**
- [ ] 16. **Checkpoint commit (**inline**).** Commit approval-gate-scope reference removals.

#### Phase 3 VbC

- [ ] 17. **VbC (**clean-room**).** Run `grep -n 'verify-plan-pipeline' .opencode/skills/approval-gate-scope/SKILL.md` — confirm no matches. Run `grep -nE 'verify plan pipeline|check pipeline completeness' .opencode/skills/approval-gate-scope/SKILL.md` — confirm no matches in description. **→ SC-3, SC-8**

**Concern transition:** Leaving approval-gate-scope cleanup → entering writing-plans additions. Phase 5 depends on Phase 3 being complete.
