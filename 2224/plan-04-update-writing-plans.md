# Phase 4 — Update writing-plans/SKILL.md

**Concern:** Add all required references to `verify-plan-pipeline` in `writing-plans/SKILL.md`.

**Files:**
- `.opencode/skills/writing-plans/SKILL.md`

**SCs:** SC-4, SC-5, SC-6, SC-9, SC-10, SC-11

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task file exists at `writing-plans/tasks/verify-plan-pipeline.md`
- Phase 1 VbC passed
- `writing-plans/SKILL.md` currently has no references to `verify-plan-pipeline`

**Exit Conditions:**
- Task Cards table includes `verify-plan-pipeline` entry
- File Structure listing includes `tasks/verify-plan-pipeline.md`
- Description includes "verify plan pipeline" and "check pipeline completeness"
- TDT row exists mapping "verify plan pipeline" / "check pipeline completeness" to `verify-plan-pipeline` task
- Invocation section has entry for `verify-plan-pipeline` with canonical dispatch string
- Workflows section includes a step referencing `verify-plan-pipeline` dispatch

---

- [ ] 18. **RED (**sub-agent**).** Write failing test asserting `writing-plans/SKILL.md` has all 6 required references (Task Cards, File Structure, description, TDT, Invocation, Workflows). **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**
- [ ] 19. **GREEN (**sub-agent**).** Edit `writing-plans/SKILL.md` to add:
      - `verify-plan-pipeline` entry in Task Cards table
      - `tasks/verify-plan-pipeline.md` in File Structure listing
      - "verify plan pipeline" and "check pipeline completeness" in description
      - TDT row: `| "verify plan pipeline" / "check pipeline completeness" | \`verify-plan-pipeline\` | ...`
      - Invocation section entry for `verify-plan-pipeline` with canonical dispatch string
      - Workflows section step referencing `verify-plan-pipeline` dispatch **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Verify all 6 required references are present in `writing-plans/SKILL.md`. **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**
- [ ] 21. **Checkpoint commit (**inline**).** Commit writing-plans reference additions.

#### Phase 4 VbC

- [ ] 22. **VbC (**clean-room**).** Run targeted grep checks:
      - `grep -n 'verify-plan-pipeline' .opencode/skills/writing-plans/SKILL.md` — confirm matches in Task Cards, File Structure, TDT, Invocation, Workflows sections
      - `grep -nE 'verify plan pipeline|check pipeline completeness' .opencode/skills/writing-plans/SKILL.md` — confirm matches in description
      - Verify TDT row maps trigger phrases to `verify-plan-pipeline` task
      - Verify Invocation entry has canonical dispatch string **→ SC-4, SC-5, SC-6, SC-9, SC-10, SC-11**

**Concern transition:** Leaving writing-plans additions → entering behavioral verification. Phase 5 depends on Phase 4 being complete.
