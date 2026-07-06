# Phase 02 — Dispatch Table Fixes

**Concern:** Fix spec-creation SKILL.md Tasks table, Invocation section, and Trigger Dispatch Table to correctly reference all 8 task files and use the correct canonical dispatch string.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Tasks table, Invocation section, Trigger Dispatch Table

**SCs:** SC-5, SC-6, SC-7

**Dependencies:** None

**Entry conditions:** Feature branch exists, pre-red-baseline complete

**Exit conditions:** All 3 SCs verified PASS

---

- [ ] 11. **Coherence gate (**clean-room**).** Read `.opencode/skills/spec-creation/SKILL.md` Tasks table, Invocation section, and Trigger Dispatch Table. Confirm current state: 1 task entry, `execute create task` reference, 1 dispatch row. Report findings. **→ SC-5, SC-6, SC-7**

- [ ] 12. **Pre-red-baseline (**clean-room**).** Run `ls .opencode/skills/spec-creation/tasks/` and count files. Confirm 8 task files exist. Record baseline. **→ SC-5**

- [ ] 13. **RED: behavioral test (**sub-agent**).** Write behavioral test at `.opencode/tests/behaviors/spec-creation-dispatch-table.sh` that sends `"execute write task from spec-creation"` via `opencode-cli run` and asserts stderr contains the correct dispatch. Run the test — it MUST FAIL (RED). **→ SC-6**

- [ ] 14. **GREEN: expand Tasks table (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` Tasks table. Expand from 1 row (create) to 8 rows: `create`, `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`. Each row with task name, description, and sub-agent indicator. **→ SC-5**

- [ ] 15. **GREEN: fix Invocation section (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` Invocation section. Change canonical dispatch from `"execute create task from spec-creation"` to `"execute write task from spec-creation"`. The `skill({name: "spec-creation"})` call remains unchanged. **→ SC-6**

- [ ] 16. **GREEN: expand Trigger Dispatch Table (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` Trigger Dispatch Table. Add 7 rows for orchestrator-invocable sub-tasks: `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`. Each row: trigger pattern, dispatch type (`sub-task`), canonical `task(..., prompt: "execute <task> from spec-creation")` string. **→ SC-7**

- [ ] 17. **GREEN doublecheck (**clean-room**).** Verify: Tasks table has 8 entries (SC-5), Invocation section has `"execute write task from spec-creation"` (SC-6), Trigger Dispatch Table has rows for all 7 sub-tasks (SC-7). **→ SC-5, SC-6, SC-7**

- [ ] 18. **Checkpoint commit (**inline**).** Commit: `git add .opencode/skills/spec-creation/SKILL.md && git commit -m "Phase 2: Expand dispatch tables and fix invocation"`. Create checkpoint tag. **→ SC-5, SC-6, SC-7**

- [ ] 19. **VbC (**clean-room**).** Verify all 3 SCs: grep for 8 task entries (SC-5), grep for `"execute write task from spec-creation"` (SC-6), grep for each sub-task row (SC-7). **→ SC-5, SC-6, SC-7**

#### Phase 02 VbC

- [ ] 19. **VbC (**clean-room**).** Verify: SC-5 (8 task entries), SC-6 (correct invocation), SC-7 (7 sub-task rows). **→ SC-5, SC-6, SC-7**

**Concern transition:** Leaving dispatch table fixes → entering write.md structural renumbering. Phase 3 depends on Phase 2 (same file — write.md is a task of spec-creation). Phase 3 modifies write.md labels, ordering, and content templates.
