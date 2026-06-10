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

Write the full YAML verdict artifact to `./tmp/{issue-N}/artifacts/pipeline-audit-test-quality-{STATUS}-{timestamp}.yaml`:

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
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-test-quality-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
```

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

