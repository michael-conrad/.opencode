# Phase 2 — Workflow Changes

**Concern:** Add handoff task, update workflow order, update TDT and Workflows section, enhance completion task.

**Files:**
- `.opencode/skills/writing-plans/tasks/handoff.md` (create)
- `.opencode/skills/writing-plans/SKILL.md` (modify)
- `.opencode/skills/writing-plans/tasks/completion.md` (modify)

**SCs:** SC-2, SC-3, SC-6, SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `plan-creation-pipeline/` deleted, cross-references updated
- Phase 1 VbC passed

**Exit Conditions:**
- `writing-plans/tasks/handoff.md` exists and calls `approval-gate --task verify-authorization`
- `writing-plans/SKILL.md` Workflows section order is: handoff → analyze → research → create → validate → (revise loop) → completion
- `writing-plans/SKILL.md` Trigger Dispatch Table includes handoff entry
- `writing-plans/tasks/completion.md` includes `local-issues sync` and chat output with exec summary + URL + AI byline

---

### Item 1 — SC-2: Create handoff task

- [ ] 10. **RED (**sub-agent**).** Write a failing enforcement test that verifies `handoff` dispatch appears in stderr when creating a plan. **→ SC-2**
- [ ] 11. **GREEN (**sub-agent**).** Create `writing-plans/tasks/handoff.md` that calls `approval-gate --task verify-authorization` and returns DONE or BLOCKED. **→ SC-2**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Verify handoff task exists and calls `approval-gate --task verify-authorization`. **→ SC-2**
- [ ] 13. **Checkpoint commit (**inline**).** Commit handoff task creation. **→ SC-2**

### Item 2 — SC-3: Update workflow order

- [ ] 14. **RED (**sub-agent**).** Write a failing enforcement test that verifies the workflow order in `writing-plans/SKILL.md` is handoff → analyze → research → create → validate → (revise loop) → completion. **→ SC-3**
- [ ] 15. **GREEN (**sub-agent**).** Update `writing-plans/SKILL.md` Workflows section: reorder to handoff → analyze → research → create → validate → (revise loop) → completion. **→ SC-3**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Verify the sequential step order matches the new workflow. **→ SC-3**
- [ ] 17. **Checkpoint commit (**inline**).** Commit workflow order update. **→ SC-3**

### Item 3 — SC-6: Update TDT and Workflows section

- [ ] 18. **RED (**sub-agent**).** Write a failing enforcement test that verifies `handoff` appears in the Trigger Dispatch Table and Workflows section. **→ SC-6**
- [ ] 19. **GREEN (**sub-agent**).** Update `writing-plans/SKILL.md` Trigger Dispatch Table to include `handoff` entry. **→ SC-6**
- [ ] 20. **GREEN (**sub-agent**).** Update `writing-plans/SKILL.md` Workflows section to reflect the new workflow with handoff. **→ SC-6**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify `handoff` appears in both TDT and Workflows section. **→ SC-6**
- [ ] 22. **Checkpoint commit (**inline**).** Commit TDT and Workflows updates. **→ SC-6**

### Item 4 — SC-4: Enhance completion.md

- [ ] 23. **RED (**sub-agent**).** Write a failing enforcement test that verifies `local-issues sync` and byline pattern appear in completion output. **→ SC-4**
- [ ] 24. **GREEN (**sub-agent**).** Enhance `writing-plans/tasks/completion.md`: add `local-issues sync` call and chat output with exec summary + URL + AI byline. **→ SC-4**
- [ ] 25. **GREEN doublecheck (**clean-room**).** Verify `local-issues sync` and byline pattern are present in completion.md. **→ SC-4**
- [ ] 26. **Checkpoint commit (**inline**).** Commit completion enhancement. **→ SC-4**

#### Phase 2 VbC

- [ ] 27. **VbC (**clean-room**).** Verify SC-2 (handoff task), SC-3 (workflow order), SC-6 (TDT/Workflows), SC-4 (completion enhancement). **→ SC-2, SC-3, SC-6, SC-4**

**Concern transition:** Leaving workflow changes → entering no-change verification. Phase 3 depends on Phase 2's modifications being complete.
