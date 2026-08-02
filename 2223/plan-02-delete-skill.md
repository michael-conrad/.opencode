# Phase 2 — Delete pr-creation-workflow Skill, Preserve closing-keywords.md

**Concern:** Eliminate the ceremony `pr-creation-workflow` skill by deleting its directory and preserving the `closing-keywords.md` reference file.

**Files:**
- `.opencode/skills/pr-creation-workflow/` (deleted)
- `.opencode/skills/pr-creation-workflow/reference/closing-keywords.md` (moved)
- `.opencode/skills/git-workflow-pr/reference/closing-keywords.md` (new target)

**SCs:** SC-13, SC-14, SC-15

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: template extracted, attestation updated
- Phase 1 VbC passed

**Exit Conditions:**
- `pr-creation-workflow` skill directory deleted
- `closing-keywords.md` preserved at `git-workflow-pr/reference/closing-keywords.md`
- Authorization scope check added as orchestrator inline Step 1 in `git-workflow-pr` Workflows section

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Deleting the skill directory and moving closing-keywords.md costs 3 file-system operations — each operation is a discovery point where an orphaned cross-reference would surface. Skipping any SC costs a stale directory that breaks skill discovery or a lost reference file. Correctness is the only success metric — there is no score for speed.

---

### Item 13 — SC-13: Delete pr-creation-workflow skill directory

- [ ] 74. **RED (**sub-agent**).** Write a failing enforcement test asserting the `pr-creation-workflow` skill directory does not exist. **→ SC-13**
- [ ] 75. **GREEN (**sub-agent**).** Delete the `.opencode/skills/pr-creation-workflow/` directory. **→ SC-13**
- [ ] 76. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 77. **Verify (**clean-room**).** Verify the directory does not exist. **→ SC-13**
- [ ] 78. **Commit (**inline**).** `git add .opencode/skills/pr-creation-workflow/ && git commit -m "Phase 2 Item 13: Delete pr-creation-workflow skill directory"`

### Item 14 — SC-14: Preserve closing-keywords.md in git-workflow-pr/reference/

- [ ] 79. **RED (**sub-agent**).** Write a failing enforcement test asserting `closing-keywords.md` exists at `.opencode/skills/git-workflow-pr/reference/closing-keywords.md`. **→ SC-14**
- [ ] 80. **GREEN (**sub-agent**).** Move `closing-keywords.md` from `pr-creation-workflow/reference/` to `git-workflow-pr/reference/`. **→ SC-14**
- [ ] 81. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 82. **Verify (**clean-room**).** Verify the file exists at the target path. **→ SC-14**
- [ ] 83. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/reference/closing-keywords.md && git commit -m "Phase 2 Item 14: Move closing-keywords.md to git-workflow-pr/reference"`

### Item 15 — SC-15: Authorization scope check as orchestrator inline Step 1

- [ ] 84. **RED (**sub-agent**).** Write a failing enforcement test asserting the `git-workflow-pr` SKILL.md contains "Verify authorization scope" as an orchestrator inline step. **→ SC-15**
- [ ] 85. **GREEN (**sub-agent**).** Add the authorization scope check as orchestrator inline Step 1 in the `git-workflow-pr` Workflows section. **→ SC-15**
- [ ] 86. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 87. **Verify (**clean-room**).** Verify "Verify authorization scope" is present in the SKILL.md. **→ SC-15**
- [ ] 88. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 2 Item 15: Add authorization scope check as orchestrator inline Step 1"`

#### Phase 2 VbC

- [ ] 89. **VbC (**clean-room**).** Verify all 3 SCs in Phase 2 (SC-13, SC-14, SC-15) pass with correct evidence types. **→ SC-13, SC-14, SC-15**

**Concern transition:** Leaving skill deletion → entering Workflows section creation. Phase 3 depends on Phase 2's authorization check being folded in before the Workflows section is finalized.
