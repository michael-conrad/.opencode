# Plan: Plan Phase Dispatch Modes

**Issue:** #1844
**Type:** SPEC-FIX
**Status:** DRAFT
**Dispatch:** inline

## Goal

Add phase-level dispatch mode declarations to plan files so the orchestrator respects per-step execution-mode markers instead of dispatching entire phases to sub-agents indiscriminately.

## Architecture

Three dispatch modes at phase level (`inline`, `sub-agent-with-context`, `sub-agent-clean-room`) declared via `Dispatch` column in split-plan phase tables or `**Dispatch:**` field in non-split plan headers. Per-step markers `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)` become distinct and meaningful only in `inline` mode. Validation rules catch mode/marker inconsistency. Plan auditor detects dispatch marking defects.

## Affected Files

| File | Change Type | Description |
|------|-------------|-------------|
| `writing-plans/tasks/write.md` | MODIFY | Add Dispatch column/field to templates, update dispatch indicator definitions |
| `writing-plans/tasks/validate.md` | MODIFY | Add dispatch mode validation rules |
| `implementation-pipeline/SKILL.md` | MODIFY | Orchestrator reads Dispatch column/field and routes accordingly |
| `audit/tasks/plan-fidelity.md` | MODIFY | Add dispatch marking defect detection |
| `.opencode/tests/behaviors/` | CREATE | Behavioral enforcement tests for dispatch routing |

## Phase Table

| Phase | Description | Files | SCs | Dispatch |
|-------|-------------|-------|-----|----------|
| 1 | Implement dispatch mode declarations, validation rules, auditor detection, and behavioral tests | `writing-plans/tasks/write.md`, `writing-plans/tasks/validate.md`, `implementation-pipeline/SKILL.md`, `audit/tasks/plan-fidelity.md`, `.opencode/tests/behaviors/` | SC-1 through SC-10 | `inline` |

## Phase 1: Implement Dispatch Mode System

**Dispatch:** inline

### Steps

1. (**sub-agent**) Write behavioral enforcement tests (RED phase) — create `.opencode/tests/behaviors/plan-dispatch-modes.sh` with tests for:
   - SC-6: Plan auditor catches dispatch marking defects
   - SC-7: Orchestrator correctly routes `inline` phases
   - SC-8: Backward compatibility (existing plans without Dispatch column still work)
   - SC-9: RED state before implementation
   - SC-10: No SC weakening
   - Chain: `none`
   - Expected: behavioral test file created, tests fail (RED)

2. (**inline**) Z3 check — verify behavioral test file exists and is non-empty
   - Chain: `step_1`

3. (**sub-agent**) Modify `writing-plans/tasks/write.md`:
   - Add `Dispatch` column to phase table template for split plans
   - Add `**Dispatch:**` field to non-split plan section header template
   - Update dispatch indicator definitions: `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)` with distinct context descriptions
   - Chain: `step_2`
   - Expected: SC-1, SC-2 pass

4. (**inline**) Z3 check — verify write.md contains "Dispatch" in phase table template and all three markers with distinct context descriptions
   - Chain: `step_3`

5. (**sub-agent**) Modify `writing-plans/tasks/validate.md`:
   - Add validation rule: `inline` phases MUST NOT contain only sub-agent steps
   - Add validation rule: `sub-agent-clean-room` phases MUST NOT contain `(**inline**)` steps
   - Add validation rule: plan auditor MUST catch dispatch marking defects
   - Chain: `step_4`
   - Expected: SC-3 pass

6. (**inline**) Z3 check — verify validate.md contains all three validation rules
   - Chain: `step_5`

7. (**sub-agent**) Modify `implementation-pipeline/SKILL.md`:
   - Add Trigger Dispatch Table entries for `inline`, `sub-agent-with-context`, `sub-agent-clean-room` dispatch modes
   - Add Overview/Persona prose describing how orchestrator reads Dispatch column/field and routes accordingly
   - Chain: `step_6`
   - Expected: SC-4, SC-5 pass

8. (**inline**) Z3 check — verify implementation-pipeline/SKILL.md contains all three dispatch mode entries in Trigger Dispatch Table and Dispatch routing prose in Overview/Persona
   - Chain: `step_7`

9. (**sub-agent**) Modify `audit/tasks/plan-fidelity.md`:
   - Add dispatch marking defect detection: missing Dispatch declaration, `inline` phase with only sub-agent steps, `sub-agent-clean-room` phase with `(**inline**)` steps
   - Chain: `step_8`
   - Expected: SC-6 pass (auditor catches defects)

10. (**inline**) Z3 check — verify plan-fidelity.md contains dispatch defect detection rules
    - Chain: `step_9`

11. (**sub-agent**) Run behavioral enforcement tests (GREEN phase) — execute `.opencode/tests/behaviors/plan-dispatch-modes.sh` and verify all tests pass
    - Chain: `step_10`
    - Expected: SC-6, SC-7, SC-8, SC-9, SC-10 pass

12. (**inline**) Z3 check — verify behavioral test output shows all PASS
    - Chain: `step_11`

13. (**sub-agent**) Run content-verification tests — execute `bash .opencode/tests/test-enforcement.sh --tag plan-dispatch` and verify all pass
    - Chain: `step_12`
    - Expected: content-verification tests pass

14. (**inline**) Z3 check — verify content-verification output shows all PASS
    - Chain: `step_13`

15. (**sub-agent**) Run regression tests — execute `bash .opencode/tests/test-enforcement.sh --changed` and verify no regressions
    - Chain: `step_14`
    - Expected: no regressions

16. (**inline**) Z3 check — verify regression test output shows no failures
    - Chain: `step_15`

17. (**sub-agent**) Verification before completion — execute verification-before-completion against all SCs
    - Chain: `step_16`
    - Expected: all SCs verified PASS

18. (**inline**) Z3 check — verify VbC output shows all SCs PASS
    - Chain: `step_17`

19. (**sub-agent**) Finishing checklist — execute finishing-a-development-branch checklist
    - Chain: `step_18`
    - Expected: branch ready for PR

20. (**inline**) Z3 check — verify finishing checklist output shows all checks PASS
    - Chain: `step_19`

21. (**sub-agent**) Review prep — execute git-workflow review-prep
    - Chain: `step_20`
    - Expected: PR ready

22. (**inline**) Z3 check — verify review-prep output shows PR readiness
    - Chain: `step_21`

## Exit Criteria

| SC ID | Criterion | Evidence Type | Verification Method |
|-------|-----------|---------------|---------------------|
| SC-1 | `writing-plans/tasks/write.md` includes Dispatch column in phase table template for split plans and `**Dispatch:**` field for non-split plans | `string` | `grep` for "Dispatch" in write.md |
| SC-2 | `writing-plans/tasks/write.md` updates dispatch indicator definitions to distinguish `(**inline**)`, `(**sub-agent**)`, `(**clean-room**)` with distinct context descriptions | `string` | `grep` for each marker in write.md |
| SC-3 | `writing-plans/tasks/validate.md` includes validation rules (a), (b), (c) | `string` | `grep` for each validation rule in validate.md |
| SC-4 | `implementation-pipeline/SKILL.md` Trigger Dispatch Table includes entries for all three dispatch modes | `string` | `grep` for mode names in Trigger Dispatch Table |
| SC-5 | `implementation-pipeline/SKILL.md` Overview/Persona describes Dispatch routing | `string` | `grep` for "Dispatch" in Overview/Persona |
| SC-6 | Plan auditor catches dispatch marking defects | `behavioral` | `opencode-cli run` with defective plan |
| SC-7 | Orchestrator correctly routes `inline` phases | `behavioral` | `opencode-cli run` with inline phase plan |
| SC-8 | No regression: existing plans without Dispatch column still work | `behavioral` | `opencode-cli run` with existing plan |
| SC-9 | Behavioral tests written before implementation (RED then GREEN) | `behavioral` | Verify test file exists and passes |
| SC-10 | No SC weakened or reclassified | `behavioral` | Cross-reference SC evidence types |

## Admonishments

> **Compliance Requirement:** All steps MUST be followed in order. Failure to comply with any step will result in the feature branch being rejected and discarded, requiring a full rework from scratch.

> **Mandatory step completeness:** All implementation-pipeline SKILL.md Trigger Dispatch Table steps MUST be included in the generated plan with correct skill/task references. Plans that omit mandatory steps are defective.

> **No SC weakening:** No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation.

## Self-Review Evidence

- [x] Spec is approved (`approved-for-pr` label present)
- [x] Authorization scope `for_pr` auto-approves plan
- [x] Single-task plan (one phase) — no split needed
- [x] All SCs mapped to phase steps
- [x] All implementation-pipeline gate steps enumerated
- [x] Behavioral SCs include `behavior_run` + `behavioral-test-evaluation` in exit criteria
- [x] Each SC carries `evidence_type` annotation
- [x] Step numbering is globally sequential
- [x] Dispatch mode declared: `inline`
