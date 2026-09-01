# Phase 1 — Reconcile co-author trailer placement on implementation vs squashed commits

**Concern:** Eliminate the contradiction in trailer placement — no co-author trailers on intermediate implementation/WIP commits, dual co-author trailers (AI + human) on the final squashed commit.

**Files:**
- `.opencode/.guidelines/commit-workflow.md`
- `.opencode/skills/git-workflow-commit/tasks/commit-prep.md`
- `.opencode/skills/git-workflow-commit/tasks/implementation.md`
- `.opencode/skills/writing-plans/reference/implementation-workflow.md`
- `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` (new)

**SCs:** SC-1a, SC-1b

**Dependencies:** None

**Entry Conditions:**
- Spec #2426 is approved (`approved-for-pr` label present)
- Feature branch exists
- The four contradictory source files are readable

**Exit Conditions:**
- The four contradictory sources state that no co-author trailers are required on intermediate implementation/WIP commits
- The four contradictory sources state that dual co-author trailers (AI + human) are required on the final squashed commit
- The behavioral test `commit-trailer-placement.sh` passes for both SC-1a and SC-1b

**Cost frame:** Running the behavioral trailer-placement test costs minutes of execution time. Skipping means the contradictory trailer rule ships unchanged and agents keep adding trailers to WIP commits, surfacing as a behavioral defect in production at 1000× the fix cost.

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns to establish baseline. **→ SC-1a, SC-1b**
- [ ] 2. **RED (**sub-agent**).** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/commit-trailer-placement.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent does NOT add co-author trailers to an implementation commit (SC-1a) and DOES add dual co-author trailers (AI + human) to the squashed commit (SC-1b). The test must fail initially because the contradictory sources require trailers on implementation commits. **→ SC-1a, SC-1b**
- [ ] 3. **GREEN (**sub-agent**).** Update the four contradictory sources (`.guidelines/commit-workflow.md`, `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-commit/tasks/implementation.md`, `writing-plans/reference/implementation-workflow.md`) to state that no co-author trailers are required on intermediate implementation/WIP commits and that dual co-author trailers (AI + human) are required on the final squashed commit. **→ SC-1a, SC-1b**
- [ ] 4. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase to verify no regressions. **→ SC-1a, SC-1b**
- [ ] 5. **Verify (**clean-room**).** Run verification-before-completion: confirm the RED test passes for SC-1a (agent omits trailers on implementation commits) and SC-1b (agent adds dual co-author trailers to the squashed commit). **→ SC-1a, SC-1b**
- [ ] 6. **Commit (**inline**).** `git add .opencode/.guidelines/commit-workflow.md .opencode/skills/git-workflow-commit/tasks/commit-prep.md .opencode/skills/git-workflow-commit/tasks/implementation.md .opencode/skills/writing-plans/reference/implementation-workflow.md .opencode/tests-v2/behaviors/commit-trailer-placement.sh && git commit -m "phase 1: reconcile co-author trailer placement on implementation vs squashed commits (#2426 SC-1a SC-1b)"`

#### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify Phase 1 deliverable meets all exit conditions. **→ SC-1a, SC-1b**

**Concern transition:** Leaving trailer-placement reconciliation → entering commit-count reconciliation. Phase 3 depends on Phase 1's reconciled trailer-placement rule.
