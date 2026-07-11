# Phase 2: Behavioral Enforcement Test — RED/GREEN Cycle

**SCs:** SC-7 (behavioral gate verification), SC-8 (RED-first)
**Concern:** Behavioral enforcement
**Evidence types:** SC-7 = `behavioral`, SC-8 = `behavioral`

## Entry Criteria

- Phase 1 complete (all 6 file changes done and verified)
- Branch pushed with Phase 1 changes

## Steps

### Step 2.1: RED Phase — Write Behavioral Test (SC-7, SC-8)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Create a behavioral enforcement test for the artifact gate bypass escape hatch. The test must: send a prompt asking the agent to create a plan for a spec WITHOUT analytical artifacts, then assert the agent returns BLOCKED instead of proceeding. Write the test to .opencode/tests/behaviors/ as test_sc7_behavioral_artifact_gate.sh. Use the standard behavioral test template from .opencode/tests/behaviors/ with with-test-home wrapper. The test MUST FAIL (RED) at this point because the Phase 1 file changes are NOT yet on the main branch — the agent should proceed past the gate because the fix doesn't exist in the deployed skill yet.")`
**Chain:** step_1.6
**Exit criteria:** Behavioral test file exists, test FAILS when run (RED)
**Verification:** Run `bash .opencode/tests/behaviors/test_sc7_behavioral_artifact_gate.sh` — expected: exit code != 0 (RED)
**Evidence type:** `behavioral` — both SC-7 and SC-8

### Step 2.2: GREEN Phase (SC-7)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Re-run the behavioral test from .opencode/tests/behaviors/test_sc7_behavioral_artifact_gate.sh. Expected: the test now PASSES (GREEN) because the behavioral test is the enforcement mechanism and does not depend on the Phase 1 file changes (behavioral tests verify agent behavior against guideline rules, not against markdown edits). If the test still FAILS, diagnose and remediate.")`
**Chain:** step_2.1
**Exit criteria:** Behavioral test PASSES when run (GREEN)

## VbC Gate for Behavioral SCs

After `behavior_run` artifact generation in Step 2.2, MUST dispatch `behavioral-test-evaluation` before allowing PASS verdict. Clean-room sub-agent reads session.yaml and judges PASS/FAIL per SC-7 and SC-8.

## Phase Completion Gate

Both SC-7 and SC-8 MUST be PASS before proceeding to Phase 3.
VbC evidence artifacts saved to `tmp/1885/artifacts/behavioral/`.
