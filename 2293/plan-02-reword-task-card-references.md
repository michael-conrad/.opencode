# Phase 2 — Reword Task-Card References

**Concern:** Reword the surviving submodule-only-PR references in the git-workflow task cards to be parent-repo + action-scoped, and add explicit permission for submodule repos' own PRs.

**Files:**
- `skills/git-workflow-commit/tasks/implementation.md`
- `skills/git-workflow-pr/tasks/pr-creation.md`
- `skills/git-workflow-branch/tasks/pre-work.md`
- `skills/git-workflow-cleanup/SKILL.md`
- `skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

**SCs:** SC-2, SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `critical-rules-049` block removed from the global guideline
- Phase 1 VbC passed
- Surviving task-card references exist in the five listed files

**Exit Conditions:**
- The prohibition applies ONLY to a parent-repo PR whose sole change is bumping submodule pointers
- A submodule repo filing its own PR for its own changes is unambiguously permitted
- No residual "in ANY context" global wording remains in the five task files

---

- [ ] 12. **RED (**sub-agent**).** `task(..., prompt: "execute red task from test-driven-development")`. Write failing behavioral tests asserting both directions: a submodule repo filing its own PR is permitted (SC-2) and the parent-repo-only scope is honored in a PR-creation context (SC-3). Must FAIL on the current global misapplication. **→ SC-2, SC-3**
- [ ] 13. **GREEN (**sub-agent**).** `task(..., prompt: "execute green task from test-driven-development")`. Reword the surviving references across the five task files to be parent-repo + action-scoped and add explicit permission for submodule repos' own PRs. **→ SC-2, SC-3**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Verify no residual "in ANY context" wording remains and the explicit permission language is present in all five files. **→ SC-2, SC-3**
- [ ] 15. **Post-regression (**sub-agent**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression patterns after GREEN. **→ SC-2, SC-3**
- [ ] 16. **Checkpoint commit (**inline**).** `git add <5 task files> && git commit -m "<message>"`. Commit the RED tests and GREEN rewording as one atomic slice. **→ SC-2, SC-3**

#### Phase 2 VbC

- [ ] 17. **VbC (**clean-room**).** `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-2 and SC-3 against the spec success criteria. If a behavioral test cannot execute, report FAIL — never substitute structural evidence. **→ SC-2, SC-3**

**Concern transition:** Leaving the task-card rewording → entering the release carve-out. Phase 3 depends on Phase 2 rewording `pr-creation.md`'s pre-push submodule pointer verification, so the release pre-validation is edited against the reworded state.
