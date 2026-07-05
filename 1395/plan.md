# Implementation Plan — [#1395](https://github.com/michael-conrad/.opencode/issues/1395) — Remove dead JSONC sub-agent configs, fold submodule ops into general task dispatch

- **Goal:** Delete four dead JSONC files from `agents/`, remove the dedicated "Sub-Agent Tasks for Submodule Operations" table from `git-workflow/SKILL.md`, and update all task files to use standard `task(subagent_type="general")` dispatch language for submodule operations.
- **Architecture:** Structural cleanup — file deletion + text replacement. No runtime behavior changes. The `must_receive`/`must_not_receive` context schemas already inline in each task file are preserved unchanged.
- **Files:**
  - `agents/submodule-dev-restore.jsonc` — DELETE
  - `agents/submodule-feature-push.jsonc` — DELETE
  - `agents/submodule-liveness-check.jsonc` — DELETE
  - `agents/submodule-tag-prework.jsonc` — DELETE
  - `skills/git-workflow/SKILL.md` — Remove sub-agent table, update routing section
  - `skills/git-workflow/tasks/pre-work.md` — Replace dedicated sub-agent language
  - `skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Same
  - `skills/git-workflow/tasks/pr-creation/enforcement-gate.md` — Same
  - `skills/git-workflow/tasks/review-prep/push-and-cleanup.md` — Same
  - `skills/git-workflow/tasks/check-pr.md` — Same
  - `skills/git-workflow/tasks/cleanup.md` — Same
  - `skills/git-workflow/tasks/pr-creation.md` — Same
  - `skills/git-workflow/tasks/review-prep.md` — Same

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute steps strictly sequentially. Do NOT proceed to step N+1 until step N is fully complete and verified. Do NOT read ahead. Do NOT batch steps. Each step is an atomic unit.

> **⚠️ STEP STATUS:** After completing each step, mark it as `[x]` in the plan file. Do NOT mark steps ahead. Do NOT skip steps.

## Phase 1 — Remove dead JSONC configs and update dispatch language

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Remove dead JSONC configs and update dispatch language | Delete 4 dead JSONC files, remove sub-agent table from SKILL.md, update 8 task files to use standard `task(subagent_type="general")` dispatch | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1–23 |

### Item 1 — Delete 4 dead JSONC files (SC-1, structural)

- [x] 1. **SC-coherence-gate (**clean-room**).** Verify plan coherence against spec #1395: confirm all 5 SCs are addressed, all 13 affected files are covered. **→ SC-1, SC-2, SC-3, SC-4, SC-5** — PASS
- [x] 2. **Pre-RED baseline (**clean-room**).** Read `agents/` directory listing to establish current state. Record that 4 `.jsonc` files exist. Write baseline to `./tmp/1395/baseline.md`. **→ SC-1** — PASS
- [x] 3. **RED phase (**clean-room**).** Write structural test: `ls .opencode/agents/*.jsonc` — assert it returns 4 files. Test MUST PASS (files exist). **→ SC-1** — PASS, 4 files confirmed
- [x] 4. **Z3 check RED (**inline**).** Run `solve check` against RED output contract. **→ SC-1** — PASS
- [x] 5. **RED doublecheck (**clean-room**).** Verify RED test correctly detects the 4 JSONC files. **→ SC-1** — PASS, 4 files confirmed via `ls`
- [x] 6. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED doublecheck output contract. **→ SC-1** — PASS
- [x] 7. **Post-RED enforcement (**clean-room**).** Verify no source code files were modified during RED phase. **→ SC-1** — PASS, only agents/ files exist
- [x] 8. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ SC-1** — PASS
- [x] 9. **GREEN phase (**clean-room**).** Delete `agents/submodule-dev-restore.jsonc`, `agents/submodule-feature-push.jsonc`, `agents/submodule-liveness-check.jsonc`, `agents/submodule-tag-prework.jsonc`. **→ SC-1** — PASS, all 4 deleted
- [x] 10. **Z3 check GREEN (**inline**).** Run `solve check` against GREEN output contract. **→ SC-1** — PASS
- [x] 11. **Post-GREEN enforcement (**clean-room**).** Verify only the 4 JSONC files were deleted (no test files modified). **→ SC-1** — PASS
- [x] 12. **Z3 check post-GREEN (**inline**).** Run `solve check` against post-GREEN enforcement output contract. **→ SC-1** — PASS
- [x] 13. **Checkpoint tag create (**clean-room**).** Create git tag `opencode-config/checkpoint/1395/phase-1-item1-opencode`. **→ SC-1** — PASS
- [x] 14. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Item 1: delete 4 dead JSONC files from agents/"`. **→ SC-1** — PASS, commit f373d347
- [x] 15. **Structural checks (**clean-room**).** Run `ls .opencode/agents/*.jsonc` — assert empty. **→ SC-1** — PASS
- [x] 16. **GREEN doublecheck (**clean-room**).** Verify SC-1: no `.jsonc` files remain in `agents/`. **→ SC-1** — PASS
- [x] 17. **GREEN VbC (**clean-room**).** Run `verification-before-completion --task verify` for SC-1. **→ SC-1** — PASS

### Item 2 — Remove .jsonc references and sub-agent table from SKILL.md (SC-2, SC-3, SC-5, string)

- [x] 18. **SC-coherence-gate (**clean-room**).** Verify Item 2 coherence: confirm SKILL.md still has the sub-agent table and `.jsonc` references. **→ SC-2, SC-3, SC-5** — PASS
- [x] 19. **Pre-RED baseline (**clean-room**).** Read `skills/git-workflow/SKILL.md` and record current state (sub-agent table at lines 89-97, `.jsonc` references in config column). Write baseline to `./tmp/1395/baseline-skill.md`. **→ SC-2, SC-3** — PASS
- [x] 20. **RED phase (**clean-room**).** Write string test: `grep -c 'Sub-Agent Tasks for Submodule Operations' skills/git-workflow/SKILL.md` — assert >= 1. Test MUST PASS (table exists). **→ SC-3** — PASS, 2 matches
- [x] 21. **Z3 check RED (**inline**).** Run `solve check` against RED output contract. **→ SC-3** — PASS
- [x] 22. **RED doublecheck (**clean-room**).** Verify RED test correctly detects the sub-agent table. **→ SC-3** — PASS
- [x] 23. **Z3 check RED doublecheck (**inline**).** Run `solve check` against RED doublecheck output contract. **→ SC-3** — PASS
- [x] 24. **Post-RED enforcement (**clean-room**).** Verify no source code files were modified during RED phase. **→ SC-3** — PASS
- [x] 25. **Z3 check post-RED (**inline**).** Run `solve check` against post-RED enforcement output contract. **→ SC-3** — PASS
- [x] 26. **GREEN phase (**clean-room**).** In `skills/git-workflow/SKILL.md`: (a) remove the "Sub-Agent Tasks for Submodule Operations" table, (b) update Sub-Agent Routing section to remove dedicated sub-agent names, (c) update cross-reference from `submodule-tag-prework` task to `pre-work.md` Step 3.5. **→ SC-2, SC-3, SC-5** — PASS
- [x] 27-34. **Item 2 commit + verify (**clean-room**).** Committed, checkpoint tagged, SC-2/3/5 verified. **→ SC-2, SC-3, SC-5** — PASS

### Item 3 — Update 8 task files to use standard dispatch language (SC-4, string)

- [x] 35-51. **Item 3 — Update 8 task files (**clean-room**).** Replace dedicated sub-agent dispatch language with standard `task(subagent_type="general")` in all 8 task files. Preserve inline schemas. **→ SC-4** — PASS, commit 53217417

### Global post-steps

- [ ] 52. **Resolve models (**inline**).** Run `.opencode/tools/resolve-models` to select cross-family auditors. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 53. **Adversarial audit — auditor 1 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_1. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 54. **Adversarial audit — auditor 2 (**clean-room**).** Dispatch `adversarial-audit --task verification-audit` with auditor_2. If non-clean-PASS: remediate and restart from resolve-models. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 55. **Cross-validate (**clean-room**).** Dispatch `adversarial-audit --task cross-validate` with both auditor artifact paths. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 56. **Regression check (**clean-room**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no regressions. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 57. **Review-prep (**clean-room**).** Dispatch `git-workflow --task review-prep` for PR readiness. **→ SC-1, SC-2, SC-3, SC-4, SC-5**
- [ ] 58. **Exec summary (**inline**).** Report completion with summary, outcome, blockers, and byline. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

> **⚠️ COMPLIANCE REQUIREMENT:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails, the orchestrator MUST NOT proceed. Diagnose the failure, remediate, re-verify, and only then advance. If remediation fails twice, report BLOCKED with both failure artifacts and HALT. Do NOT reclassify a FAIL as "close enough." Do NOT proceed past a failed step without remediation.

## Exit Criteria

- [ ] C1: All four dead JSONC files deleted from `agents/` (SC-1)
- [ ] C2: No `.jsonc` references remain in `skills/git-workflow/` (SC-2)
- [ ] C3: "Sub-Agent Tasks for Submodule Operations" table removed from `git-workflow/SKILL.md` (SC-3)
- [ ] C4: All 8 task files use standard `task(subagent_type="general")` dispatch language (SC-4)
- [ ] C5: Submodule operations listed in main routing table, not a separate sub-agent table (SC-5)
- [ ] C6: Inline `must_receive`/`must_not_receive` schemas preserved unchanged
- [ ] C7: All pipeline gates passed (coherence, RED, GREEN, VbC, audit, cross-validate, regression)
