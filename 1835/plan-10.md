# Phase 10 — Global Post-Phase

**Concern:** Adversarial audit, cross-validate, regression, review prep, completion

**Files:** All modified files

**SCs:** All

**Dependencies:** Phase 9

**Entry Criteria:** Phase 9 complete, all implementation phases done

**Exit Criteria:** All validation checks pass, plan artifacts committed, completion reported

## Step-by-Step

- [ ] 56. (**sub-agent**) Run plan validation — `task(..., prompt: "execute validate task from writing-plans")`
  - Validate against all 19+ checks in validate.md
  - SC: All

- [ ] 57. (**inline**) Z3 check — `solve check` verify validate output has PASS status
  - SC: All

- [ ] 58. (**sub-agent**) Run audit-fidelity — `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Verify plan faithfully implements spec #1835
  - SC: All

- [ ] 59. (**inline**) Z3 check — `solve check` verify audit-fidelity output has PASS AND `all_criteria_pass == true`
  - SC: All

- [ ] 60. (**sub-agent**) Run audit-concern — `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Verify concern boundaries and scope isolation
  - SC: All

- [ ] 61. (**inline**) Z3 check — `solve check` verify audit-concern output has PASS AND `all_criteria_pass == true`
  - SC: All

- [ ] 62. (**inline**) Verify all plan files exist
  - Command: `ls .opencode/.issues/1835/plan.md .opencode/.issues/1835/plan-*.md`
  - Expected: all 10 files exist

- [ ] 63. (**inline**) Verify step numbering is globally sequential across all phase files
  - Command: Parse plan step numbers, verify no per-phase restart
  - Expected: step N+1 follows step N across phase boundaries

- [ ] 64. (**sub-agent**) Run completion — `task(..., prompt: "execute completion task from writing-plans")`
  - Commit plan artifacts to feature branch
  - Sync cross-references
  - Report plan path

- [ ] 65. (**inline**) Final verification — All exit criteria met
  - Verify C1-C12 all pass
  - Report plan at `.opencode/.issues/1835/plan.md`

## Phase Completion

- [ ] All validation checks pass
- [ ] All audit checks pass
- [ ] Plan artifacts committed to feature branch
- [ ] Plan reported with path

## Concern Transition

This is the final phase. All plan artifacts are complete at `.opencode/.issues/1835/plan.md` and `.opencode/.issues/1835/plan-{01..10}.md`.
