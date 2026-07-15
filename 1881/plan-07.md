# Phase 7 — Cross-Skill Sweep & Final Gates

**Concern:** Cross-skill validation — verify all 17 sub-skills (4 issue-ops + 1 approval-gate + 5 git-workflow + 2 writing-plans + 5 spec-creation) are correctly wired with 5 dispatchers, all task files migrated, dispatch routing tested, and PR-ready gate passed.

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md` — Verify pipeline state file for cross-skill consistency
- `.opencode/skills/*/SKILL.md` — All 17 sub-skill SKILL.md files
- `.opencode/skills/*/tasks/` — All sub-skill task directories
- `.opencode/tests/behaviors/` — All behavioral test files
- `.opencode/skills/issue-operations/SKILL.md` — Dispatcher (Phase 2)
- `.opencode/skills/approval-gate/SKILL.md` — Dispatcher (Phase 3)
- `.opencode/skills/git-workflow/SKILL.md` — Dispatcher (Phase 4)
- `.opencode/skills/writing-plans/SKILL.md` — Dispatcher (Phase 5)
- `.opencode/skills/spec-creation/SKILL.md` — Dispatcher (Phase 6)
- `.opencode/skills/issue-operations-core/SKILL.md` — Sub-skill (Phase 2)
- `.opencode/skills/issue-operations-comments/SKILL.md` — Sub-skill (Phase 2)
- `.opencode/skills/issue-operations-sub-issues/SKILL.md` — Sub-skill (Phase 2)
- `.opencode/skills/issue-operations-sync/SKILL.md` — Sub-skill (Phase 2)
- `.opencode/skills/approval-gate-scope/SKILL.md` — Sub-skill (Phase 3)
- `.opencode/skills/git-workflow-branch/SKILL.md` — Sub-skill (Phase 4)
- `.opencode/skills/git-workflow-commit/SKILL.md` — Sub-skill (Phase 4)
- `.opencode/skills/git-workflow-pr/SKILL.md` — Sub-skill (Phase 4)
- `.opencode/skills/git-workflow-cleanup/SKILL.md` — Sub-skill (Phase 4)
- `.opencode/skills/git-workflow-conflict/SKILL.md` — Sub-skill (Phase 4)
- `.opencode/skills/writing-plans-creation/SKILL.md` — Sub-skill (Phase 5)
- `.opencode/skills/writing-plans-holistic/SKILL.md` — Sub-skill (Phase 5)
- `.opencode/skills/spec-creation-requirements/SKILL.md` — Sub-skill (Phase 6)
- `.opencode/skills/spec-creation-decomposition/SKILL.md` — Sub-skill (Phase 6)
- `.opencode/skills/spec-creation-validation/SKILL.md` — Sub-skill (Phase 6)
- `.opencode/skills/spec-creation-change-control/SKILL.md` — Sub-skill (Phase 6)
- `.opencode/skills/spec-creation-operating-protocol/SKILL.md` — Sub-skill (Phase 6)
- `.opencode/skills/implementation-pipeline/SKILL.md` — Pipeline state machine
- `.opencode/.issues/1881/plan.md` — Index file (update with final dispatch table)

**SCs:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9

**Dependencies:** Phases 1-6 complete

**Entry conditions:**
- All 5 split phases (Phases 2-6) complete with checkpoint commits and tags
- All dispatcher SKILL.md files written
- All sub-skill directories exist with task files

**Exit conditions:**
- 17 sub-skills confirmed with correct dispatcher routing
- All 5 original dispatchers route to sub-skills
- Full behavioral test suite PASS (all models)
- SC-9 (anti-lobotomization) verified with behavioral test
- pre-pr-gate: PR-ready verification
- No orphaned task files remain in original skill directories
- Final checkpoint tag created

**Code Path Coverage:**
- End-to-end dispatch chain: skill description → dispatcher → Trigger Dispatch Table → sub-skill entry → task execution
- Pipeline state machine: all 6 phase transitions verified

**Cross-Cutting SCs:** All cross-cutting SCs from Phases 1-6 sweep-verified together

**Interface Boundaries:**
- Final plan.md dispatch column must reflect all 17 sub-skills with correct dispatch indicators
- No task file should belong to two sub-skills
- pipeline-state-machine.yaml must have correct phase transition records for all 6 phases

**State Transitions:**
- `plan.md` dispatch table before sweep: Phase 1-6 grouped rows → after sweep: full 17 sub-skill detailed dispatch table
- Worktree state before: checkpoint tags for phases 1-6 → after: final checkpoint tag for phase 7

---

- [ ] 118. **RED: Write cross-skill behavioral tests for end-to-end dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write comprehensive cross-skill dispatch test: send a trigger for each of the 5 original skills and verify routing reaches the correct sub-skill (17 routing paths). Verify via `assert_stderr_pattern_present`. Tests must FAIL before sweep fixes. **→ SC-5**
- [ ] 119. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-5**
- [ ] 120. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-5**

- [ ] 121. **GREEN: Sweep-verify all 5 dispatcher SKILL.md files (**sub-agent**).** Verify routing tables are present and correct in issue-operations/SKILL.md, approval-gate/SKILL.md, git-workflow/SKILL.md, writing-plans/SKILL.md, spec-creation/SKILL.md. Each must reference ONLY its sub-skills, no orphaned references. **→ SC-2, SC-3, SC-5**
- [ ] 122. **per-item-VbC: Verify dispatchers (**green-vbc**: `verification-before-completion --task completion`).** Confirm all 5 dispatchers reference correct sub-skills with no orphans. **→ SC-3, SC-5**

- [ ] 123. **GREEN: Sweep-verify all 17 sub-skill SKILL.md files (**sub-agent**).** Verify each sub-skill has: correct Trigger Dispatch Table (if applicable), DISPATCH_GATE protocol, Agent-Intent purpose description, task references matching existing files. **→ SC-2, SC-4, SC-5**
- [ ] 124. **per-item-VbC: Verify sub-skill correctness (**green-vbc**: `verification-before-completion --task completion`).** Confirm all 17 sub-skills meet SKILL.md standards. **→ SC-4**

- [ ] 125. **GREEN: Sweep-verify all task files migrated (**sub-agent**).** Verify: (1) original `tasks/` directories for all 5 split skills are empty or deleted, (2) each sub-skill `tasks/` directory has correct file count, (3) no task file exists in two locations, (4) post-implementation.md lives only in `git-workflow-pr/tasks/`. **→ SC-2**
- [ ] 126. **per-item-VbC: Verify task migration (**green-vbc**: `verification-before-completion --task completion`).** Confirm all task files in correct locations with no duplicates. **→ SC-2**

- [ ] 127. **GREEN: Run full cross-skill dispatch behavioral test suite (**sub-agent**).** Run all behavioral tests for Phases 2-6 dispatch routing. Verify all PASS with `assert_stderr_pattern_present`. Reproduce RED tests now GREEN. **→ SC-5**
- [ ] 128. **per-item-VbC: Verify test suite PASS (**green-vbc**: `verification-before-completion --task completion`).** Confirm full test suite PASS across all 17 sub-skill routing paths. **→ SC-5**

- [ ] 129. **GREEN: Verify pipeline state machine consistency (**sub-agent**).** Read `.opencode/skills/implementation-pipeline/SKILL.md` pipeline state section. Verify all 6 phases have state transitions recorded. Confirm solve state machine has entries for all phases. **→ SC-6**
- [ ] 130. **per-item-VbC: Verify state machine (**green-vbc**: `verification-before-completion --task completion`).** Confirm all 6 phases present in pipeline state. **→ SC-6**

- [ ] 131. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Final cross-skill verification: (1) 17 sub-skills exist, (2) 5 dispatchers route correctly, (3) all task files migrated, (4) test suite PASS, (5) pipeline state consistent. **→ SC-ALL**

---

### pre-pr-gate (final readiness check)

- [ ] 134. **pre-pr-gate: Verify PR readiness (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run full structural checks: lint (`uvx ruff check src/`), format check (`uvx ruff format --check src/`), type check (`uvx pyright src/`), Markdown lint (`uvx pymarkdownlnt scan -r .opencode/`). Verify git status clean. **→ SC-ALL**
- [ ] 135. **pre-pr-gate doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Confirm all structural checks PASS and no uncommitted/staged changes remain. **→ SC-ALL**

---

### Final Checkpoint & PR Preparation

- [ ] 136. **Final checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 7 output: `"Phase 7: Cross-skill sweep and final gates"`. **→ SC-ALL**
- [ ] 137. **Final checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create final checkpoint tag `feature/1881-skill-split/checkpoint/phase-7-main`. **→ SC-ALL**

- [ ] 138. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_7 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 139. **solve check (**sub-agent**).** Dispatch `solve check` — verify final state consistency across all 7 phases. **→ SC-ALL**

**Exit gate:** All 7 plan phases complete. pre-pr-gate PASS. Report to developer with phase-complete summary, checkpoint tags, and open PR.
