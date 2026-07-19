---
name: test-quality-audit-generator
description: "Investigator role for the test-quality-audit DiMo chain. Collects raw evidence from test files, spec SCs, git history, and VbC artifacts. Writes evidence.yaml — does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: test-quality-audit-generator

## Purpose

Investigator role for the test-quality-audit DiMo chain. Reads test files, spec success criteria, git history, and VbC artifacts to produce `evidence.yaml` with raw evidence about test coverage and quality. This role collects evidence only — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.

> **DiMo Role: Investigator.** This task generates raw evidence for test-quality-audit. Writes `evidence.yaml` with extracted test file data, SC-to-test mappings, git history evidence, and VbC artifact data.
>
> You are the Investigator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You do not decide what passes or fails. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST NOT assess test quality — that is the Evaluator's job
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `file_paths_changed`: List of file paths changed in the implementation
- `vbc_artifact_path`: Path to VbC (Verification-before-Completion) artifact
- `spec_issue_number`: Issue number for artifact path construction
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch. The orchestrator MUST verify `spec_local_dir` is a valid directory before dispatching. If the spec is only on GitHub (not locally mirrored), the orchestrator MUST mirror it as .md files in `spec_local_dir/` first. Dispatching without a valid `spec_local_dir` is a CRITICAL VIOLATION.
- `file_paths_changed` provided and non-empty — list of file paths from the implementation diff
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for evidence artifacts)
- `vbc_artifact_path` provided (optional — if absent, RED evidence collection will note it)
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- All spec SCs extracted with evidence type declarations
- All test files from `file_paths_changed` read and their content recorded
- Test file structure evidence collected (functions, assertions, imports, symbols)
- SC-to-test mapping built
- Git history evidence collected (assertion changes, RED state, commit ordering)
- VbC artifact evidence collected (if available)
- No PASS/FAIL judgments in the output — raw evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for test-quality-audit-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 3. Verify `file_paths_changed` is provided and non-empty
- [ ] 4. If `file_paths_changed` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "file_paths_changed"
remediation: "file_paths_changed is required for test-quality-audit-generator. The orchestrator must pass the list of changed file paths from the implementation diff."
```

- [ ] 5. Verify `artifact_evidence_dir` is writable — create it if it does not exist

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Spec Content

Read all spec files from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract the SC table — all success criteria with IDs, criterion text, evidence types, and verification methods
- [ ] 4. Record each SC: ID, criterion text, declared evidence type, verification method
- [ ] 5. Identify behavioral SCs (those requiring execution evidence)
- [ ] 6. Record spec file paths, sizes, and modification timestamps

Record in evidence:

```yaml
spec:
  files:
    - path: "<relative path within spec_local_dir>"
      size_bytes: <N>
      modified_at: "<timestamp>"
  sc_table:
    - id: "SC-1"
      criterion: "<exact criterion text>"
      evidence_type: "behavioral | semantic | string | structural | absent"
      verification_method: "<text or absent>"
  sc_count: <N>
  behavioral_sc_count: <N>
  string_sc_count: <N>
  structural_sc_count: <N>
  semantic_sc_count: <N>
```

### Step 3: Load Test Files

Read all test files referenced in `file_paths_changed`:

- [ ] 1. Filter `file_paths_changed` to test files only — match paths containing `test/`, `tests/`, `_test`, `test_`, or files ending in `_test.py`, `test_*.py`
- [ ] 2. For each test file, read the full content
- [ ] 3. Record file paths, sizes, and modification timestamps
- [ ] 4. If no test files found in `file_paths_changed`, record `test_files_found: false` and proceed — do NOT BLOCK

Record in evidence:

```yaml
test_files:
  - path: "<absolute path>"
    size_bytes: <N>
    modified_at: "<timestamp>"
    line_count: <N>
test_files_found: true | false
test_file_count: <N>
```

### Step 4: Collect Test Structure Evidence

For each test file, extract structural elements without evaluating quality:

- [ ] 1. **Function inventory** — List every test function (functions starting with `test_` or methods in `Test*` classes) with their line ranges
- [ ] 2. **Assertion inventory** — For each test function, extract every assertion statement (`assert`, `self.assert*`, `pytest.raises`, etc.) with the exact assertion text
- [ ] 3. **Import inventory** — List all imports in each test file, categorized by source module
- [ ] 4. **Symbol references** — Extract all function calls and class references in test bodies
- [ ] 5. **Fixture/mock inventory** — Record any fixtures, mocks, patches, or parametrize decorators
- [ ] 6. **Test class inventory** — If test classes exist, record class names and their test methods
- [ ] 7. **Edge case indicators** — Record presence of boundary value tests (0, -1, None, empty string, empty list, max value), error condition tests (raises, exception handling), and null/empty input tests

Record in evidence:

```yaml
test_structure:
  - file: "<path>"
    functions:
      - name: "<function name>"
        line_start: <N>
        line_end: <N>
        is_test: true | false
        assertions:
          - type: "assert | assertEqual | assertRaises | pytest.raises | ..."
            text: "<exact assertion text>"
            line: <N>
        referenced_symbols: ["<symbol>", ...]
        edge_case_indicators:
          boundary_values: ["<value>", ...]
          error_conditions: ["<exception type>", ...]
          null_empty_inputs: ["<value>", ...]
    imports:
      - module: "<module path>"
        imported_names: ["<name>", ...]
        category: "stdlib | third_party | project_local"
    fixtures:
      - name: "<fixture name>"
        scope: "<function | module | session>"
    mocks:
      - target: "<patch target>"
        location: "<function or class>"
    test_classes:
      - name: "<class name>"
        methods: ["<method name>", ...]
```

### Step 5: Collect SC-to-Test Mapping Evidence

Map spec success criteria to test functions without judging coverage:

- [ ] 1. For each SC from the spec, search test files for references to the SC's criterion text, symbols, or concepts
- [ ] 2. Record which test functions appear to test each SC (based on function names, docstrings, and assertion content)
- [ ] 3. Flag any SC that has no corresponding test function (record as `tests: []`)
- [ ] 4. Do NOT judge whether the mapping is sufficient — record what exists

Record in evidence:

```yaml
sc_test_map:
  - sc_id: "SC-1"
    criterion: "<criterion text>"
    evidence_type: "<type>"
    test_functions:
      - file: "<path>"
        function: "<name>"
        match_type: "name_match | docstring_match | assertion_match | symbol_match"
    test_count: <N>
    has_tests: true | false
```

### Step 6: Collect Cross-Boundary Evidence

Collect evidence about cross-module symbol references in tests:

- [ ] 1. For each test file, identify the module under test (infer from import structure and file naming)
- [ ] 2. For each test function, record symbols imported from outside the module under test
- [ ] 3. Record function calls and class instantiations that reference external modules
- [ ] 4. Do NOT judge whether cross-boundary coverage is sufficient — record what exists

Record in evidence:

```yaml
cross_boundary:
  - test_file: "<path>"
    module_under_test: "<inferred module path>"
    external_symbols:
      - symbol: "<symbol name>"
        source_module: "<module path>"
        used_in_functions: ["<test function name>", ...]
    has_cross_boundary_references: true | false
    cross_boundary_symbol_count: <N>
```

### Step 7: Collect Git History Evidence

Collect git history data for assertion changes and RED state evidence:

- [ ] 1. **Assertion change history** — For each test file, run `git log --follow -p -- <test_file_path>` to get the full diff history
- [ ] 2. **Assertion weakening detection** — For each commit that changes test assertions, record:
  - The commit SHA and message
  - The old assertion text and new assertion text
  - Whether the implementation file changed in the same commit
  - Whether expected values changed (weakened) while implementation stayed the same
- [ ] 3. **RED state evidence** — For each test file, check git history for evidence of test-first development:
  - Record the first commit that introduced each test function
  - Record the first commit that introduced the corresponding implementation
  - Record the chronological ordering (test-first vs. implementation-first)
- [ ] 4. **Sequential TDD evidence** — If multiple test items exist, record the commit ordering:
  - For each test item, record when its test was introduced and when its implementation was introduced
  - Record whether items show individual RED/GREEN cycles or RED-ALL → GREEN-ALL pattern
- [ ] 5. If git history is unavailable (single commit, shallow clone), record `git_history_available: false`

Record in evidence:

```yaml
git_history:
  available: true | false
  assertion_changes:
    - test_file: "<path>"
      commit_sha: "<sha>"
      commit_message: "<message>"
      commit_date: "<ISO timestamp>"
      old_assertion: "<text>"
      new_assertion: "<text>"
      implementation_changed_same_commit: true | false
      expected_value_changed: true | false
      expected_value_weakened: true | false | unable_to_determine
  red_evidence:
    - test_file: "<path>"
      test_function: "<name>"
      test_first_commit: "<sha>"
      test_first_commit_date: "<ISO timestamp>"
      implementation_first_commit: "<sha or absent>"
      implementation_first_commit_date: "<ISO timestamp or absent>"
      test_before_implementation: true | false | unable_to_determine
  sequential_tdd:
    items:
      - test_function: "<name>"
        test_commit: "<sha>"
        test_commit_date: "<ISO timestamp>"
        implementation_commit: "<sha>"
        implementation_commit_date: "<ISO timestamp>"
        ordering: "test_first | implementation_first | same_commit | unable_to_determine"
    pattern: "individual_red_green | red_all_green_all | single_item | unable_to_determine"
```

### Step 8: Collect VbC Artifact Evidence

If `vbc_artifact_path` is provided, collect evidence from the VbC artifact:

- [ ] 1. Verify `vbc_artifact_path` exists and is readable
- [ ] 2. Read the VbC artifact content
- [ ] 3. Extract SC verification results — which SCs were verified and their verdicts
- [ ] 4. Extract behavioral test execution evidence — test run logs, session outputs
- [ ] 5. Extract RED/GREEN phase evidence — whether tests were confirmed RED before GREEN
- [ ] 6. If `vbc_artifact_path` is absent or unreadable, record `vbc_available: false`

Record in evidence:

```yaml
vbc_evidence:
  available: true | false
  artifact_path: "<path or absent>"
  artifact_size_bytes: <N or absent>
  sc_verification_results:
    - sc_id: "SC-1"
      verdict: "PASS | FAIL | UNVERIFIED"
      evidence_type_used: "behavioral | semantic | string | structural"
  behavioral_test_runs:
    - test_name: "<name>"
      executed: true | false
      output_available: true | false
  red_green_evidence:
    red_phase_confirmed: true | false | absent
    green_phase_confirmed: true | false | absent
```

### Step 9: Collect Edge Case Evidence

Collect evidence about edge case coverage in test files:

- [ ] 1. For each function under test (inferred from test function names and imports), count the number of test functions that exercise it
- [ ] 2. Record whether boundary value tests exist (0, -1, None, empty, max, min)
- [ ] 3. Record whether error condition tests exist (exception raising, invalid input)
- [ ] 4. Record whether null/empty input tests exist
- [ ] 5. Do NOT judge completeness — record what exists

Record in evidence:

```yaml
edge_case_evidence:
  - function_under_test: "<inferred function name>"
    test_count: <N>
    test_functions: ["<name>", ...]
    has_boundary_tests: true | false
    boundary_values_tested: ["<value>", ...]
    has_error_tests: true | false
    error_conditions_tested: ["<exception type>", ...]
    has_null_empty_tests: true | false
    null_empty_values_tested: ["<value>", ...]
```

### Step 10: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: test-quality-audit-generator
issue_number: <N>
generated_at: "<ISO timestamp>"
spec_local_dir: "<path>"
spec:
  files: [...]
  sc_table: [...]
  sc_count: <N>
  behavioral_sc_count: <N>
  string_sc_count: <N>
  structural_sc_count: <N>
  semantic_sc_count: <N>
test_files: [...]
test_files_found: true | false
test_file_count: <N>
test_structure: [...]
sc_test_map: [...]
cross_boundary: [...]
git_history:
  available: true | false
  assertion_changes: [...]
  red_evidence: [...]
  sequential_tdd: {...}
vbc_evidence:
  available: true | false
  artifact_path: "<path or absent>"
  sc_verification_results: [...]
  behavioral_test_runs: [...]
  red_green_evidence: {...}
edge_case_evidence: [...]
```

### Step 11: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: <N> spec SCs, <M> test files, <K> test functions, <J> assertion changes in git history. VbC artifact: <available|unavailable>. No judgments applied."
sc_count: <N>
test_file_count: <N>
test_function_count: <N>
git_history_available: true | false
vbc_available: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Spec Content → INVALID if skipped
- [ ] 3. Load Test Files → INVALID if skipped
- [ ] 4. Collect Test Structure Evidence → INVALID if skipped
- [ ] 5. Collect SC-to-Test Mapping Evidence → INVALID if skipped
- [ ] 6. Collect Cross-Boundary Evidence → INVALID if skipped
- [ ] 7. Collect Git History Evidence → INVALID if skipped
- [ ] 8. Collect VbC Artifact Evidence → INVALID if skipped
- [ ] 9. Collect Edge Case Evidence → INVALID if skipped
- [ ] 10. Write evidence.yaml → INVALID if skipped
- [ ] 11. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| file_paths_changed missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| No test files found in file_paths_changed | Record `test_files_found: false`, proceed — do NOT BLOCK |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| git history unavailable (shallow clone, single commit) | Record `git_history.available: false`, proceed — do NOT BLOCK |
| vbc_artifact_path absent or unreadable | Record `vbc_evidence.available: false`, proceed — do NOT BLOCK |
| Test file read fails (permissions, missing) | Record error for that file, continue with remaining files |
| No SCs found in spec | Return BLOCKED — spec must contain SC table |

## Cross-References

- `tasks/test-quality-audit.md` — Evaluator role (consumes this Investigator's evidence.yaml)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- Load [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations
- Load [Test Integrity Mandate](guidelines/080-code-standards.md) — no lobotomizing tests
- Load [Behavioral RED/GREEN as Primary Enforcement Gate](guidelines/080-code-standards.md)
- `verification-before-completion/SKILL.md` — VbC artifact format
- `000-critical-rules.md` — behavioral evidence mandate

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
