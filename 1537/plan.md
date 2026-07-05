# Implementation Plan — [#1537](https://github.com/michael-conrad/.opencode/issues/1537) — Submodule pointer bumps: workflow steps and pre-commit Gate 4 fix

- **Goal:** Ensure dirty submodule pointers are included in parent repo commits by adding pre-commit pointer checks to the workflow, updating pre-commit Gate 4 to allow submodule pointers alongside non-submodule changes, and creating a dedicated sub-agent task.
- **Architecture:** Single phase, 5 items with dependency ordering. Items 1 and 2 are independent (parallel). Items 3 and 4 depend on Item 1. Item 5 depends on Items 2, 3, and 4.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/implementation.md` — add pre-commit pointer check step
  - `.opencode/skills/git-workflow/tasks/pr-creation.md` — add pre-push pointer verification step
  - `.opencode/hooks/pre-commit` — update Gate 4 logic
  - `.opencode/skills/git-workflow/SKILL.md` — add `pre-commit-pointer-check` to trigger dispatch table
  - `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` — new sub-agent task

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute steps strictly sequentially. Do NOT proceed to step N+1 until step N is fully complete and verified. Do NOT read ahead. Do NOT batch steps. Each step is an atomic unit.

> **⚠️ STEP STATUS:** After completing each step, mark it as `[x]` in the plan file. Do NOT mark steps ahead. Do NOT skip steps.

## Phase 1 — Submodule pointer workflow and pre-commit Gate 4 fix

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Submodule pointer workflow and pre-commit Gate 4 fix | Add pre-commit pointer checks, update Gate 4, create pre-commit-pointer-check sub-task | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1–58 |

### Item 1 — Add pre-commit pointer check to implementation.md (SC-1, string)

- [ ] 1. **SC-coherence-gate (**clean-room**).** Verify plan coherence against spec #1537: confirm all 5 SCs addressed, all 5 affected files covered. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Read `implementation.md` and record current pre-commit section (no submodule pointer check). Write baseline to `./tmp/1537/baseline-impl.md`. **→ SC-1**
- [ ] 3. **RED phase (**clean-room**).** Write string test: `grep -c 'Pre-Commit Submodule Pointer Check' implementation.md` — assert 0. Test MUST PASS (step doesn't exist yet). **→ SC-1**
- [ ] 4. **Z3 check RED (**inline**).** Run `solve check` against RED output contract. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Verify RED test correctly detects absence of pointer check step. **→ SC-1**
- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED doublecheck output contract. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Verify no source code files were modified during RED phase. **→ SC-1**
- [ ] 8. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ SC-1**
- [ ] 9. **GREEN phase (**clean-room**).** In `implementation.md`, before the `git add <files>` / `git commit` block, insert a `### ⚠️ CRITICAL: Pre-Commit Submodule Pointer Check` subsection that: (1) runs `git submodule status` to detect dirty pointers, (2) if dirty pointers found, runs `git add <submodule-path>` to stage them, (3) verifies staged files include both source changes AND submodule pointer updates. **→ SC-1**
- [ ] 10. **Z3 check GREEN (**inline**).** Run `solve check` against GREEN output contract. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Verify only `implementation.md` was modified. **→ SC-1**
- [ ] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-GREEN enforcement output contract. **→ SC-1**
- [ ] 13. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1537/phase-1-item1-opencode`. **→ SC-1**
- [ ] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 1: add pre-commit submodule pointer check step to implementation.md"`. **→ SC-1**
- [ ] 15. **Structural checks (**clean-room**).** Run `grep -c 'Pre-Commit Submodule Pointer Check' implementation.md` — assert 1. **→ SC-1**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Verify SC-1: `implementation.md` has a step checking for dirty submodule pointers before commit. **→ SC-1**
- [ ] 17. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-1. **→ SC-1**

### Item 2 — Add pre-push pointer verification to pr-creation.md (SC-2, string)

- [ ] 18. **SC-coherence-gate (**clean-room**).** Verify Item 2 coherence. **→ SC-2**
- [ ] 19. **Pre-RED baseline (**clean-room**).** Read `pr-creation.md` and record current pre-push section. **→ SC-2**
- [ ] 20. **RED phase (**clean-room**).** Write string test: `grep -c 'submodule pointer' pr-creation.md` — assert 0. Test MUST PASS. **→ SC-2**
- [ ] 21. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-2**
- [ ] 22. **RED doublecheck (**clean-room**).** Verify RED test correctly detects absence. **→ SC-2**
- [ ] 23. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-2**
- [ ] 24. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-2**
- [ ] 25. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-2**
- [ ] 26. **GREEN phase (**clean-room**).** In `pr-creation.md`, before the squash/push step, insert a verification step that: (1) checks `git submodule status` for dirty pointers, (2) verifies staged/committed changes include pointer updates, (3) if pointers missing, warns and suggests re-running implementation step. **→ SC-2**
- [ ] 27. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-2**
- [ ] 28. **Post-GREEN enforcement (**clean-room**).** Verify only `pr-creation.md` modified. **→ SC-2**
- [ ] 29. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-2**
- [ ] 30. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1537/phase-1-item2-opencode`. **→ SC-2**
- [ ] 31. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 2: add submodule pointer verification step to pr-creation.md"`. **→ SC-2**
- [ ] 32. **Structural checks (**clean-room**).** Run `grep -c 'submodule pointer' pr-creation.md` — assert >= 1. **→ SC-2**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Verify SC-2: `pr-creation.md` has a step verifying submodule pointers are included. **→ SC-2**
- [ ] 34. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-2. **→ SC-2**

### Item 3 — Update pre-commit Gate 4 logic (SC-3, behavioral, depends on Item 1)

- [ ] 35. **SC-coherence-gate (**clean-room**).** Verify Item 3 coherence. **→ SC-3**
- [ ] 36. **Pre-RED baseline (**clean-room**).** Read `hooks/pre-commit` Gate 4 and record current logic (blocks ALL submodule-pointer commits). **→ SC-3**
- [ ] 37. **RED phase (**clean-room**).** Write behavioral test: commit with submodule pointer + non-submodule changes. Assert Gate 4 blocks it. Test MUST PASS (Gate 4 currently blocks all submodule-pointer commits). **→ SC-3**
- [ ] 38. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 39. **RED doublecheck (**clean-room**).** Verify RED test correctly detects Gate 4 blocking. **→ SC-3**
- [ ] 40. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 41. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-3**
- [ ] 42. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 43. **GREEN phase (**clean-room**).** In `hooks/pre-commit` Gate 4: after detecting `ALL_SUBMODULE_POINTERS=1`, also check `git status --porcelain` for unstaged non-submodule changes. If any exist, allow the commit. Only block when ALL staged files are submodule pointers AND no uncommitted non-submodule changes exist. **→ SC-3**
- [ ] 44. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 45. **Post-GREEN enforcement (**clean-room**).** Verify only `hooks/pre-commit` modified. **→ SC-3**
- [ ] 46. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 47. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1537/phase-1-item3-opencode`. **→ SC-3**
- [ ] 48. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 3: update pre-commit Gate 4 to allow submodule pointers alongside non-submodule changes"`. **→ SC-3**
- [ ] 49. **Structural checks (**clean-room**).** Run lint/typecheck on `hooks/pre-commit`. **→ SC-3**
- [ ] 50. **GREEN doublecheck (**clean-room**).** Re-run SC-3 behavioral test. Assert PASS (Gate 4 now allows mixed commits). If FAIL, remediate and re-run. **→ SC-3**
- [ ] 51. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-3. **→ SC-3**

### Item 4 — Add pre-commit-pointer-check to SKILL.md dispatch table (SC-4, string, depends on Item 1)

- [ ] 52. **SC-coherence-gate (**clean-room**).** Verify Item 4 coherence. **→ SC-4**
- [ ] 53. **Pre-RED baseline (**clean-room**).** Read `SKILL.md` trigger dispatch table and record current entries. **→ SC-4**
- [ ] 54. **RED phase (**clean-room**).** Write string test: `grep -c 'pre-commit-pointer-check' SKILL.md` — assert 0. Test MUST PASS. **→ SC-4**
- [ ] 55. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 56. **RED doublecheck (**clean-room**).** Verify RED test correctly detects absence. **→ SC-4**
- [ ] 57. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 58. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-4**
- [ ] 59. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 60. **GREEN phase (**clean-room**).** In `SKILL.md`: add `pre-commit-pointer-check` to trigger dispatch table with trigger phrases "pre-commit pointer check", "submodule pointer check", "check submodule pointers". Add to Tasks list. Add to Invocation table with `task(..., prompt: "execute pre-commit-pointer-check task from git-workflow")`. **→ SC-4**
- [ ] 61. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 62. **Post-GREEN enforcement (**clean-room**).** Verify only `SKILL.md` modified. **→ SC-4**
- [ ] 63. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 64. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1537/phase-1-item4-opencode`. **→ SC-4**
- [ ] 65. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 4: add pre-commit-pointer-check dispatch entry to SKILL.md"`. **→ SC-4**
- [ ] 66. **Structural checks (**clean-room**).** Run `grep -c 'pre-commit-pointer-check' SKILL.md` — assert >= 1. **→ SC-4**
- [ ] 67. **GREEN doublecheck (**clean-room**).** Verify SC-4: `pre-commit-pointer-check` sub-task exists in git-workflow. **→ SC-4**
- [ ] 68. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-4. **→ SC-4**

### Item 5 — Create pre-commit-pointer-check sub-agent task (SC-4, SC-5, string + behavioral, depends on Items 2, 3, 4)

- [ ] 69. **SC-coherence-gate (**clean-room**).** Verify Item 5 coherence: confirm Items 2-4 are complete. **→ SC-4, SC-5**
- [ ] 70. **Pre-RED baseline (**clean-room**).** Verify `pre-commit-pointer-check.md` does not exist. **→ SC-4**
- [ ] 71. **RED phase (**clean-room**).** Write string test: `ls tasks/pre-commit-pointer-check.md` — assert file does not exist. Test MUST PASS. **→ SC-4**
- [ ] 72. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 73. **RED doublecheck (**clean-room**).** Verify RED test correctly detects absence. **→ SC-4**
- [ ] 74. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 75. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-4**
- [ ] 76. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 77. **GREEN phase (**clean-room**).** Create `tasks/pre-commit-pointer-check.md` with: Purpose (check for dirty submodule pointers before commit), Procedure (run `git submodule status`, check if dirty pointers are staged via `git diff --cached --name-only`, warn if not staged, report PASS if staged or no dirty pointers), Result contract (`{ status, finding_summary, artifact_path, blocker_reason }`). **→ SC-4**
- [ ] 78. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 79. **Post-GREEN enforcement (**clean-room**).** Verify only the new task file was created. **→ SC-4**
- [ ] 80. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 81. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1537/phase-1-item5-opencode`. **→ SC-4, SC-5**
- [ ] 82. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 5: create pre-commit-pointer-check sub-agent task"`. **→ SC-4, SC-5**
- [ ] 83. **Structural checks (**clean-room**).** Verify `tasks/pre-commit-pointer-check.md` exists and is non-empty. **→ SC-4**
- [ ] 84. **GREEN doublecheck (**clean-room**).** Verify SC-4 (task file exists) and SC-5 (agent following workflow includes dirty pointers without `--no-verify`). **→ SC-4, SC-5**
- [ ] 85. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-4, SC-5. **→ SC-4, SC-5**

### Global post-steps

- [ ] 86. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 87. **Adversarial audit — auditor 1 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_1. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 88. **Adversarial audit — auditor 2 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_2. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 89. **Cross-validate (**clean-room**).** Dispatch `adversarial-audit --task cross-validate` with both auditor artifact paths. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 90. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no regressions. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 91. **Review-prep (**clean-room**).** Dispatch `git-workflow --task review-prep` for PR readiness. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 92. **Exec summary (**inline**).** Report completion with summary, outcome, blockers, and byline. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the orchestrator MUST NOT proceed. Diagnose the failure, remediate, re-verify, and only then advance. If remediation fails twice, report BLOCKED with both failure artifacts and HALT. Do NOT reclassify a FAIL as "close enough." Do NOT proceed past a failed step without remediation.

## Exit Criteria

- [ ] C1: `implementation.md` has a step checking for dirty submodule pointers before commit (SC-1)
- [ ] C2: `pr-creation.md` has a step verifying submodule pointers are included (SC-2)
- [ ] C3: Pre-commit Gate 4 allows submodule pointers when non-submodule changes are also staged (SC-3)
- [ ] C4: A `pre-commit-pointer-check` sub-task exists in git-workflow (SC-4)
- [ ] C5: Agent following the workflow includes dirty submodule pointers in parent repo commits without `--no-verify` (SC-5)
- [ ] C6: All pipeline gates passed (coherence, RED, GREEN, VbC, audit, cross-validate, regression)
