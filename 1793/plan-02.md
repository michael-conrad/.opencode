---
phase: 2
name: Task file migration
concern: Migrate all ~45+ task files referencing three-tier model to binary classification
scs: SC-2, SC-3
dependencies: Phase 1 complete
entry_condition: Phase 1 exit criteria met, adversarial-verification.md redesigned with binary model
exit_condition: All ~45+ task files migrated to binary classification, 000-critical-rules.md:422 updated
---

# Phase 2 — Task file migration (~45+ files)

**Concern:** Migrate all task files that reference the three-tier classification model (`auto-fix`/`conditional`/`flag-for-review`) to the new binary model. Replace `conditional` and `flag-for-review` with binary PASS/FAIL. Preserve `auto-fix` only for non-substantive mechanical fixes.

**Files:**
- `skills/audit/tasks/spec-audit.md`
- `skills/audit/tasks/verification-audit.md`
- `skills/audit/tasks/concern-separation.md`
- `skills/audit/tasks/plan-fidelity.md`
- `skills/audit/tasks/test-quality-audit.md`
- `skills/audit/tasks/spec-summary.md`
- `skills/audit/tasks/closure-verification.md`
- `skills/audit/tasks/content-audit.md`
- `skills/audit/tasks/guideline-audit.md`
- `skills/audit/tasks/coherence-maintenance.md`
- `skills/audit/tasks/drift-detection.md`
- `skills/audit/tasks/cross-validate.md`
- `skills/audit/tasks/resolve-models.md`
- `skills/verification-before-completion/tasks/verify.md`
- `skills/verification-before-completion/tasks/collect.md`
- `skills/verification-before-completion/tasks/completion.md`
- `skills/finishing-a-development-branch/tasks/checklist.md`
- `skills/finishing-a-development-branch/tasks/prepare.md`
- `skills/finishing-a-development-branch/tasks/completion.md`
- `skills/brainstorming/tasks/explore/pre-spec-inspection.md`
- `skills/brainstorming/tasks/enforcement.md`
- `skills/issue-operations/tasks/post-creation.md`
- `skills/issue-operations/tasks/completion.md`
- `skills/issue-operations/tasks/single-task-check.md`
- `skills/issue-operations/tasks/body-edit.md`
- `skills/issue-operations/tasks/verify-merge.md`
- `skills/issue-operations/tasks/capabilities.md`
- `skills/issue-operations/tasks/close.md`
- `skills/issue-operations/tasks/creation.md`
- `skills/issue-operations/tasks/pre-creation.md`
- `skills/issue-operations/tasks/link-sub-issue.md`
- `skills/systematic-debugging/tasks/diagnose.md`
- `skills/systematic-debugging/tasks/fix.md`
- `skills/engineering-approach/tasks/verify-understanding.md`
- `skills/skill-creator/tasks/validate.md`
- `skills/writing-plans/tasks/clean-room.md`
- `skills/writing-plans/tasks/validate.md`
- `skills/spec-creation/tasks/create.md`
- `skills/spec-creation/tasks/traceability.md`
- `skills/spec-creation/tasks/change-control.md`
- `skills/issue-review/tasks/audit.md`
- `skills/issue-review/tasks/gather.md`
- `skills/issue-review/tasks/triage.md`
- `skills/issue-review/tasks/qa.md`
- `guidelines/000-critical-rules.md` (line 422)

**SCs:** SC-2, SC-3

**Dependencies:** Phase 1 complete (adversarial-verification.md redesigned)

**Entry conditions:** Phase 1 exit criteria met, `adversarial-verification.md` redesigned with binary model

**Exit conditions:** All ~45+ task files migrated to binary classification, `000-critical-rules.md:422` updated

> **Compliance requirement:** Every step is mandatory. Skipping, combining, or reordering steps produces defective deliverables. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. No inline execution of sub-agent steps.
>
> **One-step-at-a-time protocol:** Execute exactly one step per dispatch. After each step, report the result before proceeding. Do not batch steps.
>
> **Self-remediation protocol:** On any FAIL signal, remediate before halting. Remediate → re-verify → proceed on PASS → HALT only on double-failure.

---

- [ ] 5. **(sub-agent) Pre-analysis — discover all affected task files.** Run grep across all skill task files for `auto-fix`, `conditional`, and `flag-for-review` patterns in finding classification tables. Produce a complete list of affected files with line numbers.
  - **RED:** Run grep for the three-tier patterns
  - **GREEN:** Complete list of affected files with line numbers catalogued
  - **VbC:** Verify grep output matches expected file list

- [ ] 6. **(sub-agent) Migrate audit task files.** Replace `conditional` and `flag-for-review` classifications with binary PASS/FAIL in all 13 audit task files. Preserve `auto-fix` for non-substantive mechanical fixes only.
  - Files: `spec-audit.md`, `verification-audit.md`, `concern-separation.md`, `plan-fidelity.md`, `test-quality-audit.md`, `spec-summary.md`, `closure-verification.md`, `content-audit.md`, `guideline-audit.md`, `coherence-maintenance.md`, `drift-detection.md`, `cross-validate.md`, `resolve-models.md`
  - **RED:** Write migration changes to each file
  - **GREEN:** All audit task files updated
  - **VbC:** Verify SC-2: no `conditional` or `flag-for-review` remains in audit task files

- [ ] 7. **(sub-agent) Migrate non-audit task files.** Replace `conditional` and `flag-for-review` with binary PASS/FAIL in all non-audit task files. Preserve `auto-fix` for non-substantive mechanical fixes only.
  - Files: `verification-before-completion/tasks/verify.md`, `collect.md`, `completion.md`; `finishing-a-development-branch/tasks/checklist.md`, `prepare.md`, `completion.md`; `brainstorming/tasks/explore/pre-spec-inspection.md`, `enforcement.md`; `issue-operations/tasks/post-creation.md`, `completion.md`, `single-task-check.md`, `body-edit.md`, `verify-merge.md`, `capabilities.md`, `close.md`, `creation.md`, `pre-creation.md`, `link-sub-issue.md`; `systematic-debugging/tasks/diagnose.md`, `fix.md`; `engineering-approach/tasks/verify-understanding.md`; `skill-creator/tasks/validate.md`; `writing-plans/tasks/clean-room.md`, `validate.md`; `spec-creation/tasks/create.md`, `traceability.md`, `change-control.md`; `issue-review/tasks/audit.md`, `gather.md`, `triage.md`, `qa.md`
  - **RED:** Write migration changes to each file
  - **GREEN:** All non-audit task files updated
  - **VbC:** Verify SC-2: no `conditional` or `flag-for-review` remains in non-audit task files

- [ ] 8. **(sub-agent) Update guidelines/000-critical-rules.md:422.** Replace stale reference to `auto-fix/conditional/flag-for-review classification` with updated binary classification language.
  - **RED:** Read line 422 context, draft updated text
  - **GREEN:** Line 422 updated
  - **VbC:** Verify SC-3: stale reference replaced

- [ ] 9. **(inline) Z3 check.** Verify Phase 2 output satisfies SC-2 and SC-3 per contract. Run solve check.
  - **RED:** Run solve check
  - **GREEN:** SAT and SOLVED status
  - **VbC:** Verify solve output

---

**Phase 2 completion:** All SC-2 and SC-3 criteria verified PASS. All ~45+ task files migrated. Proceed to Phase 3.

**Concern transition to Phase 3:** Phase 2 migrated all task files. Phase 3 adds behavioral tests to verify the binary classification is enforced at runtime, and updates the guideline reference.
