# Phase 2 — Split issue-operations

**Concern:** issue-operations → 4 sub-skills (issue-operations-core, issue-operations-comments, issue-operations-sub-issues, issue-operations-sync)

**Files:**
- `.opencode/skills/issue-operations/SKILL.md` — Converted to dispatcher
- `.opencode/skills/issue-operations-core/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/issue-operations-core/tasks/` — 14 task files
- `.opencode/skills/issue-operations-comments/SKILL.md` — New
- `.opencode/skills/issue-operations-comments/tasks/` — 1 task file
- `.opencode/skills/issue-operations-sub-issues/SKILL.md` — New
- `.opencode/skills/issue-operations-sub-issues/tasks/` — 2 task files
- `.opencode/skills/issue-operations-sync/SKILL.md` — New
- `.opencode/skills/issue-operations-sync/tasks/` — 3 task files
- `.opencode/skills/issue-operations/platforms/` — Preserved (unchanged)
- `.opencode/tests/behaviors/issue-operations-dispatch-instead-of-inline.sh` — Updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists at `.opencode/reference/dispatcher-template.md`
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 4 sub-skill directories created with SKILL.md files
- 14 + 1 + 2 + 3 = 20 task files moved to sub-skill `tasks/` directories
- Dispatcher SKILL.md routes triggers to sub-skills via Trigger Dispatch Table
- Platform sub-skills preserved and referenced
- Original `tasks/` directory deleted (empty after migration)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- All 20 task files maintain their original behavior from new locations

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved platforms), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- Dispatcher SKILL.md must preserve all trigger phrases from original
- Platform sub-skills (github-mcp, gitbucket-api, local) must be referenced by dispatcher but NOT moved
- Sub-skill SKILL.md files must use Agent-Intent Pattern descriptions

**State Transitions:**
- `issue-operations/SKILL.md` before: full skill definition → after: dispatcher only
- `issue-operations/tasks/` before: 21 files → after: empty → deleted
- Sub-skill dirs before: don't exist → after: exist with SKILL.md + tasks/

---

- [ ] 19. **RED: Write behavioral tests for issue-ops dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests that dispatch agent prompts for CRUD operations, comment operations, sub-issue operations, and sync operations. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split (original SKILL.md still in place). **→ SC-2, SC-5**
- [ ] 20. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives from infrastructure issues. **→ SC-2, SC-5**
- [ ] 21. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code, no GREEN implementation. **→ SC-2, SC-5**

- [ ] 22. **GREEN: Create 4 sub-skills (**sub-agent**).** Create `.opencode/skills/issue-operations-core/`, `issue-operations-comments/`, `issue-operations-sub-issues/`, `issue-operations-sync/` directories. Each gets SKILL.md (Agent-Intent Pattern, Trigger Dispatch Table). Move task files from `issue-operations/tasks/` to respective sub-skill `tasks/`: 14 to core, 1 to comments, 2 to sub-issues, 3 to sync. **→ SC-1, SC-2, SC-4**
- [ ] 23. **per-item-VbC: Verify 4 sub-skills (**green-vbc**: `verification-before-completion --task completion`).** Confirm: (1) 4 sub-skill dirs exist with SKILL.md, (2) all task files present in correct sub-skill tasks/, (3) platforms/ directory preserved. **→ SC-2, SC-3**

- [ ] 24. **GREEN: Dispatch known items into sub-skills (**sub-agent**).** For each task file in the original `issue-operations/tasks/`, read its frontmatter/description and assign it to one of the 4 sub-skills. Make final assignment decisions. **→ SC-2**
- [ ] 25. **per-item-VbC: Verify dispatch assignments (**green-vbc**: `verification-before-completion --task completion`).** Confirm every task file has a valid assignment to exactly one sub-skill. **→ SC-2**

- [ ] 26. **GREEN: Convert issue-operations SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/issue-operations/SKILL.md` as a dispatcher. Keep all trigger phrases and overview. Add Trigger Dispatch Table routing to 4 sub-skills. Add DISPATCH_GATE protocol. Reference platform sub-skills. **→ SC-3, SC-5**
- [ ] 27. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references all 4 sub-skills and all original trigger phrases are preserved. **→ SC-3, SC-5**

- [ ] 28. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) all sub-skill dirs exist with correct structure, (2) dispatcher routes correctly, (3) RED tests PASS after split. **→ SC-2, SC-3, SC-5**
- [ ] 29. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence coverage for Phase 2. **→ SC-ALL**
- [ ] 30. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 2 modified files. **→ SC-ALL**

- [ ] 31. **Cleanup: Delete empty original tasks/ directory (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/issue-operations/tasks/` (confirm empty first). **→ SC-2**
- [ ] 32. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 2 output: `"Phase 2: Split issue-operations into 4 sub-skills"`. **→ SC-ALL**
- [ ] 33. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-2-main`. **→ SC-ALL**

- [ ] 34. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_2 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 35. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 2. **→ SC-ALL**

**Concern transition:** Leaving issue-operations split → entering approval-gate split. Phase 3 depends on Phase 1 (dispatcher template) and runs independently of Phase 2.
