---
title: "Phase 6: Behavioral enforcement tests"
phase: 6
issue: 2020
status: draft
risk: low
Dispatch: sub-agent
---

## Entry Criteria

- [ ] Phase 5 complete
- [ ] Phase 5 Z3 check passed

## Steps

- [ ] 22. Create behavioral test for spec-creation pipeline dispatch (SC-17) (**sub-agent**)

    Create `.opencode/tests-v2/behaviors/dispatch-boundary-spec-creation.sh` that verifies:
    - After `skill("spec-creation")`, orchestrator does NOT dispatch the `create` pipeline to a sub-agent
    - Uses `assert_stderr_pattern_absent` for pipeline dispatch patterns

- [ ] 23. Create behavioral test for writing-plans pipeline dispatch (SC-18) (**sub-agent**)

    Create `.opencode/tests-v2/behaviors/dispatch-boundary-writing-plans.sh` that verifies:
    - After `skill("writing-plans")`, orchestrator does NOT dispatch the `create` pipeline to a sub-agent
    - Uses `assert_stderr_pattern_absent` for pipeline dispatch patterns

- [ ] 24. Create behavioral test for writing-plans TDT classification (SC-19) (**sub-agent**)

    Add to `dispatch-boundary-writing-plans.sh` or create separate test that verifies:
    - `writing-plans/SKILL.md` classifies `create` as `orchestrator`, not `sub-task`
    - Uses `assert_stderr_pattern_present` for orchestrator dispatch

- [ ] 25. Run behavioral tests (**clean-room**)

    Execute each behavioral test via `bash .opencode/tests-v2/behaviors/<scenario>.sh` and verify PASS.

- [ ] 26. Z3 check — solve check verify test output (**sub-agent**)

    Run `.opencode/tools/solve check` with the test contract.

## Exit Criteria

- [ ] Behavioral tests created and passing — verify: `bash .opencode/tests-v2/behaviors/dispatch-boundary-spec-creation.sh` exits 0
- [ ] Behavioral tests created and passing — verify: `bash .opencode/tests-v2/behaviors/dispatch-boundary-writing-plans.sh` exits 0
- [ ] Z3 check passes — verify: `.opencode/tools/solve check` exits 0

### Evidence Type Annotations

| SC | Evidence Type | Verification Method |
|----|---------------|---------------------|
| SC-17 | behavioral | `behavior_run` → artifact generation → `behavioral-test-evaluation` clean-room dispatch |
| SC-18 | behavioral | `behavior_run` → artifact generation → `behavioral-test-evaluation` clean-room dispatch |
| SC-19 | behavioral | `behavior_run` → artifact generation → `behavioral-test-evaluation` clean-room dispatch |

### Behavioral Evidence Steps

For each behavioral SC (SC-17, SC-18, SC-19):
1. Run `behavior_run` to generate test artifacts (stdout.log, stderr.log, manifest.yaml)
2. Dispatch `behavioral-test-evaluation` clean-room sub-agent to evaluate artifacts
3. Clean-room sub-agent returns binary PASS/FAIL verdict per SC
4. Only proceed on 100% clean PASS for all three SCs

## SC Coverage

- SC-17 (behavioral test for spec-creation pipeline dispatch)
- SC-18 (behavioral test for writing-plans pipeline dispatch)
- SC-19 (behavioral test for writing-plans TDT classification)
