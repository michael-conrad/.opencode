# Phase 1 — Bound scope and forbid recursion

**Concern:** Add all scope-bound and recursion-forbidding instruction to the task card so it operates only on the parent repo's direct submodule pointers and never recurses into nested submodules.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None

**Entry Conditions:**
- Spec #2306 is approved
- Feature branch exists
- Pre-implementation baseline captured (Step 2)

**Exit Conditions:**
- The task card bounds scope to `submodule_paths` direct pointers
- The task card forbids recursion and `git submodule foreach`
- The task card mirrors the no-`--recursive` guideline
- The task card directs explicit per-submodule operations

---

- [ ] 3. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card does NOT contain a scope-bound statement referencing `submodule_paths` and direct pointers. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add the scope-bound statement to Step 2 of the task card. **→ SC-1**
- [ ] 5. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-1.

- [ ] 6. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card does NOT forbid recursion into nested submodules. **→ SC-2**
- [ ] 7. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add the recursion prohibition to Step 2 of the task card. **→ SC-2**
- [ ] 8. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-2.

- [ ] 9. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card does NOT forbid `git submodule foreach` for the sync operation. **→ SC-3**
- [ ] 10. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add the `foreach` prohibition to Step 2 of the task card. **→ SC-3**
- [ ] 11. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-3.

- [ ] 12. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card lacks the no-`--recursive` constraint. **→ SC-4**
- [ ] 13. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add the no-`--recursive` constraint consistent with `060-tool-usage.md` §4 wording. **→ SC-4**
- [ ] 14. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-4.

- [ ] 15. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card does NOT direct explicit per-submodule operations. **→ SC-5**
- [ ] 16. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add an explicit per-submodule `git -C <path>` operation directive to the task card. **→ SC-5**
- [ ] 17. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-5.

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Read the task card and assert all five Phase 1 SCs (SC-1..SC-5) are satisfied: scope-bound statement, recursion prohibition, `foreach` prohibition, no-`--recursive` mirror, and explicit per-submodule directive. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving scope-bound and recursion-forbidding instruction → entering false-flag avoidance and divergence preservation. Phase 2 depends on Phase 1's edited task card baseline.
