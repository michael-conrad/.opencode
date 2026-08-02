# Phase 3 — Update writing-plans/SKILL.md

**Concern:** Add all `verify-plan-pipeline` references to `writing-plans/SKILL.md` — Task Cards table entry, File Structure listing, description trigger phrases, TDT row, Invocation section entry, and Workflows step.

**Files:**
- `.opencode/skills/writing-plans/SKILL.md`

**SCs:** SC-4, SC-5, SC-6, SC-9, SC-10, SC-11

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task file exists at target
- Phase 1 VbC passed
- `writing-plans/SKILL.md` exists and does NOT yet reference `verify-plan-pipeline`

**Exit Conditions:**
- `writing-plans/SKILL.md` has all required references: Task Cards, File Structure, TDT, Invocation, Workflows, description

---

- [ ] 12. **RED (**sub-agent**).** Write failing test asserting `verify-plan-pipeline` references are absent from `writing-plans/SKILL.md`. **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**
- [ ] 13. **GREEN (**sub-agent**).** Add Task Cards table entry for verify-plan-pipeline. **→ SC-4**
- [ ] 14. **GREEN (**sub-agent**).** Add File Structure listing for `tasks/verify-plan-pipeline.md`. **→ SC-5**
- [ ] 15. **GREEN (**sub-agent**).** Add description trigger phrases "verify plan pipeline" and "check pipeline completeness". **→ SC-6**
- [ ] 16. **GREEN (**sub-agent**).** Add TDT row mapping "verify plan pipeline" / "check pipeline completeness" to verify-plan-pipeline task. **→ SC-9**
- [ ] 17. **GREEN (**sub-agent**).** Add Invocation section entry with canonical dispatch string. **→ SC-10**
- [ ] 18. **GREEN (**sub-agent**).** Add Workflows section step referencing verify-plan-pipeline dispatch. **→ SC-11**
- [ ] 19. **GREEN doublecheck (**clean-room**).** Verify all 6 reference types are present. **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**
- [ ] 20. **Checkpoint commit (**inline**).** Commit writing-plans/SKILL.md additions.

#### Phase 3 VbC

- [ ] 21. **VbC (**clean-room**).** Verify all 6 required reference types exist in `writing-plans/SKILL.md`. **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**

**Concern transition:** Leaving SKILL.md updates → entering behavioral verification. Phase 4 depends on both Phase 2 and Phase 3 (both SKILL.md files must be updated for routing to work correctly).
