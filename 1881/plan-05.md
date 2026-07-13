# Phase 5 — Split writing-plans

**Concern:** writing-plans → 2 sub-skills (writing-plans-creation, writing-plans-holistic) per spec split table. Retroactive merged into creation per DEC-7.

**Files:**
- `.opencode/skills/writing-plans/SKILL.md` — Converted to dispatcher
- `.opencode/skills/writing-plans-creation/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/writing-plans-creation/tasks/` — 18 task files (17 original + retroactive merged in)
- `.opencode/skills/writing-plans-creation/contracts/` — Contracts directory moved from parent
- `.opencode/skills/writing-plans-holistic/SKILL.md` — New
- `.opencode/skills/writing-plans-holistic/tasks/` — 2 task files (holistic-self-check, audit-fidelity, audit-concern)
- `.opencode/tests/behaviors/` — writing-plans related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 2 sub-skill directories created with SKILL.md files
- 19 task files moved to sub-skill tasks/ (18 to creation, 1 to holistic)
- contracts/ directory moved to writing-plans-creation/contracts/
- Retroactive task merged into creation sub-skill (per DEC-7)
- Dispatcher SKILL.md routes triggers to sub-skills
- Original tasks/ and contracts/ directories deleted (empty)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- Contracts move with creation sub-skill (used by create pipeline)
- Retroactive plan creation routed to creation sub-skill

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- Holistic check is a standalone sub-skill (1 task file)
- Retroactive plan creation is merged into creation sub-skill (per DEC-7 — avoids 1-task sub-skill)
- Contracts must be with creation sub-skill (the primary consumer)

**State Transitions:**
- `writing-plans/SKILL.md` before: full skill → after: dispatcher
- `writing-plans/tasks/` before: 19 files → after: empty → deleted
- `writing-plans/contracts/` before: 22 templates → after: empty → deleted
- Sub-skill dirs before: don't exist → after: exist with SKILL.md + tasks/

---

- [ ] 78. **RED: Write behavioral tests for writing-plans dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests for creation pipeline, holistic check, and retroactive plan triggers. Verify via `assert_stderr_pattern_present` that creation and retroactive triggers route to `writing-plans-creation`, holistic triggers route to `writing-plans-holistic`. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 79. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-2, SC-5**
- [ ] 80. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-2, SC-5**

- [ ] 81. **GREEN: Create writing-plans-creation sub-skill (**sub-agent**).** Create `.opencode/skills/writing-plans-creation/` with SKILL.md. Move 18 task files from original tasks/ (17 creation pipeline + retroactive merged in). Move contracts/ to `creation/contracts/`. **→ SC-1, SC-2, SC-4**
- [ ] 82. **per-item-VbC: Verify creation sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm creation sub-skill exists with 18 task files and contracts/ directory. **→ SC-2**

- [ ] 83. **GREEN: Create writing-plans-holistic sub-skill (**sub-agent**).** Create `.opencode/skills/writing-plans-holistic/` with SKILL.md. Move 1 task file (holistic-self-check) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 84. **per-item-VbC: Verify holistic sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm holistic sub-skill exists with 1 task file. **→ SC-2**

- [ ] 85. **GREEN: Convert writing-plans SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/writing-plans/SKILL.md` as dispatcher. Add Trigger Dispatch Table routing to 2 sub-skills. Keep all trigger phrases including `holistic check`, `plan quality verification`, `retroactive plan`, `backfill plan`. Retroactive triggers route to `writing-plans-creation`. **→ SC-3, SC-5**
- [ ] 86. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references both sub-skills and preserves all original trigger phrases. **→ SC-3, SC-5**

- [ ] 87. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) 2 sub-skill dirs exist, (2) creation has 18 task files + contracts/, (3) holistic has 1 task file, (4) original tasks/ and contracts/ empty, (5) RED tests PASS after split. **→ SC-2, SC-3, SC-5**
- [ ] 88. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence for Phase 5. **→ SC-ALL**
- [ ] 89. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 5 modified files. **→ SC-ALL**

- [ ] 90. **Cleanup: Delete empty original directories (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/writing-plans/tasks/` and `rmdir .opencode/skills/writing-plans/contracts/` (confirm both empty first). **→ SC-2**
- [ ] 91. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 5 output: `"Phase 5: Split writing-plans into 2 sub-skills (retroactive merged into creation)"`. **→ SC-ALL**
- [ ] 92. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-5-main`. **→ SC-ALL**

- [ ] 93. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_5 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 94. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 5. **→ SC-ALL**

**Concern transition:** Leaving writing-plans split → entering spec-creation split. Phase 6 depends on Phase 1 (dispatcher template) and runs independently of Phases 2-5.
