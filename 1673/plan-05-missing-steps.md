# Phase 5 — Missing Pipeline Steps

**Concern:** spec-creation's pipeline header declares `adversarial-audit --task spec-audit` as a mandatory step, but the Operating Protocol never dispatches it. write.md Step 40 references `spec-auditor` (invalid skill name). Orphan task files (`change-control.md`, `handoffs/spec-to-plan.md`) have no dispatch path.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Operating Protocol
- `.opencode/skills/spec-creation/tasks/write.md` — Step 40
- `.opencode/skills/spec-creation/tasks/change-control.md` — orphan task file
- `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` — orphan task file

**SCs:** SC-18, SC-19, SC-20, SC-21

**Dependencies:** Phase 2 (same file — spec-creation SKILL.md Operating Protocol)

**Entry conditions:** Phase 2 committed

**Exit conditions:** adversarial-audit dispatch added to Operating Protocol, write.md Step 40 fixed, orphan task files resolved

---

### Global Pre-Steps

- [ ] 47. **Coherence gate (**clean-room**).** `skill({name: "pre-analysis"})` → `task(..., prompt: "execute pre-analysis task from pre-analysis")` for spec-creation Operating Protocol and write.md Step 40. Verify current state before making changes.

- [ ] 48. **Pre-red-baseline (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-18, SC-19, SC-20. Confirm current state fails.

### Phase 5 Steps

- [ ] 49. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-18. Edit `.opencode/skills/spec-creation/SKILL.md` Operating Protocol: add `[sub-task: spec-audit] task(..., prompt: "execute spec-audit task from adversarial-audit")` step between the completion step and the correctness-over-speed note.

- [ ] 50. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-19. Edit `.opencode/skills/spec-creation/tasks/write.md` Step 40: change `spec-auditor` reference to `skill({name: "adversarial-audit"})` → `task(..., prompt: "execute spec-audit task from adversarial-audit")`.

- [ ] 51. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-20. Add dispatch path for `change-control.md` in spec-creation SKILL.md Trigger Dispatch Table and Operating Protocol. The task handles spec versioning and revision discipline — it is not dead code.

- [ ] 52. **GREEN (**sub-agent**).** `skill({name: "test-driven-development"})` → `task(..., prompt: "execute green task from test-driven-development")` for SC-21. Add dispatch path for `handoffs/spec-to-plan.md` in writing-plans SKILL.md Trigger Dispatch Table. The task validates spec structural completeness before plan creation — it is not dead code.

- [ ] 53. **GREEN doublecheck (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for SC-18, SC-19, SC-20, SC-21. Verify: Operating Protocol has adversarial-audit dispatch, write.md Step 40 references correct skill, spec-creation dispatch table has change-control row, writing-plans dispatch table has spec-to-plan row.

- [ ] 54. **Checkpoint commit (**inline**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute commit task from git-workflow")` with message: `Phase 5: add missing pipeline steps — adversarial-audit dispatch, fix write.md Step 40, resolve orphan task files`.

### Global Post-Steps

- [ ] 55. **Full behavioral test run (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for all SCs. Run all behavioral tests: SC-3, SC-4, SC-14, SC-17. Confirm all PASS.

- [ ] 56. **Adversarial audit (**clean-room**).** `skill({name: "adversarial-audit"})` → `task(..., prompt: "execute spec-audit task from adversarial-audit")` for the completed spec-creation and writing-plans changes. Verify no defects remain.

- [ ] 57. **Cross-validate (**clean-room**).** `skill({name: "adversarial-audit"})` → `task(..., prompt: "execute verification-audit task from adversarial-audit")` for the behavioral test results. Cross-validate PASS verdicts.

- [ ] 58. **Regression check (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute verify task from verification-before-completion")` for existing enforcement tests. Run `bash .opencode/tests/test-enforcement.sh --changed` to confirm no regressions.

- [ ] 59. **Finishing checklist (**clean-room**).** `skill({name: "finishing-a-development-branch"})` → `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Verify branch readiness: uncommitted changes, unpushed commits, lint, typecheck.

- [ ] 60. **Review prep (**clean-room**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute review-prep task from git-workflow")`. Generate compare URL and PR body.

- [ ] 61. **Cleanup (**clean-room**).** `skill({name: "git-workflow"})` → `task(..., prompt: "execute cleanup task from git-workflow")`. Delete merged branches, close issues, sync dev.

#### Phase 5 VbC

- [ ] 62. **VbC (**clean-room**).** `skill({name: "verification-before-completion"})` → `task(..., prompt: "execute completion task from verification-before-completion")` for SC-18, SC-19, SC-20, SC-21. Verify all four SCs pass. Confirm all behavioral tests PASS, adversarial audit PASS, regression check PASS.

**Concern transition:** All phases complete. Proceed to plan exit criteria verification.
