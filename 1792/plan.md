# Implementation Plan — [#1792](https://github.com/michael-conrad/.opencode/issues/1792) — Audit tasks produce PASS+hedging verdicts — no self-consistency gate prevents "minor defects are acceptable" persona

**Spec: #1792** — [SPEC-FIX](https://github.com/michael-conrad/.opencode/issues/1792)

**Goal:** Add self-consistency gates to 10 audit task files, remove non-binary classifications from 6 files, remove severity-based exceptions from 2 files, and add behavioral enforcement tests.

**Architecture:** All changes are within `.opencode/skills/audit/tasks/`. Three concern groups: (A) self-consistency gate addition, (B) non-binary classification removal, (C) severity exception removal. Behavioral tests verify SC-6 and SC-7.

**Files:**
- `.opencode/skills/audit/tasks/spec-audit.md` — self-consistency gate + Bidirectional Findings fix + WARNING→ERROR reclassification
- `.opencode/skills/audit/tasks/verification-audit.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/concern-separation.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/plan-fidelity.md` — self-consistency gate + flag-for-review removal
- `.opencode/skills/audit/tasks/closure-verification.md` — self-consistency gate
- `.opencode/skills/audit/tasks/content-audit.md` — self-consistency gate
- `.opencode/skills/audit/tasks/guideline-audit.md` — self-consistency gate
- `.opencode/skills/audit/tasks/coherence-maintenance.md` — self-consistency gate
- `.opencode/skills/audit/tasks/drift-detection.md` — self-consistency gate
- `.opencode/skills/audit/tasks/resolve-models.md` — self-consistency gate
- `.opencode/skills/audit/tasks/test-quality-audit.md` — remove FAIL (inconclusive)
- `.opencode/skills/audit/tasks/spec-summary.md` — remove cosmetic severity
- `.opencode/skills/audit/tasks/cross-validate.md` — remove severity-based exception
- `.opencode/tests/behaviors/` — behavioral tests for SC-6, SC-7

> **Compliance requirement:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables that must be discarded. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. No inline execution of sub-agent steps.

> **One-step-at-a-time protocol:** Execute exactly one step per dispatch. After each step, report the result before proceeding to the next step. Do not batch steps. Do not preload context for future steps. Each sub-agent receives only the context it needs for its single step.

> **Step Status:** Mark each step `[x]` when complete. Do not mark steps complete before they are executed. A step is complete only when its sub-agent returns DONE and the orchestrator has verified the result.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|-------------|------------|
| 1 | Audit Task Hardening | Add self-consistency gates, remove non-binary classifications, remove severity exceptions, add behavioral tests | SC-1 through SC-17 | None | 1–28 |

> **Compliance requirement:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables that must be discarded. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. No inline execution of sub-agent steps.

> **Self-remediation protocol:** On any FAIL signal at any pipeline stage, the orchestrator MUST remediate before halting. Remediate → re-verify → proceed on PASS → HALT only on double-failure. See `000-critical-rules.md` §critical-rules-hard-fail.

## Phase 1 — Audit Task Hardening

**Concern:** Add self-consistency gates to audit task verdict YAML, remove non-binary classifications (flag-for-review, FAIL (inconclusive), cosmetic), remove severity-based exceptions, and add behavioral enforcement tests.

**Files:** 13 audit task files + behavioral test files

**SCs:** SC-1 through SC-17

**Dependencies:** None

**Entry condition:** Feature branch created, spec approved

**Exit condition:** All 17 SCs verified PASS, behavioral tests pass, plan committed

### Global Pre-Phase

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec-to-codebase coherence: confirm all 13 affected files exist, confirm all patterns to be changed are present, confirm no conflicting open issues. **→ SC-1 through SC-17**

- [ ] 2. **Pre-RED baseline (**inline**).** Run existing behavioral tests to establish baseline. `bash .opencode/tests/test-enforcement.sh --tag audit` — expected: existing tests pass, new behavioral tests for SC-6/SC-7 do not exist yet.

### Concern Group A: Self-Consistency Gate (9 files)

- [ ] 3. **RED — Behavioral test SC-6 (**sub-agent**).** Write behavioral enforcement test for SC-6: spec-audit sub-agent returns FAIL (not PASS with caveats) when its own explanation contains hedging language. Test must FAIL (RED) because the self-consistency gate does not exist yet. **→ SC-6**

- [ ] 4. **RED — Behavioral test SC-7 (**sub-agent**).** Write behavioral enforcement test for SC-7: concern-separation sub-agent returns FAIL (not flag-for-review) for a finding that is not clean PASS. Test must FAIL (RED) because flag-for-review still exists. **→ SC-7**

- [ ] 5. **GREEN — spec-audit.md self-consistency gate (**sub-agent**).** Add self-consistency gate to spec-audit.md verdict YAML: if `result: "PASS"` and `explanation` contains critique/hedging language, downgrade to FAIL. Also fix Bidirectional Findings table to generate findings ONLY for FAIL criteria. **→ SC-1, SC-3**

- [ ] 6. **GREEN — verification-audit.md self-consistency gate (**sub-agent**).** Add self-consistency gate to verification-audit.md verdict YAML. **→ SC-2**

- [ ] 7. **GREEN — concern-separation.md self-consistency gate + flag-for-review removal (**sub-agent**).** Add self-consistency gate and remove `flag-for-review` classification. All finding types are either PASS or FAIL. **→ SC-4**

- [ ] 8. **GREEN — plan-fidelity.md self-consistency gate + flag-for-review removal (**sub-agent**).** Add self-consistency gate and remove `flag-for-review` classification. All finding types are either PASS or FAIL. **→ SC-5**

- [ ] 9. **GREEN — closure-verification.md self-consistency gate (**sub-agent**).** Add self-consistency gate to closure-verification.md verdict YAML. **→ SC-11**

- [ ] 10. **GREEN — content-audit.md self-consistency gate (**sub-agent**).** Add self-consistency gate to content-audit.md verdict YAML. **→ SC-12**

- [ ] 11. **GREEN — guideline-audit.md self-consistency gate (**sub-agent**).** Add self-consistency gate to guideline-audit.md verdict YAML. **→ SC-13**

- [ ] 12. **GREEN — coherence-maintenance.md self-consistency gate (**sub-agent**).** Add self-consistency gate to coherence-maintenance.md verdict YAML. **→ SC-14**

- [ ] 13. **GREEN — drift-detection.md self-consistency gate (**sub-agent**).** Add self-consistency gate to drift-detection.md verdict YAML. **→ SC-15**

- [ ] 14. **GREEN — resolve-models.md self-consistency gate (**sub-agent**).** Add self-consistency gate to resolve-models.md verdict YAML. **→ SC-16**

### Concern Group B: Non-Binary Classification Removal (2 remaining files)

- [ ] 15. **GREEN — test-quality-audit.md FAIL (inconclusive) removal (**sub-agent**).** Remove `FAIL (inconclusive)` verdict. Only PASS and FAIL are valid verdicts. **→ SC-8**

- [ ] 16. **GREEN — spec-summary.md cosmetic severity removal (**sub-agent**).** Remove `cosmetic` severity classification. All findings are PASS or FAIL. **→ SC-9**

### Concern Group C: Severity Exception Removal (2 files)

- [ ] 17. **GREEN — cross-validate.md severity exception removal (**sub-agent**).** Remove severity-based exception at line 273. All FAILs cascade to overall_verdict = FAIL. WARNING is a FAIL condition. **→ SC-10**

- [ ] 18. **GREEN — spec-audit.md WARNING→ERROR reclassification (**sub-agent**).** Remove WARNING/ERROR severity distinction from SC-SEM criteria table. All SC-SEM criteria are ERROR. Remove `severity` field from per_criterion YAML format. **→ SC-17**

### Global Post-Phase

- [ ] 19. **GREEN doublecheck — Behavioral test SC-6 (**sub-agent**).** Re-run behavioral test for SC-6. Test must PASS (GREEN) because the self-consistency gate now exists. **→ SC-6**

- [ ] 20. **GREEN doublecheck — Behavioral test SC-7 (**sub-agent**).** Re-run behavioral test for SC-7. Test must PASS (GREEN) because flag-for-review has been removed. **→ SC-7**

- [ ] 21. **String SC verification (**sub-agent**).** Verify all string SCs (SC-1 through SC-5, SC-8 through SC-17) via grep/pattern matching against the modified files. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17**

- [ ] 22. **Audit — spec-audit (**sub-agent**).** Run spec-audit on the modified spec to verify all SCs are satisfied. **→ SC-1 through SC-17**

- [ ] 23. **Audit — cross-validate (**sub-agent**).** Cross-validate audit results for consensus. **→ SC-1 through SC-17**

- [ ] 24. **Regression check (**sub-agent**).** Run existing audit behavioral tests to verify no regressions. `bash .opencode/tests/test-enforcement.sh --tag audit` **→ SC-1 through SC-17**

- [ ] 25. **Review-prep (**sub-agent**).** Run finishing checklist: verify all changes committed, branch clean, compare URL generated. **→ SC-1 through SC-17**

- [ ] 26. **Checkpoint commit (**inline**).** Commit all changes with message: `fix(audit): add self-consistency gates, remove non-binary classifications (#1792)`

- [ ] 27. **Collect behavioral evidence (**inline**).** Collect behavioral evidence artifacts from `{project_root}/tmp/behavioral-evidence-*/` into `{project_root}/tmp/1792/artifacts/`.

- [ ] 28. **Exec summary (**inline**).** Report completion: summary of changes, SC verification status, behavioral test results.

#### Phase 1 VbC

- [ ] 29. **VbC (**clean-room**).** Verify all 17 SCs pass: SC-1 through SC-5, SC-8 through SC-17 via string evidence (grep), SC-6 and SC-7 via behavioral evidence (test execution). **→ SC-1 through SC-17**

## Exit Criteria

- [ ] C1. All 17 SCs verified PASS
- [ ] C2. Behavioral tests for SC-6 and SC-7 pass
- [ ] C3. All 13 audit task files modified correctly
- [ ] C4. No regressions in existing audit behavioral tests
- [ ] C5. All changes committed to feature branch
- [ ] C6. Plan committed to `.opencode/.issues/1792/plan.md`
