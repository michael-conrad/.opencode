# Phase 3 — Update References and Verify

**Concern:** Update cross-references, behavioral tests, and final verification sweep.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/tests-v2/behaviors/approval-gate-scope-routing.sh`
- `.opencode/tests-v2/behaviors/fast-path-workflow-reorder.sh`

**SCs:** SC-10, SC-11, SC-12

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: all `approval-gate-scope` files deleted
- Phase 2 VbC passed

**Exit Conditions:**
- All cross-references to deleted task files updated or removed
- Behavioral enforcement tests updated to use merged skill dispatch
- No remaining references to `approval-gate-scope` in any `.opencode/` file

---

- [ ] 43. **RED — SC-10 (**sub-agent**).** Write a grep test that shows `approval-gate-scope/tasks/` references still exist in `.opencode/`. **→ SC-10**
- [ ] 44. **GREEN — SC-10 (**sub-agent**).** Update or remove all `Read [Text](path)` references to `approval-gate-scope/tasks/` in `.opencode/guidelines/000-critical-rules.md` and `.opencode/skills/approval-gate/SKILL.md`. **→ SC-10**
- [ ] 45. **Verify — SC-10 (**clean-room**).** Verify `grep -r 'approval-gate-scope/tasks/' .opencode/` returns zero matches. **→ SC-10**
- [ ] 46. **Commit — SC-10 (**inline**).** `git add .opencode/guidelines/000-critical-rules.md .opencode/skills/approval-gate/SKILL.md && git commit -m 'refactor: update cross-references to deleted approval-gate-scope task files'`

- [ ] 47. **RED — SC-11 (**sub-agent**).** Write a behavioral test that dispatches to the old `approval-gate-scope` skill and verify it fails. **→ SC-11**
- [ ] 48. **GREEN — SC-11 (**sub-agent**).** Update `.opencode/tests-v2/behaviors/approval-gate-scope-routing.sh` and `.opencode/tests-v2/behaviors/fast-path-workflow-reorder.sh` to dispatch to the merged `approval-gate` skill. **→ SC-11**
- [ ] 49. **Verify — SC-11 (**clean-room**).** Run `opencode run` with skill dispatch assertion: stderr contains `Skill "approval-gate"` and does NOT contain `Skill "approval-gate-scope"`. **→ SC-11**
- [ ] 50. **Commit — SC-11 (**inline**).** `git add .opencode/tests-v2/behaviors/ && git commit -m 'refactor: update behavioral tests to dispatch to merged approval-gate skill'`

- [ ] 51. **RED — SC-12 (**sub-agent**).** Write a grep test that shows remaining `approval-gate-scope` references in `.opencode/`. **→ SC-12**
- [ ] 52. **GREEN — SC-12 (**sub-agent**).** Clean up any remaining references to `approval-gate-scope` in `.opencode/` files. **→ SC-12**
- [ ] 53. **Verify — SC-12 (**clean-room**).** Verify `grep -r 'approval-gate-scope' .opencode/` returns zero matches across all file types. **→ SC-12**
- [ ] 54. **Commit — SC-12 (**inline**).** `git add .opencode/ && git commit -m 'refactor: final cleanup of approval-gate-scope references'`

#### Phase 3 VbC

- [ ] 55. **VbC (**clean-room**).** Verify SC-10 (no stale cross-references), SC-11 (behavioral tests use merged skill), SC-12 (no remaining references). **→ SC-10, SC-11, SC-12**

**Concern transition:** Leaving reference updates → entering post-implementation. All phases complete.

---

## Post-Implementation

- [ ] 56. **Audit (**clean-room**).** Adversarial audit of the deliverable. Dispatch `verification-audit DiMo investigator` from audit skill. **→ all SCs**
- [ ] 57. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, etc.) via `finishing-a-development-branch`. **→ all SCs**
- [ ] 58. **Pre-PR gate (**clean-room**).** Verify all SC verdicts before PR creation — BLOCK if any FAIL. **→ all SCs**
- [ ] 59. **Regression check (**sub-agent**).** Final regression check before PR. **→ all SCs**
- [ ] 60. **Review prep (**sub-agent**).** Prepare PR review context via `git-workflow-pr`. **→ all SCs**
- [ ] 61. **Create PR (**sub-agent**).** Create the pull request via `git-workflow-pr`. **→ all SCs**
- [ ] 62. **Executive summary (**sub-agent**).** Generate completion executive summary via `completion-core`. **→ all SCs**
