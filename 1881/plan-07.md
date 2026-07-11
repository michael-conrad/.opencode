# Phase 7 — Cross-Skill Sweep (Post)

**Concern:** Cross-skill integration — update all cross-references, guidelines, tests, and run final verification

**Files:**
- `.opencode/guidelines/000-critical-rules.md` — Update skill references to use dispatcher names
- `.opencode/guidelines/010-approval-gate.md` — Update approval-gate references
- `.opencode/guidelines/020-go-prohibitions.md` — Update skill references
- `.opencode/guidelines/060-tool-usage.md` — Update tool/skill references
- `.opencode/guidelines/080-code-standards.md` — Update test/skill references
- `.opencode/guidelines/140-planning-spec-creation.md` — Update spec-creation references
- `.opencode/guidelines/141-planning-status-tracking.md` — Update status tracking references
- `.opencode/AGENTS.md` — Update skill references and index
- `.opencode/README.md` — Update skill list
- `.opencode/tests/test-enforcement.sh` — Update test path references
- `~50 content-verification scenarios` — Update skill paths
- `~20 behavioral tests` — Update dispatch assertions
- All 37 skill files — Cross-reference audit and update

**SCs:** SC-6, SC-7, SC-8

**Dependencies:** Phases 2, 3, 4, 5, 6 (all per-skill splits complete)

**Entry conditions:**
- All 5 dispatchers converted (issue-operations, approval-gate, git-workflow, writing-plans, spec-creation)
- All 20 sub-skills created with task files
- All behavior tests written (RED) and passing (GREEN)

**Exit conditions:**
- All guideline cross-references updated to reference dispatcher names (sub-skill names where specific)
- AGENTS.md skill index updated
- README.md skill list updated
- All ~50 content-verification test scenarios reference current skill paths
- All ~20 behavioral tests pass
- Cross-skill conflict check: no orphaned triggers, all task files in exactly one sub-skill
- Holistic spec audit PASS for all 11 dimensions
- Cross-validation of verification results PASS
- Review-prep complete with compare URL
- Executive summary produced

**Code Path Coverage:**
- Cross-skill coverage: every file and test path in the .opencode/ subtree
- All 37 skills referenced for cross-reference audit

**Cross-Cutting SCs:** SC-6 (cross-references), SC-7 (behavioral tests), SC-8 (all SCs verified)

**Interface Boundaries:**
- The cross-skill sweep is a global operation — it touches every skill file, guideline, and test
- No destructive operations — only file edits (updating references)

**State Transitions:**
- Guideline files before: reference old parent-skill paths → after: reference dispatcher/sub-skill paths
- Test files before: reference old task file paths → after: reference new sub-skill task paths
- AGENTS.md/README.md before: reference 37 skills → after: reference 5 dispatchers + 20 sub-skills

---

- [ ] 64. **Cross-reference audit: Guidelines (**sub-agent**).** Search all 9 affected guideline files for references to the 5 parent skills. For each reference, determine if it should target the dispatcher or a specific sub-skill. Produce audit findings list. **→ SC-6**
- [ ] 65. **Cross-reference audit: AGENTS.md and README.md (**sub-agent**).** Search AGENTS.md and README.md for skill references. Update skill index to reflect dispatcher + sub-skill structure. **→ SC-6**
- [ ] 66. **Cross-reference audit: Skill cross-references (**sub-agent**).** Search all 37 skill SKILL.md files for cross-references to the 5 target skills. Update dispatcher/sub-skill references. **→ SC-6**
- [ ] 67. **Cross-reference audit: Enforcement tests (**sub-agent**).** Search all content-verification test scenarios and behavioral test scripts for references to old task file paths. Update to new sub-skill task paths. Update dispatch assertions to match sub-skill names. **→ SC-6, SC-7**
- [ ] 68. **Apply guideline cross-reference updates (**sub-agent**).** Based on audit findings from step 64, apply all guideline reference updates. Fix 9 guideline files. **→ SC-6**
- [ ] 69. **Apply AGENTS.md/README.md updates (**sub-agent**).** Update AGENTS.md skill index and README.md skill list. **→ SC-6**
- [ ] 70. **Apply skill cross-reference updates (**sub-agent**).** Based on audit findings from step 66, apply all skill cross-reference updates across 37 skill files. **→ SC-6**
- [ ] 71. **Apply enforcement test updates (**sub-agent**).** Update ~50 content-verification scenarios and ~20 behavioral test scripts. Run each updated test to confirm PASS. **→ SC-6, SC-7**
- [ ] 72. **Cross-skill conflict check: Orphaned triggers (**sub-agent**).** Search all 5 dispatcher SKILL.md files for trigger phrases. Verify each dispatcher trigger resolves to an existing sub-skill. Flag any orphaned triggers. **→ SC-5, SC-7**
- [ ] 73. **Cross-skill conflict check: Missing task files (**sub-agent**).** Inventory all ~95 task files across the 5 parent skills. Verify each task file exists in exactly one sub-skill. Flag any task files that weren't migrated or exist in multiple locations. **→ SC-2, SC-7**
- [ ] 74. **Run full test suite (**sub-agent**).** Run all enforcement tests: `bash .opencode/tests/test-enforcement.sh --tag all` and `bash .opencode/tests/behaviors/*.sh`. All must PASS. **→ SC-7**
- [ ] 75. **Holistic spec audit (**clean-room**).** Dispatch clean-room sub-agent with spec issue body and all plan artifacts. Evaluate against all 11 plan dimensions from `.opencode/reference/holistic-dimensions.yaml`. Return PASS for all 11 or BLOCKED with failing dimension details. **→ SC-8**
- [ ] 76. **Cross-validate verification results (**clean-room**).** Dispatch clean-room sub-agent with VbC artifacts from all phases. Cross-validate that every SC has at least one PASS verdict from the verification artifacts. Flag any SC with FAIL or missing evidence. **→ SC-8**
- [ ] 77. **Review-prep (**sub-agent**).** Dispatch `git-workflow --task review-prep` with compare URL. Verify branch vs base diff. **→ SC-8**
- [ ] 78. **Run regression check (**sub-agent**).** Run `bash .opencode/tests/test-enforcement.sh --changed` and `bash .opencode/tests/with-test-home opencode-cli run 'regression check'`. All must PASS. **→ SC-7**
- [ ] 79. **Checkpoint commit: Cross-skill sweep (**inline**).** `git add .opencode/guidelines/ .opencode/AGENTS.md .opencode/README.md .opencode/tests/ && git commit -m "Phase 7: Cross-skill sweep — update references and tests"` **→ SC-ALL**
- [ ] 80. **Final commit: All phases (**inline**).** `git add -A && git status` — verify working tree clean. `git commit -m "feat: Split 5 overloaded skills into dispatcher + sub-skills (closes #1881)"` or squash-all into one PR commit. **→ SC-ALL**

#### Phase 7 VbC

- [ ] 81. **VbC (**clean-room**).** Verify: (1) All cross-references updated, (2) no orphaned triggers, (3) all task files in exactly one sub-skill, (4) all enforcement tests PASS, (5) holistic spec audit PASS, (6) cross-validation PASS. **→ SC-6, SC-7, SC-8**

**Concern transition:** Cross-skill sweep complete. All 8 SCs verified. Plan execution complete — ready for PR creation.
