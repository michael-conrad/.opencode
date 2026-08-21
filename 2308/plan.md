---
plan_schema_version: "1.0"
issue: 2308
title: "Replace residual 'dev' trunk references in git-workflow-cleanup cleanup.md"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 1
    skill: verification-before-completion
    task: verify
  - phase: 1
    skill: audit
    task: verification-audit
  - phase: 1
    skill: finishing-a-development-branch
    task: checklist
  - phase: 1
    skill: verification-before-completion
    task: verify
  - phase: 1
    skill: git-workflow-pr
    task: create
---

# Implementation Plan — #2308 — Replace Residual 'dev' Trunk References

**Goal:** Replace the 5 residual hardcoded `dev` trunk/tip references in `skills/git-workflow-cleanup/tasks/cleanup.md` with dynamic `$DEFAULT_BRANCH` resolution or neutral terminology, so the cleanup workflow no longer references a trunk branch that no longer exists.

**Architecture:** Single-phase, single-item documentation/task-card terminology change confined to one task card. The existing `$DEFAULT_BRANCH` resolution block (lines 9-12) is left untouched. Executable commands are not altered — only prose and label references change. This matches the pattern already established in `branch-cleanup.md` and `verify-merge.md`.

**Files:**
- `skills/git-workflow-cleanup/tasks/cleanup.md`

---

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `coherence-extraction` from audit to verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline to verify trunk tip, clean state, and submodule currency. (**sub-agent**)
  - Context: `{issue_number: 2308}`

## Phase 1 — Replace residual 'dev' trunk references with $DEFAULT_BRANCH (SC-1)

Concern: Eliminate all 5 residual hardcoded `dev` trunk/tip references in `cleanup.md`, replacing them with `$DEFAULT_BRANCH` or neutral terminology, without altering executable commands or the `$DEFAULT_BRANCH` resolution block.

### Item 1 — Replace the 5 residual 'dev' references (SC-1)

- [ ] **RED phase** — write a failing test that verifies the grep pattern `origin/dev|local dev|at dev|to dev|dev tip|dev HEAD|dev synced` against `skills/git-workflow-cleanup/tasks/cleanup.md` returns matches (the residual `dev` references still exist). (**clean-room**)
  - Context: `{issue_number: 2308}`, `{sc: SC-1}`
  - Evidence type: `structural` — grep for residual `dev` references
  - The RED test MUST fail because the 5 residual references (lines 109, 141, 146, 180, 327) are still present.
- [ ] **RED doublecheck** — dispatch `verify` from verification-before-completion to confirm the RED test fails as expected (matches found). (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **GREEN phase** — replace the 5 residual references in `skills/git-workflow-cleanup/tasks/cleanup.md`:
  - Line 109: "Switches to dev" → "Switches to $DEFAULT_BRANCH"
  - Line 141: "Get local dev HEAD:" → "Get local $DEFAULT_BRANCH HEAD:"
  - Line 146: "Get remote dev HEAD:" → "Get remote $DEFAULT_BRANCH HEAD:"
  - Line 180: "ready for next dev cycle" → "ready for next cycle"
  - Line 327: "Local dev synced" → "Local $DEFAULT_BRANCH synced"
  - Do NOT alter any executable command. Do NOT modify the `$DEFAULT_BRANCH` resolution block (lines 9-12). No scope creep. (**clean-room**)
  - Context: `{issue_number: 2308}`, `{sc: SC-1}`
- [ ] **Post-regression** — run the regression test patterns to confirm no other `cleanup.md` behavior changed. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Verify** — dispatch `verify` from verification-before-completion to confirm the grep pattern `origin/dev|local dev|at dev|to dev|dev tip|dev HEAD|dev synced` returns zero matches against `cleanup.md`. (**sub-agent**)
  - Context: `{issue_number: 2308}`, `{sc: SC-1}`
  - Evidence type: `structural` — grep returns zero matches
- [ ] **Checkpoint commit** — stage `skills/git-workflow-cleanup/tasks/cleanup.md` and commit the test + change as a single atomic slice. (**inline**)
  - Commit message references issue #2308

#### Phase 1 VbC

- [ ] **VbC** — dispatch `verify` from verification-before-completion to re-confirm SC-1: zero residual `dev` references, executable commands unchanged, `$DEFAULT_BRANCH` resolution block intact. (**clean-room**)
  - Context: `{issue_number: 2308}`, `{sc: SC-1}`

**Concern transition:** Leaving the residual-`dev`-reference replacement → entering post-implementation gates. This is a single-phase plan; no further phases depend on Phase 1.

---

## Post-Implementation

- [ ] **Structural checks** — dispatch `checklist` from finishing-a-development-branch to run lint/typecheck/format checks. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Verification before completion** — dispatch `completion` from verification-before-completion to verify all SCs are satisfied. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Pre-PR gate** — dispatch `verify` from verification-before-completion to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Audit** — dispatch `verification-audit DiMo investigator` from audit (followed by validator, evaluator, arbiter in sequence) with `{spec_local_dir, artifact_evidence_dir}`. If non-clean-pass, remediate and restart. On clean PASS, collect artifact path for cross-validate. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Cross-validate** — dispatch `cross-validate` from audit to produce consensus findings. (**clean-room**)
  - Context: `{issue_number: 2308}`
- [ ] **Regression check** — dispatch `phase-4` from test-driven-development to run final regression test patterns. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Review prep** — dispatch `review-prep` from git-workflow to prepare PR review context. (**sub-agent**)
  - Context: `{issue_number: 2308}`
- [ ] **Create PR** — dispatch `create` from git-workflow-pr to create the pull request. (**sub-agent**)
  - Context: `{issue_number: 2308}`, `{authorization_scope}`, `{halt_at}`
- [ ] **Completion** — dispatch `completion` from completion-core to report executive summary. (**sub-agent**)
  - Context: `{issue_number: 2308}`

## Exit Criteria

| SC | Phase | Criterion | Evidence Type |
|----|-------|-----------|---------------|
| SC-1 | 1 | `cleanup.md` contains zero residual hardcoded `dev` trunk/tip references; all 5 replaced with `$DEFAULT_BRANCH` or neutral terminology | `structural` |
