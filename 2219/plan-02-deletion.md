# Phase 2 — Deletion

**Concern:** Dead-branch deletion — delete the dead branch (local + remote), park at trunk tip, and acknowledge the dirty submodule pointer.

**Files:**
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (add deletion + parking + dirty pointer steps)
- `.opencode/tests-v2/behaviors/` (new behavioral enforcement tests for SC-3, SC-4)

**SCs:** SC-3, SC-4

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: detection logic classifies branch as DEAD
- Phase 1 VbC passed
- Submodule PR merge confirmed via API

**Exit Conditions:**
- Dead branch deleted locally and remotely
- Repo parked on trunk tip
- Submodule pointer left dirty (not committed)
- Behavioral enforcement tests exist and pass for SC-3, SC-4

---

- [ ] 13. **RED: SC-3 — branch deletion + trunk parking (**sub-agent**).** Write a behavioral enforcement test that sends a prompt to the agent with a test repo where a dead branch is detected. Assert via `assert_semantic` that the agent deletes the branch (local + remote) and parks at trunk tip. Use `assert_stderr_pattern` as secondary corroboration for `git branch -d`, `git push origin --delete`, and `git checkout $DEFAULT_BRANCH`. The test MUST FAIL. **→ SC-3**
- [ ] 14. **RED: SC-4 — dirty pointer preservation (**sub-agent**).** Write a behavioral enforcement test that verifies the agent leaves the submodule pointer dirty after trunk parking. Assert via `assert_semantic` that the agent does NOT commit the dirty pointer. Use `assert_stderr_pattern_absent` as secondary corroboration for absence of `git add` or `git commit` on submodule paths. The test MUST FAIL. **→ SC-4**
- [ ] 15. **GREEN: SC-3 — implement branch deletion + trunk parking (**sub-agent**).** Add deletion logic at the end of Phase 5 in `check-pr.md`. Reuse the pattern from `branch-cleanup.md` Step 3.4: `git branch -d <branch>`, `git push origin --delete <branch>`, `git fetch --prune`, `git remote prune origin`. Then park at trunk tip: `git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH" --ff-only`. Handle remote-already-deleted gracefully. **→ SC-3**
- [ ] 16. **GREEN: SC-4 — implement dirty pointer acknowledgment (**sub-agent**).** After trunk parking, reuse the pattern from `branch-cleanup.md` Step 1.7: detect dirty submodule pointer(s) via `git status`, acknowledge them as expected, and do NOT commit. Add explicit FORBIDDEN/REQUIRED blocks mirroring Step 1.7's language. **→ SC-4**
- [ ] 17. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-3, SC-4**
- [ ] 18. **Verify (**clean-room**).** Verify implementation against SC-3, SC-4. Run the behavioral tests from steps 13-14 — they should now PASS. **→ SC-3, SC-4**
- [ ] 19. **Checkpoint commit (**inline**).** Stage and commit: `git add .opencode/skills/git-workflow-cleanup/tasks/check-pr.md .opencode/tests-v2/behaviors/ && git commit -m "Phase 2: dead-branch deletion + dirty pointer (SC-3, SC-4)"`

#### Phase 2 VbC

- [ ] 20. **VbC (**clean-room**).** Verify both behavioral tests PASS. Verify deletion logic matches `branch-cleanup.md` Step 3.4 pattern. Verify dirty pointer handling matches Step 1.7 pattern. **→ SC-3, SC-4**

**Concern transition:** Leaving deletion → entering verification. Phase 3 depends on all detection and deletion changes being implemented.
