## Problem

Behavioral test files were created and committed but never executed. The SCs for #2003 (SC-1, SC-3, SC-4) and #2004 (SC-12) were claimed as PASS based on file existence alone — the tests were never run via `bash tests-v2/behaviors/<scenario>.sh` to confirm they produce artifacts and the agent dispatches correctly.

This is a structural evidence substitution for behavioral evidence: file existence (structural) was used to claim PASS for behavioral SCs that require test execution with output inspection.

## Root Cause

The implementation pipeline has no gate requiring behavioral tests to be RUN (not just created) before the SC can be marked PASS. The pattern is:

1. Write test file → `git add` → `git commit` → claim SC PASS
2. Never run `bash tests-v2/behaviors/<scenario>.sh` to verify the test produces artifacts
3. Never evaluate the artifacts to confirm the agent dispatches correctly

The artifact-only generator paradigm (tests always exit 0) makes this worse — a test that was never run still "passes" because the script exits 0 unconditionally. The real verification happens in artifact evaluation, which was never performed.

## Evidence

- `tests-v2/behaviors/spec-creation-dispatch.sh` — committed in 8b9af2bb, never run
- `tests-v2/behaviors/writing-plans-dispatch.sh` — committed in f4194143, never run
- PR #2005 was created with both tests unexecuted
- When run just now, `writing-plans-dispatch.sh` hit lock contention (another test running) — the test infrastructure itself was not ready

## Fix Approach

1. Add a critical-rules entry: "Behavioral tests MUST be executed and produce non-empty artifacts before the corresponding SC can be claimed PASS. Creating a test file without running it is a FAIL."
2. Add a verification-before-completion step that runs each behavioral test and verifies artifact existence before allowing the SC to pass
3. Run both behavioral tests now to establish baseline

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Critical-rules entry added: behavioral tests must be run (not just created) before SC can be claimed PASS | `string` | grep for "behavioral test.*run" in `000-critical-rules.md` |
| SC-2 | Both behavioral tests (`spec-creation-dispatch.sh`, `writing-plans-dispatch.sh`) produce non-empty artifact directories with stdout.log, stderr.log, and manifest.yaml | `behavioral` | `bash tests-v2/behaviors/spec-creation-dispatch.sh` + `bash tests-v2/behaviors/writing-plans-dispatch.sh` → verify artifact dirs exist and contain required files |
| SC-3 | PR #2005 is updated with the run evidence (or a new commit adding the verification step) | `structural` | PR #2005 has a commit adding the run-verification gate |

## Affected Files

- `.opencode/guidelines/000-critical-rules.md` — New critical-rules entry
- `.opencode/tests-v2/behaviors/spec-creation-dispatch.sh` — Must be run (already exists)
- `.opencode/tests-v2/behaviors/writing-plans-dispatch.sh` — Must be run (already exists)

## Non-Goals

- Not changing the artifact-only generator paradigm (tests should still exit 0)
- Not changing how behavioral tests are written
- Not retroactively fixing other unrun tests in the repo

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
