# Phase 2 — git-workflow-pr status reconciliation

**Concern:** When an implementation-for-PR workflow completes, the agent checks the ticket's current status and updates it to reflect the PR-created state if warranted.

**Files:**
- `.opencode/skills/git-workflow-pr/SKILL.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow-pr/tasks/completion.md`

**SCs:** SC-2

**Dependencies:** None

**Entry Conditions:**
- Spec #2272 is approved
- Feature branch exists
- Coherence gate and baseline check passed (pre-implementation steps)
- Pre-regression and pre-regression-verify passed

**Exit Conditions:**
- git-workflow-pr skill workflows include a status-check-and-update step on completion
- The step reads the ticket's current status and updates it (PR-created/for_pr state) when an update is warranted
- SC-2 behavioral test passes

---

- [ ] 12. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing behavioral enforcement test asserting the agent checks the ticket's current status and updates it to the PR-created state when an implementation-for-PR workflow completes. **→ SC-2**
- [ ] 13. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to add the status-check-and-update step to the git-workflow-pr skill workflows on completion. **→ SC-2**
- [ ] 14. **GREEN doublecheck (**clean-room**).** Verify the git-workflow-pr skill workflows now instruct the agent to check the ticket's current status and update it to the PR-created state when warranted. **→ SC-2**
- [ ] 15. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-2**
- [ ] 16. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-2. **→ SC-2**
- [ ] 17. **Checkpoint commit (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC-2**

#### Phase 2 VbC

- [ ] 18. **VbC (**clean-room**).** Verify SC-2 is satisfied: the git-workflow-pr skill workflows check the ticket's current status and update it to the PR-created state on completion when warranted. **→ SC-2**

**Concern transition:** Leaving git-workflow-pr status reconciliation → entering shared status-check discipline and documentation. Phase 3 depends on the status-check-and-update steps committed in Phases 1 and 2.
