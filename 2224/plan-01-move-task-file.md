# Phase 1 — Move Task File

**Concern:** Move the `verify-plan-pipeline` task file from `approval-gate-scope` to `writing-plans`.

**Files:**
- `.opencode/skills/approval-gate-scope/tasks/verify-plan-pipeline.md` (deleted)
- `.opencode/skills/writing-plans/tasks/verify-plan-pipeline.md` (new)

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2224 is approved
- Feature branch exists
- Source file exists at `approval-gate-scope/tasks/verify-plan-pipeline.md`
- Target file does NOT exist at `writing-plans/tasks/verify-plan-pipeline.md`

**Exit Conditions:**
- `verify-plan-pipeline.md` exists at `writing-plans/tasks/`
- `verify-plan-pipeline.md` no longer exists at `approval-gate-scope/tasks/`
- File content is identical between source and target

---

- [ ] 3. **RED (**sub-agent**).** Write failing test asserting `verify-plan-pipeline.md` exists at `writing-plans/tasks/` and does NOT exist at `approval-gate-scope/tasks/`. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Copy `approval-gate-scope/tasks/verify-plan-pipeline.md` to `writing-plans/tasks/verify-plan-pipeline.md`. Delete the original file. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Verify file exists at target, does not exist at source, content is identical. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Commit file move.

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify `writing-plans/tasks/verify-plan-pipeline.md` exists and `approval-gate-scope/tasks/verify-plan-pipeline.md` does not. **→ SC-1**

**Concern transition:** Leaving file move → entering cross-reference cleanup. Phases 2, 3, and 4 depend on Phase 1's file being at the target location.
