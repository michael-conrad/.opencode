# Implementation Plan — [#1793](https://github.com/michael-conrad/.opencode/issues/1793) — Three-tier finding classification migration

**Goal:** Redesign or remove the three-tier finding classification model (`auto-fix`/`conditional`/`flag-for-review`) from `adversarial-verification.md`, migrate all ~30+ task files to the new binary model, update stale guideline reference, and add behavioral tests.

**Architecture:** The three-tier model is defined canonically in `skills/approval-gate/enforcement/adversarial-verification.md` and referenced by ~30+ task files across audit, VbC, finishing-a-development-branch, brainstorming, issue-operations, systematic-debugging, and engineering-approach skills. The migration replaces non-binary tiers (`conditional`, `flag-for-review`) with binary PASS/FAIL, preserving `auto-fix` only for non-substantive mechanical fixes.

**Files:**
- `skills/approval-gate/enforcement/adversarial-verification.md` — Canonical definition
- All audit task files (spec-audit, verification-audit, concern-separation, plan-fidelity, test-quality-audit, spec-summary, closure-verification, content-audit, guideline-audit, coherence-maintenance, drift-detection, cross-validate, resolve-models)
- `skills/verification-before-completion/tasks/verify.md`
- `skills/verification-before-completion/tasks/completion.md`
- `skills/finishing-a-development-branch/tasks/checklist.md`
- `skills/finishing-a-development-branch/tasks/prepare.md`
- `skills/brainstorming/tasks/explore/pre-spec-inspection.md`
- `skills/brainstorming/tasks/enforcement.md`
- `skills/issue-operations/tasks/post-creation.md`
- `skills/issue-operations/tasks/completion.md`
- `skills/issue-operations/tasks/single-task-check.md`
- `skills/issue-operations/tasks/close.md`
- `skills/issue-operations/tasks/verify-merge.md`
- `skills/issue-operations/tasks/pre-creation.md`
- `skills/issue-operations/tasks/link-sub-issue.md`
- `skills/issue-operations/tasks/body-edit.md`
- `skills/systematic-debugging/tasks/diagnose.md`
- `skills/systematic-debugging/tasks/fix.md`
- `skills/engineering-approach/tasks/verify-understanding.md`
- `skills/skill-creator/tasks/validate.md`
- `guidelines/000-critical-rules.md` (line 422)

> **Compliance requirement:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces a defective deliverable. The implementation-pipeline SKILL.md Trigger Dispatch Table steps are mandatory — no exceptions. "Continue" does not waive this requirement.

> **One-step-at-a-time protocol:** Execute steps sequentially. Do NOT skip ahead. Do NOT batch steps. Each step produces a discrete artifact. Each RED phase must fail before GREEN makes it pass.

> **Step status:** After each step, update the step checkbox with `✅` (pass) or `❌` (fail). If fail, remediate before proceeding.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | adversarial-verification.md redesign | Redesign canonical three-tier model to binary PASS/FAIL, preserving auto-fix for non-substantive fixes | SC-1 | #1792 (must be completed first) | 1-4 |
| 2 | Task file migration | Migrate all ~45+ task files referencing three-tier model to binary classification | SC-2, SC-3 | Phase 1 | 5-9 |
| 3 | Behavioral tests + guidelines update | Add behavioral tests for SC-4 and SC-5, verify guideline reference update | SC-4, SC-5 | Phase 2 | 10-16 |

> **Compliance requirement:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces a defective deliverable. The implementation-pipeline SKILL.md Trigger Dispatch Table steps are mandatory — no exceptions. "Continue" does not waive this requirement.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run. Do NOT skip failed steps. Do NOT mark a step as complete without verification evidence.

## Exit Criteria

- [ ] C1: `adversarial-verification.md` three-tier model redesigned — no tier implies "defects are acceptable"
- [ ] C2: All ~30+ task files migrated to binary classification
- [ ] C3: `guidelines/000-critical-rules.md:422` updated
- [ ] C4: Behavioral test verifies audit sub-agent produces only binary PASS/FAIL (no `flag-for-review`)
- [ ] C5: Behavioral test verifies VbC sub-agent produces only binary PASS/FAIL (no `conditional`)
- [ ] C6: All implementation-pipeline gate steps enumerated in phase structure
- [ ] C7: Step numbering is globally sequential across all phases
