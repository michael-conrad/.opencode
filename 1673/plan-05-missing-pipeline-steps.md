# Phase 05 — Missing Pipeline Steps

**Concern:** Add missing dispatch paths for adversarial-audit, change-control, and spec-to-plan in spec-creation and writing-plans SKILL.md files.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — Operating Protocol, Trigger Dispatch Table
- `.opencode/skills/spec-creation/tasks/write.md` — Step 40
- `.opencode/skills/writing-plans/SKILL.md` — Trigger Dispatch Table

**SCs:** SC-18, SC-19, SC-20, SC-21

**Dependencies:** Phase 2 (same file — spec-creation SKILL.md)

**Entry conditions:** Phase 2 checkpoint committed, feature branch current

**Exit conditions:** All 4 SCs verified PASS

---

- [ ] 42. **Coherence gate (**clean-room**).** Read spec-creation SKILL.md Operating Protocol and Trigger Dispatch Table. Read write.md Step 40. Read writing-plans SKILL.md Trigger Dispatch Table. Confirm missing entries: no adversarial-audit step, no change-control row, no spec-to-plan row. **→ SC-18, SC-19, SC-20, SC-21**

- [ ] 43. **Pre-red-baseline (**clean-room**).** Run `grep -c "execute spec-audit task from adversarial-audit" .opencode/skills/spec-creation/SKILL.md` (expect 0), `grep -c "spec-auditor" .opencode/skills/spec-creation/tasks/write.md` (expect 3), `grep -c "change-control" .opencode/skills/spec-creation/SKILL.md` (expect 0 in Trigger Dispatch Table), `grep -c "spec-to-plan" .opencode/skills/writing-plans/SKILL.md` (expect 0 in Trigger Dispatch Table). Record baselines. **→ SC-18, SC-19, SC-20, SC-21**

- [ ] 44. **GREEN: add adversarial-audit to spec-creation Operating Protocol (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` Operating Protocol. Add step: `task(..., prompt: "execute spec-audit task from adversarial-audit")`. **→ SC-18**

- [ ] 45. **GREEN: fix write.md Step 40 (**sub-agent**).** Edit `.opencode/skills/spec-creation/tasks/write.md` Step 40. Replace `spec-auditor` references with `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute spec-audit task from adversarial-audit")`. **→ SC-19**

- [ ] 46. **GREEN: add change-control to spec-creation Trigger Dispatch Table (**sub-agent**).** Edit `.opencode/skills/spec-creation/SKILL.md` Trigger Dispatch Table. Add row for `change-control` task with trigger pattern, dispatch type (`sub-task`), and canonical `task(..., prompt: "execute change-control task from spec-creation")` string. **→ SC-20**

- [ ] 47. **GREEN: add spec-to-plan to writing-plans Trigger Dispatch Table (**sub-agent**).** Edit `.opencode/skills/writing-plans/SKILL.md` Trigger Dispatch Table. Add row for `handoffs/spec-to-plan` task with trigger pattern, dispatch type (`sub-task`), and canonical `task(..., prompt: "execute handoffs/spec-to-plan task from writing-plans")` string. **→ SC-21**

- [ ] 48. **GREEN doublecheck (**clean-room**).** Verify: `grep -q "execute spec-audit task from adversarial-audit" .opencode/skills/spec-creation/SKILL.md` (SC-18), `grep -q "execute spec-audit task from adversarial-audit" .opencode/skills/spec-creation/tasks/write.md` (SC-19), `grep -q "change-control" .opencode/skills/spec-creation/SKILL.md` (SC-20), `grep -q "spec-to-plan" .opencode/skills/writing-plans/SKILL.md` (SC-21). **→ SC-18, SC-19, SC-20, SC-21**

- [ ] 49. **Checkpoint commit (**inline**).** Commit: `git add .opencode/skills/spec-creation/SKILL.md .opencode/skills/spec-creation/tasks/write.md .opencode/skills/writing-plans/SKILL.md && git commit -m "Phase 5: Add missing pipeline steps"`. Create checkpoint tag. **→ SC-18, SC-19, SC-20, SC-21**

- [ ] 50. **VbC (**clean-room**).** Verify all 4 SCs: grep for adversarial-audit in spec-creation SKILL.md (SC-18), grep for adversarial-audit in write.md Step 40 (SC-19), grep for change-control in spec-creation Trigger Dispatch Table (SC-20), grep for spec-to-plan in writing-plans Trigger Dispatch Table (SC-21). **→ SC-18, SC-19, SC-20, SC-21**

#### Phase 05 VbC

- [ ] 50. **VbC (**clean-room**).** Verify: SC-18 (adversarial-audit in Operating Protocol), SC-19 (adversarial-audit in write.md Step 40), SC-20 (change-control in Trigger Dispatch Table), SC-21 (spec-to-plan in Trigger Dispatch Table). **→ SC-18, SC-19, SC-20, SC-21**

**Concern transition:** Leaving missing pipeline steps → entering Phase 6 (pipeline enforcement gates). Phase 6 depends on Phase 4 (same files — writing-plans SKILL.md and create.md).

---

## Global Post-Steps

- [ ] 64. **Adversarial audit (**clean-room**).** Dispatch `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute spec-audit task from adversarial-audit")` for the spec. Dispatch `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute plan-fidelity task from adversarial-audit")` for the plan. Collect findings and remediate any FAIL verdicts. **→ All SCs**

- [ ] 65. **Cross-validate (**clean-room**).** Dispatch `skill({name: "adversarial-audit"})` then `task(..., prompt: "execute cross-validate task from adversarial-audit")`. Verify that all SC evidence artifacts match the declared evidence types. Downgrade any EVIDENCE_TYPE_MISMATCH to FAIL. **→ All SCs**

- [ ] 66. **Regression check (**clean-room**).** Run `uvx ruff check .opencode/skills/` and `uvx pyright .opencode/skills/` (if Python files exist). Run `uvx pymarkdownlnt scan -r .opencode/skills/` for markdown files. Fix any regressions. **→ All SCs**

- [ ] 67. **Finishing checklist (**clean-room**).** Dispatch `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Verify: all changes committed, no uncommitted files, branch is up to date with dev, all SCs verified PASS. **→ All SCs**

- [ ] 68. **Review-prep (**clean-room**).** Dispatch `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`. Generate compare URL, diff summary, and reviewer context. **→ All SCs**

- [ ] 69. **Cleanup (**clean-room**).** Dispatch `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`. Delete merged branches, close issues, sync dev. **→ All SCs**

- [ ] 70. **Executive summary (**inline**).** Report: all 29 SCs verified PASS across 6 phases. Plan file paths: `.opencode/.issues/1673/plan.md` (index), `.opencode/.issues/1673/plan-01-*` through `plan-06-*` (phase files). HALT. **→ All SCs**
