# Phase 3 — shared status-check discipline and documentation

**Concern:** The agent performs a status check (reads current ticket status) before reporting completion of an implementation audit or implementation-for-PR, skipping the update only when the status is already correct; the behavior is documented in the audit and git-workflow-pr skills.

**Files:**
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/git-workflow-pr/SKILL.md`
- `.opencode/guidelines/` (only if per-skill mandates are insufficient)

**SCs:** SC-3, SC-4

**Dependencies:** Phase 1, Phase 2

**Entry Conditions:**
- Phase 1 complete: audit skill has the status-check-and-update step after a PASS verdict
- Phase 1 VbC passed
- Phase 2 complete: git-workflow-pr skill has the status-check-and-update step on completion
- Phase 2 VbC passed

**Exit Conditions:**
- Behavioral test asserts the agent reads current ticket status before reporting completion in both audit and implementation-for-PR workflows, skipping the update only when already correct
- Status-check-and-update behavior documented in audit and git-workflow-pr skills
- SC-3 and SC-4 behavioral tests pass

---

- [ ] 19. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing behavioral enforcement test asserting the agent reads the current ticket status before reporting completion in both the audit and implementation-for-PR workflows, skipping the update only when the status is already correct. **→ SC-3**
- [ ] 20. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to document the status-check-and-update behavior in the audit and git-workflow-pr skills so the agent is instructed to perform it. **→ SC-4**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify the audit and git-workflow-pr skills instruct the agent to read the current ticket status before reporting completion and skip the update only when the status is already correct. **→ SC-3, SC-4**
- [ ] 22. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-3, SC-4**
- [ ] 23. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-3 and SC-4. **→ SC-3, SC-4**
- [ ] 24. **Checkpoint commit (**inline**).** Stage and commit the test and change together as one atomic slice. **→ SC-3, SC-4**

#### Phase 3 VbC

- [ ] 25. **VbC (**clean-room**).** Verify SC-3 and SC-4 are satisfied: the agent reads current ticket status before reporting completion in both workflows, skipping the update only when already correct, and the behavior is documented in both skills. **→ SC-3, SC-4**

**Concern transition:** Leaving shared status-check discipline and documentation → entering post-implementation steps.

---

## Post-Implementation Steps

- [ ] 26. **Audit (**sub-agent**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 27. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify workflow constraints. **→ all SCs**
- [ ] 28. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")` to run the finishing checklist (lint, typecheck, etc.). **→ all SCs**
- [ ] 29. **Pre-PR gate (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL. **→ all SCs**
- [ ] 30. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` for the final regression check before PR. **→ all SCs**
- [ ] 31. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` to prepare PR review context. **→ all SCs**
- [ ] 32. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")` to create the pull request. **→ all SCs**
- [ ] 33. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")` to generate the completion executive summary. **→ all SCs**
