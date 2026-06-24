# Implementation Plan — [#1376](https://github.com/michael-conrad/.opencode/issues/1376) — implementation-pipeline SKILL.md orchestrator entry point

**Goal:** Fix implementation-pipeline SKILL.md to provide an orchestrator-facing entry point, create the missing `assemble-work.md` task file, and fix `pipeline-executor.md` purpose statement.

**Architecture:** Three concerns. Concern B (create `assemble-work.md`) and Concern C (fix `pipeline-executor.md`) execute in parallel. Concern A (rewrite SKILL.md) executes last — it references both B and C by name.

**Files:**
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` (new)
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Create `tasks/assemble-work.md` and fix `tasks/pipeline-executor.md`

**Concern:** B (assemble-work.md creation) + C (pipeline-executor.md fix) — parallel, independent

**Files:** `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`, `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`

**SCs:** SC-4, SC-5, SC-6, SC-7, SC-11, SC-12, SC-13, SC-14, SC-15

**Dependencies:** None

**Entry condition:** Feature branch exists, spec approved

**Exit condition:** Both files modified, all 9 SCs verified PASS

- [ ] 1. **RED (**clean-room**).** Verify `tasks/assemble-work.md` does not exist — `ls` returns non-zero. **→ SC-4**
- [ ] 2. **GREEN (**clean-room**).** Create `tasks/assemble-work.md` with: purpose (orchestrator entry point after plan approval), plan reading from `.issues/{N}/plan.md` **→ SC-5**, work state file reading, pre-flight verification, feature branch/worktree creation, Step 1.5 entry proof marker **→ SC-11**, sub-agent dispatch, post-sub-agent completion checkpoint with hash mismatch detection **→ SC-14**, work state verification **→ SC-13**, OVERFLOW handling **→ SC-12**, squash-merge, verification gates, routing to `pipeline-executor` **→ SC-6**, result contract return. **→ SC-4, SC-5, SC-6, SC-11, SC-12, SC-13, SC-14**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify all 7 SCs: SC-4 (file exists), SC-5 (plan.md reference), SC-6 (pipeline-executor reference), SC-11 (Step 1.5/entry proof), SC-12 (OVERFLOW), SC-13 (work state), SC-14 (completion checkpoint/hash mismatch).
- [ ] 4. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/assemble-work.md && git commit -m "feat: create tasks/assemble-work.md entry point"`

- [ ] 5. **RED (**clean-room**).** Verify `pipeline-executor.md` contains step count pattern — `grep` for `[0-9]+-step` returns match. **→ SC-7**
- [ ] 6. **GREEN (**clean-room**).** Remove step count from Purpose section. Ensure purpose describes itself as internal step dispatch table, not orchestrator entry point. **→ SC-7, SC-15**
- [ ] 7. **GREEN doublecheck (**clean-room**).** Verify SC-7 (no `[0-9]+-step` pattern) and SC-15 (no "orchestrator entry" or "entry point" in purpose).
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md && git commit -m "fix: remove stale step count and fix purpose in pipeline-executor.md"`

#### Phase 1 VbC

- [ ] 9. **VbC (**clean-room**).** Verify all 9 SCs PASS: SC-4, SC-5, SC-6, SC-7, SC-11, SC-12, SC-13, SC-14, SC-15. **→ SC-4 through SC-7, SC-11 through SC-15**

**Concern transition:** Leaving Concern B+C (assemble-work + pipeline-executor) → entering Concern A (SKILL.md rewrite). Phase 2 depends on Phase 1 — SKILL.md references `assemble-work` by name.

## Phase 2 — Rewrite SKILL.md

**Concern:** A (SKILL.md rewrite) — depends on Phase 1 (references `assemble-work.md` by name)

**Files:** `.opencode/skills/implementation-pipeline/SKILL.md`

**SCs:** SC-1, SC-2, SC-3, SC-8, SC-9, SC-10

**Dependencies:** Phase 1 complete

**Entry condition:** `tasks/assemble-work.md` exists

**Exit condition:** SKILL.md rewritten, all 6 SCs verified PASS

- [ ] 10. **RED (**clean-room**).** Verify description contains "17 serial dispatch steps" — `grep` returns match. **→ SC-1**
- [ ] 11. **GREEN (**clean-room**).** Remove "17 serial dispatch steps", "Z3-verified", "YAML contract". Add orchestrator-facing trigger description with mandatory signal ("MUST dispatch here"). **→ SC-1, SC-2**
- [ ] 12. **GREEN doublecheck (**clean-room**).** Verify SC-1 (no internal details) and SC-2 (MUST signal present).

- [ ] 13. **RED (**clean-room**).** Verify Overview contains "17 serial" or "Z3" or "YAML contract" — `grep` returns match. **→ SC-8**
- [ ] 14. **GREEN (**clean-room**).** Remove step count, Z3, YAML contract details. Replace with orchestrator-facing purpose statement. **→ SC-8**
- [ ] 15. **GREEN doublecheck (**clean-room**).** Verify SC-8 (no internal details in Overview).

- [ ] 16. **RED (**clean-room**).** Verify no "execute plan" in trigger table — `grep` returns no match. **→ SC-3**
- [ ] 17. **GREEN (**clean-room**).** Add row: `"execute plan" / "implement spec" / "run pipeline" / "assemble work"` → `assemble-work` with dispatch `orchestrator` and context `{issue_number, plan_path, authorization_scope, halt_at, pr_strategy}`. **→ SC-3**
- [ ] 18. **GREEN doublecheck (**clean-room**).** Verify SC-3 (orchestrator entry in trigger table).

- [ ] 19. **RED (**clean-room**).** Verify no `assemble-work` in Invocation — `grep` returns no match. **→ SC-9**
- [ ] 20. **GREEN (**clean-room**).** Add `assemble-work` as the entry point task in the invocation table. **→ SC-9**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Verify SC-9 (assemble-work in Invocation).

- [ ] 22. **RED (**clean-room**).** Verify no `assemble-work` in Sub-Agent Routing — `grep` returns no match. **→ SC-10**
- [ ] 23. **GREEN (**clean-room**).** Add `assemble-work` as the orchestrator entry point that routes to `pipeline-executor`. **→ SC-10**
- [ ] 24. **GREEN doublecheck (**clean-room**).** Verify SC-10 (assemble-work in Sub-Agent Routing).

- [ ] 25. **Checkpoint commit (**inline**).** `git add .opencode/skills/implementation-pipeline/SKILL.md && git commit -m "fix: rewrite SKILL.md with orchestrator-facing entry point"`

#### Phase 2 VbC

- [ ] 26. **VbC (**clean-room**).** Verify all 6 SCs PASS: SC-1, SC-2, SC-3, SC-8, SC-9, SC-10. **→ SC-1, SC-2, SC-3, SC-8, SC-9, SC-10**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- SC-1: SKILL.md description does not contain "17 serial dispatch steps", "Z3-verified", or "YAML contract"
- SC-2: SKILL.md description contains mandatory signal ("MUST dispatch here" or equivalent)
- SC-3: SKILL.md Trigger Dispatch Table has orchestrator entry point for "execute plan" / "implement spec"
- SC-4: `tasks/assemble-work.md` exists
- SC-5: `tasks/assemble-work.md` reads plan from `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- SC-6: `tasks/assemble-work.md` dispatches to pipeline-executor
- SC-7: `tasks/pipeline-executor.md` does not contain a step count ("N-step", "N serial", etc.)
- SC-8: SKILL.md Overview does not contain step count, Z3, or YAML contract details
- SC-9: SKILL.md Invocation table includes `assemble-work` entry
- SC-10: SKILL.md Sub-Agent Routing mentions `assemble-work` as entry point
- SC-11: `tasks/assemble-work.md` references Step 1.5 entry proof marker
- SC-12: `tasks/assemble-work.md` references OVERFLOW handling
- SC-13: `tasks/assemble-work.md` references work state verification
- SC-14: `tasks/assemble-work.md` references post-sub-agent completion checkpoint
- SC-15: `tasks/pipeline-executor.md` purpose does not describe itself as orchestrator entry point
