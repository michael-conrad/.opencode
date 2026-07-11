# Phase 4 — Split git-workflow

**Concern:** git-workflow → 5 sub-skills (git-workflow-branch, git-workflow-commit, git-workflow-pr, git-workflow-cleanup, git-workflow-conflict)

**Files:**
- `.opencode/skills/git-workflow/SKILL.md` — Converted to dispatcher
- `.opencode/skills/git-workflow-branch/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/git-workflow-branch/tasks/` — 3 + 3 submodule task files (pre-work, submodule mgmt, provenance)
- `.opencode/skills/git-workflow-commit/SKILL.md` — New
- `.opencode/skills/git-workflow-commit/tasks/` — 3 task files
- `.opencode/skills/git-workflow-pr/SKILL.md` — New
- `.opencode/skills/git-workflow-pr/tasks/` — 3 + 1 received task files (post-implementation.md from approval-gate)
- `.opencode/skills/git-workflow-cleanup/SKILL.md` — New
- `.opencode/skills/git-workflow-cleanup/tasks/` — 3 task files
- `.opencode/skills/git-workflow-conflict/SKILL.md` — New
- `.opencode/skills/git-workflow-conflict/tasks/` — 1 task file
- `.opencode/skills/approval-gate/tasks/post-implementation.md` — MOVED to git-workflow-pr/tasks/
- `.opencode/tests/behaviors/` — git-workflow related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists
- post-implementation.md present at `.opencode/skills/approval-gate/tasks/post-implementation.md`
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 5 sub-skill directories created with SKILL.md files
- 12 original task files + 3 submodule task files moved to sub-skill `tasks/`
- post-implementation.md received from approval-gate and placed in git-workflow-pr/tasks/
- Dispatcher SKILL.md routes triggers to sub-skills
- pair-* tasks distributed by lifecycle phase to appropriate sub-skills
- Original `tasks/` directory deleted (empty after migration)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- Pair-mode WIP-commit switching tasks distributed to lifecycle-matching sub-skills
- Submodule management tasks assigned to git-workflow-branch

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- post-implementation.md currently lives under approval-gate — must be physically moved during this phase
- pair-* tasks (pair-pre-work, pair-commit, pair-cleanup, pair-pr-creation, pair-mode-resume) go to respective lifecycle sub-skills
- Submodule tasks (submodule-sync, pre-commit-pointer-check, provenance) go to git-workflow-branch
- Conflict-resolution cross-reference from git-workflow-conflict must reference the existing `conflict-resolution` skill

**State Transitions:**
- `git-workflow/SKILL.md` before: full skill → after: dispatcher
- `git-workflow/tasks/` before: 18 files → after: empty → deleted
- `approval-gate/tasks/` before: has post-implementation.md → after: empty
- Sub-skill dirs before: don't exist → after: exist with SKILL.md + tasks/

---

- [ ] 33. **RED: Write behavioral tests for git-workflow dispatch routing (**sub-agent**).** Write behavioral tests for pre-work, commit, PR creation, cleanup, and rebase/conflict triggers. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 34. **GREEN: Create git-workflow-branch sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-branch/` with SKILL.md. Include pre-work, submodule-sync, pre-commit-pointer-check, and provenance tasks. Move 3 + 3 task files from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 35. **GREEN: Create git-workflow-commit sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-commit/` with SKILL.md. Move 3 task files (commit, pair-commit, amend) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 36. **GREEN: Create git-workflow-pr sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-pr/` with SKILL.md. Move 3 task files from original tasks/. RECEIVE post-implementation.md from `.opencode/skills/approval-gate/tasks/post-implementation.md` (physical move to `git-workflow-pr/tasks/`). **→ SC-1, SC-2, SC-4**
- [ ] 37. **GREEN: Create git-workflow-cleanup sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-cleanup/` with SKILL.md. Move 3 task files (cleanup, pair-cleanup, merge cleanup) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 38. **GREEN: Create git-workflow-conflict sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-conflict/` with SKILL.md. Move 1 task file (rebase/merge conflict resolution) from original tasks/. Reference `conflict-resolution` skill. **→ SC-1, SC-2, SC-4**
- [ ] 39. **GREEN: Distribute pair-* and submodule tasks (**sub-agent**).** Distribute pair-pre-work → branch, pair-commit → commit, pair-pr-creation → pr, pair-cleanup → cleanup, pair-mode-resume → branch. Assign submodule-sync, pre-commit-pointer-check, provenance → branch. **→ SC-2**
- [ ] 40. **GREEN: Convert git-workflow SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/git-workflow/SKILL.md` as dispatcher. Add Trigger Dispatch Table routing to 5 sub-skills. Add DISPATCH_GATE protocol. Keep all trigger phrases (pre-work, commit, pr, cleanup, conflict, release PR, pair-*). **→ SC-3, SC-5**
- [ ] 41. **GREEN doublecheck: Verify sub-skill structure (**sub-agent**).** Confirm: (1) 5 sub-skill dirs exist, (2) all task files present, (3) post-implementation.md moved to git-workflow-pr/, (4) approval-gate/tasks/ empty, (5) dispatcher Trigger Dispatch Table references all 5 sub-skills. **→ SC-2, SC-3, SC-5**
- [ ] 42. **Cleanup: Delete empty original tasks/ directories (**inline**).** `rmdir .opencode/skills/git-workflow/tasks/` and `rmdir .opencode/skills/approval-gate/tasks/` (confirm both empty first). **→ SC-2**
- [ ] 43. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow* .opencode/skills/approval-gate/tasks/ .opencode/tests/behaviors/ && git commit -m "Phase 4: Split git-workflow into 5 sub-skills"` **→ SC-ALL**

#### Phase 4 VbC

- [ ] 44. **VbC (**clean-room**).** Verify: (1) 5 sub-skill dirs exist with correct tasks, (2) post-implementation.md in git-workflow-pr, (3) pair-* + submodule tasks correctly distributed, (4) dispatcher routes correctly, (5) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving git-workflow split → entering writing-plans split. Phase 5 depends on Phase 1 (dispatcher template) and runs independently of Phases 2-4.
