---
name: test-quality-audit
license: MIT
provenance: AI-generated
---

# Task: test-quality-audit

## Purpose

Structural test quality audit — reader-only checks on test files. Evaluates test quality through five criteria without executing tests.

## Entry Criteria

- VbC evidence artifact completed
- File paths changed known (`file_paths_changed`)
- Spec success criteria available (`spec_success_criteria`)

## Task Context

```yaml
{
  "spec_success_criteria": "<SC list from spec>",
  "file_paths_changed": ["<path1>", "<path2>", ...],
  "vbc_artifact_path": "<path to VbC artifact>",
  "worktree.path": "<worktree.path>",
  "github.owner": "<github.owner>",
  "github.repo": "<github.repo>"
}
```

## Exit Criteria

- All five checklist criteria evaluated with PASS/FAIL (no FAIL (inconclusive) verdicts)
- Verdict produced in standard YAML block format per criterion
- Remediation recommended as FIX_TEST, FIX_CODE, or SPEC_GAP

## Procedure

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify VbC artifact path is provided and non-empty
- [ ] 2. Verify `file_paths_changed` is provided and non-empty
- [ ] 3. Verify `spec_success_criteria` is provided and non-empty
- [ ] 4. If VbC artifact path is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "VbC artifact path"
remediation: "VbC artifact path is required for test-quality-audit. The orchestrator must run verification-before-completion first and provide the artifact path."
```

- [ ] 5. If `file_paths_changed` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "file_paths_changed"
remediation: "Changed file paths are required for test-quality-audit. The orchestrator must pass file_paths_changed from the implementation diff."
```

- [ ] 6. If `spec_success_criteria` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_success_criteria"
remediation: "Spec success criteria are required for test-quality-audit. The orchestrator must provide the SC list from the spec."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Load Test Files

Read the test files referenced in `file_paths_changed` and the VbC artifact.

### Step 2: Evaluate Checklist Criteria

For each criterion below, produce an independent evaluation using reader-only analysis:

#### 1. Assertion Plausibility

Do expected values reference the spec SC's specified values? Are expected values tautological (assert True, assert result is not None only)?

- PASS: All assertions reference specific expected values from the spec SCs
- FAIL: Any assertion is tautological or references values unrelated to SCs
- FAIL (inconclusive): Insufficient evidence to determine

#### 2. Cross-Boundary Coverage

Is there at least one test that references symbols from outside the immediate component?

- PASS: At least one test calls a function or uses a class from a different module than the one under test
- FAIL: All tests are strictly intra-module
- FAIL (inconclusive): Single-module change where cross-boundary testing is not applicable

#### 3. Edge-Case Completeness

Is there more than one test per function? Missing boundary/error/empty/null cases?

- PASS: At least one test per function, plus separate tests for boundary values, error conditions, empty/null inputs
- FAIL: Single test per function, missing edge cases
- FAIL (inconclusive): Cannot determine function boundaries from file structure

#### 4. Assertion Weakening Detection (Retroactive)

Does git diff show expected values changing between commits while the function implementation stays the same?

- PASS: No evidence of assertion weakening — expected values consistent across commits
- FAIL: Expected values changed in test while implementation remained unchanged
- FAIL (inconclusive): Single commit or no git history available

#### 5. RED Evidence

Is there evidence that the test was confirmed FAIL before implementation (in git history or VbC artifact)?

- PASS: Git history or VbC artifact shows test was run and failed before implementation began
- FAIL: No evidence of RED state — test was created alongside or after implementation
- FAIL (inconclusive): Cannot determine order from available evidence

#### 6. Sequential TDD (TQ-11)

Across multiple test items, is there evidence of RED-before-GREEN ordering (each item's test FAILs before its implementation PASSes)?

- PASS: Multiple items show individual RED/GREEN cycles — each test confirmed FAIL before its implementation was written
- FAIL: Tests for multiple items were all written before any implementation (RED-ALL → GREEN-ALL pattern)
- FAIL (inconclusive): Single item only, or insufficient git history to determine ordering

### Step 3: Produce Verdict

```yaml
criterion: assertion_plausibility
result: PASS|FAIL|FAIL (inconclusive)
evidence: "<tool-call reference or file path>"
remediation: FIX_TEST|FIX_CODE|SPEC_GAP
recommendation: "<prose description of what to fix>"
---
criterion: cross_boundary_coverage
result: PASS|FAIL|FAIL (inconclusive)
evidence: "<tool-call reference>"
remediation: FIX_CODE
recommendation: "<prose>"
---
criterion: edge_case_completeness
result: PASS|FAIL|FAIL (inconclusive)
evidence: "<tool-call reference>"
remediation: FIX_TEST|SPEC_GAP
recommendation: "<prose>"
---
criterion: assertion_weakening
result: PASS|FAIL|FAIL (inconclusive)
evidence: "<git diff reference>"
remediation: FIX_TEST
recommendation: "<prose>"
---
criterion: red_evidence
result: PASS|FAIL|FAIL (inconclusive)
evidence: "<VbC artifact reference or git log>"
remediation: FIX_TEST|SPEC_GAP
recommendation: "<prose>"
```

### Step 4: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-test-quality-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: test_quality
auditor_type: test-quality-audit
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
overall: PASS|FAIL|PARTIAL
criteria:
  - criterion: "assertion_plausibility"
    result: "PASS|FAIL|FAIL (inconclusive)"
    evidence: "<tool-call reference>"
    remediation: "FIX_TEST|FIX_CODE|SPEC_GAP"
    recommendation: "<prose>"
exec_summary: "Test quality audit: X/Y criteria passed."
```

### Step 5: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-test-quality-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 0 (Pre-Flight Validation Gate) → INVALID if skipped
- Step 1 (Load Test Files) → INVALID if skipped
- Step 2 (Evaluate Checklist Criteria) → INVALID if skipped
- Step 3 (Produce Verdict) → INVALID if skipped
- Step 4 (Write Verdict Artifact to Disk) → INVALID if skipped
- Step 5 (Return Frugal Result Contract) → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| Test files do not exist | Return BLOCKED with missing file paths |
| VbC artifact unavailable | Return BLOCKED — prerequisite unmet |
| No git history for weakening check | Mark assertion_weakening as FAIL (inconclusive) with note |

## Cross-References

- `resolve-models` task — auditor model resolution (adversarial-audit --task resolve-models)
- `verification-before-completion/SKILL.md` — VbC artifact format
- `spec-creation/tasks/write.md` — Step 4: Determinism Gate
- `spec-creation/tasks/write.md` — SC verification methods
- `080-code-standards.md` — Behavioral Enforcement Tests

