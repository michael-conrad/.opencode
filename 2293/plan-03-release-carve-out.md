# Phase 3 — Release Carve-Out

**Concern:** Add a release carve-out to `pr-creation.md` release pre-validation so dirty/staged submodule pointers do not block a parent-repo release.

**Files:**
- `skills/git-workflow-pr/tasks/pr-creation.md`

**SCs:** SC-4

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: `pr-creation.md` pre-push submodule pointer verification reworded to parent-repo + action scope
- Phase 2 VbC passed

**Exit Conditions:**
- The "no uncommitted submodule changes" release pre-validation check does NOT block a parent-repo release
- Dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release, consistent with AGENTS.md Release discipline and `create-pr.md` Step 6.8

---

- [ ] 18. **RED (**sub-agent**).** `task(..., prompt: "execute red task from test-driven-development")`. Write a failing behavioral test asserting the release path proceeds (release carve-out applied) when dirty/staged submodule pointers are expected. Must FAIL on the current blocking. **→ SC-4**
- [ ] 19. **GREEN (**sub-agent**).** `task(..., prompt: "execute green task from test-driven-development")`. Add the release carve-out to `pr-creation.md` release pre-validation: dirty/staged submodule pointers are EXPECTED and permitted in a parent-repo release; the "no uncommitted submodule changes" check SHALL NOT block the release path. **→ SC-4**
- [ ] 20. **GREEN doublecheck (**clean-room**).** Verify the release pre-validation no longer blocks the release path when dirty/staged submodule pointers are present. **→ SC-4**
- [ ] 21. **Post-regression (**sub-agent**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression patterns after GREEN. **→ SC-4**
- [ ] 22. **Checkpoint commit (**inline**).** `git add skills/git-workflow-pr/tasks/pr-creation.md && git commit -m "<message>"`. Commit the RED test and GREEN carve-out as one atomic slice. **→ SC-4**

#### Phase 3 VbC

- [ ] 23. **VbC (**clean-room**).** `task(..., prompt: "execute verify task from verification-before-completion")`. Verify SC-4 against the spec success criterion. If a behavioral test cannot execute, report FAIL — never substitute structural evidence. **→ SC-4**

## Post-Implementation Gates

- [ ] 24. **Audit (**sub-agent**).** `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 25. **Structural checks (**sub-agent**).** `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run finishing checklist (lint, typecheck, etc.). **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 26. **Pre-PR gate (**clean-room**).** `task(..., prompt: "execute verify task from verification-before-completion")`. Read all SC verdicts; BLOCK if any FAIL. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 27. **Regression check (**sub-agent**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 28. **Review-prep (**sub-agent**).** `task(..., prompt: "execute review-prep from git-workflow-pr. Read `git-workflow-pr/tasks/review-prep.md` first")`. Prepare PR review context. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 29. **Create PR (**sub-agent**).** `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request. **→ SC-1, SC-2, SC-3, SC-4**
- [ ] 30. **Exec summary (**sub-agent**).** `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary. **→ SC-1, SC-2, SC-3, SC-4**
