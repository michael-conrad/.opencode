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

- [ ] 14. **RED: Write behavioral tests for issue-ops dispatch routing (**sub-agent**).** Write behavioral tests that dispatch agent prompts for CRUD operations, comment operations, sub-issue operations, and sync operations. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split (original SKILL.md still in place). **→ SC-2, SC-5**
- [ ] 15. **GREEN: Create issue-operations-core sub-skill (**sub-agent**).** Create `.opencode/skills/issue-operations-core/` directory with SKILL.md (Agent-Intent Pattern, Trigger Dispatch Table). Move 14 task files from `issue-operations/tasks/` to `issue-operations-core/tasks/`. Task scope: CRUD operations for issues, comments, labels, sub-issues, assignees. **→ SC-1, SC-2, SC-4**
- [ ] 16. **GREEN: Create issue-operations-comments sub-skill (**sub-agent**).** Create `.opencode/skills/issue-operations-comments/` directory with SKILL.md. Move `read-comments.md` from `issue-operations/tasks/` (and any other comment-specific task files). **→ SC-1, SC-2, SC-4**
- [ ] 17. **GREEN: Create issue-operations-sub-issues sub-skill (**sub-agent**).** Create `.opencode/skills/issue-operations-sub-issues/` directory with SKILL.md. Move sub-issue task files from `issue-operations/tasks/`. **→ SC-1, SC-2, SC-4**
- [ ] 18. **GREEN: Create issue-operations-sync sub-skill (**sub-agent**).** Create `.opencode/skills/issue-operations-sync/` directory with SKILL.md. Move sync-related task files from `issue-operations/tasks/`. **→ SC-1, SC-2, SC-4**
- [ ] 19. **GREEN: Dispatch known items into sub-skills (**sub-agent**).** For each task file in the original `issue-operations/tasks/`, read its frontmatter/description and assign it to one of the 4 sub-skills. Make the final assignment decisions. **→ SC-2**
- [ ] 20. **GREEN: Convert issue-operations SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/issue-operations/SKILL.md` as a dispatcher. Keep all trigger phrases and overview. Add Trigger Dispatch Table routing to 4 sub-skills. Add DISPATCH_GATE protocol. Reference platform sub-skills. **→ SC-3, SC-5**
- [ ] 21. **GREEN doublecheck: Verify sub-skill structure (**sub-agent**).** Confirm: (1) 4 sub-skill dirs exist with SKILL.md, (2) all task files present in correct sub-skill tasks/, (3) platforms/ directory preserved, (4) dispatcher Trigger Dispatch Table references all 4 sub-skills. **→ SC-2, SC-3, SC-5**
- [ ] 22. **Cleanup: Delete empty original tasks/ directory (**inline**).** `rmdir .opencode/skills/issue-operations/tasks/` (confirm empty first). **→ SC-2**
- [ ] 23. **Checkpoint commit (**inline**).** `git add .opencode/skills/issue-operations* .opencode/tests/behaviors/ && git commit -m "Phase 2: Split issue-operations into 4 sub-skills"` **→ SC-ALL**

#### Phase 2 VbC

- [ ] 24. **VbC (**clean-room**).** Verify: (1) All 4 sub-skill dirs exist with SKILL.md + tasks/, (2) original tasks/ dir deleted, (3) platforms/ preserved, (4) dispatcher routes to correct sub-skills, (5) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving issue-operations split → entering approval-gate split. Phase 3 depends on Phase 1 (dispatcher template) and runs independently of Phase 2.
