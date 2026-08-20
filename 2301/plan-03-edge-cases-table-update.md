# Phase 3 — Edge Cases table update

**Concern:** Update the Edge Cases table entry for "Issue already imported" to reflect the new completeness-check behavior.

**Files:**
- `.opencode/skills/issue-operations-sync/tasks/import-remote.md`

**SCs:** SC3

**Dependencies:** None (sequenced after Phase 1 to avoid same-file edit conflicts on `import-remote.md`)

**Entry Conditions:**
- Spec #2301 is approved
- Feature branch exists

**Exit Conditions:**
- The Edge Cases table entry for "Issue already imported" reflects the new completeness-check behavior (materialize missing files rather than halt on directory existence)

---

- [ ] 17. **Pre-regression (**sub-agent**).** Run regression test patterns before the RED phase. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-*`
  - Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`
- [ ] 18. **Pre-regression verify (**sub-agent**).** Verify pre-regression results. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-regression-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 19. **RED (**sub-agent**).** Write a failing doc-edit check for the Edge Cases row. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-red-*`
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
  - The check asserts the "Issue already imported" row reflects the new completeness-check behavior
- [ ] 20. **GREEN (**sub-agent**).** Update the Edge Cases "Issue already imported" row. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-green-*`
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Update the row to reflect the new completeness-check behavior (materialize missing files rather than halt on directory existence)
- [ ] 21. **Post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 22. **Verify (**sub-agent**).** Verify implementation against success criteria. **→ SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Confirm the Edge Cases row reflects the new completeness-check behavior
- [ ] 23. **Commit (**inline**).** Stage and commit the doc edit. **→ SC3**
  - Orchestrator runs `git add <files> && git commit -m "<message>"`
  - No co-author trailers during implementation commits

#### Phase 3 VbC

- [ ] 24. **VbC (**clean-room**).** Verify the Edge Cases "Issue already imported" row reflects the new completeness-check behavior. **→ SC3**

**Concern transition:** Leaving the Edge Cases table update → entering post-implementation steps (structural checks, verification, audit, cross-validate, review-prep, PR creation, completion).

---

## Post-Implementation

- [ ] 25. **Audit (**sub-agent**).** Adversarial audit of the deliverable. **→ SC1, SC2, SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-audit-*`
  - Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`
  - Follow with validator, evaluator, arbiter in sequence
- [ ] 26. **Z3 check (**inline**).** Run Z3 constraint solver verification. **→ SC1, SC2, SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-z3-check-*`
  - Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] 27. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, etc.). **→ SC1, SC2, SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-structural-checks-*`
  - Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
- [ ] 28. **Pre-PR gate (**sub-agent**).** Verify all SC verdicts before PR creation. **→ SC1, SC2, SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-pre-pr-gate-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Reads all SC verdicts, BLOCKs if any FAIL
- [ ] 29. **Regression check (**sub-agent**).** Final regression check before PR. **→ SC1, SC2, SC3**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2301}/artifacts/pipeline-regression-check-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 30. **Review prep (**sub-agent**).** Prepare PR review context. **→ SC1, SC2, SC3**
  - Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
- [ ] 31. **Create PR (**sub-agent**).** Create the pull request. **→ SC1, SC2, SC3**
  - Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`
- [ ] 32. **Exec summary (**sub-agent**).** Generate completion executive summary. **→ SC1, SC2, SC3**
  - Dispatch `task(..., prompt: "execute completion task from completion-core")`
