# Implementation Plan — [#1445](https://github.com/michael-conrad/.opencode/issues/1445) — Submodule dev sync verification and conflict detection

- **Goal:** Add `--ff-only` enforcement, `main` branch creation fallback, and actionable HALT-on-divergence behavior to all submodule trunk sync operations across pre-work, cleanup, and mid-feature sync.
- **Architecture:** Three lifecycle points (pre-work, cleanup, mid-feature) each get `--ff-only` trunk pull + `main` branch creation fallback. A shared divergence/conflict reporting pattern is extracted for T6. Submodule operations remain sub-agent-dispatched; the changes are in task files and agent configs.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/pre-work.md` — Step 3.5 submodule init/sync
  - `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Step 1.9 submodule dev restore
  - `.opencode/skills/git-workflow/tasks/submodule-sync.md` — mid-feature sync procedure
  - `.opencode/skills/git-workflow/SKILL.md` — sub-agent task context updates
  - `.opencode/agents/submodule-tag-prework.jsonc` — agent config for pre-work sub-agent
  - `.opencode/agents/submodule-dev-restore.jsonc` — agent config for cleanup sub-agent

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute steps strictly sequentially. Do NOT proceed to step N+1 until step N is fully complete and verified. Do NOT read ahead. Do NOT batch steps. Each step is an atomic unit.

> **⚠️ STEP STATUS:** After completing each step, mark it as `[x]` in the plan file. Do NOT mark steps ahead. Do NOT skip steps.

## Phase 1 — Submodule dev sync verification and conflict detection

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Submodule dev sync verification and conflict detection | Add `--ff-only` enforcement, `main` branch creation, and HALT-on-divergence to all 3 lifecycle points | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | None | 1–58 |

### T1 — Pre-work `main` branch creation (SC-1, behavioral)

- [ ] 1. **SC-coherence-gate (**clean-room**).** Verify plan coherence against spec #1445: confirm all 6 SCs addressed, all 6 affected files covered. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 2. **Pre-RED baseline (**clean-room**).** Read `pre-work.md` Step 3.5 and record current submodule sync procedure (no `main` branch creation). Write baseline to `./tmp/1445/baseline-prework.md`. **→ SC-1**
- [ ] 3. **RED phase (**clean-room**).** Write behavioral test: send pre-work prompt to a submodule setup where `main` branch is missing. Assert the agent creates `main` from the default branch. Test MUST FAIL (change doesn't exist yet). **→ SC-1**
- [ ] 4. **Z3 check RED (**inline**).** Run `solve check` against RED output contract. **→ SC-1**
- [ ] 5. **RED doublecheck (**clean-room**).** Verify RED test correctly fails because `main` branch creation is absent. **→ SC-1**
- [ ] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED doublecheck output contract. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**clean-room**).** Verify no source code files were modified during RED phase. **→ SC-1**
- [ ] 8. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ SC-1**
- [ ] 9. **GREEN phase (**clean-room**).** Edit `pre-work.md` Step 3.5: after `git checkout dev`, add `git checkout -b main dev || true` fallback (create `main` from `dev` if missing). Update `submodule-tag-prework.jsonc` with the new behavior. **→ SC-1**
- [ ] 10. **Z3 check GREEN (**inline**).** Run `solve check` against GREEN output contract. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**clean-room**).** Verify only `pre-work.md` and `submodule-tag-prework.jsonc` were modified. **→ SC-1**
- [ ] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-GREEN enforcement output contract. **→ SC-1**
- [ ] 13. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T1-opencode`. **→ SC-1**
- [ ] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T1: pre-work creates main branch in submodules from default branch if missing"`. **→ SC-1**
- [ ] 15. **Structural checks (**clean-room**).** Run lint/typecheck on modified files. **→ SC-1**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Re-run T1 behavioral test. Assert PASS. If FAIL, remediate and re-run. **→ SC-1**
- [ ] 17. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-1. **→ SC-1**

### T2 — Pre-work `--ff-only` enforcement (SC-2, behavioral)

- [ ] 18. **SC-coherence-gate (**clean-room**).** Verify T2 coherence against spec. **→ SC-2**
- [ ] 19. **Pre-RED baseline (**clean-room**).** Read `pre-work.md` Step 3.5 and record current `git pull` pattern (no `--ff-only`). **→ SC-2**
- [ ] 20. **RED phase (**clean-room**).** Write behavioral test: send pre-work prompt to a submodule with diverged history. Assert the agent uses `--ff-only` and HALTs on non-fast-forward. Test MUST FAIL. **→ SC-2**
- [ ] 21. **Z3 check RED (**inline**).** Run `solve check` against RED output contract. **→ SC-2**
- [ ] 22. **RED doublecheck (**clean-room**).** Verify RED test correctly fails. **→ SC-2**
- [ ] 23. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED doublecheck output contract. **→ SC-2**
- [ ] 24. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-2**
- [ ] 25. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ SC-2**
- [ ] 26. **GREEN phase (**clean-room**).** Edit `pre-work.md` Step 3.5: change `git pull origin dev` to `git pull origin dev --ff-only`. Add HALT-on-failure with actionable message. Update `submodule-tag-prework.jsonc`. **→ SC-2**
- [ ] 27. **Z3 check GREEN (**inline**).** Run `solve check` against GREEN output contract. **→ SC-2**
- [ ] 28. **Post-GREEN enforcement (**clean-room**).** Verify only `pre-work.md` and `submodule-tag-prework.jsonc` modified. **→ SC-2**
- [ ] 29. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-GREEN enforcement output contract. **→ SC-2**
- [ ] 30. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T2-opencode`. **→ SC-2**
- [ ] 31. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T2: pre-work uses --ff-only for submodule trunk pull and HALTs on non-fast-forward"`. **→ SC-2**
- [ ] 32. **Structural checks (**clean-room**).** Run lint/typecheck. **→ SC-2**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Re-run T2 behavioral test. Assert PASS. If FAIL, remediate and re-run. **→ SC-2**
- [ ] 34. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-2. **→ SC-2**

### T3 — Cleanup `main` branch creation (SC-3, behavioral)

- [ ] 35. **SC-coherence-gate (**clean-room**).** Verify T3 coherence. **→ SC-3**
- [ ] 36. **Pre-RED baseline (**clean-room**).** Read `branch-cleanup.md` Step 1.9 and record current state. **→ SC-3**
- [ ] 37. **RED phase (**clean-room**).** Write behavioral test: cleanup prompt with missing `main` branch. Assert agent creates it. Test MUST FAIL. **→ SC-3**
- [ ] 38. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 39. **RED doublecheck (**clean-room**).** Verify RED test correctly fails. **→ SC-3**
- [ ] 40. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 41. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-3**
- [ ] 42. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 43. **GREEN phase (**clean-room**).** Edit `branch-cleanup.md` Step 1.9: add `git checkout -b main dev || true` fallback. Update `submodule-dev-restore.jsonc`. **→ SC-3**
- [ ] 44. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 45. **Post-GREEN enforcement (**clean-room**).** Verify only `branch-cleanup.md` and `submodule-dev-restore.jsonc` modified. **→ SC-3**
- [ ] 46. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-3**
- [ ] 47. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T3-opencode`. **→ SC-3**
- [ ] 48. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T3: cleanup submodule trunk restore creates main branch if missing"`. **→ SC-3**
- [ ] 49. **Structural checks (**clean-room**).** Run lint/typecheck. **→ SC-3**
- [ ] 50. **GREEN doublecheck (**clean-room**).** Re-run T3 behavioral test. Assert PASS. **→ SC-3**
- [ ] 51. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-3. **→ SC-3**

### T4 — Cleanup `--ff-only` enforcement (SC-4, behavioral)

- [ ] 52. **SC-coherence-gate (**clean-room**).** Verify T4 coherence. **→ SC-4**
- [ ] 53. **Pre-RED baseline (**clean-room**).** Read `branch-cleanup.md` Step 1.9 and record current `git pull` pattern. **→ SC-4**
- [ ] 54. **RED phase (**clean-room**).** Write behavioral test: cleanup prompt with diverged history. Assert `--ff-only` and HALT. Test MUST FAIL. **→ SC-4**
- [ ] 55. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 56. **RED doublecheck (**clean-room**).** Verify RED test correctly fails. **→ SC-4**
- [ ] 57. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 58. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-4**
- [ ] 59. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 60. **GREEN phase (**clean-room**).** Edit `branch-cleanup.md` Step 1.9: change `git pull origin dev` to `git pull origin dev --ff-only`. Add HALT-on-failure with actionable message. Update `submodule-dev-restore.jsonc`. **→ SC-4**
- [ ] 61. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 62. **Post-GREEN enforcement (**clean-room**).** Verify only `branch-cleanup.md` and `submodule-dev-restore.jsonc` modified. **→ SC-4**
- [ ] 63. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-4**
- [ ] 64. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T4-opencode`. **→ SC-4**
- [ ] 65. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T4: cleanup submodule trunk restore uses --ff-only and HALTs on non-fast-forward"`. **→ SC-4**
- [ ] 66. **Structural checks (**clean-room**).** Run lint/typecheck. **→ SC-4**
- [ ] 67. **GREEN doublecheck (**clean-room**).** Re-run T4 behavioral test. Assert PASS. **→ SC-4**
- [ ] 68. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-4. **→ SC-4**

### T5 — Mid-feature sync `--ff-only` (SC-5, behavioral)

- [ ] 69. **SC-coherence-gate (**clean-room**).** Verify T5 coherence. **→ SC-5**
- [ ] 70. **Pre-RED baseline (**clean-room**).** Read `submodule-sync.md` and record current procedure. **→ SC-5**
- [ ] 71. **RED phase (**clean-room**).** Write behavioral test: mid-feature sync prompt with diverged history. Assert `--ff-only` and divergence report. Test MUST FAIL. **→ SC-5**
- [ ] 72. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-5**
- [ ] 73. **RED doublecheck (**clean-room**).** Verify RED test correctly fails. **→ SC-5**
- [ ] 74. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-5**
- [ ] 75. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-5**
- [ ] 76. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-5**
- [ ] 77. **GREEN phase (**clean-room**).** Edit `submodule-sync.md`: add `--ff-only` flag, add `main` branch creation fallback, add divergence reporting. Update `SKILL.md` sub-agent task context for `submodule-sync`. **→ SC-5**
- [ ] 78. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-5**
- [ ] 79. **Post-GREEN enforcement (**clean-room**).** Verify only `submodule-sync.md` and `SKILL.md` modified. **→ SC-5**
- [ ] 80. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-5**
- [ ] 81. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T5-opencode`. **→ SC-5**
- [ ] 82. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T5: mid-feature submodule sync uses --ff-only and reports divergence"`. **→ SC-5**
- [ ] 83. **Structural checks (**clean-room**).** Run lint/typecheck. **→ SC-5**
- [ ] 84. **GREEN doublecheck (**clean-room**).** Re-run T5 behavioral test. Assert PASS. **→ SC-5**
- [ ] 85. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-5. **→ SC-5**

### T6 — Actionable divergence reporting (SC-6, behavioral, depends on T1-T5)

- [ ] 86. **SC-coherence-gate (**clean-room**).** Verify T6 coherence: confirm all 3 lifecycle points now have divergence detection. **→ SC-6**
- [ ] 87. **Pre-RED baseline (**clean-room**).** Read all 3 task files and record current divergence reporting (none). **→ SC-6**
- [ ] 88. **RED phase (**clean-room**).** Write behavioral test covering all 3 lifecycle points with diverged submodule history. Assert agent reports: (a) which submodule diverged, (b) ahead/behind commits, (c) suggested resolution, (d) HALTs. Test MUST FAIL. **→ SC-6**
- [ ] 89. **Z3 check RED (**inline**).** Run `solve check`. **→ SC-6**
- [ ] 90. **RED doublecheck (**clean-room**).** Verify RED test correctly fails. **→ SC-6**
- [ ] 91. **Z3 check RED doublecheck (**inline**).** Run `solve check`. **→ SC-6**
- [ ] 92. **Post-RED enforcement (**clean-room**).** Verify no source code files modified. **→ SC-6**
- [ ] 93. **Z3 check post-RED (**inline**).** Run `solve check`. **→ SC-6**
- [ ] 94. **GREEN phase (**clean-room**).** Extract consistent divergence reporting pattern across all 3 task files. Each HALT-on-divergence must include: submodule path, ahead/behind commit counts, suggested resolution, and HALT for developer consultation. Update all 6 affected files. **→ SC-6**
- [ ] 95. **Z3 check GREEN (**inline**).** Run `solve check`. **→ SC-6**
- [ ] 96. **Post-GREEN enforcement (**clean-room**).** Verify only the 6 affected files modified. **→ SC-6**
- [ ] 97. **Z3 check post-GREEN (**inline**).** Run `solve check`. **→ SC-6**
- [ ] 98. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1445/phase-1-T6-opencode`. **→ SC-6**
- [ ] 99. **Checkpoint commit (**inline**).** `git add -A && git commit -m "T6: all divergence/conflict situations report actionable information and HALT for developer consultation"`. **→ SC-6**
- [ ] 100. **Structural checks (**clean-room**).** Run lint/typecheck. **→ SC-6**
- [ ] 101. **GREEN doublecheck (**clean-room**).** Re-run T6 behavioral test. Assert PASS. **→ SC-6**
- [ ] 102. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-6. **→ SC-6**

### Global post-steps

- [ ] 103. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 104. **Adversarial audit — auditor 1 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_1. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 105. **Adversarial audit — auditor 2 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_2. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 106. **Cross-validate (**clean-room**).** Dispatch `adversarial-audit --task cross-validate` with both auditor artifact paths. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 107. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no regressions. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 108. **Review-prep (**clean-room**).** Dispatch `git-workflow --task review-prep` for PR readiness. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 109. **Exec summary (**inline**).** Report completion with summary, outcome, blockers, and byline. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the orchestrator MUST NOT proceed. Diagnose the failure, remediate, re-verify, and only then advance. If remediation fails twice, report BLOCKED with both failure artifacts and HALT. Do NOT reclassify a FAIL as "close enough." Do NOT proceed past a failed step without remediation.

## Exit Criteria

- [ ] C1: T1 implemented — pre-work creates `main` branch in submodules from default branch if missing (SC-1)
- [ ] C2: T2 implemented — pre-work uses `--ff-only` for submodule trunk pull and HALTs on non-fast-forward (SC-2)
- [ ] C3: T3 implemented — cleanup submodule trunk restore creates `main` branch if missing (SC-3)
- [ ] C4: T4 implemented — cleanup submodule trunk restore uses `--ff-only` and HALTs on non-fast-forward (SC-4)
- [ ] C5: T5 implemented — mid-feature submodule sync uses `--ff-only` and reports divergence (SC-5)
- [ ] C6: T6 implemented — all divergence/conflict situations report actionable information and HALT for developer consultation (SC-6)
- [ ] C7: All 6 behavioral tests pass (RED → GREEN cycle complete)
- [ ] C8: All pipeline gates passed (coherence, RED, GREEN, VbC, audit, cross-validate, regression)
