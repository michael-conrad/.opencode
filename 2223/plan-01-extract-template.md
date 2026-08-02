# Phase 1 — Extract PR Body Template, Update Attestation, Update Gates

**Concern:** Decouple the PR body template from platform-specific API calls and update attestation to use the DiMo 4-role chain.

**Files:**
- `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` (new)
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-27, SC-28

**Dependencies:** None

**Entry Conditions:**
- Spec #2223 is approved
- Feature branch exists
- The `create-pr.md` file exists with the inline PR body template

**Exit Conditions:**
- Standalone template file exists at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`
- Template contains all 7 required sections (Summary, Outcome, Verification Attestation, VbC Table, DiMo Chain Attestation, Spec-Card-Mapped Commits, closing keywords)
- DiMo Chain Attestation table uses correct 6 columns
- Verification Attestation line references "DiMo 4-role audit chain"
- Attestation line states no synthesis corrections
- Both platform sections in `create-pr.md` reference the same standalone template
- Verification-evidence-check gate references `judgment.yaml`
- Data Flow table references DiMo Chain Attestation

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Extracting the template and updating attestation costs ~14 file-creation and text-replacement operations — each operation is a discovery point where a stale reference or wrong column header would be caught. Skipping any SC costs a structural defect in the template that propagates to every future PR body. Correctness is the only success metric — there is no score for speed.

---

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ pre-regression**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ pre-regression-verify**

### Item 1 — SC-1: Extract PR body template to standalone reference file

- [ ] 3. **RED (**sub-agent**).** Write a failing enforcement test asserting that the PR body template exists at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` as a standalone file (not embedded in an API call). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Extract the PR body template from `create-pr.md` to `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`. Replace the inline template in `create-pr.md` with a reference to the standalone file. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 6. **Verify (**clean-room**).** Verify standalone template file exists at target path. **→ SC-1**
- [ ] 7. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md && git commit -m "Phase 1 Item 1: Extract PR body template to standalone reference file"`

### Item 2 — SC-2: Template contains Summary section

- [ ] 8. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Summary:**`. **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Add the Summary section to the template file. **→ SC-2**
- [ ] 10. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 11. **Verify (**clean-room**).** Verify `**Summary:**` is present in the template file. **→ SC-2**
- [ ] 12. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 2: Add Summary section to template"`

### Item 3 — SC-3: Template contains Outcome section

- [ ] 13. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Outcome:**`. **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Add the Outcome section to the template file. **→ SC-3**
- [ ] 15. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 16. **Verify (**clean-room**).** Verify `**Outcome:**` is present in the template file. **→ SC-3**
- [ ] 17. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 3: Add Outcome section to template"`

### Item 4 — SC-4: Template contains Verification Attestation section

- [ ] 18. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Verification Attestation:**`. **→ SC-4**
- [ ] 19. **GREEN (**sub-agent**).** Add the Verification Attestation section to the template file. **→ SC-4**
- [ ] 20. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 21. **Verify (**clean-room**).** Verify `**Verification Attestation:**` is present in the template file. **→ SC-4**
- [ ] 22. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 4: Add Verification Attestation section to template"`

### Item 5 — SC-5: Template contains VbC Table section

- [ ] 23. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Detail: VbC Table**`. **→ SC-5**
- [ ] 24. **GREEN (**sub-agent**).** Add the VbC Table section to the template file. **→ SC-5**
- [ ] 25. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 26. **Verify (**clean-room**).** Verify `**Detail: VbC Table**` is present in the template file. **→ SC-5**
- [ ] 27. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 5: Add VbC Table section to template"`

### Item 6 — SC-6: Template contains DiMo Chain Attestation section

- [ ] 28. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Detail: DiMo Chain Attestation**`. **→ SC-6**
- [ ] 29. **GREEN (**sub-agent**).** Add the DiMo Chain Attestation section to the template file. **→ SC-6**
- [ ] 30. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 31. **Verify (**clean-room**).** Verify `**Detail: DiMo Chain Attestation**` is present in the template file. **→ SC-6**
- [ ] 32. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 6: Add DiMo Chain Attestation section to template"`

### Item 7 — SC-7: Template contains Spec-Card-Mapped Commits section

- [ ] 33. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `**Detail: Spec-Card-Mapped Commits**`. **→ SC-7**
- [ ] 34. **GREEN (**sub-agent**).** Add the Spec-Card-Mapped Commits section to the template file. **→ SC-7**
- [ ] 35. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 36. **Verify (**clean-room**).** Verify `**Detail: Spec-Card-Mapped Commits**` is present in the template file. **→ SC-7**
- [ ] 37. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 7: Add Spec-Card-Mapped Commits section to template"`

### Item 8 — SC-8: Template contains closing keywords

- [ ] 38. **RED (**sub-agent**).** Write a failing enforcement test asserting the template contains `Fixes #` or `Implements #`. **→ SC-8**
- [ ] 39. **GREEN (**sub-agent**).** Add closing keywords (`Fixes #N` / `Implements #N`) to the template file. **→ SC-8**
- [ ] 40. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 41. **Verify (**clean-room**).** Verify `Fixes #` or `Implements #` is present in the template file. **→ SC-8**
- [ ] 42. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 8: Add closing keywords to template"`

### Item 9 — SC-9: DiMo Chain Attestation table uses correct columns

- [ ] 43. **RED (**sub-agent**).** Write a failing enforcement test asserting the DiMo Chain Attestation table uses columns: Criterion, Evidence Type, Investigator, Validator, Evaluator, Arbiter. **→ SC-9**
- [ ] 44. **GREEN (**sub-agent**).** Set the DiMo Chain Attestation table header to the correct 6 columns. **→ SC-9**
- [ ] 45. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 46. **Verify (**clean-room**).** Verify the table header contains all 6 required columns. **→ SC-9**
- [ ] 47. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 9: Set DiMo Chain Attestation table columns"`

### Item 10 — SC-10: Verification Attestation references DiMo 4-role chain

- [ ] 48. **RED (**sub-agent**).** Write a failing enforcement test asserting the Verification Attestation line references "DiMo 4-role audit chain" not "Dual independent auditors". **→ SC-10**
- [ ] 49. **GREEN (**sub-agent**).** Update the Verification Attestation line to reference "DiMo 4-role audit chain". **→ SC-10**
- [ ] 50. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 51. **Verify (**clean-room**).** Verify "DiMo 4-role" is present in the template file. **→ SC-10**
- [ ] 52. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 10: Update Verification Attestation to reference DiMo 4-role chain"`

### Item 11 — SC-11: Attestation line states no synthesis corrections needed

- [ ] 53. **RED (**sub-agent**).** Write a failing enforcement test asserting the attestation line states "The Arbiter accepted all Evaluator verdicts as final — no synthesis corrections were needed or applied". **→ SC-11**
- [ ] 54. **GREEN (**sub-agent**).** Add the attestation line stating no synthesis corrections were needed. **→ SC-11**
- [ ] 55. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 56. **Verify (**clean-room**).** Verify "no synthesis corrections" is present in the template file. **→ SC-11**
- [ ] 57. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/pr-body-template.md && git commit -m "Phase 1 Item 11: Add attestation line stating no synthesis corrections"`

### Item 12 — SC-12: Both platform sections reference same standalone template

- [ ] 58. **RED (**sub-agent**).** Write a failing enforcement test asserting both platform sections (GitHub MCP, GitBucket CLI) in `create-pr.md` reference the same standalone template file. **→ SC-12**
- [ ] 59. **GREEN (**sub-agent**).** Update both platform sections in `create-pr.md` to reference the standalone template file. **→ SC-12**
- [ ] 60. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 61. **Verify (**clean-room**).** Verify both platform sections reference the same template path. **→ SC-12**
- [ ] 62. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md && git commit -m "Phase 1 Item 12: Both platform sections reference standalone template"`

### Item 27 — SC-27: Verification-evidence-check gate references judgment.yaml

- [ ] 63. **RED (**sub-agent**).** Write a failing enforcement test asserting the verification-evidence-check gate in `create-pr.md` checks for `judgment.yaml` with `overall_verdict: PASS`. **→ SC-27**
- [ ] 64. **GREEN (**sub-agent**).** Update the verification-evidence-check gate in `create-pr.md` to reference `judgment.yaml`. **→ SC-27**
- [ ] 65. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 66. **Verify (**clean-room**).** Verify "judgment.yaml" is present in the gate section. **→ SC-27**
- [ ] 67. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md && git commit -m "Phase 1 Item 27: Update verification-evidence-check gate to reference judgment.yaml"`

### Item 28 — SC-28: Data Flow table references DiMo Chain Attestation

- [ ] 68. **RED (**sub-agent**).** Write a failing enforcement test asserting the Data Flow table in `create-pr.md` references "DiMo Chain Attestation" → `judgment.yaml`. **→ SC-28**
- [ ] 69. **GREEN (**sub-agent**).** Update the Data Flow table in `create-pr.md` to reference DiMo Chain Attestation → `judgment.yaml`. **→ SC-28**
- [ ] 70. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 71. **Verify (**clean-room**).** Verify "DiMo Chain Attestation" is present in the Data Flow table. **→ SC-28**
- [ ] 72. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md && git commit -m "Phase 1 Item 28: Update Data Flow table to reference DiMo Chain Attestation"`

#### Phase 1 VbC

- [ ] 73. **VbC (**clean-room**).** Verify all 14 SCs in Phase 1 (SC-1 through SC-12, SC-27, SC-28) pass with correct evidence types. **→ SC-1 through SC-12, SC-27, SC-28**

**Concern transition:** Leaving template extraction and attestation update → entering skill deletion. Phase 2 depends on Phase 1's template being extracted so the skill deletion can reference the new structure.
