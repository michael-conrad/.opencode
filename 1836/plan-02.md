# Phase 2: Add Analysis-Depth Prevention Gate

**SCs:** SC-6
**Evidence types:** `string`
**Chain:** `phase_1`

## Concern

Plans no longer include blast radius analysis, separation of concerns, decomposition depth, cross-cutting concerns, or full code path exercising. The analysis-depth prevention gate fires BEFORE plan creation begins, catching missing analysis in the spec rather than after plan creation.

## Steps

- [ ] 27. (**sub-agent**) Research — read `writing-plans/tasks/validate.md` current checks (20 structural checks), identify where to add analysis-depth checks
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `phase_1`
  - Expected: evidence artifacts with current validate.md structure

- [ ] 28. (**inline**) Z3 check — verify research output contains evidence_artifacts
  - Command: `solve check`
  - Chain: `step_27`

- [ ] 29. (**sub-agent**) Add analysis-depth checks to `writing-plans/tasks/validate.md`
  - Add 5 new validation checks (after existing check 20):
    - **Check 21:** Blast radius analysis — spec identifies what files/symbols are affected and what depends on them
    - **Check 22:** Separation of concerns — each concern is isolated to its own phase/item
    - **Check 23:** Decomposition depth — work is decomposed to the lowest testable level
    - **Check 24:** Cross-cutting concern identification — concerns spanning multiple phases are explicitly identified
    - **Check 25:** Full code path exercising — all affected code paths are enumerated
  - Each check: `(**inline**)`, grep for key phrases in spec body, FAIL on absence
  - **SC-6:** Verify `grep` for "blast radius", "separation of concerns", "decomposition", "cross-cutting", "full code path" in validate.md returns matches
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_28`
  - Expected: validate.md updated with 5 new checks

- [ ] 30. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_29`

- [ ] 31. (**sub-agent**) Clean-room plan generation — add analysis-depth checks to validate.md (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_30`
  - Expected: clean_room_plan in output

- [ ] 32. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_31`

- [ ] 33. (**sub-agent**) Revisit — verify the new checks integrate correctly with existing validate.md structure (no duplicate check IDs, proper numbering)
  - Dispatch: `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_32`
  - Expected: resolution_status in revisit output

- [ ] 34. (**inline**) Z3 check — verify revisit output has resolution_status
  - Command: `solve check`
  - Chain: `step_33`

- [ ] 35. (**sub-agent**) Validate — run validation checks on modified validate.md
  - Dispatch: `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_34`
  - Expected: PASS status

- [ ] 36. (**inline**) Z3 check — verify validate output has PASS status
  - Command: `solve check`
  - Chain: `step_35`

- [ ] 37. (**sub-agent**) Audit fidelity — verify analysis-depth checks match spec requirements
  - Dispatch: `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_36`
  - Expected: PASS in audit-fidelity output

- [ ] 38. (**inline**) Z3 check — verify audit-fidelity output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_37`

- [ ] 39. (**sub-agent**) Audit concern — verify analysis-depth checks don't overlap with existing checks
  - Dispatch: `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_38`
  - Expected: PASS in audit-concern output

- [ ] 40. (**inline**) Z3 check — verify audit-concern output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_39`

- [ ] 41. (**sub-agent**) Completion — signal phase 2 complete
  - Dispatch: `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_40`
  - Expected: lifecycle event in completion output

- [ ] 42. (**inline**) Z3 check — verify completion output has lifecycle event
  - Command: `solve check`
  - Chain: `step_41`

## VbC (Verification before Completion)

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-6 | `writing-plans/tasks/validate.md` includes checks for all five analysis-depth dimensions | `string` | `grep` for "blast radius", "separation of concerns", "decomposition", "cross-cutting", "full code path" in validate.md |

## Phase Completion

- [ ] All SCs verified PASS
- [ ] Evidence artifacts written to `tmp/1836/phase-2-evidence/`
- [ ] Phase 2 complete — proceed to Phase 3
