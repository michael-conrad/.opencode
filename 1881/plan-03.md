# Phase 3 — Split approval-gate

**Concern:** approval-gate → 4 sub-skills (approval-gate-scope, approval-gate-labels, approval-gate-revision, approval-gate-bug-discovery)

**Files:**
- `.opencode/skills/approval-gate/SKILL.md` — Converted to dispatcher
- `.opencode/skills/approval-gate-scope/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/approval-gate-scope/tasks/` — 17 task files
- `.opencode/skills/approval-gate-scope/enforcement/` — 3 enforcement files
- `.opencode/skills/approval-gate-labels/SKILL.md` — New (thin router, delegates to scope)
- `.opencode/skills/approval-gate-revision/SKILL.md` — New (thin router, delegates to scope)
- `.opencode/skills/approval-gate-bug-discovery/SKILL.md` — New (thin router, delegates to scope)
- `.opencode/skills/approval-gate/tasks/post-implementation.md` — LEFT in place (moved in Phase 4)
- `.opencode/tests/behaviors/` — approval-gate related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists at `.opencode/reference/dispatcher-template.md`
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 4 sub-skill directories created with SKILL.md files (scope has tasks/, enforcement/; 3 thin routers have no task files)
- 17 task files moved to approval-gate-scope/tasks/
- 3 enforcement files moved to approval-gate-scope/enforcement/
- Dispatcher SKILL.md routes triggers to sub-skills
- post-implementation.md remains in original tasks/ dir for Phase 4 pickup
- Original enforcement/ dir deleted (empty after migration)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- all task files maintain original behavior from new locations

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- labels, revision, bug-discovery sub-skills are thin routers with no task files (delegate to scope)
- post-implementation.md is NOT an approval-gate task — left for Phase 4 git-workflow split
- enforcement/ directory migrates to approval-gate-scope/enforcement/

**State Transitions:**
- `approval-gate/SKILL.md` before: full skill + enforcement → after: dispatcher only
- `approval-gate/tasks/` before: 18 files + post-implementation.md → after: only post-implementation.md remains
- `approval-gate/enforcement/` before: 3 files → after: empty → deleted
- Thin router dirs before: don't exist → after: exist with basic SKILL.md

---

- [ ] 36. **RED: Write behavioral tests for approval-gate dispatch routing (**sub-agent**).** Dispatch `test-driven-development --task red`. Write behavioral tests that dispatch agent prompts for scope verification, label application, revision revocation, and bug discovery. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 37. **red-doublecheck (**clean-room**).** Dispatch `verification-before-completion --task verify`. Verify RED tests fail with expected failure reasons — confirm no false-negatives. **→ SC-2, SC-5**
- [ ] 38. **post-red-enforcement (**sub-agent**).** Dispatch `implementation-pipeline --task post-red-enforcement`. Verify RED step produced only test code. **→ SC-2, SC-5**

- [ ] 39. **GREEN: Create approval-gate-scope sub-skill (**sub-agent**).** Create `.opencode/skills/approval-gate-scope/` directory with SKILL.md (Agent-Intent Pattern, Trigger Dispatch Table). Move 17 task files from `approval-gate/tasks/` to `scope/tasks/`. Move 3 enforcement files from `approval-gate/enforcement/` to `scope/enforcement/`. **→ SC-1, SC-2, SC-4**
- [ ] 40. **per-item-VbC: Verify scope sub-skill (**green-vbc**: `verification-before-completion --task completion`).** Confirm scope sub-skill has SKILL.md, tasks/ with 17 files, enforcement/ with 3 files. **→ SC-2**

- [ ] 41. **GREEN: Create 3 thin router sub-skills (**sub-agent**).** Create `.opencode/skills/approval-gate-labels/`, `approval-gate-revision/`, `approval-gate-bug-discovery/` directories. Each gets a minimal SKILL.md with Trigger Dispatch Table that delegates to `approval-gate-scope` for task execution. No task files. **→ SC-1, SC-4, SC-5**
- [ ] 42. **per-item-VbC: Verify thin router sub-skills (**green-vbc**: `verification-before-completion --task completion`).** Confirm 3 thin router dirs exist with basic SKILL.md and correct delegation references. **→ SC-4, SC-5**

- [ ] 43. **GREEN: Convert approval-gate SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/approval-gate/SKILL.md` as a dispatcher. Keep all trigger phrases. Add Trigger Dispatch Table routing to 4 sub-skills. Add DISPATCH_GATE protocol. Note: post-implementation.md stays in original tasks/ directory. **→ SC-3, SC-5**
- [ ] 44. **per-item-VbC: Verify dispatcher routing (**green-vbc**: `verification-before-completion --task completion`).** Verify dispatcher Trigger Dispatch Table references all 4 sub-skills and preserves original trigger phrases. **→ SC-3, SC-5**

- [ ] 45. **GREEN doublecheck (**sub-agent**).** Dispatch `verification-before-completion --task verify`. Confirm: (1) 4 sub-skill dirs exist, (2) scope has tasks/ + enforcement/, (3) thin routers present, (4) post-implementation.md remains, (5) dispatcher routes correctly, (6) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 46. **completeness-gate (**sub-agent**).** Dispatch `completeness-gate --task check`. Verify SC-1 through SC-5 have VbC evidence for Phase 3. **→ SC-ALL**
- [ ] 47. **structural-checks (**sub-agent**).** Dispatch `finishing-a-development-branch --task checklist`. Run lint/typecheck on Phase 3 modified files. **→ SC-ALL**

- [ ] 48. **Cleanup: Delete empty original enforcement/ directory (**sub-agent**).** Dispatch `git-workflow --task commit-prep` with cleanup instruction — `rmdir .opencode/skills/approval-gate/enforcement/` (confirm empty first). Original tasks/ NOT deleted (post-implementation.md remains). **→ SC-2**
- [ ] 49. **Checkpoint commit (**sub-agent**).** Dispatch `git-workflow --task commit-prep`. Stage and commit Phase 3 output: `"Phase 3: Split approval-gate into 4 sub-skills"`. **→ SC-ALL**
- [ ] 50. **checkpoint-tag-create (**sub-agent**).** Dispatch `implementation-pipeline --task checkpoint-tag-create`. Create checkpoint tag `feature/1881-skill-split/checkpoint/phase-3-main`. **→ SC-ALL**

- [ ] 51. **solve state update (**sub-agent**).** Update solve state: `solve state update {project_root}/tmp/1881/state/ --var-name phase_3 --var-value complete --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml`. **→ SC-ALL**
- [ ] 52. **solve check (**sub-agent**).** Dispatch `solve check` — verify state consistency after Phase 3. **→ SC-ALL**

**Concern transition:** Leaving approval-gate split → entering git-workflow split. Phase 4 depends on Phase 1 (dispatcher template). Phase 4 also picks up post-implementation.md from Phase 3's remaining tasks directory.
