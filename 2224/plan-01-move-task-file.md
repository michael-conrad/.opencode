# Phase 1 — Move Task File

**Concern:** Copy `verify-plan-pipeline.md` from `approval-gate-scope/tasks/` to `writing-plans/tasks/` and delete the source.

**Files:**
- `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md` (delete)
- `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` (new)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2224 is approved
- Feature branch exists
- Source file exists at `approval-gate-scope/tasks/verify-plan-pipeline.md`
- Target path does not exist at `writing-plans/tasks/verify-plan-pipeline.md`

**Exit Conditions:**
- `verify-plan-pipeline.md` exists at `writing-plans/tasks/`
- `verify-plan-pipeline.md` no longer exists at `approval-gate-scope/tasks/`

---

- [ ] 1. **RED (**sub-agent**).** Write failing test asserting `verify-plan-pipeline.md` exists at target path and does NOT exist at source path. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Copy file to target, delete from source. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify target exists, source deleted. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** Commit task file move.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `writing-plans/tasks/verify-plan-pipeline.md` exists and `approval-gate-scope/tasks/verify-plan-pipeline.md` does not. **→ SC-1**

**Concern transition:** Leaving file move → entering SKILL.md cross-reference updates. Phase 2 depends on Phase 1's file move.
