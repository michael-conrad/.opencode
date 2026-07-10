# Phase 3: Add TDD Chaining Triggers to Dispatch Tables

**SCs:** SC-7, SC-8
**Evidence types:** `string` (both)
**Chain:** `phase_2`

## Concern

The agent has regressed to running red/red/red → green/green/green instead of interleaved red/green → red/green → red/green. Add trigger entries to `implementation-pipeline/SKILL.md` and `executing-plans/SKILL.md` Trigger Dispatch Tables that cause the agent to self-dispatch when it detects batched RED/GREEN patterns.

## Steps

- [ ] 43. (**sub-agent**) Research — read `implementation-pipeline/SKILL.md` §Trigger Dispatch Table, identify where to add TDD chaining trigger entries
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `phase_2`
  - Expected: evidence artifacts with current dispatch table structure

- [ ] 44. (**inline**) Z3 check — verify research output contains evidence_artifacts
  - Command: `solve check`
  - Chain: `step_43`

- [ ] 45. (**sub-agent**) Add TDD chaining triggers to `implementation-pipeline/SKILL.md` Trigger Dispatch Table
  - Add new trigger entry that detects batched RED/GREEN (multiple REDs before any GREEN):
    - User says / Context: "multiple red phases" / "batch red" / "red/red/red" / "batched RED/GREEN"
    - Task: `tdd-chaining-gate`
    - Dispatches To: `implementation-pipeline --task tdd-chaining-gate`
    - Dispatch: `sub-task`
    - Context passed: `{issue_number}`
  - **SC-7:** Verify `grep` for TDD chaining trigger patterns in SKILL.md Trigger Dispatch Table returns matches
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_44`
  - Expected: SKILL.md updated with new trigger entries

- [ ] 46. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_45`

- [ ] 47. (**sub-agent**) Clean-room plan generation — add TDD chaining triggers to `implementation-pipeline/SKILL.md` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_46`
  - Expected: clean_room_plan in output

- [ ] 48. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_47`

- [ ] 49. (**sub-agent**) Research — read `executing-plans/SKILL.md` §Trigger Dispatch Table, identify where to add per-item TDD cycle enforcement trigger entries
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `step_48`
  - Expected: evidence artifacts with current dispatch table structure

- [ ] 50. (**inline**) Z3 check — verify research output contains evidence_artifacts
  - Command: `solve check`
  - Chain: `step_49`

- [ ] 51. (**sub-agent**) Add per-item TDD cycle enforcement triggers to `executing-plans/SKILL.md` Trigger Dispatch Table
  - Add new trigger entry:
    - User says / Context: "execute plan" / "run plan" / "implement plan" / "tdd cycle" / "per-item tdd"
    - Task: `tdd-cycle-enforcement`
    - Dispatch: `sub-task`
    - Context passed: `{plan_issue, spec_issue}`
  - **SC-8:** Verify `grep` for per-item TDD enforcement trigger patterns in SKILL.md Trigger Dispatch Table returns matches
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_50`
  - Expected: SKILL.md updated with new trigger entries

- [ ] 52. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_51`

- [ ] 53. (**sub-agent**) Clean-room plan generation — add per-item TDD enforcement triggers to `executing-plans/SKILL.md` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_52`
  - Expected: clean_room_plan in output

- [ ] 54. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_53`

- [ ] 55. (**sub-agent**) Revisit — verify new trigger entries integrate correctly with existing dispatch tables (no duplicate entries, proper format)
  - Dispatch: `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_54`
  - Expected: resolution_status in revisit output

- [ ] 56. (**inline**) Z3 check — verify revisit output has resolution_status
  - Command: `solve check`
  - Chain: `step_55`

- [ ] 57. (**sub-agent**) Validate — run validation checks on both modified SKILL.md files
  - Dispatch: `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_56`
  - Expected: PASS status

- [ ] 58. (**inline**) Z3 check — verify validate output has PASS status
  - Command: `solve check`
  - Chain: `step_57`

- [ ] 59. (**sub-agent**) Audit fidelity — verify trigger entries match spec requirements
  - Dispatch: `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_58`
  - Expected: PASS in audit-fidelity output

- [ ] 60. (**inline**) Z3 check — verify audit-fidelity output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_59`

- [ ] 61. (**sub-agent**) Audit concern — verify trigger entries don't overlap with existing entries
  - Dispatch: `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_60`
  - Expected: PASS in audit-concern output

- [ ] 62. (**inline**) Z3 check — verify audit-concern output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_61`

- [ ] 63. (**sub-agent**) Completion — signal phase 3 complete
  - Dispatch: `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_62`
  - Expected: lifecycle event in completion output

- [ ] 64. (**inline**) Z3 check — verify completion output has lifecycle event
  - Command: `solve check`
  - Chain: `step_63`

## VbC (Verification before Completion)

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-7 | `implementation-pipeline/SKILL.md` Trigger Dispatch Table contains entries detecting batched RED/GREEN | `string` | `grep` for TDD chaining trigger patterns in SKILL.md Trigger Dispatch Table |
| SC-8 | `executing-plans/SKILL.md` Trigger Dispatch Table contains entries for per-item TDD cycle enforcement | `string` | `grep` for per-item TDD enforcement trigger patterns in SKILL.md Trigger Dispatch Table |

## Phase Completion

- [ ] All SCs verified PASS
- [ ] Evidence artifacts written to `tmp/1836/phase-3-evidence/`
- [ ] Phase 3 complete — proceed to Phase 4
