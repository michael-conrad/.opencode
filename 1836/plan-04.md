# Phase 4: Behavioral Tests + Audit

**SCs:** SC-9, SC-11
**Evidence types:** `behavioral` (SC-9), `string` (SC-11)
**Chain:** `phase_3`

## Concern

Write behavioral enforcement tests that verify the agent actually follows the restored rules. SC-9 verifies RED/GREEN interleaving (not batch RED then batch GREEN). SC-11 verifies no hard-gate content remains in unreachable `operating-protocol.md` files.

## Steps

- [ ] 65. (**sub-agent**) Research — read existing behavioral test infrastructure in `.opencode/tests/behaviors/` for patterns and helpers
  - Read `helpers.sh` for assertion helpers
  - Read existing test scripts for pattern reference
  - Dispatch: `task(..., prompt: "execute research task from writing-plans")`
  - Chain: `phase_3`
  - Expected: evidence artifacts with test patterns

- [ ] 66. (**inline**) Z3 check — verify research output contains evidence_artifacts
  - Command: `solve check`
  - Chain: `step_65`

- [ ] 67. (**sub-agent**) Write behavioral test `tdd-interleaving.sh` — verifies agent interleaves RED/GREEN (not batch RED then batch GREEN)
  - Test sends a multi-item TDD prompt via `opencode-cli run`
  - Uses `assert_semantic` to verify interleaved dispatch pattern in stderr
  - **SC-9:** `behavior_run` produces artifacts; `behavioral-test-evaluation` clean-room dispatch verifies PASS
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_66`
  - Expected: test file at `.opencode/tests/behaviors/tdd-interleaving.sh`

- [ ] 68. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_67`

- [ ] 69. (**sub-agent**) Clean-room plan generation — write `tdd-interleaving.sh` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_68`
  - Expected: clean_room_plan in output

- [ ] 70. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_69`

- [ ] 71. (**sub-agent**) Write behavioral test `analysis-depth-gate.sh` — verifies plan creation pipeline rejects a spec missing analysis depth
  - Test sends a spec lacking analysis depth via `opencode-cli run`
  - Uses `assert_semantic` to verify plan creation is blocked
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_70`
  - Expected: test file at `.opencode/tests/behaviors/analysis-depth-gate.sh`

- [ ] 72. (**inline**) Z3 check — verify write output contains file path
  - Command: `solve check`
  - Chain: `step_71`

- [ ] 73. (**sub-agent**) Clean-room plan generation — write `analysis-depth-gate.sh` (spec body only, no existing plan context)
  - Dispatch: `task(..., prompt: "execute write task from writing-plans")`
  - Chain: `step_72`
  - Expected: clean_room_plan in output

- [ ] 74. (**inline**) Z3 check — verify clean-room plan output contains clean_room_plan
  - Command: `solve check`
  - Chain: `step_73`

- [ ] 75. (**sub-agent**) Audit all `operating-protocol.md` files — check for hard-gate content not reachable via Trigger Dispatch Table
  - Glob all `.opencode/skills/*/tasks/operating-protocol.md` files
  - For each file found: read content, identify hard-gate enforcement language
  - For each hard-gate item: verify it is either in SKILL.md (reachable via `skill()`) or has a dispatch entry in the Trigger Dispatch Table
  - **SC-11:** Verify no hard-gate enforcement content remains in any `operating-protocol.md` file that is not reachable via the Trigger Dispatch Table
  - Dispatch: `task(..., prompt: "execute audit-fidelity task from writing-plans")`
  - Chain: `step_74`
  - Expected: audit report with PASS/FAIL per file

- [ ] 76. (**inline**) Z3 check — verify audit output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_75`

- [ ] 77. (**sub-agent**) Revisit — resolve any findings from the operating-protocol.md audit
  - For any hard-gate content found in unreachable operating-protocol.md: either restore to SKILL.md or add a dispatch entry
  - Dispatch: `task(..., prompt: "execute revisit task from writing-plans")`
  - Chain: `step_76`
  - Expected: resolution_status in revisit output

- [ ] 78. (**inline**) Z3 check — verify revisit output has resolution_status
  - Command: `solve check`
  - Chain: `step_77`

- [ ] 79. (**sub-agent**) Run behavioral tests — execute both new behavioral tests
  - Run: `bash .opencode/tests/with-test-home bash .opencode/tests/behaviors/tdd-interleaving.sh`
  - Run: `bash .opencode/tests/with-test-home bash .opencode/tests/behaviors/analysis-depth-gate.sh`
  - **SC-9 behavioral evidence:** `behavior_run` produces artifacts; dispatch `behavioral-test-evaluation` before allowing PASS verdict
  - Dispatch: `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_78`
  - Expected: PASS for both tests

- [ ] 80. (**inline**) Z3 check — verify validate output has PASS status
  - Command: `solve check`
  - Chain: `step_79`

- [ ] 81. (**sub-agent**) Run full enforcement test suite — verify no regressions
  - Run: `bash .opencode/tests/with-test-home bash .opencode/tests/test-enforcement.sh --changed`
  - Dispatch: `task(..., prompt: "execute validate task from writing-plans")`
  - Chain: `step_80`
  - Expected: PASS for all tests

- [ ] 82. (**inline**) Z3 check — verify validate output has PASS status
  - Command: `solve check`
  - Chain: `step_81`

- [ ] 83. (**sub-agent**) Audit concern — verify behavioral tests don't overlap with existing tests
  - Dispatch: `task(..., prompt: "execute audit-concern task from writing-plans")`
  - Chain: `step_82`
  - Expected: PASS in audit-concern output

- [ ] 84. (**inline**) Z3 check — verify audit-concern output has PASS AND `all_criteria_pass == true`
  - Command: `solve check`
  - Chain: `step_83`

- [ ] 85. (**sub-agent**) Completion — signal phase 4 complete
  - Dispatch: `task(..., prompt: "execute completion task from writing-plans")`
  - Chain: `step_84`
  - Expected: lifecycle event in completion output

- [ ] 86. (**inline**) Z3 check — verify completion output has lifecycle event
  - Command: `solve check`
  - Chain: `step_85`

## VbC (Verification before Completion)

| SC | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-9 | Behavioral test verifies agent interleaves RED/GREEN (not batch RED then batch GREEN) | `behavioral` | `opencode-cli run` with multi-item TDD prompt; `assert_semantic` verifies interleaved dispatch pattern. After `behavior_run` produces artifacts, dispatch `behavioral-test-evaluation` before allowing PASS verdict. |
| SC-11 | No hard-gate enforcement content remains in any `operating-protocol.md` file not reachable via Trigger Dispatch Table | `string` | Audit all `operating-protocol.md` files for hard-gate language; verify each is either in SKILL.md or has a dispatch entry |

## Phase Completion

- [ ] All SCs verified PASS
- [ ] Behavioral evidence artifacts preserved at `tmp/1836/behavioral/`
- [ ] Full enforcement test suite passes
- [ ] Phase 4 complete — all phases done
