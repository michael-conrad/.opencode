---
phase: 1
name: adversarial-verification.md redesign
concern: Redesign canonical three-tier model to binary PASS/FAIL, preserving auto-fix for non-substantive fixes
scs: SC-1
dependencies: "#1792 must be completed first"
entry_condition: "#1792 PR merged, feature branch feature/1793-three-tier-classification exists"
exit_condition: adversarial-verification.md redesigned with binary classification model, no tier implies "defects are acceptable"
---

# Phase 1 — adversarial-verification.md redesign

**Concern:** Redesign the canonical three-tier finding classification model in `adversarial-verification.md` to eliminate non-binary outcomes while preserving `auto-fix` for non-substantive mechanical fixes.

**Files:**
- `skills/approval-gate/enforcement/adversarial-verification.md`

**SCs:** SC-1

**Dependencies:** #1792 must be completed first (surgical removal of `flag-for-review` from audit tasks)

**Entry conditions:** #1792 PR merged, feature branch `feature/1793-three-tier-classification` exists

**Exit conditions:** `adversarial-verification.md` redesigned with binary classification model, no tier implies "defects are acceptable"

> **Compliance requirement:** Every step is mandatory. Skipping, combining, or reordering steps produces defective deliverables. The orchestrator dispatches each step to a clean-room sub-agent via `task()`. No inline execution of sub-agent steps.
>
> **One-step-at-a-time protocol:** Execute exactly one step per dispatch. After each step, report the result before proceeding. Do not batch steps.
>
> **Self-remediation protocol:** On any FAIL signal, remediate before halting. Remediate → re-verify → proceed on PASS → HALT only on double-failure.

---

- [ ] 1. **(sub-agent) Pre-analysis — read adversarial-verification.md.** Read `skills/approval-gate/enforcement/adversarial-verification.md` to understand current three-tier model structure. Document all three-tier references (auto-fix, conditional, flag-for-review) with line numbers.
  - **RED:** Read the file, catalogue all three-tier references
  - **GREEN:** File read and references catalogued
  - **VbC:** Verify all three-tier references are catalogued

- [ ] 2. **(sub-agent) Redesign — rewrite adversarial-verification.md.** Replace `conditional` and `flag-for-review` tiers with binary PASS/FAIL. Preserve `auto-fix` tier for non-substantive mechanical fixes only (formatting, typos). Update all finding type tables and classification references. Ensure no tier implies "defects are acceptable".
  - **RED:** Write the redesigned file content
  - **GREEN:** File content written
  - **VbC:** Verify SC-1: no tier implies "defects are acceptable"

- [ ] 3. **(sub-agent) Audit fidelity.** Run audit-fidelity against spec SC-1 to verify redesigned file matches spec.
  - **RED:** Run audit-fidelity against spec SC-1
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

- [ ] 4. **(inline) Z3 check.** Verify Phase 1 output satisfies SC-1 per contract. Run solve check.
  - **RED:** Run solve check
  - **GREEN:** SAT and SOLVED status
  - **VbC:** Verify solve output

---

**Phase 1 completion:** All SC-1 criteria verified PASS. Proceed to Phase 2.

**Concern transition to Phase 2:** Phase 1 redesigned the canonical definition. Phase 2 migrates all ~45+ task files that reference the three-tier model to use the new binary classification.
