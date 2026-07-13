# Phase 3 — Split approval-gate

**Concern:** approval-gate → 1 sub-skill (approval-gate-scope) with labels/revision/bug-discovery as sub-tasks per spec DEC-3

**Files:**
- `.opencode/skills/approval-gate/SKILL.md` — Converted to dispatcher
- `.opencode/skills/approval-gate-scope/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/approval-gate-scope/tasks/` — 22 task files (all from original tasks/)
- `.opencode/skills/approval-gate-scope/enforcement/` — 5 enforcement files
- `.opencode/skills/approval-gate/tasks/post-implementation.md` — LEFT in place (moved in Phase 4)
- `.opencode/tests/behaviors/` — approval-gate related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists at `.opencode/reference/dispatcher-template.md`
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 1 sub-skill directory created (approval-gate-scope) with SKILL.md
- 22 task files moved to approval-gate-scope/tasks/
- 5 enforcement files moved to approval-gate-scope/enforcement/
- Labels, revision, and bug-discovery concerns embedded as sub-tasks within scope task files (per DEC-3)
- Dispatcher SKILL.md routes triggers to scope sub-skill
- post-implementation.md remains in original tasks/ dir for Phase 4 pickup
- Original enforcement/ dir deleted (empty after migration)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → scope sub-skill entry
- All 22 task files maintain original behavior from new locations
- Labels, revision, bug-discovery triggers all route to scope (single sub-skill)

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- Labels, revision, bug-discovery are NOT separate sub-skills — they are sub-tasks within scope per DEC-3
- post-implementation.md is NOT an approval-gate task — left for Phase 4 git-workflow split
- enforcement/ directory migrates to approval-gate-scope/enforcement/

**State Transitions:**
- `approval-gate/SKILL.md` before: full skill + enforcement → after: dispatcher only
- `approval-gate/tasks/` before: 22 files + post-implementation.md → after: only post-implementation.md remains
- `approval-gate/enforcement/` before: 5 files → after: empty → deleted
- `approval-gate-scope/` before: doesn't exist → after: exists with SKILL.md + tasks/ + enforcement/

---

- [ ] 36. **RED: Write behavioral tests for approval-gate dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests that dispatch agent prompts for scope verification, label application, revision revocation, and bug discovery. Verify via `assert_stderr_pattern_present` that all 4 trigger categories route to `approval-gate-scope` (single sub-skill). Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 37. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-2, SC-5**
- [ ] 38. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-2, SC-5**

- [ ] 39. **GREEN: Create approval-gate-scope sub-skill (**sub-agent**).** Create `.opencode/skills/approval-gate-scope/` directory with SKILL.md (Agent-Intent Pattern, Trigger Dispatch Table). Move 22 task files from `approval-gate/tasks/` to `scope/tasks/`. Move 5 enforcement files from `approval-gate/enforcement/` to `scope/enforcement/`. Labels, revision, and bug-discovery concerns are embedded as sub-tasks within scope task files — no separate sub-skills created. **→ SC-1, SC-2, SC-4**
- [ ] 40. **per-item-VbC: Verify scope sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm scope sub-skill has SKILL.md, tasks/ with 22 files, enforcement/ with 5 files. **→ SC-2**

- [ ] 41. **GREEN: Convert approval-gate SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/approval-gate/SKILL.md` as a dispatcher. Keep all trigger phrases. Add Trigger Dispatch Table routing to `approval-gate-scope` (single sub-skill). Add DISPATCH_GATE protocol. Note: post-implementation.md stays in original tasks/ directory. **→ SC-3, SC-5**
- [ ] 42. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references `approval-gate-scope` and preserves all original trigger phrases. **→ SC-3, SC-5**

- [ ] 43. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) 1 sub-skill dir exists (approval-gate-scope), (2) scope has tasks/ (22 files) + enforcement/ (5 files), (3) post-implementation.md remains, (4) dispatcher routes to scope, (5) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 44. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence for Phase 3. **→ SC-ALL**
- [ ] 45. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 3 modified files. **→ SC-ALL**

- [ ] 46. **Cleanup: Delete empty original enforcement/ directory (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/approval-gate/enforcement/` (confirm empty first). Original tasks/ NOT deleted (post-implementation.md remains). **→ SC-2**
- [ ] 47. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 3 output: `"Phase 3: Split approval-gate into 1 sub-skill (scope) with labels/revision/bug-discovery as sub-tasks"`. **→ SC-ALL**
- [ ] 48. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-3-main`. **→ SC-ALL**

- [ ] 49. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_3 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 50. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 3. **→ SC-ALL**

**Concern transition:** Leaving approval-gate split → entering git-workflow split. Phase 4 depends on Phase 1 (dispatcher template). Phase 4 also picks up post-implementation.md from Phase 3's remaining tasks directory.
