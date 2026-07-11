# Plan: Fix plan-fidelity auditor hard-coded evaluation criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do NOT batch steps, skip ahead, or combine operations. Each step is an atomic unit — complete it fully before moving to the next.

## Issue

[SPEC-FIX] Plan-fidelity auditor hard-codes evaluation criteria instead of reading from authoritative skill cards (#1436)

## Goal

Replace hard-coded expected values in `audit/tasks/plan-fidelity.md` evaluation criteria with dynamic references to authoritative skill cards, and add a general principle requiring dynamic references.

## Architecture

Single-file edit to `.opencode/skills/audit/tasks/plan-fidelity.md`. No structural changes — only text replacements in the evaluation criteria table and addition of a general principle paragraph.

## Files

| File | Action | Purpose |
|------|--------|---------|
| `.opencode/skills/audit/tasks/plan-fidelity.md` | Edit | Update evaluation criteria expected results and add general principle |

## Phase Table

| Phase | Concern | Files | SCs | Dependencies |
|-------|---------|-------|-----|--------------|
| 1 | Fix hard-coded criteria in plan-fidelity evaluation table | `.opencode/skills/audit/tasks/plan-fidelity.md` | SC-1, SC-2, SC-3, SC-4, SC-5 | None |

## Phase 1 — Fix hard-coded criteria in plan-fidelity evaluation table

### Concern

The evaluation criteria table in `audit/tasks/plan-fidelity.md` embeds concrete expected values (e.g., `(**clean-room**) or (**inline**)`, `P1_I1_G1`) instead of referencing authoritative skill cards. This causes false FAIL verdicts when authoritative sources change.

### Files

- `.opencode/skills/audit/tasks/plan-fidelity.md`

### Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | PF-DISPATCH-MODE expected result changed from hard-coded `(**clean-room**) or (**inline**)` to dynamic reference: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators" | `string` |
| SC-2 | PF-Z3-CONTRACT expected result: `P1_I1_G1` format removed and replaced with reference to `solve/tasks/contract.md` §Contract YAML Structure — typed variables (`type`, `domain`, `nullable`) with Z3 expression constraints | `string` |
| SC-3 | A general principle added to the evaluation criteria section stating criteria expected values MUST reference authoritative skill cards, not hard-code values | `string` |
| SC-4 | All other criteria in the evaluation criteria table reviewed for hard-coded concrete values in the Expected Result column that are not sourced from an authoritative skill card; any found are flagged for follow-up | `string` |
| SC-5 | PF-6 expected result changed from hard-coded `(**clean-room**) or (**inline**)` to same dynamic reference as PF-DISPATCH-MODE: "valid dispatch indicator per `writing-plans/tasks/write.md` §Dispatch Indicators" | `string` |

### Dependencies

None.

### Entry Conditions

- Feature branch `feature/fix-plan-fidelity-hardcoded-criteria-1436` exists
- Spec #1436 is approved (`approved-for-pr` label confirmed)

### Exit Conditions

- All 5 SCs verified PASS via grep
- Plan committed to feature branch

### Steps

- [ ] 1. **Add general principle to evaluation criteria section (**inline**).**
  - Add a paragraph at the top of the evaluation criteria table (before the table) stating: "Evaluation criteria expected values MUST reference authoritative skill cards, not hard-code concrete values. Each Expected Result cell must reference a live authoritative source (e.g., `per writing-plans/tasks/write.md §Dispatch Indicators`) rather than embedding concrete values."
  - SC: SC-3
  - Verification: `grep -n "MUST reference\|authoritative skill card" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match

- [ ] 2. **Update PF-DISPATCH-MODE expected result (**inline**).**
  - Change line 121 Expected Result from `Every step title contains \`(**clean-room**)\` or \`(**inline**)\` — exactly one of the two` to `Every step title contains a valid dispatch indicator per \`writing-plans/tasks/write.md\` §Dispatch Indicators — exactly one of the three`
  - SC: SC-1
  - Verification: `grep -n "valid dispatch indicator per" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match

- [ ] 3. **Update PF-6 expected result (**inline**).**
  - Change line 114 Expected Result from `RED GREEN REFACTOR structure present; RED and GREEN are separate phases, not combined; every step has \`(**clean-room**)\` or \`(**inline**)\` dispatch mode indicator in title` to `RED GREEN REFACTOR structure present; RED and GREEN are separate phases, not combined; every step has a valid dispatch indicator per \`writing-plans/tasks/write.md\` §Dispatch Indicators — exactly one of the three`
  - SC: SC-5
  - Verification: `grep -n "valid dispatch indicator per" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least 2 matches

- [ ] 4. **Update PF-Z3-CONTRACT expected result (**inline**).**
  - Change line 118 Expected Result from `Check: (1) Hierarchical phase→item→gate booleans exist (e.g., P1_I1_G1, P1_I2_G1). (2) NO preconditions declared (preconditions block valid state transitions). (3) Invariants enforce serial ordering (implies pN, pN-1). Any check fails → PF-BLOCKED.` to `Check: (1) Contract follows \`solve/tasks/contract.md\` §Contract YAML Structure — typed variables (\`type\`, \`domain\`, \`nullable\`) with Z3 expression constraints. (2) NO preconditions declared (preconditions block valid state transitions). (3) Invariants enforce serial ordering (implies pN, pN-1). Any check fails → PF-BLOCKED.`
  - SC: SC-2
  - Verification: (1) `grep -n "P1_I1_G1" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return no matches. (2) `grep -n "contract.*schema\|typed.*variable\|Z3 expression" .opencode/skills/audit/tasks/plan-fidelity.md` — MUST return at least one match

- [ ] 5. **Review all other criteria for hard-coded values (**inline**).**
  - Scan every row in the evaluation criteria table (lines 109-128). For each Expected Result cell, check if it contains a concrete value (e.g., `(**clean-room**)`, `P1_I1_G1`) that is NOT a reference to an authoritative source (e.g., `per writing-plans/tasks/write.md`). If any such value exists, flag it for follow-up.
  - SC: SC-4
  - Verification: `grep -n "e\.g\.,\|e\.g\. \|hard-coded\|hardcoded" .opencode/skills/audit/tasks/plan-fidelity.md` — review output. For each match, check if the Expected Result column contains a concrete value that is NOT a reference to an authoritative source. If any such value exists, FAIL.

- [ ] 6. **Verify all SCs (**inline**).**
  - Run all verification commands from SC-1 through SC-5
  - All MUST pass
  - If any FAIL: remediate and re-verify

- [ ] 7. **Commit plan artifact (**inline**).**
  - `git add .opencode/.issues/1436/plan.md`
  - `git commit -m "plan: add implementation plan for #1436"`
  - SC: All
  - Verification: `git log --oneline -1` shows the commit

## Exit Criteria

- [ ] All 5 SCs verified PASS
- [ ] Plan committed to feature branch
- [ ] No hard-coded concrete values remain in evaluation criteria Expected Result cells without authoritative source references

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
