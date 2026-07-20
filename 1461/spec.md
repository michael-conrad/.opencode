# [SPEC-FIX] Writing-plans pipeline: replace inline Z3 passthrough with real contract verification

## Problem

The writing-plans pipeline calls for Z3 verification checks at 8 steps (6, 8, 10, 14, 16, 18, 20, 22). Every single step is implemented as an inline `echo PASS` — no contract file is loaded, no state file is produced, no `solve check` is actually invoked. The verification label ("Z3 gate") is cargo-culted from the pipeline template but the infrastructure to make it meaningful does not exist.

This was documented as **Lesson 7** in the session-2026-06-27 lessons learned. The solve tool exists and works (#872, closed), contract schemas have been proposed (#1198, #1222, both open), but no wiring connects pipeline stage boundaries to actual Z3 verification.

Root cause: three missing pieces create a dependency chain:
1. No contract schema for writing-plans pipeline stages — what state variables exist at each gate?
2. No state file production at stage boundaries — what is the current state at step N?
3. No `solve check` invocation — where does the actual verification call happen?

## Related

- Lesson 7: `opencode/.issues/lessons-learned/session-2026-06-27/README.md`
- #1198 contract-schema Z3-state wiring (open)
- #1222 enforcement-gated contract schema (open)
- #1320 writing-plans Z3 contract decomposition (open)
- #1393 writing-plans skill task file defects (open)

## Proposed Approach

1. **Define contract schema** for writing-plans pipeline: variables representing pipeline stage progress (phases completed, current step, sub-issue count, audit status, SC verification status). File at `opencode/skills/writing-plans/contracts/pipeline-contract.yaml`.

2. **Produce state at stage boundaries**: Each pipeline step that currently has an inline `echo PASS` Z3 gate produces a state YAML at `./tmp/state/writing-plans/<issue>/step-<N>.yaml` with current pipeline variables.

3. **Replace inline echo PASS with actual `solve check`**: Each gate step invokes `solve check --state-path <state-file> --contract-path <contract-file> --output json` and verifies SAT. On UNSAT + unsat core, the gate returns FAIL with the unsat core variables.

4. **Update writing-plans skill task files**: Replace the current inline echo commands in the relevant task files with the state-production + solve-check sequence.

5. **Pipeline-readiness check**: Existing pipeline-readiness gates (step 16) get state validation as an additional criterion.

6. **Behavioral enforcement tests**: New tests in `opencode/tests/behaviors/` verifying that pipeline gates actually reject UNSAT states.

## Phase Plan

### Phase 1: Contract schema and state format definition
- Define `pipeline-contract.yaml` with typed variables
- Define state.yaml format per stage boundary
- Update existing contract template patterns from `spec-creation` skill for reuse

### Phase 2: Wire production + verification into pipeline steps
- Add state-file production to each gate step
- Replace `echo PASS` with `solve check --output json`
- Handle UNSAT return (FAIL + unsat core report)

### Phase 3: Behavioral enforcement tests
- Write test: pipeline stage with SAT state passes
- Write test: pipeline stage with UNSAT state (missing prerequisite) fails with unsat core

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Contract schema YAML defines all pipeline variables (phases_completed, current_step, sub_issue_count, audit_status, sc_verification_status, exit_criteria_bitmask) with types and domains | `structural` + `string` |
| SC-2 | Each of the 8 gate steps produces a state YAML at `./tmp/state/writing-plans/<issue>/step-<N>.yaml` | `structural` |
| SC-3 | Each gate step invokes `solve check --output json` and verifies SAT response | `behavioral` |
| SC-4 | UNSAT state returns FAIL with unsat core variables in sub-agent result contract | `behavioral` |
| SC-5 | Existing pipeline steps continue to work with no regressions | `behavioral` |
| SC-6 | Behavioral test: SAT state at step 6 passes the gate | `behavioral` |
| SC-7 | Behavioral test: UNSAT state (missing sub-issue before step 14) fails the gate with unsat core | `behavioral` |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash-free)
