---
skill: engineering-approach
task: verify-before-complete
type: discipline-enforcing
license: MIT
---

# Task: verify-before-complete

## Purpose

Enforce the verify-before-declaring-complete discipline per engineering-approach Operating Protocol §3.

## Procedure

### Step 1a: Produce Saved Test Run Artifact

Before declaring completion, produce a saved test run artifact file:
```bash
mkdir -p ./tmp/artifacts/
uv run pytest test/ --junitxml=./tmp/artifacts/test-results.xml
```

The artifact file is the permanent record that runtime verification occurred. Without it, completion claims are unverifiable post-hoc — a skipped artifact equals an unverifiable completion.

### Step 1: Run Tests Manually

Execute the test suite against the implementation. Do not assume tests pass based on code inspection alone.

### Step 2: Check Edge Cases

Identify and verify edge cases from the spec. Confirm each edge case is handled correctly.

### Step 3: Validate Success Criteria

For each success criterion in the approved spec:
- [ ] Produce a tool-call artifact confirming the criterion is met
- [ ] Flag any criterion that cannot be verified as FAIL

### Step 4: Report Findings

Present a pass/fail table with per-criterion evidence. If all criteria pass, declare complete. If any fail, return to implementation.

## Entry Criteria

- Implementation completed
- Spec has defined success criteria

## Exit Criteria

- All success criteria verified with tool-call evidence
- Edge cases validated

## Context Required

- Spec issue content
- Implementation file paths
- Session values: <github.owner>, <github.repo>

## Result Contract

```yaml
status: VERIFIED | VERIFICATION_FAILED
tests_run_manually: true | false
success_criteria: { total: N, passed: N, failed: N }
evidence_artifacts: [artifact1, artifact2, ...]
```

```yaml+symbolic
rules:
  - id: eng-approach-003
    title: "Must verify before declaring complete"
    conditions:
      all: ["implementation_complete_claimed == true", "tests_run_manually == false"]
    actions: [HALT, RUN_TESTS, VERIFY_CRITERIA]
    source: "engineering-approach/tasks/verify-before-complete.md"
```

Co-authored with AI: <AgentName> (<ModelId>)
