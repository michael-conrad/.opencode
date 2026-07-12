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

- [ ] 53. **RED: Write behavioral tests for git-workflow dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests for pre-work, commit, PR creation, cleanup, and rebase/conflict triggers. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 54. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-2, SC-5**
- [ ] 55. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-2, SC-5**

- [ ] 56. **GREEN: Create git-workflow-branch sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-branch/` with SKILL.md. Include pre-work, submodule-sync, pre-commit-pointer-check, and provenance tasks. Move 3 + 3 task files from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 57. **per-item-VbC: Verify branch sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm branch sub-skill exists with 6 task files and correct SKILL.md. **→ SC-2**

- [ ] 58. **GREEN: Create git-workflow-commit sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-commit/` with SKILL.md. Move 3 task files (commit, pair-commit, amend) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 59. **per-item-VbC: Verify commit sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm commit sub-skill exists with 3 task files. **→ SC-2**

- [ ] 60. **GREEN: Create git-workflow-pr sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-pr/` with SKILL.md. Move 3 task files from original tasks/. RECEIVE post-implementation.md from `.opencode/skills/approval-gate/tasks/post-implementation.md` (physical move to `git-workflow-pr/tasks/`). **→ SC-1, SC-2, SC-4**
- [ ] 61. **per-item-VbC: Verify PR sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm PR sub-skill exists with 4 task files (3 original + post-implementation.md), and approval-gate/tasks/ is empty. **→ SC-2**

- [ ] 62. **GREEN: Create git-workflow-cleanup sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-cleanup/` with SKILL.md. Move 3 task files (cleanup, pair-cleanup, merge cleanup) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 63. **per-item-VbC: Verify cleanup sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm cleanup sub-skill exists with 3 task files. **→ SC-2**

- [ ] 64. **GREEN: Create git-workflow-conflict sub-skill (**sub-agent**).** Create `.opencode/skills/git-workflow-conflict/` with SKILL.md. Move 1 task file (rebase/merge conflict resolution) from original tasks/. Reference `conflict-resolution` skill. **→ SC-1, SC-2, SC-4**
- [ ] 65. **per-item-VbC: Verify conflict sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm conflict sub-skill exists with 1 task file and correct cross-reference. **→ SC-2**

- [ ] 66. **GREEN: Distribute pair-* and submodule tasks (**sub-agent**).** Distribute pair-pre-work → branch, pair-commit → commit, pair-pr-creation → pr, pair-cleanup → cleanup, pair-mode-resume → branch. Assign submodule-sync, pre-commit-pointer-check, provenance → branch. **→ SC-2**
- [ ] 67. **per-item-VbC: Verify task distribution (**green-vbc**: `verification-before-completion --task completion`).** Confirm all pair-* and submodule tasks assigned to correct sub-skills. **→ SC-2**

- [ ] 68. **GREEN: Convert git-workflow SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/git-workflow/SKILL.md` as dispatcher. Add Trigger Dispatch Table routing to 5 sub-skills. Add DISPATCH_GATE protocol. Keep all trigger phrases (pre-work, commit, pr, cleanup, conflict, release PR, pair-*). **→ SC-3, SC-5**
- [ ] 69. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references all 5 sub-skills and preserves all original trigger phrases. **→ SC-3, SC-5**

- [ ] 70. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) 5 sub-skill dirs exist, (2) all task files present, (3) post-implementation.md moved to git-workflow-pr/, (4) approval-gate/tasks/ empty, (5) dispatcher references all 5 sub-skills, (6) RED tests PASS after split. **→ SC-2, SC-3, SC-5**
- [ ] 71. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence for Phase 4. **→ SC-ALL**
- [ ] 72. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 4 modified files. **→ SC-ALL**

- [ ] 73. **Cleanup: Delete empty original tasks/ directories (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/git-workflow/tasks/` and `rmdir .opencode/skills/approval-gate/tasks/` (confirm both empty first). **→ SC-2**
- [ ] 74. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 4 output: `"Phase 4: Split git-workflow into 5 sub-skills"`. **→ SC-ALL**
- [ ] 75. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-4-main`. **→ SC-ALL**

- [ ] 76. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_4 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 77. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 4. **→ SC-ALL**

**Concern transition:** Leaving git-workflow split → entering writing-plans split. Phase 5 depends on Phase 1 (dispatcher template) and runs independently of Phases 2-4.
