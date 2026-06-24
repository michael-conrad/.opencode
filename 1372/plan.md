# Implementation Plan — [`.opencode#1372`](https://github.com/michael-conrad/.opencode/issues/1372) — writing-plans dispatch classification fix

- [ ] **Goal:** Fix the `writing-plans` skill's Trigger Dispatch Table which classifies orchestrator tasks (`create`, `retroactive`, `completion`) as `sub-task`, making them impossible to execute. Purge the deprecated `tasks/create/` subdirectory. Embed the canonical Plan Format Requirements section in `create.md`. Update all 6 SKILL.md files referencing `.issues/` paths to use dual pattern with parenthetical explanation.
- [ ] **Architecture:** Phase 1 → Phase 2 → Phase 3 (sequential). Phase 1 fixes all task file content and SKILL.md metadata, and adds the Plan Format Requirements section to `create.md`. Phase 2 purges the deprecated `create/` subdirectory — depends on Phase 1 removing all references to those files first. Phase 3 updates all 6 SKILL.md files that reference `.issues/` paths to use the dual pattern with parenthetical explanation.
- [ ] **Files:**
  - `.opencode/skills/writing-plans/SKILL.md` — Phase 1, Phase 3
  - `.opencode/skills/writing-plans/tasks/create.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/completion.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/retroactive.md` — Phase 1
  - `.opencode/skills/writing-plans/tasks/create/create-and-validate.md` — Phase 2 (DELETE)
  - `.opencode/skills/writing-plans/tasks/create/plan-structure.md` — Phase 2 (DELETE)
  - `.opencode/skills/plan-creation-pipeline/SKILL.md` — Phase 3
  - `.opencode/skills/issue-operations/SKILL.md` — Phase 3
  - `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md` — Phase 3
  - `.opencode/skills/issue-operations/platforms/local/SKILL.md` — Phase 3
  - `.opencode/skills/implementation-pipeline/SKILL.md` — Phase 3

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1 — Fix Dispatch Classification and Task Files

**Concern:** writing-plans skill metadata and task file content
**Files:** SKILL.md, create.md, completion.md, retroactive.md
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26
**Dependencies:** None
**Entry condition:** SKILL.md Trigger Dispatch Table classifies `create`, `retroactive`, `completion` as `sub-task`. Invocation table lists them as `task()` calls. Sub-Agent Routing claims "All tasks run via `task()`" and "No inline work". create.md operating protocol missing 11 steps. completion.md contains `task()` calls and skill invocations. retroactive.md is a simplified 3-step procedure. create.md has no Plan Format Requirements section.
**Exit condition:** All 24 SCs pass. Trigger Dispatch Table correct. All task files aligned with 21-step pipeline. No orchestrator-level operations in sub-task files. create.md has canonical Plan Format Requirements section.

**Artifact paths:** `./tmp/1372/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 1. **Coherence gate (**clean-room**).** Verify all 24 SCs are coherent and non-conflicting.
  - [ ] 1a. Read spec SC table, confirm evidence types match verification methods
  - [ ] 1b. Read current state of all 4 files to confirm defects exist as described
- [ ] 2. **Pre-RED baseline (**clean-room**).** Capture current state of all 4 files.
  - [ ] 2a. Record line counts for all 4 files
  - [ ] 2b. grep for `sub-task` in Trigger Dispatch Table rows for create/retroactive/completion — confirm present
  - [ ] 2c. grep for `task(..., prompt: "execute create task"` in SKILL.md — confirm present
  - [ ] 2d. grep for `task(` in completion.md — confirm present
  - [ ] 2e. grep for `invoke` in completion.md — confirm present
  - [ ] 2f. grep for "All tasks run via" and "No inline work" in SKILL.md — confirm present
  - [ ] 2g. Count steps in create.md operating protocol — confirm 7
  - [ ] 2h. Count steps in retroactive.md — confirm 3
  - [ ] 2i. grep for "Spec-to-plan handoff" in create.md entry criteria — confirm present
  - [ ] 2j. grep for `completion-core.md` in completion.md — confirm present
  - [ ] 2k. grep for `## Plan Format Requirements` in create.md — confirm absent
  - [ ] 2l. grep for `create-and-validate\|plan-structure` in create.md — confirm present
  - [ ] 2m. Save all baselines

#### RED+green P1-I1 — Fix SKILL.md Trigger Dispatch Table

- [ ] 3. **RED (**clean-room**).** grep for `create.*sub-task` in SKILL.md Trigger Dispatch Table — confirm match exists. **→ SC-1, SC-2, SC-3**
- [ ] 4. **GREEN (**clean-room**).** Edit SKILL.md Trigger Dispatch Table: change `create`, `retroactive`, `completion` dispatch types from `sub-task` to `orchestrator`. **→ SC-1, SC-2, SC-3**
- [ ] 5. **GREEN doublecheck (**clean-room**).** grep for `create.*orchestrator` in SKILL.md — confirm present. grep for `create.*sub-task` in Trigger Dispatch Table — confirm absent. **→ SC-1, SC-2, SC-3**
- [ ] 6. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "SKILL.md: fix Trigger Dispatch Table — create/retroactive/completion → orchestrator"`

#### RED+green P1-I2 — Fix SKILL.md Invocation table

- [ ] 7. **RED (**clean-room**).** grep for `task(..., prompt: "execute create task"` in SKILL.md — confirm match exists. **→ SC-4**
- [ ] 8. **GREEN (**clean-room**).** Edit SKILL.md Invocation table: replace `task()` call entries for `create` and `completion` with instruction that orchestrator reads task file and executes steps inline. **→ SC-4**
- [ ] 9. **GREEN doublecheck (**clean-room**).** grep for `task(..., prompt: "execute create task"` in SKILL.md — confirm absent. grep for `task(..., prompt: "execute completion task"` — confirm absent. **→ SC-4**
- [ ] 10. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "SKILL.md: fix Invocation table — orchestrator reads task file, does not task() itself"`

#### RED+green P1-I3 — Fix SKILL.md §Sub-Agent Routing

- [ ] 11. **RED (**clean-room**).** grep for "All tasks run via" in SKILL.md — confirm match exists. grep for "No inline work" in SKILL.md — confirm match exists. **→ SC-11, SC-12**
- [ ] 12. **GREEN (**clean-room**).** Edit SKILL.md §Sub-Agent Routing: remove "All tasks run via `task(subagent_type="general")`" and "No inline work". Replace with text distinguishing orchestrator tasks (inline) from sub-task dispatches. **→ SC-11, SC-12**
- [ ] 13. **GREEN doublecheck (**clean-room**).** grep for "All tasks run via" in SKILL.md — confirm absent. grep for "No inline work" in SKILL.md — confirm absent. **→ SC-11, SC-12**
- [ ] 14. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "SKILL.md: fix Sub-Agent Routing — remove false claims about task() and inline work"`

#### RED+green P1-I4 — Fix create.md operating protocol

- [ ] 15. **RED (**clean-room**).** Count steps in create.md operating protocol — confirm fewer than 21. **→ SC-7**
- [ ] 16. **GREEN (**clean-room**).** Add missing steps to create.md operating protocol: add `[inline]` step 1 (verify spec approved) and all 10 `[z3-check]` steps from the 21-step pipeline. Verify exactly 21 steps: 1 inline + 10 sub-task + 10 z3-check. **→ SC-7**
- [ ] 17. **GREEN doublecheck (**clean-room**).** Count steps in create.md operating protocol — confirm exactly 21. Verify 1 `[inline]` step, 10 `[sub-task:` steps, 10 `[z3-check]` steps. **→ SC-7**
- [ ] 18. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "create.md: add missing 11 steps to operating protocol — now 21 steps"`

#### RED+green P1-I5 — Fix create.md entry criteria

- [ ] 19. **RED (**clean-room**).** grep for "Spec-to-plan handoff" in create.md entry criteria — confirm match exists. **→ SC-13**
- [ ] 20. **GREEN (**clean-room**).** Edit create.md entry criteria: remove "Spec-to-plan handoff PASS" line. **→ SC-13**
- [ ] 21. **GREEN doublecheck (**clean-room**).** grep for "Spec-to-plan handoff" in create.md — confirm absent. **→ SC-13**
- [ ] 22. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "create.md: remove circular Spec-to-plan handoff from entry criteria"`

#### RED+green P1-I6 — Fix create.md stale references

- [ ] 23. **RED (**clean-room**).** grep for "10 decomposed sub-task files" in create.md — confirm match exists. grep for `create-and-validate\|plan-structure` in create.md — confirm matches exist. **→ SC-16**
- [ ] 24. **GREEN (**clean-room**).** Edit create.md: remove claim of "10 decomposed sub-task files" from line 5. Remove entire §Sub-Task Files table. **→ SC-16**
- [ ] 25. **GREEN doublecheck (**clean-room**).** grep for "10 decomposed sub-task files" in create.md — confirm absent. grep for `create-and-validate\|plan-structure` in create.md — confirm absent. **→ SC-16**
- [ ] 26. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "create.md: remove stale sub-task file claims and Sub-Task Files table"`

#### RED+green P1-I7 — Fix completion.md

- [ ] 27. **RED (**clean-room**).** grep for `task(` in completion.md — confirm match exists. grep for `invoke` in completion.md — confirm match exists. grep for `completion-core.md` in completion.md — confirm match exists. **→ SC-8, SC-9, SC-14**
- [ ] 28. **GREEN (**clean-room**).** Edit completion.md: remove `task()` call, remove all "invoke `writing-plans`" / "invoke `issue-operations`" lines, fix path from `completion-core.md` to `completion-core/SKILL.md`. **→ SC-8, SC-9, SC-14**
- [ ] 29. **GREEN doublecheck (**clean-room**).** grep for `task(` in completion.md — confirm absent. grep for `invoke` in completion.md — confirm absent. grep for `completion-core/SKILL.md` in completion.md — confirm present. **→ SC-8, SC-9, SC-14**
- [ ] 30. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "completion.md: remove task() calls, skill invocations, fix path reference"`

#### RED+green P1-I8 — Fix retroactive.md

- [ ] 31. **RED (**clean-room**).** Count steps in retroactive.md — confirm 3 (simplified). grep for "Run `validate` task checks" — confirm present. grep for "issue-operations -> read-sub-issues" — confirm present. **→ SC-10**
- [ ] 32. **GREEN (**clean-room**).** Edit retroactive.md: replace simplified 3-step procedure with the 21-step pipeline. Remove "Run `validate` task checks" and "issue-operations -> read-sub-issues" lines. **→ SC-10**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Count steps in retroactive.md — confirm 21. grep for "Run `validate` task checks" — confirm absent. grep for "issue-operations -> read-sub-issues" — confirm absent. **→ SC-10**
- [ ] 34. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "retroactive.md: align with 21-step pipeline, remove sub-task dispatches"`

#### RED+green P1-I9 — Add Plan Format Requirements section to create.md

- [ ] 35. **RED (**clean-room**).** grep for `## Plan Format Requirements` in create.md — confirm absent. grep for "Compliance Requirement" in create.md — confirm absent. **→ SC-17, SC-18**
- [ ] 36. **GREEN (**clean-room**).** Add `## Plan Format Requirements` section to create.md with:
  - [ ] 36a. All 14 required sections in order (title, goal/architecture/files, admonishment, phase sections, phase metadata, sequential numbering, dispatch indicators with all three modes, sub-steps, RED+green item chains, SC annotations, phase completion block, concern transitions, bottom admonishment, exit criteria)
  - [ ] 36b. Admonishment text verbatim
  - [ ] 36c. Prohibited patterns list (dispatch tables, hardcoded gate sequences, TBD/TODO, shared cross-references, zero-indexed numbering, line number references)
  - [ ] 36d. All 12 validation rules
  - [ ] 36e. Dispatch indicator specification with `(**sub-agent**)`, `(**clean-room**)`, `(**inline**)`
  - [ ] 36f. RED+green item chain specification with interleaved ordering
  - [ ] 36g. Phase completion block specification
  - [ ] 36h. Concern transition specification
  - [ ] 36i. Exit criteria specification
  **→ SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
- [ ] 37. **GREEN doublecheck (**clean-room**).**
  - [ ] 37a. grep for `## Plan Format Requirements` in create.md — present
  - [ ] 37b. grep for "Compliance Requirement" in create.md — present
  - [ ] 37c. grep for `(**sub-agent**)` in create.md — present
  - [ ] 37d. grep for `(**clean-room**)` in create.md — present
  - [ ] 37e. grep for `(**inline**)` in create.md — present
  - [ ] 37f. grep for "Prohibited Patterns" in create.md — present
  - [ ] 37g. grep for "RED+green" in create.md — present
  - [ ] 37h. grep for "Phase completion" in create.md — present
  - [ ] 37i. grep for "Concern transition" in create.md — present
  - [ ] 37j. grep for "Exit Criteria" in create.md — present
  - [ ] 37k. Count validation rules in Plan Format Requirements section — 12
  **→ SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26**
- [ ] 38. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "create.md: add canonical Plan Format Requirements section"`

#### Phase 1 VbC

- [ ] 39. **VbC (**clean-room**).** Run all grep assertions from each item's GREEN doublecheck — all must PASS. Confirm all 4 files modified correctly. **→ SC-1 through SC-24**

**Concern transition:** Leaving skill metadata and task file content (Phase 1) → entering deprecated file purge (Phase 2). Phase 2 depends on Phase 1 removing all references to `create-and-validate.md` and `plan-structure.md` from `create.md`.

---

## Phase 2 — Purge Deprecated create/ Subdirectory

**Concern:** writing-plans skill file structure — remove deprecated monolithic legacy files
**Files:** `tasks/create/create-and-validate.md` (DELETE), `tasks/create/plan-structure.md` (DELETE)
**SCs:** SC-15
**Dependencies:** Phase 1 complete (create.md no longer references these files)
**Entry condition:** `tasks/create/` subdirectory exists with `create-and-validate.md` and `plan-structure.md`. create.md no longer references them.
**Exit condition:** `tasks/create/` subdirectory does not exist. SC-15 passes.

**Artifact paths:** `./tmp/1372/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`

- [ ] 40. **Coherence gate (**clean-room**).** Verify SC-15 consistent with Phase 1 exit state.
  - [ ] 40a. Confirm create.md no longer references `create-and-validate` or `plan-structure`
  - [ ] 40b. Confirm `tasks/create/` subdirectory still exists
- [ ] 41. **Pre-RED baseline (**clean-room**).** `ls .opencode/skills/writing-plans/tasks/create/` — confirm both files exist. `wc -l` on both files.

#### RED+green P2-I1 — Purge deprecated files

- [ ] 42. **RED (**clean-room**).** `ls .opencode/skills/writing-plans/tasks/create/` — confirm directory exists. **→ SC-15**
- [ ] 43. **GREEN (**clean-room**).** Delete `tasks/create/create-and-validate.md` and `tasks/create/plan-structure.md`. Remove `tasks/create/` directory. **→ SC-15**
- [ ] 44. **GREEN doublecheck (**clean-room**).** `ls .opencode/skills/writing-plans/tasks/create/` — confirm "No such file or directory". **→ SC-15**
- [ ] 45. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "writing-plans: purge deprecated tasks/create/ subdirectory"`

#### Phase 2 VbC

- [ ] 46. **VbC (**clean-room**).** Confirm directory gone. Confirm no stale references in create.md. **→ SC-15**

**Concern transition:** Leaving deprecated file purge (Phase 2) → entering SKILL.md .issues/ path updates (Phase 3). Phase 3 is independent of Phase 2 — no dependency.

---

## Phase 3 — Update .issues/ Path References in All SKILL.md Files

**Concern:** All 6 SKILL.md files that reference `.issues/` paths must use the dual pattern `.issues/{N}/` (root repo) or `*/.issues/{N}/` (submodule/sub-repo) with parenthetical explanation.
**Files:** writing-plans/SKILL.md, plan-creation-pipeline/SKILL.md, issue-operations/SKILL.md, issue-operations/platforms/github-mcp/SKILL.md, issue-operations/platforms/local/SKILL.md, implementation-pipeline/SKILL.md
**SCs:** SC-27, SC-28, SC-29, SC-30, SC-31, SC-32
**Dependencies:** None
**Entry condition:** All 6 SKILL.md files have bare `.issues/` references without dual pattern or explanation.
**Exit condition:** All 6 SKILL.md files use `.issues/{N}/` or `*/.issues/{N}/` with parenthetical explanation. SC-27 through SC-32 pass.

- [ ] 47. **Coherence gate (**clean-room**).** Verify SC-27 through SC-32 are consistent and non-conflicting.
  - [ ] 47a. Read all 6 SKILL.md files, identify all `.issues/` references
- [ ] 48. **Pre-RED baseline (**clean-room**).** grep for `.issues/` in all 6 files — capture count of bare references.

#### RED+green P3-I1 through P3-I6 — Update each SKILL.md

- [ ] 49. **RED (**clean-room**).** grep for `.issues/` in `writing-plans/SKILL.md` — confirm bare references exist without dual pattern. **→ SC-27**
- [ ] 50. **GREEN (**clean-room**).** Edit `writing-plans/SKILL.md`: add `(root repo)` or `(submodule/sub-repo)` parenthetical to all `.issues/` references. **→ SC-27**
- [ ] 51. **GREEN doublecheck (**clean-room**).** grep for `root repo.*submodule\|root repo.*sub-repo` in `writing-plans/SKILL.md` — confirm all `.issues/` refs have explanation. **→ SC-27**
- [ ] 52. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "writing-plans/SKILL.md: dual .issues/ path pattern with parenthetical explanation"`

- [ ] 53. **RED (**clean-room**).** grep for `.issues/` in `plan-creation-pipeline/SKILL.md` — confirm bare references exist. **→ SC-28**
- [ ] 54. **GREEN (**clean-room**).** Edit `plan-creation-pipeline/SKILL.md`: add parenthetical to all `.issues/` references. **→ SC-28**
- [ ] 55. **GREEN doublecheck (**clean-room**).** grep for explanation in `plan-creation-pipeline/SKILL.md`. **→ SC-28**
- [ ] 56. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "plan-creation-pipeline/SKILL.md: dual .issues/ path pattern"`

- [ ] 57. **RED (**clean-room**).** grep for `.issues/` in `issue-operations/SKILL.md` — confirm bare references exist. **→ SC-29**
- [ ] 58. **GREEN (**clean-room**).** Edit `issue-operations/SKILL.md`: add parenthetical to all `.issues/` references. **→ SC-29**
- [ ] 59. **GREEN doublecheck (**clean-room**).** grep for explanation in `issue-operations/SKILL.md`. **→ SC-29**
- [ ] 60. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "issue-operations/SKILL.md: dual .issues/ path pattern"`

- [ ] 61. **RED (**clean-room**).** grep for `.issues/` in `github-mcp/SKILL.md` — confirm bare references exist. **→ SC-30**
- [ ] 62. **GREEN (**clean-room**).** Edit `github-mcp/SKILL.md`: add parenthetical to all `.issues/` references. **→ SC-30**
- [ ] 63. **GREEN doublecheck (**clean-room**).** grep for explanation in `github-mcp/SKILL.md`. **→ SC-30**
- [ ] 64. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "github-mcp/SKILL.md: dual .issues/ path pattern"`

- [ ] 65. **RED (**clean-room**).** grep for `.issues/` in `local/SKILL.md` — confirm bare references exist. **→ SC-31**
- [ ] 66. **GREEN (**clean-room**).** Edit `local/SKILL.md`: add parenthetical to all `.issues/` references. **→ SC-31**
- [ ] 67. **GREEN doublecheck (**clean-room**).** grep for explanation in `local/SKILL.md`. **→ SC-31**
- [ ] 68. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "local/SKILL.md: dual .issues/ path pattern"`

- [ ] 69. **RED (**clean-room**).** grep for `.issues/` in `implementation-pipeline/SKILL.md` — confirm bare references exist. **→ SC-32**
- [ ] 70. **GREEN (**clean-room**).** Edit `implementation-pipeline/SKILL.md`: add parenthetical to all `.issues/` references. **→ SC-32**
- [ ] 71. **GREEN doublecheck (**clean-room**).** grep for explanation in `implementation-pipeline/SKILL.md`. **→ SC-32**
- [ ] 72. **Checkpoint commit (**inline**).** `git -C .opencode commit -m "implementation-pipeline/SKILL.md: dual .issues/ path pattern"`

#### Phase 3 VbC

- [ ] 73. **VbC (**clean-room**).** Run all grep assertions from each item's GREEN doublecheck — all must PASS. Confirm all 6 files updated correctly. **→ SC-27 through SC-32**

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: All 6 files modified or deleted — SKILL.md, create.md, completion.md, retroactive.md updated; create-and-validate.md and plan-structure.md deleted.
- [ ] C2: Trigger Dispatch Table classifies `create`, `retroactive`, `completion` as `orchestrator`.
- [ ] C3: No `task()` calls or skill invocations in completion.md.
- [ ] C4: create.md operating protocol has 21 steps. retroactive.md aligned with 21-step pipeline.
- [ ] C5: create.md has canonical Plan Format Requirements section with all 14 required sections, 12 validation rules, prohibited patterns, and all three dispatch indicator modes.
- [ ] C6: `tasks/create/` subdirectory does not exist.
- [ ] C7: All SC-1 through SC-24 pass verification.
- [ ] C8: Plan stored at `.opencode/.issues/1372/plan.md`.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
