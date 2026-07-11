# Phase 5 — Split writing-plans

**Concern:** writing-plans → 3 sub-skills (writing-plans-creation, writing-plans-holistic, writing-plans-retroactive)

**Files:**
- `.opencode/skills/writing-plans/SKILL.md` — Converted to dispatcher
- `.opencode/skills/writing-plans-creation/SKILL.md` — New, with Trigger Dispatch Table
- `.opencode/skills/writing-plans-creation/tasks/` — 15 task files
- `.opencode/skills/writing-plans-creation/contracts/` — Contracts directory moved from parent
- `.opencode/skills/writing-plans-holistic/SKILL.md` — New
- `.opencode/skills/writing-plans-holistic/tasks/` — 4 task files
- `.opencode/skills/writing-plans-retroactive/SKILL.md` — New
- `.opencode/skills/writing-plans-retroactive/tasks/` — 1 task file
- `.opencode/tests/behaviors/` — writing-plans related tests updated

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Phase 1 (dispatcher template exists)

**Entry conditions:**
- Dispatcher template exists
- validate.md accepts Agent-Intent Pattern

**Exit conditions:**
- 3 sub-skill directories created with SKILL.md files
- 19 task files moved to sub-skill tasks/
- contracts/ directory moved to writing-plans-creation/contracts/
- Dispatcher SKILL.md routes triggers to sub-skills
- Original tasks/ and contracts/ directories deleted (empty)
- Behavioral tests for dispatch routing PASS

**Code Path Coverage:**
- SKILL.md routing section → Trigger Dispatch Table → sub-skill entry points
- Contracts move with creation sub-skill (used by create pipeline)

**Cross-Cutting SCs:** SC-1 (dispatcher template), SC-2 (sub-skill task ownership), SC-3 (preserved triggers), SC-4 (Agent-Intent descriptions), SC-5 (dispatch routing)

**Interface Boundaries:**
- Holistic check and retroactive plan creation are variants of the creation pipeline; their dispatcher triggers route to their own sub-skills
- Contracts must be with creation sub-skill (the primary consumer)

**State Transitions:**
- `writing-plans/SKILL.md` before: full skill → after: dispatcher
- `writing-plans/tasks/` before: 19 files → after: empty → deleted
- `writing-plans/contracts/` before: 22 templates → after: empty → deleted
- Sub-skill dirs before: don't exist → after: exist with SKILL.md + tasks/

---

- [ ] 45. **RED: Write behavioral tests for writing-plans dispatch routing (**sub-agent**).** Write behavioral tests for creation pipeline, holistic check, and retroactive plan triggers. Verify via `assert_stderr_pattern_present` that routing targets correct sub-skill. Tests must FAIL before split. **→ SC-2, SC-5**
- [ ] 46. **GREEN: Create writing-plans-creation sub-skill (**sub-agent**).** Create `.opencode/skills/writing-plans-creation/` with SKILL.md. Move 15 task files from original tasks/. Move contracts/ to `creation/contracts/`. **→ SC-1, SC-2, SC-4**
- [ ] 47. **GREEN: Create writing-plans-holistic sub-skill (**sub-agent**).** Create `.opencode/skills/writing-plans-holistic/` with SKILL.md. Move 4 task files (holistic-self-check, validate, audit-fidelity, audit-concern) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 48. **GREEN: Create writing-plans-retroactive sub-skill (**sub-agent**).** Create `.opencode/skills/writing-plans-retroactive/` with SKILL.md. Move 1 task file (retroactive plan creation) from original tasks/. **→ SC-1, SC-2, SC-4**
- [ ] 49. **GREEN: Convert writing-plans SKILL.md to dispatcher (**sub-agent**).** Rewrite `.opencode/skills/writing-plans/SKILL.md` as dispatcher. Add Trigger Dispatch Table routing to 3 sub-skills. Keep all trigger phrases including `holistic check`, `plan quality verification`, `retroactive plan`, `backfill plan`. **→ SC-3, SC-5**
- [ ] 50. **GREEN doublecheck: Verify sub-skill structure (**sub-agent**).** Confirm: (1) 3 sub-skill dirs exist, (2) all task files present, (3) contracts/ moved to creation/, (4) original tasks/ and contracts/ empty. **→ SC-2, SC-3, SC-5**
- [ ] 51. **Cleanup: Delete empty original directories (**inline**).** `rmdir .opencode/skills/writing-plans/tasks/` and `rmdir .opencode/skills/writing-plans/contracts/` (confirm both empty first). **→ SC-2**
- [ ] 52. **Checkpoint commit (**inline**).** `git add .opencode/skills/writing-plans* .opencode/tests/behaviors/ && git commit -m "Phase 5: Split writing-plans into 3 sub-skills"` **→ SC-ALL**

#### Phase 5 VbC

- [ ] 53. **VbC (**clean-room**).** Verify: (1) 3 sub-skill dirs exist with correct tasks, (2) contracts/ with creation, (3) dispatcher routes correctly, (4) RED tests PASS after split. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving writing-plans split → entering spec-creation split. Phase 6 depends on Phase 1 (dispatcher template) and runs independently of Phases 2-5.
