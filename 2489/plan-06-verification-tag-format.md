# Phase 6 — Integrity Verification + Tag-Format Correction (includes Post-Implementation)

**Concern:** Close the repair loop (the reference-integrity check passes on the repaired repo), correct the six tag-format sites to the suffixed form, then run all post-implementation gates through PR creation.

**Files:**
- `.opencode/tools/` (reference-integrity check — execution only)
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (tag-format sites 1, 2, 5, 6)
- `.opencode/skills/git-workflow-branch/tasks/provenance.md` (tag-format sites 3, 4)

**SCs:** SC-13, SC-11

**Dependencies:** Phase 5 (SC-8/SC-9/SC-10 → SC-13), Phase 4 (SC-12)

**Entry Conditions:**
- Phase 5 complete: all 15 repairs in place, SC-7 through SC-10 PASS
- Phase 5 VbC passed

**Exit Conditions:**
- The reference-integrity check passes on the repaired repository
- All six Tag-Format Site Inventory sites carry the suffixed `<parent-repo>/<issue-number>-<submodule>` form
- All post-implementation gates pass; PR created (for_pr scope boundary)

**Code Path Coverage:** Path 2 (pre-work — format fix at tag step, commit-message template, Step 5 rebase/checkout commands); agent-facing text only.

**Cross-Cutting SCs:** agent-facing text (format strings); behavioral evidence for SC-13 (check execution, not grep).

**Interface Boundaries:** Tag naming convention unchanged — the suffixed form is already canonical (#950, 191 existing tags); no contract fields change; `trunk-push-provenance.md` trunk-push tagging step is explicitly excluded (already suffixed).

**State Transitions:** tag-format documentation — before: six phrase-anchored sites document/reference the unsuffixed form; after: all six carry or consistently reference the suffixed form, keeping the pre-work Step 3→4→5 command chain coherent.

**Cost frame:** Verifying the format grep costs seconds — format rot is caught before the next tag is created unsuffixed. Skipping costs the next pre-work tag being created in a format that matches zero of 191 existing tags, discovered at tag lookup time.

---

- [ ] 53. **RED (**task-card**).** SC-13 RED: run the reference-integrity check against the current (pre-Phase-5) repository state snapshot or reasoning record showing it reports failure on the known-broken references — recorded as the RED baseline evidence. **→ SC-13**
- [ ] 54. **GREEN (**task-card**).** No code change. With Items 8-10 repairs in place, re-run the check against the repaired repository — it passes. **→ SC-13**
- [ ] 55. **Verify (**task-card**).** Verify SC-13: run the check against the repaired repo; inspect the exit code (zero) — behavioral evidence. No additional commit (verification-only item against Item 12's implementation). **→ SC-13**
- [ ] 56. **RED (**task-card**).** Format RED: grep each of the six Tag-Format Site Inventory sites (located by phrase anchor, never line number) for the unsuffixed `<parent-repo>/<issue-number>` pattern — all six return matches. **→ SC-11**
- [ ] 57. **GREEN (**task-card**).** Append the `-<submodule>` suffix at the 4 primary-defect sites (pre-work.md Step 3 item 5 tag line and Step 4 commit-message template; provenance.md "Tag-based provenance (Tier 3)" paragraph and tier-table Pre-work row) and update the 2 consequential same-cluster sites (pre-work.md Step 5 rebase/checkout command lines) to reference the suffixed tag form per the canonical rule. Do NOT touch the trunk-push-provenance.md trunk-push tagging step (already suffixed). Re-run the grep: zero unsuffixed matches at all six sites. **→ SC-11**
- [ ] 58. **COMMIT (**direct**).** `git add` the format-corrected files; commit (message: correct tag-format sites to suffixed form). **→ SC-11**
- [ ] 59. **Verify + VbC (**task-card**).** Verify SC-11: grep each inventory site by phrase anchor for the unsuffixed pattern — zero matches at all six sites. Verify SC-13 and SC-11 verdicts are PASS with evidence artifacts on disk. **→ SC-11, SC-13**
- [ ] 60. **Audit (**task-card**).** Dispatch the adversarial audit: execute verification-audit DiMo investigator from audit (read `audit/tasks/verification-audit-investigator.md` first), followed by validator, evaluator, arbiter in sequence. **→ all SCs**
- [ ] 61. **Z3 check (**direct**).** Orchestrator runs `.opencode/tools/solve check` with the dependency contract (`.opencode/.issues/2489/dependency-contract.yaml`) and the recorded SC state — all preconditions and the postcondition conjunction must be satisfiable. **→ all SCs**
- [ ] 62. **Structural checks (**task-card**).** Dispatch the finishing checklist from finishing-a-development-branch (lint, typecheck, branch readiness). **→ all SCs**
- [ ] 63. **Pre-PR gate (**task-card**).** Dispatch verification-before-completion verify task reading all SC verdicts — BLOCKs if any FAIL (DONE_WITH_CONCERNS coerces to FAIL; EVIDENCE_TYPE_MISMATCH is a hard FAIL). **→ all SCs**
- [ ] 64. **Regression check (**task-card**).** Dispatch test-driven-development phase-4 task for the final regression check before PR. **→ all SCs**
- [ ] 65. **Review-prep (**task-card**).** Dispatch review-prep from git-workflow-pr (read `git-workflow-pr/tasks/review-prep.md` first). **→ all SCs**
- [ ] 66. **Create PR (**task-card**).** Dispatch create from git-workflow-pr — stacked PR targeting the trunk (for_pr scope; PR strategy stacked; one branch, N commits, one PR). HALT after PR creation — human-only merge. **→ all SCs**
- [ ] 67. **Exec summary (**task-card**).** Dispatch completion task from completion-core — generate the completion executive summary. **→ all SCs**

#### Phase 6 Completion Block

- [ ] SC-13 verdict recorded with behavioral evidence (check exit code zero on repaired repo)
- [ ] SC-11 verdict recorded with string evidence (per-site phrase-anchored grep outputs)
- [ ] Audit consensus verdict recorded; Z3 check satisfied; structural checks pass
- [ ] Pre-PR gate PASS on all 13 SC verdicts; regression check green
- [ ] PR created (stacked); completion summary emitted; HALT at the pr_created scope boundary

**Concern transition:** Plan complete. All 13 SCs and both coordination mandates verified; PR created; scope boundary reached (for_pr → halt after pr_created).
