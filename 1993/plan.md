# Implementation Plan — [#1993](https://github.com/michael-conrad/.opencode/issues/1993) — Refactor spec-creation skill

**Goal:** Restructure spec-creation skill to 3 workflows, remove task() calls from task cards, add frugal contract pattern, fix pipeline order.

**Architecture:** 3-phase sequential plan. Phase 1 rewrites SKILL.md (dispatch table + pipeline). Phase 2 cleans 4 task cards and creates 3 new ones. Phase 3 adds critical violation and verifies clean files.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` (create)
- `.opencode/guidelines/000-critical-rules.md`

**Dispatch:** `skill({name: "writing-plans"})` then `task(..., prompt: "execute create from writing-plans-creation")`

> **Compliance Requirement:** All steps in this document MUST be followed in order. Failure to comply with any step will result in the feature branch being discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do not read ahead, batch steps, or combine edits. After each step, verify the result before proceeding to the next. If a step fails, stop and report.

> **Step status:** Each step MUST be marked `[ ]` (pending), `[x]` (completed), or `[~]` (in progress) as work progresses.

---

## Phase 1 — SKILL.md restructure

**Concern:** Dispatch table integrity and pipeline definition
**SCs:** SC-1, SC-3, SC-7, SC-8, SC-9, SC-10

- [ ] 1. **Coherence gate — Phase 1 (**inline**).** Verify plan items match spec SCs for Phase 1. If any SC is not covered, HALT.

- [ ] 2. **Pre-red-baseline — Phase 1 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 3. **RED: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** `task(..., prompt: "execute RED for SC-1 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-1", target: ".opencode/skills/spec-creation/SKILL.md", action: "remove 8 dispatch entries"}`. **→ SC-1**

- [ ] 4. **GREEN: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-1 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-1", target: ".opencode/skills/spec-creation/SKILL.md", action: "remove 8 dispatch entries"}`. **→ SC-1**

- [ ] 5. **GREEN doublecheck: Remove 8 fake dispatch entries from SKILL.md (**inline**).** `grep -c '| \`' .opencode/skills/spec-creation/SKILL.md` on dispatch table section — count should be 2.

- [ ] 6. **Checkpoint commit: Remove 8 fake dispatch entries from SKILL.md (**inline**).** `git commit -m "1993: remove 8 fake dispatch entries from spec-creation SKILL.md"`

- [ ] 7. **RED: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** `task(..., prompt: "execute RED for SC-1 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-1", target: ".opencode/skills/spec-creation/SKILL.md", action: "add revise dispatch entry"}`. **→ SC-1**

- [ ] 8. **GREEN: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-1 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-1", target: ".opencode/skills/spec-creation/SKILL.md", action: "add revise dispatch entry"}`. **→ SC-1**

- [ ] 9. **GREEN doublecheck: Add `revise` dispatch entry to SKILL.md (**inline**).** `grep 'revise' .opencode/skills/spec-creation/SKILL.md | grep '|'` — should find dispatch row.

- [ ] 10. **Checkpoint commit: Add `revise` dispatch entry to SKILL.md (**inline**).** `git commit -m "1993: add revise dispatch entry to spec-creation SKILL.md"`

- [ ] 11. **RED: Add Pipeline section to SKILL.md (**sub-agent**).** `task(..., prompt: "execute RED for SC-3, SC-7, SC-8, SC-9, SC-10 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: ["SC-3", "SC-7", "SC-8", "SC-9", "SC-10"], target: ".opencode/skills/spec-creation/SKILL.md", action: "add pipeline section"}`. **→ SC-3, SC-7, SC-8, SC-9, SC-10**

- [ ] 12. **GREEN: Add Pipeline section to SKILL.md (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-3, SC-7, SC-8, SC-9, SC-10 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: ["SC-3", "SC-7", "SC-8", "SC-9", "SC-10"], target: ".opencode/skills/spec-creation/SKILL.md", action: "add pipeline section"}`. **→ SC-3, SC-7, SC-8, SC-9, SC-10**

- [ ] 13. **GREEN doublecheck: Add Pipeline section to SKILL.md (**inline**).** `grep '## Pipeline' .opencode/skills/spec-creation/SKILL.md` — should find header. `grep -c 'contracts/' .opencode/skills/spec-creation/SKILL.md` — should be 0.

- [ ] 14. **Checkpoint commit: Add Pipeline section to SKILL.md (**inline**).** `git commit -m "1993: add 25-step create and 6-step revise pipeline to spec-creation SKILL.md"`

- [ ] 15. **RED: Delete `operating-protocol.md` task card (**sub-agent**).** `task(..., prompt: "execute RED for SC-3 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-3", target: ".opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md", action: "delete file"}`. **→ SC-3**

- [ ] 16. **GREEN: Delete `operating-protocol.md` task card (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-3 from plan. Read \`plan.md\` Phase 1 section first")` with params `{sc: "SC-3", target: ".opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md", action: "delete file"}`. **→ SC-3**

- [ ] 17. **GREEN doublecheck: Delete `operating-protocol.md` task card (**inline**).** `ls .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md 2>&1` — should return "No such file or directory".

- [ ] 18. **Checkpoint commit: Delete `operating-protocol.md` task card (**inline**).** `git commit -m "1993: delete operating-protocol.md task card, content moved to SKILL.md"`

- [ ] 19. **VbC — Phase 1 (**clean-room**).** `task(..., prompt: "execute VbC for Phase 1 from plan. Read \`plan.md\` Phase 1 section first")` with params `{phase: 1, scs: ["SC-1", "SC-3", "SC-7", "SC-8", "SC-9", "SC-10"]}`.

- [ ] 20. **Audit — Phase 1 (**inline**).** `skill({name: "audit"})` then `task(..., prompt: "execute spec-audit task from audit for issue 1993")`

- [ ] 21. **Cross-validate — Phase 1 (**inline**).** Verify audit PASS, no regressions.

- [ ] 22. **Regression check — Phase 1 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

- [ ] 23. **Finishing checklist — Phase 1 (**inline**).** `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`

- [ ] 24. **Review-prep — Phase 1 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`

- [ ] 25. **Cleanup — Phase 1 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`

---

## Phase 2 — Task card cleanup

**Concern:** Task card structural correctness and frugal contract pattern
**SCs:** SC-2, SC-4, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21

- [ ] 26. **Coherence gate — Phase 2 (**inline**).** Verify plan items match spec SCs for Phase 2. If any SC is not covered, HALT.

- [ ] 27. **Pre-red-baseline — Phase 2 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 28. **RED: Remove 4 `task()` calls from `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-2, SC-15 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-15"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove task() calls"}`. **→ SC-2, SC-15**

- [ ] 29. **GREEN: Remove 4 `task()` calls from `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2, SC-15 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-15"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove task() calls"}`. **→ SC-2, SC-15**

- [ ] 30. **GREEN doublecheck: Remove 4 `task()` calls from `create.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 31. **Checkpoint commit: Remove 4 `task()` calls from `create.md` (**inline**).** `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

- [ ] 32. **RED: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-16 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-16", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "replace tmp paths"}`. **→ SC-16**

- [ ] 33. **GREEN: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-16 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-16", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "replace tmp paths"}`. **→ SC-16**

- [ ] 34. **GREEN doublecheck: Replace `{project_root}/tmp/` paths in `create.md` (**inline**).** `grep -c 'project_root}/tmp/' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 35. **Checkpoint commit: Replace `{project_root}/tmp/` paths in `create.md` (**inline**).** `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

- [ ] 36. **RED: Add result contract section to `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-17 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-17", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "add result contract"}`. **→ SC-17**

- [ ] 37. **GREEN: Add result contract section to `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-17 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-17", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "add result contract"}`. **→ SC-17**

- [ ] 38. **GREEN doublecheck: Add result contract section to `create.md` (**inline**).** Read create.md — confirm `## Result Contract` section present with status, finding_summary, artifact_path, blocker_reason.

- [ ] 39. **Checkpoint commit: Add result contract section to `create.md` (**inline**).** `git commit -m "1993: add result contract section to create.md (D-4)"`

- [ ] 40. **RED: Add read-from-disk specification to `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-18 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-18", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "add read-from-disk spec"}`. **→ SC-18**

- [ ] 41. **GREEN: Add read-from-disk specification to `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-18 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-18", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "add read-from-disk spec"}`. **→ SC-18**

- [ ] 42. **GREEN doublecheck: Add read-from-disk specification to `create.md` (**inline**).** Read create.md — confirm `## Input Artifacts` section present listing artifact paths.

- [ ] 43. **Checkpoint commit: Add read-from-disk specification to `create.md` (**inline**).** `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

- [ ] 44. **RED: Renumber steps sequentially in `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-19 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-19", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "renumber steps"}`. **→ SC-19**

- [ ] 45. **GREEN: Renumber steps sequentially in `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-19 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-19", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "renumber steps"}`. **→ SC-19**

- [ ] 46. **GREEN doublecheck: Renumber steps sequentially in `create.md` (**inline**).** Grep step numbers in create.md — verify monotonic sequence, no duplicates.

- [ ] 47. **Checkpoint commit: Renumber steps sequentially in `create.md` (**inline**).** `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

- [ ] 48. **RED: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-20 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-20", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "replace remote API reads"}`. **→ SC-20**

- [ ] 49. **GREEN: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-20 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-20", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "replace remote API reads"}`. **→ SC-20**

- [ ] 50. **GREEN doublecheck: Replace remote API reads with local file reads in `create.md` (**inline**).** `grep -c 'read-issue' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 51. **Checkpoint commit: Replace remote API reads with local file reads in `create.md` (**inline**).** `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

- [ ] 52. **RED: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** `task(..., prompt: "execute RED for SC-21 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-21", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove pre-PR gate ref"}`. **→ SC-21**

- [ ] 53. **GREEN: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-21 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-21", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove pre-PR gate ref"}`. **→ SC-21**

- [ ] 54. **GREEN doublecheck: Remove forward reference to non-existent pre-PR gate (**inline**).** `grep -c 'pre-PR gate' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 55. **Checkpoint commit: Remove forward reference to non-existent pre-PR gate (**inline**).** `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

- [ ] 56. **RED: Remove remote issue creation from `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-2, SC-11 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-11"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove remote issue creation"}`. **→ SC-2, SC-11**

- [ ] 57. **GREEN: Remove remote issue creation from `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2, SC-11 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-11"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove remote issue creation"}`. **→ SC-2, SC-11**

- [ ] 58. **GREEN doublecheck: Remove remote issue creation from `create.md` (**inline**).** Read create.md — confirm no remote issue creation instructions remain.

- [ ] 59. **Checkpoint commit: Remove remote issue creation from `create.md` (**inline**).** `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

- [ ] 60. **RED: Remove `skill()` call from `create.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-2, SC-15 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-15"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove skill() call"}`. **→ SC-2, SC-15**

- [ ] 61. **GREEN: Remove `skill()` call from `create.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2, SC-15 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: ["SC-2", "SC-15"], target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "remove skill() call"}`. **→ SC-2, SC-15**

- [ ] 62. **GREEN doublecheck: Remove `skill()` call from `create.md` (**inline**).** `grep -c 'skill({name:' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 63. **Checkpoint commit: Remove `skill()` call from `create.md` (**inline**).** `git commit -m "1993: remove skill() call from create.md (D-8)"`

- [ ] 64. **RED: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** `task(..., prompt: "execute RED for SC-16 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-16", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "move lifecycle manifest"}`. **→ SC-16**

- [ ] 65. **GREEN: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-16 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-16", target: ".opencode/skills/spec-creation-validation/tasks/create.md", action: "move lifecycle manifest"}`. **→ SC-16**

- [ ] 66. **GREEN doublecheck: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**inline**).** `grep 'lifecycle.yaml' .opencode/skills/spec-creation-validation/tasks/create.md` — should reference `.issues/{N}/lifecycle.yaml`.

- [ ] 67. **Checkpoint commit: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**inline**).** `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

- [ ] 68. **RED: Fix `analytical-artifacts.md` category error (**sub-agent**).** `task(..., prompt: "execute RED for SC-4 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-4", target: ".opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md", action: "fix category error"}`. **→ SC-4**

- [ ] 69. **GREEN: Fix `analytical-artifacts.md` category error (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-4 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-4", target: ".opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md", action: "fix category error"}`. **→ SC-4**

- [ ] 70. **GREEN doublecheck: Fix `analytical-artifacts.md` category error (**inline**).** `grep -c 'orchestrator' .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md` — should be 0.

- [ ] 71. **Checkpoint commit: Fix `analytical-artifacts.md` category error (**inline**).** `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

- [ ] 72. **RED: Clean `completion.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", target: ".opencode/skills/spec-creation-validation/tasks/completion.md", action: "remove task() calls"}`. **→ SC-2**

- [ ] 73. **GREEN: Clean `completion.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", target: ".opencode/skills/spec-creation-validation/tasks/completion.md", action: "remove task() calls"}`. **→ SC-2**

- [ ] 74. **GREEN doublecheck: Clean `completion.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/completion.md` — should be 0.

- [ ] 75. **Checkpoint commit: Clean `completion.md` (**inline**).** `git commit -m "1993: remove task() calls from completion.md"`

- [ ] 76. **RED: Clean `change-control.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", target: ".opencode/skills/spec-creation-change-control/tasks/change-control.md", action: "remove task() call"}`. **→ SC-2**

- [ ] 77. **GREEN: Clean `change-control.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", target: ".opencode/skills/spec-creation-change-control/tasks/change-control.md", action: "remove task() call"}`. **→ SC-2**

- [ ] 78. **GREEN doublecheck: Clean `change-control.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-change-control/tasks/change-control.md` — should be 0.

- [ ] 79. **Checkpoint commit: Clean `change-control.md` (**inline**).** `git commit -m "1993: remove task() calls from change-control.md"`

- [ ] 80. **RED: Create `create-remote-stub.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-12 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-12", target: ".opencode/skills/spec-creation-validation/tasks/create-remote-stub.md", action: "create file"}`. **→ SC-12**

- [ ] 81. **GREEN: Create `create-remote-stub.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-12 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-12", target: ".opencode/skills/spec-creation-validation/tasks/create-remote-stub.md", action: "create file"}`. **→ SC-12**

- [ ] 82. **GREEN doublecheck: Create `create-remote-stub.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` — should exist.

- [ ] 83. **Checkpoint commit: Create `create-remote-stub.md` (**inline**).** `git commit -m "1993: create create-remote-stub.md task card"`

- [ ] 84. **RED: Create `pre-spec-inspection.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-13 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-13", target: ".opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md", action: "create file"}`. **→ SC-13**

- [ ] 85. **GREEN: Create `pre-spec-inspection.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-13 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-13", target: ".opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md", action: "create file"}`. **→ SC-13**

- [ ] 86. **GREEN doublecheck: Create `pre-spec-inspection.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` — should exist.

- [ ] 87. **Checkpoint commit: Create `pre-spec-inspection.md` (**inline**).** `git commit -m "1993: create pre-spec-inspection.md task card"`

- [ ] 88. **RED: Create `revise-remote-body.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-14 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-14", target: ".opencode/skills/spec-creation-validation/tasks/revise-remote-body.md", action: "create file"}`. **→ SC-14**

- [ ] 89. **GREEN: Create `revise-remote-body.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-14 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-14", target: ".opencode/skills/spec-creation-validation/tasks/revise-remote-body.md", action: "create file"}`. **→ SC-14**

- [ ] 90. **GREEN doublecheck: Create `revise-remote-body.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` — should exist.

- [ ] 91. **Checkpoint commit: Create `revise-remote-body.md` (**inline**).** `git commit -m "1993: create revise-remote-body.md task card"`

- [ ] 92. **RED: Verify all spec-creation task cards are clean (**sub-agent**).** `task(..., prompt: "execute RED for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", action: "verify clean task cards"}`. **→ SC-2**

- [ ] 93. **GREEN: Verify all spec-creation task cards are clean (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{sc: "SC-2", action: "verify clean task cards"}`. **→ SC-2**

- [ ] 94. **GREEN doublecheck: Verify all spec-creation task cards are clean (**inline**).** `grep -rn 'task(' .opencode/skills/spec-creation*/tasks/ --include='*.md'` — should be 0 matches.

- [ ] 95. **Checkpoint commit: Verify all spec-creation task cards are clean (**inline**).** `git commit -m "1993: verify all spec-creation task cards clean of task() calls"`

- [ ] 96. **VbC — Phase 2 (**clean-room**).** `task(..., prompt: "execute VbC for Phase 2 from plan. Read \`plan.md\` Phase 2 section first")` with params `{phase: 2, scs: ["SC-2", "SC-4", "SC-11", "SC-12", "SC-13", "SC-14", "SC-15", "SC-16", "SC-17", "SC-18", "SC-19", "SC-20", "SC-21"]}`.

- [ ] 97. **Audit — Phase 2 (**inline**).** `skill({name: "audit"})` then `task(..., prompt: "execute spec-audit task from audit for issue 1993")`

- [ ] 98. **Cross-validate — Phase 2 (**inline**).** Verify audit PASS, no regressions.

- [ ] 99. **Regression check — Phase 2 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

- [ ] 100. **Finishing checklist — Phase 2 (**inline**).** `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`

- [ ] 101. **Review-prep — Phase 2 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`

- [ ] 102. **Cleanup — Phase 2 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`

---

## Phase 3 — Critical violation + verification

**Concern:** Enforcement and regression prevention
**SCs:** SC-5, SC-6

- [ ] 103. **Coherence gate — Phase 3 (**inline**).** Verify plan items match spec SCs for Phase 3. If any SC is not covered, HALT.

- [ ] 104. **Pre-red-baseline — Phase 3 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 105. **RED: Add critical violation to `000-critical-rules.md` (**sub-agent**).** `task(..., prompt: "execute RED for SC-5 from plan. Read \`plan.md\` Phase 3 section first")` with params `{sc: "SC-5", target: ".opencode/guidelines/000-critical-rules.md", action: "add critical violation"}`. **→ SC-5**

- [ ] 106. **GREEN: Add critical violation to `000-critical-rules.md` (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-5 from plan. Read \`plan.md\` Phase 3 section first")` with params `{sc: "SC-5", target: ".opencode/guidelines/000-critical-rules.md", action: "add critical violation"}`. **→ SC-5**

- [ ] 107. **GREEN doublecheck: Add critical violation to `000-critical-rules.md` (**inline**).** `grep -c 'task cards MUST NOT contain task()' .opencode/guidelines/000-critical-rules.md` — should be 1.

- [ ] 108. **Checkpoint commit: Add critical violation to `000-critical-rules.md` (**inline**).** `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

- [ ] 109. **RED: Verify 13 clean task cards unmodified (**sub-agent**).** `task(..., prompt: "execute RED for SC-6 from plan. Read \`plan.md\` Phase 3 section first")` with params `{sc: "SC-6", action: "verify clean task cards unmodified"}`. **→ SC-6**

- [ ] 110. **GREEN: Verify 13 clean task cards unmodified (**sub-agent**).** `task(..., prompt: "execute GREEN for SC-6 from plan. Read \`plan.md\` Phase 3 section first")` with params `{sc: "SC-6", action: "verify clean task cards unmodified"}`. **→ SC-6**

- [ ] 111. **GREEN doublecheck: Verify 13 clean task cards unmodified (**inline**).** `git diff -- .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md` — should show zero changes.

- [ ] 112. **Checkpoint commit: Verify 13 clean task cards unmodified (**inline**).** `git commit -m "1993: verify 13 clean task cards unmodified"` (only if changes were reverted)

- [ ] 113. **VbC — Phase 3 (**clean-room**).** `task(..., prompt: "execute VbC for Phase 3 from plan. Read \`plan.md\` Phase 3 section first")` with params `{phase: 3, scs: ["SC-5", "SC-6"]}`.

- [ ] 114. **Audit — Phase 3 (**inline**).** `skill({name: "audit"})` then `task(..., prompt: "execute spec-audit task from audit for issue 1993")`

- [ ] 115. **Cross-validate — Phase 3 (**inline**).** Verify audit PASS, no regressions.

- [ ] 116. **Regression check — Phase 3 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

- [ ] 117. **Finishing checklist — Phase 3 (**inline**).** `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`

- [ ] 118. **Review-prep — Phase 3 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`

- [ ] 119. **Cleanup — Phase 3 (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`

---

## Exit Criteria

- [ ] C1. SKILL.md Trigger Dispatch Table has exactly 3 entries (SC-1)
- [ ] C2. `revise` dispatch entry exists in SKILL.md (SC-1)
- [ ] C3. Pipeline section exists in SKILL.md with read/write/contract for each sub-task step (SC-3, SC-8, SC-9)
- [ ] C4. No `{project_root}/tmp/{N}/contracts/` paths in SKILL.md pipeline (SC-7)
- [ ] C5. Create pipeline starts with `local-issues sync`, ends with `local-issues sync` (SC-10)
- [ ] C6. `operating-protocol.md` deleted (SC-3)
- [ ] C7. `create.md` contains no `task(` or `skill({name:` calls (SC-15)
- [ ] C8. `create.md` contains no `{project_root}/tmp/` paths (SC-16)
- [ ] C9. `create.md` contains result contract section (SC-17)
- [ ] C10. `create.md` contains read-from-disk specification (SC-18)
- [ ] C11. `create.md` has sequentially numbered steps (SC-19)
- [ ] C12. `create.md` self-review reads from local `.issues/{N}/spec.md` (SC-20)
- [ ] C13. `create.md` does not reference "pre-PR gate" (SC-21)
- [ ] C14. `create.md` does NOT create the remote issue (SC-11)
- [ ] C15. `completion.md` has no `task(` calls (SC-2)
- [ ] C16. `change-control.md` has no `task(` calls (SC-2)
- [ ] C17. `analytical-artifacts.md` has no orchestrator-level instructions (SC-4)
- [ ] C18. `create-remote-stub.md` exists (SC-12)
- [ ] C19. `pre-spec-inspection.md` exists (SC-13)
- [ ] C20. `revise-remote-body.md` exists (SC-14)
- [ ] C21. No task card under any spec-creation sub-skill contains `task(...)` (SC-2)
- [ ] C22. `000-critical-rules.md` contains sub-agent task() prohibition (SC-5)
- [ ] C23. All 13 clean task cards have zero changes in git diff (SC-6)
