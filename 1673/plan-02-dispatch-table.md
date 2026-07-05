# Phase 2 — Dispatch Table Fixes

**Concern:** spec-creation SKILL.md has a broken dispatch table — references a `create` task that doesn't exist, Tasks table lists only 1 of 8 task files, and the Trigger Dispatch Table has no rows for orchestrator-invocable sub-tasks.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Tasks table, Invocation section, Trigger Dispatch Table

**SCs:** SC-5, SC-6, SC-7

**Dependencies:** None (independent of Phase 1 — different section of same file, merge-safe)

**Entry conditions:** Feature branch exists

**Exit conditions:** Tasks table lists all 8 task files, dispatch string references `write` task, dispatch table has rows for all 7 sub-tasks

---

### Global Pre-Steps

- [ ] 12. **Coherence gate (**clean-room**).** `skill({name: "pre-analysis"})` → `task(..., prompt: "execute pre-analysis task from pre-analysis")` for spec-creation SKILL.md dispatch table. Verify current dispatch table structure, Tasks table, and Invocation section before making changes.

- [ ] 13. **Pre-red-baseline (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-5, SC-6, SC-7. Confirm current state fails.

### Phase 2 Steps

- [ ] 14. **RED (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute red task from test-driven-development")` for SC-5. Write behavioral test: verify spec-creation SKILL.md Tasks table lists all 8 task files. Confirm FAIL.

- [ ] 15. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-5. Edit `.opencode/skills/spec-creation/SKILL.md` Tasks table: expand from single `create` entry to all 8 task files: `requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`, `change-control`.

- [ ] 16. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-6. Edit Invocation section: change canonical dispatch string from `task(..., prompt: "execute create task from spec-creation")` to `task(..., prompt: "execute write task from spec-creation")`.

- [ ] 17. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-7. Edit Trigger Dispatch Table: expand from single row to include all 7 orchestrator-invocable sub-tasks (`requirements`, `decompose`, `traceability`, `pipeline-readiness-gate`, `risk`, `write`, `completion`). Each row must have: trigger phrase, task name, dispatch type (`sub-task`), and canonical `task(..., prompt: "execute <task> task from spec-creation")` string.

- [ ] 18. **GREEN doublecheck (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-5, SC-6, SC-7. Verify: Tasks table has 8 entries, dispatch string references `write` task, dispatch table has rows for all 7 sub-tasks with canonical strings.

- [ ] 19. **Checkpoint commit (**inline**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute commit task from git-workflow")` with message: `Phase 2: expand spec-creation dispatch table — Tasks table, Invocation string, Trigger Dispatch Table rows`.

### Global Post-Steps

- [ ] 20. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-5. Run behavioral test: verify Tasks table lists 8 entries. Confirm PASS.

- [ ] 21. **Behavioral test (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-7. Run behavioral test: verify dispatch table has rows for all 7 sub-tasks with canonical strings. Confirm PASS.

#### Phase 2 VbC

- [ ] 22. **VbC (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute completion task from verification-before-completion")` for SC-5, SC-6, SC-7. Verify all three SCs pass.

**Concern transition:** Leaving dispatch table fixes → entering write.md structural renumbering. Phase 3 depends on Phase 2 (same file — `write.md` is referenced by the dispatch table).
