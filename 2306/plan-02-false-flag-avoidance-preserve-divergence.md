# Phase 2 — False-flag avoidance and divergence preservation

**Concern:** Document false-pointer-flag avoidance and verify preservation of the correct `--ff-only` divergence feature.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`

**SCs:** SC-6, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: task card edited with scope-bound and recursion-forbidding instruction
- Phase 1 VbC passed

**Exit Conditions:**
- The task card documents that syncing a submodule to its own trunk tip must not be reported as a parent pointer change
- The `--ff-only` divergence block is byte-identical to the pre-change baseline

---

- [ ] 19. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the task card does NOT document false-pointer-flag avoidance. **→ SC-6**
- [ ] 20. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Add a note that syncing a submodule to its own trunk tip must not be reported as a parent pointer change. **→ SC-6**
- [ ] 21. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-6.

- [ ] 22. **RED (**sub-agent**).** Dispatch `execute red task from test-driven-development`. Write a failing enforcement test asserting the `--ff-only` divergence block differs from the pre-change baseline. **→ SC-7**
- [ ] 23. **GREEN (**sub-agent**).** Dispatch `execute green task from test-driven-development`. Ensure the divergence block is unchanged (no-op if already preserved). **→ SC-7**
- [ ] 24. **Checkpoint commit (**inline**).** Stage and commit the task card text change for SC-7 (or no-op if already preserved).

#### Phase 2 VbC

- [ ] 25. **VbC (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Read the task card and assert both Phase 2 SCs (SC-6, SC-7) are satisfied: false-pointer-flag avoidance note present, and divergence block byte-identical to the pre-change baseline. **→ SC-6, SC-7**

---

## Post-Implementation

- [ ] 26. **Structural checks (**sub-agent**).** Dispatch `execute checklist task from finishing-a-development-branch`. Run the finishing checklist (lint, typecheck, format) on the modified task card and confirm no regressions.
- [ ] 27. **Verification (**clean-room**).** Dispatch `execute verify task from verification-before-completion`. Read all SC verdicts (SC-1..SC-7); BLOCK if any FAIL. Confirm all 7 SCs pass with string evidence.
- [ ] 28. **Audit (**clean-room**).** Dispatch `execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first`, followed by validator, evaluator, arbiter in sequence. Adversarially audit the task card change against the spec.
- [ ] 29. **Cross-validate (**clean-room**).** Independently re-verify the deliverable against the spec's success criteria, confirming SC-7's divergence block is byte-identical to the pre-change baseline.
- [ ] 30. **Review-prep (**sub-agent**).** Dispatch `execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first`. Prepare PR review context.
- [ ] 31. **Create PR (**sub-agent**).** Dispatch `execute create task from git-workflow-pr`. Create the pull request for the task card change.
- [ ] 32. **Completion (**sub-agent**).** Dispatch `execute completion task from completion-core`. Generate the completion executive summary.
