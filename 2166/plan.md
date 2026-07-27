---
plan_schema_version: "1.0"
issue: 2166
title: "Remove dead stderr-grep assertion helpers and convert legacy scripts to artifact-only generators"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red-phase
  - phase: 1
    skill: test-driven-development
    task: green-phase
  - phase: 2
    skill: test-driven-development
    task: red-phase
  - phase: 2
    skill: test-driven-development
    task: green-phase
  - phase: 3
    skill: test-driven-development
    task: red-phase
  - phase: 3
    skill: test-driven-development
    task: green-phase
  - phase: 4
    skill: test-driven-development
    task: red-phase
  - phase: 4
    skill: test-driven-development
    task: green-phase
  - phase: 5
    skill: verification-before-completion
    task: verify
---

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline to verify trunk tip, clean state, and submodule currency. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Phase 1 — Remove dead assertion helpers (SC-1 through SC-9)

Concern: Remove 9 dead `assert_*` function definitions from `helpers.sh` that grep stderr/stdout for tool call patterns. These are dead code — zero callers outside the 2 legacy scripts being converted in Phase 2.

### Item 1 — Remove `assert_tool_calls_made` (SC-1)

- [ ] **RED phase** — write a failing test that verifies `assert_tool_calls_made` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-1}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_tool_calls_made` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-1}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 2 — Remove `assert_skill_called` (SC-2)

- [ ] **RED phase** — write a failing test that verifies `assert_skill_called` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-2}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_skill_called` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-2}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 3 — Remove `assert_no_skill_called` (SC-3)

- [ ] **RED phase** — write a failing test that verifies `assert_no_skill_called` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-3}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_no_skill_called` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-3}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 4 — Remove `assert_stderr_pattern_present` (SC-4)

- [ ] **RED phase** — write a failing test that verifies `assert_stderr_pattern_present` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-4}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_stderr_pattern_present` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-4}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 5 — Remove `assert_stderr_pattern_absent` (SC-5)

- [ ] **RED phase** — write a failing test that verifies `assert_stderr_pattern_absent` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-5}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_stderr_pattern_absent` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-5}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 6 — Remove `assert_stderr_pattern_present_all_models` (SC-6)

- [ ] **RED phase** — write a failing test that verifies `assert_stderr_pattern_present_all_models` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-6}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_stderr_pattern_present_all_models` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-6}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 7 — Remove `assert_stderr_pattern_absent_all_models` (SC-7)

- [ ] **RED phase** — write a failing test that verifies `assert_stderr_pattern_absent_all_models` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-7}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_stderr_pattern_absent_all_models` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-7}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 8 — Remove `assert_forbidden_pattern_absent` (SC-8)

- [ ] **RED phase** — write a failing test that verifies `assert_forbidden_pattern_absent` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-8}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_forbidden_pattern_absent` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-8}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 9 — Remove `assert_required_pattern_present` (SC-9)

- [ ] **RED phase** — write a failing test that verifies `assert_required_pattern_present` function definition is absent from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-9}`
  - Evidence type: `string` — grep for function definition
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — remove the `assert_required_pattern_present` function definition from `helpers.sh`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-9}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Phase 2 — Convert legacy scripts to artifact-only generators (SC-10, SC-11)

Concern: Convert 2 legacy behavioral test scripts from inline `assert_semantic` evaluation to artifact-only generators that call `behavior_run` and exit 0.

### Item 10 — Convert `verify-auth-step5d.sh` to artifact-only (SC-10)

- [ ] **RED phase** — write a failing test that verifies `verify-auth-step5d.sh` calls `behavior_run` and exits 0 without `assert_semantic`, `OVERALL_RESULT`, or `exit $OVERALL_RESULT`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-10}`
  - Evidence type: `behavioral` — run the script, verify it produces artifacts and exits 0 without evaluating
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — convert `verify-auth-step5d.sh` to artifact-only generator: call `behavior_run`, exit 0, remove `assert_semantic`, `OVERALL_RESULT`, and `exit $OVERALL_RESULT`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-10}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

### Item 11 — Convert `2146-session-timestamp.sh` to artifact-only (SC-11)

- [ ] **RED phase** — write a failing test that verifies `2146-session-timestamp.sh` calls `behavior_run` and exits 0 without `assert_semantic`, `OVERALL_RESULT`, or `exit $OVERALL_RESULT`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-11}`
  - Evidence type: `behavioral` — run the script, verify it produces artifacts and exits 0 without evaluating
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — convert `2146-session-timestamp.sh` to artifact-only generator: call `behavior_run`, exit 0, remove `assert_semantic`, `OVERALL_RESULT`, and `exit $OVERALL_RESULT`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-11}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Phase 3 — Update `assert_semantic` to include structured data (SC-12)

Concern: Update `assert_semantic` to pass structured data (`session.yaml`, `timeline.yaml`) to the clean-room inspector.

### Item 12 — Update `assert_semantic` to include structured data (SC-12)

- [ ] **RED phase** — write a failing behavioral test that verifies the inspector prompt contains structured data from `session.yaml` (tool name, callID, status, input, output, timestamps) and `timeline.yaml` summary, appended after raw stdout/stderr. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-12}`
  - Evidence type: `behavioral` — verify inspector prompt contains structured data
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — update `assert_semantic` in `helpers.sh` to pass `session.yaml` and `timeline.yaml` to the clean-room inspector alongside `stdout.log`/`stderr.log`. Append structured data after raw output, not replacing it. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-12}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Phase 4 — Verify/ensure `event` table export in `__export_sqlite_to_yaml` (SC-14)

Concern: Verify that `__export_sqlite_to_yaml` queries the `event` table from `sqlite_master` and exports it.

### Item 14 — Verify/ensure `event` table export in `__export_sqlite_to_yaml` (SC-14)

- [ ] **RED phase** — write a failing test that verifies `__export_sqlite_to_yaml` queries the `event` table from `sqlite_master`. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-14}`
  - Evidence type: `string` — grep for `event` table query
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — if `__export_sqlite_to_yaml` does not query the `event` table, add the query. If it already does, confirm and document. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-14}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Phase 5 — Verify backward compatibility (SC-13)

Concern: Run all existing behavioral tests to confirm no regressions after dead code removal and script conversion.

### Item 13 — All existing behavioral tests continue to pass (SC-13)

- [ ] **RED phase** — write a failing test that verifies `test-enforcement.sh --tag behavioral` passes with zero failures. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-13}`
  - Evidence type: `string` — run the test suite, verify all pass
- [ ] **Z3 check RED** — run `solve --task check` to validate RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **RED doublecheck** — dispatch `verification-before-completion --task verify` to confirm RED test fails as expected. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check RED doublecheck** — run `solve --task check` to validate RED doublecheck state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-RED enforcement** — dispatch `post-red-enforcement` from implementation-pipeline to verify RED gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-RED** — run `solve --task check` to validate post-RED state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **GREEN phase** — run `test-enforcement.sh --tag behavioral` and confirm all tests pass. No code changes needed — this is a verification-only phase. (**clean-room**)
  - Context: `{issue_number: 2166}`, `{sc: SC-13}`
- [ ] **Z3 check GREEN** — run `solve --task check` to validate GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Post-GREEN enforcement** — dispatch `post-green-enforcement` from implementation-pipeline to verify GREEN gate passed. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Z3 check post-GREEN** — run `solve --task check` to validate post-GREEN state transition. (**inline**)
  - Context: `{issue_number: 2166}`, `{contract_path: skills/implementation-pipeline/pipeline-state-machine.yaml}`
- [ ] **Checkpoint tag create** — dispatch `checkpoint-tag-create` from implementation-pipeline. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Checkpoint commit** — dispatch `commit-prep` from git-workflow to save checkpoint. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Exit Criteria

| SC | Phase | Criterion | Evidence Type |
|----|-------|-----------|---------------|
| SC-1 | 1 | `assert_tool_calls_made` function definition removed from `helpers.sh` | `string` |
| SC-2 | 1 | `assert_skill_called` function definition removed from `helpers.sh` | `string` |
| SC-3 | 1 | `assert_no_skill_called` function definition removed from `helpers.sh` | `string` |
| SC-4 | 1 | `assert_stderr_pattern_present` function definition removed from `helpers.sh` | `string` |
| SC-5 | 1 | `assert_stderr_pattern_absent` function definition removed from `helpers.sh` | `string` |
| SC-6 | 1 | `assert_stderr_pattern_present_all_models` function definition removed from `helpers.sh` | `string` |
| SC-7 | 1 | `assert_stderr_pattern_absent_all_models` function definition removed from `helpers.sh` | `string` |
| SC-8 | 1 | `assert_forbidden_pattern_absent` function definition removed from `helpers.sh` | `string` |
| SC-9 | 1 | `assert_required_pattern_present` function definition removed from `helpers.sh` | `string` |
| SC-10 | 2 | `verify-auth-step5d.sh` converted to artifact-only generator | `behavioral` |
| SC-11 | 2 | `2146-session-timestamp.sh` converted to artifact-only generator | `behavioral` |
| SC-12 | 3 | `assert_semantic` passes `session.yaml` and `timeline.yaml` to clean-room inspector | `behavioral` |
| SC-14 | 4 | `__export_sqlite_to_yaml` queries and exports the `event` table | `string` |
| SC-13 | 5 | All existing behavioral tests continue to pass | `string` |

## Post-Implementation

- [ ] **Structural checks** — dispatch `checklist` from finishing-a-development-branch to run lint/typecheck/format. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Verification before completion** — dispatch `completion` from verification-before-completion to verify all SCs are satisfied. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **SC count gate** — dispatch `sc-count-gate` from implementation-pipeline to verify all 14 SCs have verdicts. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Pre-PR gate** — dispatch `verify` from verification-before-completion to check all SC verdicts — BLOCK if any FAIL. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Audit** — dispatch the appropriate audit task from audit skill with `{spec_local_dir, artifact_evidence_dir}`. If non-clean-pass, remediate and restart. On clean PASS, collect artifact path for cross-validate. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Cross-validate** — dispatch `cross-validate` from audit to produce consensus findings. (**clean-room**)
  - Context: `{issue_number: 2166}`
- [ ] **Regression check** — dispatch `patterns` from test-driven-development to generate regression test patterns. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Review prep** — dispatch `review-prep` from git-workflow to prepare PR review context. (**sub-agent**)
  - Context: `{issue_number: 2166}`
- [ ] **Create PR** — dispatch `create` from pr-creation-workflow to create the pull request. (**sub-agent**)
  - Context: `{issue_number: 2166}`, `{authorization_scope}`, `{halt_at}`
- [ ] **Completion** — dispatch `completion` from completion-core to report executive summary. (**sub-agent**)
  - Context: `{issue_number: 2166}`

## Lifecycle Events

- `2026-07-27T20:20:00Z` — `plan_created` — Plan file at `.opencode/.issues/2166/plan.md`, 5 phases, 14 SCs, linear DAG (Phase 1 → 2 → 3 → 4 → 5)
