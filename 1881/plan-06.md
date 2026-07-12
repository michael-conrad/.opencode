# Phase 6 — Split spec-creation

**Concern:** spec-creation → 4 sub-skills (spec-creation-requirements, spec-creation-decomposition, spec-creation-validation, spec-creation-change-control)

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Converted to dispatcher
- `.opencode/skills/spec-creation-requirements/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/spec-creation-requirements/tasks/` — 2 task files (requirements extraction, pre-spec inspection)
- `.opencode/skills/spec-creation-decomposition/SKILL.md` — New
- `.opencode/skills/spec-creation-decomposition/tasks/` — 7 task files (decompose, brainstorming, etc.)
- `.opencode/skills/spec-creation-decomposition/contracts/` — Contracts directory moved from parent
- `.opencode/skills/spec-creation-validation/SKILL.md` — New
- `.opencode/skills/spec-creation-validation/tasks/` — 4 task files (validate, holistic self-check, completion)
- `.opencode/skills/spec-creation-change-control/SKILL.md` — New
- `.opencode/skills/spec-creation-change-control/tasks/` — 1 task file
- `.opencode/tests/behaviors/` — spec-creation related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 4 sub-skill directories created with SKILL.md files
- 14 task files moved to sub-skill tasks/
- contracts/ directory moved to decomposition/contracts/
- Completion task assigned to validation sub-skill
- Dispatcher SKILL.md routes triggers to sub-skills
- Original tasks/ and contracts/ directories deleted (empty)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- Completion task assigned to validation (makes sense: validation owns the completion gate)

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- Requirements sub-skill owns the early-phase spec work (extraction, pre-spec inspection)
- Decomposition sub-skill owns the middle-phase work (brainstorming, SC writing, phase/model-writing)
- Validation sub-skill owns the verification gate (validate, holistic-self-check, completion)
- Change-control sub-skill owns the revision workflow

**State Transitions:**
- `spec-creation/SKILL.md` before: full skill → after: dispatcher
- `spec-creation/tasks/` before: 14 files → after: empty → deleted
- `spec-creation/contracts/` before: contract templates → after: empty → deleted
- Sub-skill dirs before: don't exist → after: exist with SKILL.md + tasks/

---

- [ ] 97. **RED: Write behavioral tests for spec-creation dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests for requirements, decomposition, validation, and change control triggers. Verify via `assert_stderr_pattern_present` that routing targets correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 98. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-2, SC-5**
- [ ] 99. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-2, SC-5**

- [ ] 100. **GREEN: Create spec-creation-requirements sub-skill (**sub-agent**).** Create `.opencode/skills/spec-creation-requirements/` with SKILL.md. Move 2 task files (requirements extraction, pre-spec inspection) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 101. **per-item-VbC: Verify requirements sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm requirements sub-skill exists with 2 task files. **→ SC-2**

- [ ] 102. **GREEN: Create spec-creation-decomposition sub-skill (**sub-agent**).** Create `.opencode/skills/spec-creation-decomposition/` with SKILL.md. Move 7 task files (decompose, brainstorming, SC authoring, phase/model-writing). Move contracts/ from parent. **→ SC-1, SC-2, SC-4**
- [ ] 103. **per-item-VbC: Verify decomposition sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm decomposition sub-skill exists with 7 task files and contracts/ directory. **→ SC-2**

- [ ] 104. **GREEN: Create spec-creation-validation sub-skill (**sub-agent**).** Create `.opencode/skills/spec-creation-validation/` with SKILL.md. Move 4 task files (validate, holistic-self-check, completion). Assign completion task ownership. **→ SC-1, SC-2, SC-4**
- [ ] 105. **per-item-VbC: Verify validation sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm validation sub-skill exists with 4 task files including completion. **→ SC-2**

- [ ] 106. **GREEN: Create spec-creation-change-control sub-skill (**sub-agent**).** Create `.opencode/skills/spec-creation-change-control/` with SKILL.md. Move 1 task file (change control) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 107. **per-item-VbC: Verify change-control sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm change-control sub-skill exists with 1 task file. **→ SC-2**

- [ ] 108. **GREEN: Convert spec-creation SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/spec-creation/SKILL.md` as dispatcher. Add Trigger Dispatch Table routing to 4 sub-skills. Keep all trigger phrases. **→ SC-3, SC-5**
- [ ] 109. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references all 4 sub-skills and preserves all original trigger phrases. **→ SC-3, SC-5**

- [ ] 110. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) 4 sub-skill dirs exist, (2) all task files present, (3) contracts/ with decomposition, (4) completion assigned to validation, (5) dispatcher references all 4 sub-skills, (6) RED tests PASS after split. **→ SC-2, SC-3, SC-5**
- [ ] 111. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence for Phase 6. **→ SC-ALL**
- [ ] 112. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 6 modified files. **→ SC-ALL**

- [ ] 113. **Cleanup: Delete empty original directories (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/spec-creation/tasks/` and `rmdir .opencode/skills/spec-creation/contracts/` (confirm both empty first). **→ SC-2**
- [ ] 114. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 6 output: `"Phase 6: Split spec-creation into 4 sub-skills"`. **→ SC-ALL**
- [ ] 115. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-6-main`. **→ SC-ALL**

- [ ] 116. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_6 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 117. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 6. **→ SC-ALL**

**Concern transition:** Leaving spec-creation split → entering cross-skill sweep. Phase 7 depends on all per-skill split phases (Phases 2-6).
