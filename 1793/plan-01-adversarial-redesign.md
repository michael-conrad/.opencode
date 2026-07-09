# Phase 1 — adversarial-verification.md redesign

**Concern:** Redesign the canonical three-tier finding classification model in `adversarial-verification.md` to eliminate non-binary outcomes while preserving `auto-fix` for non-substantive mechanical fixes.

**Files:**
- `skills/approval-gate/enforcement/adversarial-verification.md`

**SCs:** SC-1

**Dependencies:** #1792 must be completed first (surgical removal of `flag-for-review` from audit tasks)

**Entry conditions:** #1792 PR merged, feature branch `feature/1793-three-tier-classification` exists

**Exit conditions:** `adversarial-verification.md` redesigned with binary classification model, no tier implies "defects are acceptable"

---

- [ ] 1. (**sub-agent**) Read `skills/approval-gate/enforcement/adversarial-verification.md` to understand current three-tier model structure
  - **RED:** Read the file, document all three-tier references
  - **GREEN:** File read and references catalogued
  - **VbC:** Verify all three-tier references are catalogued

- [ ] 2. (**sub-agent**) Redesign the three-tier model to binary classification:
  - Replace `conditional` and `flag-for-review` tiers with binary PASS/FAIL
  - Preserve `auto-fix` tier for non-substantive mechanical fixes (formatting, typos)
  - Ensure no tier implies "defects are acceptable"
  - Update all finding type tables and classification references
  - **RED:** Write the redesigned file content
  - **GREEN:** File content written
  - **VbC:** Verify SC-1: no tier implies "defects are acceptable"

- [ ] 3. (**sub-agent**) Audit fidelity — verify redesigned file matches spec SC-1
  - **RED:** Run audit-fidelity against spec SC-1
  - **GREEN:** Audit passes with all_criteria_pass == true
  - **VbC:** Verify audit output

- [ ] 4. (**inline**) Z3 check — verify Phase 1 output satisfies SC-1 per contract
  - **RED:** Run solve check
  - **GREEN:** SAT and SOLVED status
  - **VbC:** Verify solve output

---

**Phase 1 completion:** All SC-1 criteria verified PASS. Proceed to Phase 2.

**Concern transition to Phase 2:** Phase 1 redesigned the canonical definition. Phase 2 migrates all ~30+ task files that reference the three-tier model to use the new binary classification.
