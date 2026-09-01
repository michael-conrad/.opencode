# Phase 3 — Establish canonical rule (one squashed commit per issue with dual trailers) consistently across gates

**Concern:** Ensure the canonical rule — exactly one squashed commit per issue with dual co-author trailers (AI + human) — is stated consistently across the PR/squash/enforcement/finishing gates.

**Files:**
- `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md`
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md`
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md`
- `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` (new)

**SCs:** SC-3a, SC-3b

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: trailer-placement rule reconciled (no trailers on implementation commits, dual trailers on squashed commit)
- Phase 1 VbC passed
- Phase 2 complete: commit-count rule reconciled (multiple WIP commits during dev, squash at PR)
- Phase 2 VbC passed
- The five canonical gate files are readable

**Exit Conditions:**
- The five canonical gate files state the one-squashed-commit-per-issue rule consistently
- The five canonical gate files state the dual-trailer-on-squashed-commit rule consistently
- The behavioral test `squash-dual-trailer.sh` passes for both SC-3a and SC-3b

**Cost frame:** Running the behavioral squash-dual-trailer test costs minutes of execution time. Skipping means the canonical one-squashed-commit-per-issue and dual-trailer rules are not consistently enforced and agents produce multiple commits per issue or ship squashed commits without proper co-author trailers, surfacing as a behavioral defect at 1000× the fix cost.

---

- [ ] 15. **Pre-regression (**sub-agent**).** Run regression test patterns to establish baseline. **→ SC-3a, SC-3b**
- [ ] 16. **RED (**sub-agent**).** Write a behavioral enforcement test at `.opencode/tests-v2/behaviors/squash-dual-trailer.sh` that runs `bash .opencode/tests-v2/with-test-home opencode run '<message>'` and asserts stderr shows the agent produces exactly one squashed commit per issue (SC-3a) and adds dual co-author trailers (AI + human) to the squashed commit (SC-3b). The test must fail initially because the canonical rule is not stated consistently across the gates. **→ SC-3a, SC-3b**
- [ ] 17. **GREEN (**sub-agent**).** Ensure the canonical rule (exactly one squashed commit per issue with dual co-author trailers) is stated consistently across the five gate files (`git-workflow-pr/tasks/pr-creation.md`, `squash-push.md`, `enforcement-gate.md`, `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`). **→ SC-3a, SC-3b**
- [ ] 18. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase to verify no regressions. **→ SC-3a, SC-3b**
- [ ] 19. **Verify (**clean-room**).** Run verification-before-completion: confirm the RED test passes for SC-3a (agent produces exactly one squashed commit per issue) and SC-3b (agent adds dual co-author trailers to the squashed commit). **→ SC-3a, SC-3b**
- [ ] 20. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/tasks/pr-creation.md .opencode/skills/git-workflow-pr/tasks/pr-creation/squash-push.md .opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md .opencode/skills/finishing-a-development-branch/tasks/checklist.md .opencode/skills/finishing-a-development-branch/tasks/prepare.md .opencode/tests-v2/behaviors/squash-dual-trailer.sh && git commit -m "phase 3: state canonical one-squashed-commit-per-issue with dual trailers consistently across gates (#2426 SC-3a SC-3b)"`

#### Phase 3 VbC

- [ ] 21. **VbC (**clean-room**).** Verify Phase 3 deliverable meets all exit conditions. **→ SC-3a, SC-3b**

**Concern transition:** All six SCs covered. Ready for post-implementation steps.
