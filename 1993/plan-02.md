# Phase 2 — Task card cleanup

**Concern:** Task card structural correctness and frugal contract pattern

**Files:**
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` (create)

**SCs:** SC-2, SC-4, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21

**Dependencies:** Phase 1 complete (SKILL.md has pipeline section)

**Entry conditions:** SKILL.md restructured, operating-protocol.md deleted

**Exit conditions:** All 4 modified task cards clean, 3 new task cards exist, no task() calls remain

**Code Path Coverage:** create.md (746 lines), completion.md (102 lines), change-control.md (154 lines), analytical-artifacts.md (172 lines)

**Cross-Cutting SCs:** SC-2 (no task() calls) applies to all 4 modified task cards

**Interface Boundaries:** Each task card is consumed by sub-agents — must contain only sub-agent-executable procedures, no orchestrator-level instructions

**State Transitions:** create.md transitions from orchestrator-level (with task() calls) to pure sub-agent procedure

---

- [ ] 18. **RED: Remove 4 `task()` calls from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
- [ ] 19. **GREEN: Remove 4 `task()` calls from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
- [ ] 20. **GREEN doublecheck (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.
- [ ] 21. **Checkpoint commit (**inline**).** `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

- [ ] 22. **RED: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** **→ SC-16**
- [ ] 23. **GREEN: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** **→ SC-16**
- [ ] 24. **GREEN doublecheck (**inline**).** `grep -c 'project_root}/tmp/' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.
- [ ] 25. **Checkpoint commit (**inline**).** `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

- [ ] 26. **RED: Add result contract section to `create.md` (**sub-agent**).** **→ SC-17**
- [ ] 27. **GREEN: Add result contract section to `create.md` (**sub-agent**).** **→ SC-17**
- [ ] 28. **GREEN doublecheck (**inline**).** Read create.md — confirm `## Result Contract` section present with status, finding_summary, artifact_path, blocker_reason.
- [ ] 29. **Checkpoint commit (**inline**).** `git commit -m "1993: add result contract section to create.md (D-4)"`

- [ ] 30. **RED: Add read-from-disk specification to `create.md` (**sub-agent**).** **→ SC-18**
- [ ] 31. **GREEN: Add read-from-disk specification to `create.md` (**sub-agent**).** **→ SC-18**
- [ ] 32. **GREEN doublecheck (**inline**).** Read create.md — confirm `## Input Artifacts` section present listing artifact paths.
- [ ] 33. **Checkpoint commit (**inline**).** `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

- [ ] 34. **RED: Renumber steps sequentially in `create.md` (**sub-agent**).** **→ SC-19**
- [ ] 35. **GREEN: Renumber steps sequentially in `create.md` (**sub-agent**).** **→ SC-19**
- [ ] 36. **GREEN doublecheck (**inline**).** Grep step numbers in create.md — verify monotonic sequence, no duplicates.
- [ ] 37. **Checkpoint commit (**inline**).** `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

- [ ] 38. **RED: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** **→ SC-20**
- [ ] 39. **GREEN: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** **→ SC-20**
- [ ] 40. **GREEN doublecheck (**inline**).** `grep -c 'read-issue' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.
- [ ] 41. **Checkpoint commit (**inline**).** `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

- [ ] 42. **RED: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** **→ SC-21**
- [ ] 43. **GREEN: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** **→ SC-21**
- [ ] 44. **GREEN doublecheck (**inline**).** `grep -c 'pre-PR gate' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.
- [ ] 45. **Checkpoint commit (**inline**).** `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

- [ ] 46. **RED: Remove remote issue creation from `create.md` (**sub-agent**).** **→ SC-2, SC-11**
- [ ] 47. **GREEN: Remove remote issue creation from `create.md` (**sub-agent**).** **→ SC-2, SC-11**
- [ ] 48. **GREEN doublecheck (**inline**).** Read create.md — confirm no remote issue creation instructions remain.
- [ ] 49. **Checkpoint commit (**inline**).** `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

- [ ] 50. **RED: Remove `skill()` call from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
- [ ] 51. **GREEN: Remove `skill()` call from `create.md` (**sub-agent**).** **→ SC-2, SC-15**
- [ ] 52. **GREEN doublecheck (**inline**).** `grep -c 'skill({name:' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.
- [ ] 53. **Checkpoint commit (**inline**).** `git commit -m "1993: remove skill() call from create.md (D-8)"`

- [ ] 54. **RED: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** **→ SC-16**
- [ ] 55. **GREEN: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** **→ SC-16**
- [ ] 56. **GREEN doublecheck (**inline**).** `grep 'lifecycle.yaml' .opencode/skills/spec-creation-validation/tasks/create.md` — should reference `.issues/{N}/lifecycle.yaml`.
- [ ] 57. **Checkpoint commit (**inline**).** `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

- [ ] 58. **RED: Fix `analytical-artifacts.md` category error (**sub-agent**).** **→ SC-4**
- [ ] 59. **GREEN: Fix `analytical-artifacts.md` category error (**sub-agent**).** **→ SC-4**
- [ ] 60. **GREEN doublecheck (**inline**).** `grep -c 'orchestrator' .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md` — should be 0.
- [ ] 61. **Checkpoint commit (**inline**).** `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

- [ ] 62. **RED: Clean `completion.md` (**sub-agent**).** **→ SC-2**
- [ ] 63. **GREEN: Clean `completion.md` (**sub-agent**).** **→ SC-2**
- [ ] 64. **GREEN doublecheck (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/completion.md` — should be 0.
- [ ] 65. **Checkpoint commit (**inline**).** `git commit -m "1993: remove task() calls from completion.md"`

- [ ] 66. **RED: Clean `change-control.md` (**sub-agent**).** **→ SC-2**
- [ ] 67. **GREEN: Clean `change-control.md` (**sub-agent**).** **→ SC-2**
- [ ] 68. **GREEN doublecheck (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-change-control/tasks/change-control.md` — should be 0.
- [ ] 69. **Checkpoint commit (**inline**).** `git commit -m "1993: remove task() calls from change-control.md"`

- [ ] 70. **RED: Create `create-remote-stub.md` (**sub-agent**).** **→ SC-12**
- [ ] 71. **GREEN: Create `create-remote-stub.md` (**sub-agent**).** **→ SC-12**
- [ ] 72. **GREEN doublecheck (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` — should exist.
- [ ] 73. **Checkpoint commit (**inline**).** `git commit -m "1993: create create-remote-stub.md task card"`

- [ ] 74. **RED: Create `pre-spec-inspection.md` (**sub-agent**).** **→ SC-13**
- [ ] 75. **GREEN: Create `pre-spec-inspection.md` (**sub-agent**).** **→ SC-13**
- [ ] 76. **GREEN doublecheck (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` — should exist.
- [ ] 77. **Checkpoint commit (**inline**).** `git commit -m "1993: create pre-spec-inspection.md task card"`

- [ ] 78. **RED: Create `revise-remote-body.md` (**sub-agent**).** **→ SC-14**
- [ ] 79. **GREEN: Create `revise-remote-body.md` (**sub-agent**).** **→ SC-14**
- [ ] 80. **GREEN doublecheck (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` — should exist.
- [ ] 81. **Checkpoint commit (**inline**).** `git commit -m "1993: create revise-remote-body.md task card"`

- [ ] 82. **RED: Verify all spec-creation task cards are clean (**sub-agent**).** **→ SC-2**
- [ ] 83. **GREEN: Verify all spec-creation task cards are clean (**sub-agent**).** **→ SC-2**
- [ ] 84. **GREEN doublecheck (**inline**).** `grep -rn 'task(' .opencode/skills/spec-creation*/tasks/ --include='*.md'` — should be 0 matches.
- [ ] 85. **Checkpoint commit (**inline**).** `git commit -m "1993: verify all spec-creation task cards clean of task() calls"`

#### Phase 2 VbC

- [ ] 86. **VbC (**clean-room**).**

**Concern transition:** Leaving task card structural correctness → entering enforcement and regression prevention. Phase 3 depends on Phase 2's clean task cards being verified.
