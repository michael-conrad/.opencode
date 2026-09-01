# Phase 2 — Reconcile commit-count rule (multiple WIP commits acceptable, squash at PR)

**Concern:** Eliminate the contradiction in commit count — multiple WIP commits during development are acceptable, and squash to exactly one commit per issue occurs at PR creation.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/skills/git-workflow-commit/tasks/implementation.md`
- `.opencode/skills/git-workflow-commit/SKILL.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md`
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md`
- `.opencode/guidelines/115-branch-naming.md`
- `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` (new)

**SCs:** SC-2a, SC-2b

**Dependencies:** None (independent of Phase 1)

**Entry Conditions:**
- Spec #2426 is approved
- Feature branch exists
- The seven commit-count source files are readable

**Exit Conditions:**
- The seven commit-count sources state that multiple WIP commits during development are acceptable
- The seven commit-count sources state that squash to exactly one commit per issue occurs at PR creation
- The behavioral test `commit-count-squash-timing.sh` passes for both SC-2a and SC-2b

**Cost frame:** Running the behavioral commit-count test costs minutes of execution time. Skipping means the commit-count contradiction persists and agents keep squashing during dev, surfacing as a behavioral defect at 1000× the fix cost.

---

- [ ] 8. **Pre-regression (**sub-agent**).** Run regression test patterns to establish baseline. **→ SC-2a, SC-2b**
- [ ] 9. **RED (**sub-agent**).** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/commit-count-squash-timing.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent makes multiple WIP commits during development (SC-2a) and defers squash to PR creation (SC-2b). The test must fail initially because the sources conflict on commit count. **→ SC-2a, SC-2b**
- [ ] 10. **GREEN (**sub-agent**).** Update the seven commit-count sources (`000-critical-rules.md`, `git-workflow-commit/tasks/implementation.md`, `git-workflow-commit/SKILL.md`, `git-workflow-pr/tasks/pr-creation.md`, `git-workflow-pr/tasks/review-prep.md`, `git-workflow-branch/tasks/operating-protocol.md`, `115-branch-naming.md`) to state that multiple WIP commits during development are acceptable and that squash to exactly one commit per issue occurs at PR creation. **→ SC-2a, SC-2b**
- [ ] 11. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase to verify no regressions. **→ SC-2a, SC-2b**
- [ ] 12. **Verify (**clean-room**).** Run verification-before-completion: confirm the RED test passes for SC-2a (agent makes multiple WIP commits during dev) and SC-2b (agent defers squash to PR creation). **→ SC-2a, SC-2b**
- [ ] 13. **Commit (**inline**).** `git add .opencode/guidelines/000-critical-rules.md .opencode/skills/git-workflow-commit/tasks/implementation.md .opencode/skills/git-workflow-commit/SKILL.md .opencode/skills/git-workflow-pr/tasks/pr-creation.md .opencode/skills/git-workflow-pr/tasks/review-prep.md .opencode/skills/git-workflow-branch/tasks/operating-protocol.md .opencode/guidelines/115-branch-naming.md .opencode/tests-v2/behaviors/commit-count-squash-timing.sh && git commit -m "phase 2: reconcile commit-count rule to multiple WIP commits with squash at PR (#2426 SC-2a SC-2b)"`

#### Phase 2 VbC

- [ ] 14. **VbC (**clean-room**).** Verify Phase 2 deliverable meets all exit conditions. **→ SC-2a, SC-2b**

**Concern transition:** Leaving commit-count reconciliation → entering canonical-rule consistency. Phase 3 depends on Phase 2's reconciled commit-count rule.
