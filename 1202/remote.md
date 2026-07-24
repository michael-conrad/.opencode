---
remote_issue: 1202
remote_url: "https://github.com/michael-conrad/.opencode/issues/1202"
last_sync: "2026-06-14T16:59:22Z"
source: github
---

## Summary

RED-phase tests and REGRESSION-phase tests are being mixed. The RED sub-agent writes tests that include regression-style assertions (verifying existing behavior), and the REGRESSION gate receives no dedicated tests. This produces two defects:

1. RED tests fail on pre-existing broken behavior instead of the new feature's absence — the agent chases unrelated failures instead of testing the spec requirement
2. REGRESSION tests are never written — the safety net for existing functionality is absent

RED and REGRESSION serve opposite purposes: RED asserts a spec requirement that does not exist yet (expected FAIL), REGRESSION asserts existing behavior is preserved (expected PASS). They belong in separate test files with separate concerns. The RED test file should contain exactly one concern: the spec requirement for this phase. The REGRESSION test file should contain exactly one concern: existing behavior still works.

## Root Cause

The `test-driven-development` skill's RED task has no concern-boundary constraint — it writes whatever tests seem relevant. The `post-red-enforcement` structural gate only checks `git diff --name-only -- src/` (no source changes) but does not inspect the test files themselves. Nothing prevents the RED phase from modifying existing regression test suites or embedding regression assertions in the RED test file.

## Affected Files

| File | Change |
|------|--------|
| `skills/test-driven-development/tasks/red.md` | Add concern-boundary constraint: RED test file must contain exactly one assertion or assertion set — the spec requirement. No existing test modification. |
| `skills/implementation-pipeline/tasks/post-red-enforcement.md` | Add test-file inspection: verify RED only created/updated the dedicated RED test file, not existing regression or integration test suites |
| `skills/implementation-pipeline/tasks/regression-check.md` | Add concern-boundary requirement: regression tests must verify existing behavior, not re-test the new feature |
| `skills/implementation-pipeline/SKILL.md` | Update Dispatch Routing Table row for `regression-check` to specify "regression-only tests (not RED duplicates)" |
| `.opencode/.guidelines/test-boundaries.md` | New flat reference card: RED/REGRESSION concern-boundary rules |

## Spec

### Phase 1: Create Test Boundary Reference Card

Create `.opencode/.guidelines/test-boundaries.md` as a flat card (no internal headings, the file IS the section):

```
RED and REGRESSION tests serve opposite purposes and must never be mixed in the same file or assertion set.

RED tests assert a spec requirement that does not exist yet. They are expected to FAIL when the phase starts. A RED test file must contain exactly one concern: the spec requirement for this phase. It must not test existing behavior, must not modify existing test suites, and must not include assertions about anything outside the spec.

REGRESSION tests assert that existing behavior is preserved after a change. They are expected to PASS. A regression test file must not test the new feature — that is the RED test's job. Regression tests run against the full existing test suite plus dedicated regression-only tests that verify nothing broke.

RED test files are created fresh per phase. REGRESSION tests are written as separate files or added to existing regression suites. They are never the same file.
```

### Phase 2: Constrain RED Task in test-driven-development

In `skills/test-driven-development/tasks/red.md`, add a mandatory entry criterion:

- RED test file path MUST be `.opencode/tests/behaviors/<phase-label>.sh` or similar — a NEW file, not a modification to existing tests
- RED test MUST contain exactly one assertion concern: the spec SC being tested
- RED test MUST NOT modify existing regression or integration test files
- RED test MUST NOT include assertions about existing behavior (that is the REGRESSION test's job)

Add a mandatory post-condition check: after writing the RED test, verify `git diff --name-only` shows only the new RED test file (no modifications to existing suites).

### Phase 3: Strengthen post-red-enforcement

In `implementation-pipeline`'s post-red-enforcement task, add:

1. `git diff --name-only` — confirm only test files were touched (already exists: `-- src/` check)
2. `git diff --name-only -- $(find .opencode/tests -name "*.sh" -o -name "*.py" | head -20)` — confirm no existing test files were modified. Only NEW test files are acceptable.
3. If existing test files were modified: BLOCK with TEST_BOUNDARY_VIOLATION — RED must not modify existing tests

### Phase 4: Constrain REGRESSION task

In `implementation-pipeline`'s regression-check step definition in the Dispatch Routing Table:

- Regression tests MUST focus on existing behavior preservation
- Regression tests MUST NOT replicate RED test assertions (that would be testing the new feature, not existing behavior)
- The regression-check gate runs the full existing test suite and any dedicated regression-only test files — but NOT the phase's RED test file (which is expected to FAIL at this point? No — GREEN should have made it PASS. Actually, regression should include the RED test now that GREEN passed, to confirm the new feature didn't break anything.)

This last point needs clarification: after GREEN makes RED pass, including the RED test in regression is correct — it's now a "behavior that should pass." But the regression gate must not *write* new RED-like assertions. The concern boundary applies at *test-writing time*, not test-execution time. The regression-check executes all tests; it does not write new ones. The concern boundary for writing lives in the RED phase and the regression-writing sub-task.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `test-boundaries.md` reference card exists with RED/REGRESSION separation rules | `string` |
| SC-2 | RED task in test-driven-development includes entry criterion: new file only, one concern, no existing test modification | `string` |
| SC-3 | post-red-enforcement inspects git diff for existing test file modifications and BLOCKs on violation | `behavioral` |
| SC-4 | Behavioral test: RED sub-agent that modifies existing test files instead of creating new ones fails post-red-enforcement | `behavioral` |
| SC-5 | Behavioral test: RED test file containing multiple concerns (spec requirement + regression assertion) fails RED review | `behavioral` |
| SC-6 | Regression-check executes full test suite but does not write RED-like assertions | `structural` |

## Non-Goals

- Not changing the GREEN task — GREEN implementation runs against the RED test, which is correct
- Not changing the execution order — RED → GREEN → REGRESSION remains the same
- Not removing the existing test suite from regression — regression runs ALL tests, including the now-passing RED test

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/test-boundary-separation`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)