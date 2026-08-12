# Phase 3 — PR Autoclose Protection

**Concern:** Fix `create-pr.md` so plan-phase sub-issues are not auto-closed on PR merge (SC-4).

**Files:**
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`

**SCs:** SC-4

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: behavioral test proves zero sub-issue creation at finishing time
- Phase 2 VbC passed
- `create-pr.md` lines 123-124 still sweep sub-issues into `autoclose_issues`

**Exit Conditions:**
- `create-pr.md` autoclose preserves parent issue autoclose and excludes plan-phase sub-issues
- SC-4 string verification passes
- issue-operations-sub-issues API capability and multi-task authorization cascade model unchanged (out of scope)

---

- [ ] 21. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing content-verification assertion: `grep` `create-pr.md` for the `autoclose_issues` sub-issue collection (lines 123-124) returns a match (the sweep is still present). Confirm the assertion fails. **→ SC-4**
- [ ] 22. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to remove or gate the sub-issue collection in `autoclose_issues` in `create-pr.md` so plan-phase sub-issues are never auto-closed on PR merge; preserve the parent issue autoclose. **→ SC-4**
- [ ] 23. **GREEN doublecheck (**clean-room**).** Verify `create-pr.md` no longer sweeps plan-phase sub-issues into autoclose and that parent autoclose is preserved. **→ SC-4**
- [ ] 24. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-4**
- [ ] 25. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-4 (grep `create-pr.md` for `autoclose_issues` → sub-issue collection removed or gated). **→ SC-4**
- [ ] 26. **Checkpoint commit (**inline**).** Stage `create-pr.md` and commit the change as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-4**

#### Phase 3 VbC

- [ ] 27. **VbC (**clean-room**).** Verify SC-4 is satisfied: `create-pr.md` does not sweep plan-phase sub-issues into PR-merge autoclose (parent preserved). **→ SC-4**

**Concern transition:** Leaving PR autoclose protection → entering plan-content protection. Phase 4 depends on Phase 3 complete.
