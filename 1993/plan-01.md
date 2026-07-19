# Phase 1 — SKILL.md restructure

**Concern:** Dispatch table integrity and pipeline definition

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)

**SCs:** SC-1, SC-3, SC-7, SC-8, SC-9, SC-10

**Dependencies:** None

**Entry conditions:** Spec #1993 approved, plan created

**Exit conditions:** SKILL.md has 3 dispatch entries, pipeline section present, operating-protocol.md deleted

**Code Path Coverage:** SKILL.md dispatch table (lines 27-39), Invocation table (lines 45-57), operating-protocol.md (entire file)

**Cross-Cutting SCs:** None

**Interface Boundaries:** SKILL.md is consumed by orchestrator via `skill()` — dispatch table entries must match canonical dispatch string format

**State Transitions:** SKILL.md transitions from 11-entry dispatch table to 3-entry dispatch table; pipeline content moves from operating-protocol.md to SKILL.md

---

- [ ] 1. **RED: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** **→ SC-1**
- [ ] 2. **GREEN: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** **→ SC-1**
- [ ] 3. **GREEN doublecheck (**inline**).** `grep -c '| \`' .opencode/skills/spec-creation/SKILL.md` on dispatch table section — count should be 2.
- [ ] 4. **Checkpoint commit (**inline**).** `git commit -m "1993: remove 8 fake dispatch entries from spec-creation SKILL.md"`

- [ ] 5. **RED: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** **→ SC-1**
- [ ] 6. **GREEN: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** **→ SC-1**
- [ ] 7. **GREEN doublecheck (**inline**).** `grep 'revise' .opencode/skills/spec-creation/SKILL.md | grep '|'` — should find dispatch row.
- [ ] 8. **Checkpoint commit (**inline**).** `git commit -m "1993: add revise dispatch entry to spec-creation SKILL.md"`

- [ ] 9. **RED: Add Pipeline section to SKILL.md (**sub-agent**).** **→ SC-3, SC-7, SC-8, SC-9, SC-10**
- [ ] 10. **GREEN: Add Pipeline section to SKILL.md (**sub-agent**).** **→ SC-3, SC-7, SC-8, SC-9, SC-10**
- [ ] 11. **GREEN doublecheck (**inline**).** `grep '## Pipeline' .opencode/skills/spec-creation/SKILL.md` — should find header. `grep -c 'contracts/' .opencode/skills/spec-creation/SKILL.md` — should be 0.
- [ ] 12. **Checkpoint commit (**inline**).** `git commit -m "1993: add 25-step create and 6-step revise pipeline to spec-creation SKILL.md"`

- [ ] 13. **RED: Delete `operating-protocol.md` task card (**sub-agent**).** **→ SC-3**
- [ ] 14. **GREEN: Delete `operating-protocol.md` task card (**sub-agent**).** **→ SC-3**
- [ ] 15. **GREEN doublecheck (**inline**).** `ls .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md 2>&1` — should return "No such file or directory".
- [ ] 16. **Checkpoint commit (**inline**).** `git commit -m "1993: delete operating-protocol.md task card, content moved to SKILL.md"`

#### Phase 1 VbC

- [ ] 17. **VbC (**clean-room**).**

**Concern transition:** Leaving dispatch table integrity → entering task card structural correctness. Phase 2 depends on Phase 1's SKILL.md having the correct pipeline section that the cleaned task cards will reference.
