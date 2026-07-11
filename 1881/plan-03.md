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

- [ ] 25. **RED: Write behavioral tests for approval-gate dispatch routing (**sub-agent**).** Write behavioral tests that dispatch agent prompts for scope verification, label application, revision revocation, and bug discovery. Verify via `assert_stderr_pattern_present` that routing targets the correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 26. **GREEN: Create approval-gate-scope sub-skill (**sub-agent**).** Create `.opencode/skills/approval-gate-scope/` directory with SKILL.md (Agent-Intent Pattern, Trigger Dispatch Table). Move 17 task files from `approval-gate/tasks/` to `scope/tasks/`. Move 3 enforcement files from `approval-gate/enforcement/` to `scope/enforcement/`. **→ SC-1, SC-2, SC-4**
- [ ] 27. **GREEN: Create thin router sub-skills (**sub-agent**).** Create `.opencode/skills/approval-gate-labels/`, `.opencode/skills/approval-gate-revision/`, and `.opencode/skills/approval-gate-bug-discovery/` directories. Each gets a minimal SKILL.md with Trigger Dispatch Table that delegates to `approval-gate-scope` for task execution. No task files. **→ SC-1, SC-4, SC-5**
- [ ] 28. **GREEN: Convert approval-gate SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/approval-gate/SKILL.md` as a dispatcher. Keep all trigger phrases. Add Trigger Dispatch Table routing to 4 sub-skills. Add DISPATCH_GATE protocol. Note: post-implementation.md stays in original tasks/ directory. **→ SC-3, SC-5**
- [ ] 29. **GREEN doublecheck: Verify sub-skill structure (**sub-agent**).** Confirm: (1) 4 sub-skill dirs exist, (2) scope has tasks/ + enforcement/, (3) thin routers exist with basic SKILL.md, (4) post-implementation.md still in original tasks/, (5) dispatcher Trigger Dispatch Table references all 4 sub-skills. **→ SC-2, SC-3, SC-5**
- [ ] 30. **Cleanup: Delete empty original enforcement/ directory (**inline**).** `rmdir .opencode/skills/approval-gate/enforcement/` (confirm empty first). Original tasks/ NOT deleted (post-implementation.md remains). **→ SC-2**
- [ ] 31. **Checkpoint commit (**inline**).** `git add .opencode/skills/approval-gate* .opencode/tests/behaviors/ && git commit -m "Phase 3: Split approval-gate into 4 sub-skills"` **→ SC-ALL**

#### Phase 3 VbC

- [ ] 32. **VbC (**clean-room**).** Verify: (1) 4 sub-skill dirs exist, (2) scope has tasks/ + enforcement/, (3) thin routers present, (4) post-implementation.md remains, (5) dispatcher routes correctly, (6) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving approval-gate split → entering git-workflow split. Phase 4 depends on Phase 1 (dispatcher template). Phase 4 also picks up post-implementation.md from Phase 3's remaining tasks directory.
