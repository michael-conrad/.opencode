# Phase 2 — Delete Files

**Concern:** Delete all `approval-gate-scope` files and directories.

**Files:**
- `.opencode/skills/approval-gate-scope/SKILL.md`
- `.opencode/skills/approval-gate-scope/tasks/` (22 files)
- `.opencode/skills/approval-gate-scope/enforcement/` (5 files)
- `.opencode/skills/approval-gate-scope/tasks/verify-authorization/` (13 files)
- `.opencode/skills/approval-gate-scope/tasks/screen/` (2 files)
- `.opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/` (3 files)
- `.opencode/skills/approval-gate-scope/tasks/pre-impl/` (6 files)

**SCs:** SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `approval-gate/SKILL.md` has merged content
- Phase 1 complete: dispatch calls updated
- Phase 1 VbC passed

**Exit Conditions:**
- `approval-gate-scope/SKILL.md` deleted
- All 22 task files under `approval-gate-scope/tasks/` deleted
- All 5 enforcement files under `approval-gate-scope/enforcement/` deleted
- All 13 verify-authorization sub-task files deleted
- All 2 screen sub-task files deleted
- All 3 gap-fill-cascade sub-task files deleted
- All 6 pre-impl sub-task files deleted

---

- [ ] 14. **RED — SC-2 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/SKILL.md` succeeds (file exists). **→ SC-2**
- [ ] 15. **GREEN — SC-2 (**sub-agent**).** `git rm .opencode/skills/approval-gate-scope/SKILL.md`. **→ SC-2**
- [ ] 16. **Verify — SC-2 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/SKILL.md` returns error. **→ SC-2**
- [ ] 17. **Commit — SC-2 (**inline**).** `git commit -m 'refactor: delete approval-gate-scope/SKILL.md'`

- [ ] 18. **RED — SC-4 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/tasks/` shows files. **→ SC-4**
- [ ] 19. **GREEN — SC-4 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/tasks/`. **→ SC-4**
- [ ] 20. **Verify — SC-4 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/tasks/` returns error or empty. **→ SC-4**
- [ ] 21. **Commit — SC-4 (**inline**).** `git commit -m 'refactor: delete 22 task files in approval-gate-scope/tasks/'`

- [ ] 22. **RED — SC-5 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/enforcement/` shows files. **→ SC-5**
- [ ] 23. **GREEN — SC-5 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/enforcement/`. **→ SC-5**
- [ ] 24. **Verify — SC-5 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/enforcement/` returns error or empty. **→ SC-5**
- [ ] 25. **Commit — SC-5 (**inline**).** `git commit -m 'refactor: delete 5 enforcement files in approval-gate-scope/enforcement/'`

- [ ] 26. **RED — SC-6 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/tasks/verify-authorization/` shows files. **→ SC-6**
- [ ] 27. **GREEN — SC-6 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/tasks/verify-authorization/`. **→ SC-6**
- [ ] 28. **Verify — SC-6 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/tasks/verify-authorization/` returns error or empty. **→ SC-6**
- [ ] 29. **Commit — SC-6 (**inline**).** `git commit -m 'refactor: delete 13 verify-authorization sub-task files'`

- [ ] 30. **RED — SC-7 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/tasks/screen/` shows files. **→ SC-7**
- [ ] 31. **GREEN — SC-7 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/tasks/screen/`. **→ SC-7**
- [ ] 32. **Verify — SC-7 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/tasks/screen/` returns error or empty. **→ SC-7**
- [ ] 33. **Commit — SC-7 (**inline**).** `git commit -m 'refactor: delete 2 screen sub-task files'`

- [ ] 34. **RED — SC-8 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/` shows files. **→ SC-8**
- [ ] 35. **GREEN — SC-8 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/`. **→ SC-8**
- [ ] 36. **Verify — SC-8 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/` returns error or empty. **→ SC-8**
- [ ] 37. **Commit — SC-8 (**inline**).** `git commit -m 'refactor: delete 3 gap-fill-cascade sub-task files'`

- [ ] 38. **RED — SC-9 (**sub-agent**).** Write a test that `ls .opencode/skills/approval-gate-scope/tasks/pre-impl/` shows files. **→ SC-9**
- [ ] 39. **GREEN — SC-9 (**sub-agent**).** `git rm -r .opencode/skills/approval-gate-scope/tasks/pre-impl/`. **→ SC-9**
- [ ] 40. **Verify — SC-9 (**clean-room**).** Verify `ls .opencode/skills/approval-gate-scope/tasks/pre-impl/` returns error or empty. **→ SC-9**
- [ ] 41. **Commit — SC-9 (**inline**).** `git commit -m 'refactor: delete 6 pre-impl sub-task files'`

#### Phase 2 VbC

- [ ] 42. **VbC (**clean-room**).** Verify all 7 structural SCs (SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9) — each `ls` target returns error or empty. **→ SC-2, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9**

**Concern transition:** Leaving file deletion → entering reference updates and verification. Phase 3 depends on Phase 2's complete deletion of all `approval-gate-scope` files.
