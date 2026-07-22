---
name: test-quality-audit-knowledge-supporter
description: "Validator role for the test-quality-audit chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: test-quality-audit-knowledge-supporter

## Purpose

Validator role for the test-quality-audit chain. Reads `evidence.yaml` produced by the Investigator, validates each evidence item against source data (spec files, test files, git history, VbC artifacts), and writes `reasoning.yaml` with validated evidence. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory containing `evidence.yaml` from the Investigator
- `file_paths_changed`: List of file paths changed in the implementation
- `vbc_artifact_path`: Path to VbC (Verification-before-Completion) artifact
- `spec_issue_number`: Issue number for artifact path construction
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_EVIDENCE_YAML.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `file_paths_changed` provided and non-empty — list of file paths from the implementation diff
- `spec_issue_number` provided
- `github.owner`, `github.repo` available

## Exit Criteria

- All evidence items from `evidence.yaml` validated against source data
- Spec SC table cross-checked against actual spec files
- Test file evidence validated — files exist, sizes match, content readable
- Test structure evidence validated — functions, assertions, imports verified against actual test files
- SC-to-test mappings verified — SC IDs exist in spec, test functions exist in test files
- Cross-boundary evidence validated — external symbols verified against actual test file imports
- Git history evidence validated — assertion changes, RED state, sequential TDD cross-checked against actual git log
- VbC artifact evidence validated — artifact exists, content readable, SC verdicts cross-checked
- Edge case evidence validated — functions under test verified against actual test files
- `reasoning.yaml` written to `{artifact_evidence_dir}/reasoning.yaml`
- No PASS/FAIL judgments in output — validated evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove `reasoning.yaml` if it exists from a prior run at `{artifact_evidence_dir}/reasoning.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file and confirm it is non-empty
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_YAML
missing: "{artifact_evidence_dir}/evidence.yaml"
remediation: "evidence.yaml is required for test-quality-audit-knowledge-supporter. The Investigator must produce evidence.yaml before the Validator can validate it."
```

- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 4. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for test-quality-audit-knowledge-supporter. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 5. Verify `file_paths_changed` is provided and non-empty
- [ ] 6. If `file_paths_changed` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "file_paths_changed"
remediation: "file_paths_changed is required for test-quality-audit-knowledge-supporter. The orchestrator must pass the list of changed file paths from the implementation diff."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load evidence.yaml

Read the Investigator's `evidence.yaml` from `{artifact_evidence_dir}/evidence.yaml`:

- [ ] 1. Read the full YAML file via `read` tool
- [ ] 2. Parse the evidence structure: `spec`, `test_files`, `test_structure`, `sc_test_map`, `cross_boundary`, `git_history`, `vbc_evidence`, `edge_case_evidence`
- [ ] 3. Extract the list of SCs with their declared evidence types from `spec.sc_table`
- [ ] 4. Extract the list of test files with their metadata (path, size, modification time, line count)
- [ ] 5. Extract the test structure data (functions, assertions, imports, fixtures, mocks, test classes)
- [ ] 6. Extract the SC-to-test mapping from `sc_test_map`
- [ ] 7. Extract cross-boundary evidence from `cross_boundary`
- [ ] 8. Extract git history evidence from `git_history`
- [ ] 9. Extract VbC evidence from `vbc_evidence`
- [ ] 10. Extract edge case evidence from `edge_case_evidence`
- [ ] 11. Record the `generated_at` timestamp and `issue_number` from the evidence

### Step 3: Validate Spec Evidence

Cross-check the spec data in `evidence.yaml` against the actual spec files:

- [ ] 1. **Spec file existence** — For each file in `spec.files`, verify the file exists at the recorded path within `spec_local_dir/`. Use `glob` or `read` to confirm.
- [ ] 2. **Spec file metadata** — For each spec file, verify `size_bytes` and `modified_at` match the actual file on disk.
- [ ] 3. **SC table validation** — For each SC in `spec.sc_table`:
  - [ ] 3a. Verify the SC ID exists in the spec files — read the spec files and confirm the SC ID and criterion text match
  - [ ] 3b. Verify the `evidence_type` declared in the evidence matches the evidence type declared in the spec source
  - [ ] 3c. Verify the `verification_method` (if present) matches the spec source
- [ ] 4. **SC count validation** — Verify `spec.sc_count` matches the actual number of SCs found in the spec files
- [ ] 5. **SC type count validation** — Verify `spec.behavioral_sc_count`, `spec.string_sc_count`, `spec.structural_sc_count`, and `spec.semantic_sc_count` match the actual counts from the spec's evidence type declarations

Record validation results:

```yaml
spec_validation:
  files:
    - path: "<relative path within spec_local_dir>"
      exists: true | false
      size_matches: true | false
      evidence_size: <N>
      actual_size: <N>
      modified_at_matches: true | false
      evidence_modified: "<timestamp>"
      actual_modified: "<timestamp>"
  sc_table:
    - sc_id: "SC-1"
      sc_exists_in_spec: true | false
      criterion_text_matches: true | false
      evidence_type_matches_spec: true | false
      spec_declared_type: "<type from spec>"
      evidence_declared_type: "<type from evidence.yaml>"
      verification_method_matches: true | false | not_applicable
  sc_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
  behavioral_sc_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
  string_sc_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
  structural_sc_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
  semantic_sc_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
```

### Step 4: Validate Test File Evidence

Cross-check the test file data in `evidence.yaml` against the actual files on disk:

- [ ] 1. **Test file existence** — For each test file in `test_files`, verify the file exists at the recorded path. Use `glob` or `read` to confirm.
- [ ] 2. **Test file metadata** — For each test file, verify `size_bytes`, `modified_at`, and `line_count` match the actual file on disk.
- [ ] 3. **Test file readability** — For each test file, attempt to read the file. Record whether it is readable and non-empty.
- [ ] 4. **Test file count** — Verify `test_file_count` matches the actual count of test files in the list.
- [ ] 5. **Test files found flag** — Verify `test_files_found` is consistent with the actual presence of test files. If `test_files_found: false` but test files exist in `file_paths_changed`, flag as `TEST_FILES_FOUND_MISMATCH`. If `test_files_found: true` but no test files exist, flag as `TEST_FILES_FOUND_MISMATCH`.

Record validation results:

```yaml
test_file_validation:
  files:
    - path: "<absolute path>"
      exists: true | false
      readable: true | false
      size_matches: true | false
      evidence_size: <N>
      actual_size: <N>
      modified_at_matches: true | false
      evidence_modified: "<timestamp>"
      actual_modified: "<timestamp>"
      line_count_matches: true | false
      evidence_line_count: <N>
      actual_line_count: <N>
  test_file_count:
    evidence_value: <N>
    actual_value: <N>
    result: validated | mismatch
  test_files_found:
    evidence_value: true | false
    actual_value: true | false
    result: validated | mismatch
```

### Step 5: Validate Test Structure Evidence

Cross-check the test structure data in `evidence.yaml` against the actual test file contents:

- [ ] 1. **Function inventory** — For each test file's `functions` list, read the actual test file and verify:
  - [ ] 1a. Each function name exists in the file
  - [ ] 1b. `line_start` and `line_end` are within the file's line range
  - [ ] 1c. `is_test` classification is consistent with the function name (starts with `test_` or is a method in a `Test*` class)
- [ ] 2. **Assertion inventory** — For each function's `assertions` list, verify the assertion text appears in the function body. Spot-check at least 3 assertions per file.
- [ ] 3. **Import inventory** — For each test file's `imports` list, verify the module and imported names appear in the file's import statements.
- [ ] 4. **Fixture/mock inventory** — For each test file's `fixtures` and `mocks` lists, verify the fixture names and patch targets appear in the file.
- [ ] 5. **Test class inventory** — For each test file's `test_classes` list, verify the class name and method names exist in the file.
- [ ] 6. **Edge case indicators** — For each function's `edge_case_indicators`, verify the recorded boundary values, error conditions, and null/empty inputs appear in the function body.

Record validation results:

```yaml
test_structure_validation:
  - file: "<path>"
    functions:
      - name: "<function name>"
        exists_in_file: true | false
        line_range_valid: true | false
        is_test_correct: true | false
        assertions:
          - type: "<assertion type>"
            text: "<assertion text>"
            found_in_function: true | false
        imports_valid: true | false
        fixtures_valid: true | false
        mocks_valid: true | false
        test_classes_valid: true | false
        edge_case_indicators_valid: true | false
```

### Step 6: Validate SC-to-Test Mapping Evidence

Cross-check the SC-to-test mapping in `evidence.yaml` against source data:

- [ ] 1. **SC existence check** — For each entry in `sc_test_map`, verify the SC ID exists in the spec files at `spec_local_dir/`. Read the spec files and confirm the SC ID and criterion text match.
- [ ] 2. **Evidence type cross-check** — For each SC, read the declared evidence type from the spec source and compare against the `evidence_type` in the mapping. Record any mismatch.
- [ ] 3. **Test function existence** — For each test function listed in the SC's `test_functions` array, verify the function exists in the recorded test file. Read the test file and confirm the function name is present.
- [ ] 4. **Match type validation** — For each test function, verify the `match_type` classification is consistent with the actual content:
  - `name_match` — the function name contains the SC ID or criterion keywords
  - `docstring_match` — the function's docstring references the SC
  - `assertion_match` — the function's assertions reference values from the SC
  - `symbol_match` — the function calls symbols related to the SC
- [ ] 5. **Test count validation** — Verify `test_count` matches the actual count of test functions in the list.
- [ ] 6. **Has tests flag** — Verify `has_tests` is consistent with the presence of test functions. If `has_tests: false` but test functions are listed, flag as `HAS_TESTS_MISMATCH`. If `has_tests: true` but no test functions are listed, flag as `HAS_TESTS_MISMATCH`.

Record validation results:

```yaml
sc_test_map_validation:
  - sc_id: "SC-1"
    sc_exists_in_spec: true | false
    criterion_text_matches: true | false
    evidence_type_matches_spec: true | false
    spec_declared_type: "<type from spec>"
    evidence_declared_type: "<type from evidence.yaml>"
    test_functions:
      - file: "<path>"
        function: "<name>"
        exists_in_file: true | false
        match_type_valid: true | false
        evidence_match_type: "<type>"
        observed_match_type: "<type>"
    test_count:
      evidence_value: <N>
      actual_value: <N>
      result: validated | mismatch
    has_tests:
      evidence_value: true | false
      actual_value: true | false
      result: validated | mismatch
```

### Step 7: Validate Cross-Boundary Evidence

Cross-check the cross-boundary evidence in `evidence.yaml` against actual test file contents:

- [ ] 1. **Module under test** — For each entry in `cross_boundary`, verify the `module_under_test` inference is consistent with the test file's import structure and file naming.
- [ ] 2. **External symbol existence** — For each `external_symbols` entry, verify the symbol exists in the test file's imports and is used in the recorded test functions.
- [ ] 3. **Source module validation** — For each external symbol, verify the `source_module` matches the import statement in the test file.
- [ ] 4. **Used in functions** — For each external symbol, verify the `used_in_functions` list matches actual usage in the test file.
- [ ] 5. **Flag validation** — Verify `has_cross_boundary_references` and `cross_boundary_symbol_count` are consistent with the actual data.

Record validation results:

```yaml
cross_boundary_validation:
  - test_file: "<path>"
    module_under_test_valid: true | false
    evidence_module: "<inferred module>"
    observed_module: "<inferred module>"
    external_symbols:
      - symbol: "<symbol name>"
        exists_in_imports: true | false
        source_module_matches: true | false
        evidence_source: "<module path>"
        actual_source: "<module path>"
        used_in_functions_valid: true | false
    has_cross_boundary_references:
      evidence_value: true | false
      actual_value: true | false
      result: validated | mismatch
    cross_boundary_symbol_count:
      evidence_value: <N>
      actual_value: <N>
      result: validated | mismatch
```

### Step 8: Validate Git History Evidence

Cross-check the git history evidence in `evidence.yaml` against the actual git log:

- [ ] 1. **Git history availability** — Verify `git_history.available` is consistent with the actual git repository state. Run `git log --oneline -1` to confirm git history exists.
- [ ] 2. If `git_history.available: false`, verify that git history is genuinely unavailable (shallow clone, single commit). Record as `validated` if confirmed.
- [ ] 3. If `git_history.available: true`:
  - [ ] 3a. **Assertion changes** — For each entry in `assertion_changes`, run `git log --follow -p -- <test_file_path>` and verify:
    - The commit SHA exists
    - The commit message matches
    - The old and new assertion text appear in the diff
    - `implementation_changed_same_commit` is consistent with the commit's file list
    - `expected_value_changed` and `expected_value_weakened` are consistent with the diff
  - [ ] 3b. **RED evidence** — For each entry in `red_evidence`, verify:
    - The test function exists in the test file
    - `test_first_commit` is a valid commit SHA
    - `implementation_first_commit` (if present) is a valid commit SHA
    - `test_before_implementation` is consistent with commit timestamps
  - [ ] 3c. **Sequential TDD** — For each item in `sequential_tdd.items`, verify:
    - The test function exists
    - `test_commit` and `implementation_commit` are valid commit SHAs
    - `ordering` is consistent with commit timestamps
  - [ ] 3d. **Pattern validation** — Verify `sequential_tdd.pattern` is consistent with the items' ordering data
- [ ] 4. If git history is unavailable but `evidence.yaml` claims `available: true`, flag as `GIT_HISTORY_AVAILABILITY_MISMATCH`

Record validation results:

```yaml
git_history_validation:
  available:
    evidence_value: true | false
    actual_value: true | false
    result: validated | mismatch
  assertion_changes:
    - test_file: "<path>"
      commit_sha: "<sha>"
      commit_exists: true | false
      commit_message_matches: true | false
      old_assertion_in_diff: true | false
      new_assertion_in_diff: true | false
      implementation_changed_same_commit_valid: true | false
      expected_value_changed_valid: true | false
      expected_value_weakened_valid: true | false
  red_evidence:
    - test_file: "<path>"
      test_function: "<name>"
      test_function_exists: true | false
      test_first_commit_valid: true | false
      implementation_first_commit_valid: true | false | not_applicable
      test_before_implementation_valid: true | false
  sequential_tdd:
    items:
      - test_function: "<name>"
        test_function_exists: true | false
        test_commit_valid: true | false
        implementation_commit_valid: true | false
        ordering_valid: true | false
    pattern:
      evidence_value: "<pattern>"
      observed_value: "<pattern>"
      result: validated | mismatch
```

### Step 9: Validate VbC Artifact Evidence

Cross-check the VbC artifact evidence in `evidence.yaml` against the actual VbC artifact:

- [ ] 1. **VbC availability** — Verify `vbc_evidence.available` is consistent with the actual presence of the VbC artifact.
- [ ] 2. If `vbc_evidence.available: true`:
  - [ ] 2a. Verify `artifact_path` exists and is readable
  - [ ] 2b. Verify `artifact_size_bytes` matches the actual file size
  - [ ] 2c. Read the VbC artifact and verify `sc_verification_results` — for each SC verdict, confirm the SC ID, verdict, and evidence type used match the VbC artifact content
  - [ ] 2d. Verify `behavioral_test_runs` — for each test run, confirm `executed` and `output_available` match the VbC artifact content
  - [ ] 2e. Verify `red_green_evidence` — confirm `red_phase_confirmed` and `green_phase_confirmed` match the VbC artifact content
- [ ] 3. If `vbc_evidence.available: false`, verify that no VbC artifact path was provided or the artifact is genuinely absent. Record as `validated` if confirmed.

Record validation results:

```yaml
vbc_validation:
  available:
    evidence_value: true | false
    actual_value: true | false
    result: validated | mismatch
  artifact_path:
    evidence_value: "<path or absent>"
    exists: true | false
    result: validated | mismatch | not_applicable
  artifact_size_bytes:
    evidence_value: <N or absent>
    actual_value: <N or absent>
    result: validated | mismatch | not_applicable
  sc_verification_results:
    - sc_id: "SC-1"
      found_in_vbc: true | false
      verdict_matches: true | false
      evidence_verdict: "PASS | FAIL | UNVERIFIED"
      actual_verdict: "PASS | FAIL | UNVERIFIED"
      evidence_type_used_matches: true | false
  behavioral_test_runs:
    - test_name: "<name>"
      found_in_vbc: true | false
      executed_matches: true | false
      output_available_matches: true | false
  red_green_evidence:
    red_phase_confirmed_matches: true | false | not_applicable
    green_phase_confirmed_matches: true | false | not_applicable
```

### Step 10: Validate Edge Case Evidence

Cross-check the edge case evidence in `evidence.yaml` against actual test file contents:

- [ ] 1. **Function under test existence** — For each entry in `edge_case_evidence`, verify the `function_under_test` exists in the test files (inferred from test function names and imports).
- [ ] 2. **Test function existence** — For each test function in the `test_functions` list, verify the function exists in the test files.
- [ ] 3. **Test count validation** — Verify `test_count` matches the actual count of test functions in the list.
- [ ] 4. **Boundary tests** — Verify `has_boundary_tests` is consistent with the presence of boundary value assertions in the test functions. Spot-check `boundary_values_tested` against actual test content.
- [ ] 5. **Error tests** — Verify `has_error_tests` is consistent with the presence of error condition assertions in the test functions. Spot-check `error_conditions_tested` against actual test content.
- [ ] 6. **Null/empty tests** — Verify `has_null_empty_tests` is consistent with the presence of null/empty input assertions in the test functions. Spot-check `null_empty_values_tested` against actual test content.

Record validation results:

```yaml
edge_case_validation:
  - function_under_test: "<inferred function name>"
    function_exists_in_tests: true | false
    test_functions:
      - name: "<test function name>"
        exists_in_file: true | false
    test_count:
      evidence_value: <N>
      actual_value: <N>
      result: validated | mismatch
    has_boundary_tests:
      evidence_value: true | false
      actual_value: true | false
      result: validated | mismatch
    boundary_values_valid: true | false
    has_error_tests:
      evidence_value: true | false
      actual_value: true | false
      result: validated | mismatch
    error_conditions_valid: true | false
    has_null_empty_tests:
      evidence_value: true | false
      actual_value: true | false
      result: validated | mismatch
    null_empty_values_valid: true | false
```

### Step 11: Assemble reasoning.yaml

Assemble the validated evidence into the reasoning structure:

```yaml
reasoning:
  generated_at: "<ISO timestamp>"
  spec_issue_number: <N>
  evidence_source: "{artifact_evidence_dir}/evidence.yaml"
  evidence_generated_at: "<timestamp from evidence.yaml>"
  validation_summary:
    total_evidence_sections: 8
    sections_validated: <N>
    sections_with_issues: <N>
    total_items_validated: <N>
    total_validated: <N>
    total_mismatches: <N>
    total_unverifiable: <N>
  spec_validation: {...}
  test_file_validation: {...}
  test_structure_validation: [...]
  sc_test_map_validation: [...]
  cross_boundary_validation: [...]
  git_history_validation: {...}
  vbc_validation: {...}
  edge_case_validation: [...]
  issues:
    - type: "SC_NOT_IN_SPEC | TYPE_DECLARATION_MISMATCH | TEST_FILE_NOT_FOUND | TEST_FILES_FOUND_MISMATCH | FUNCTION_NOT_FOUND | ASSERTION_NOT_FOUND | IMPORT_MISMATCH | HAS_TESTS_MISMATCH | CROSS_BOUNDARY_MISMATCH | GIT_HISTORY_AVAILABILITY_MISMATCH | COMMIT_NOT_FOUND | VBC_ARTIFACT_MISSING | VBC_VERDICT_MISMATCH | EDGE_CASE_MISMATCH | METADATA_MISMATCH | UNREADABLE_FILE"
      sc_id: "<SC-ID or null>"
      file: "<path or null>"
      description: "<description>"
```

### Step 12: Write reasoning.yaml

Write the assembled reasoning structure to `{artifact_evidence_dir}/reasoning.yaml`:

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `reasoning.yaml` with the complete reasoning structure
- [ ] 3. Verify the file was written and is non-empty

### Step 13: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: {sections_validated}/8 sections validated, {total_validated}/{total_items_validated} items confirmed. {total_mismatches} mismatches, {total_unverifiable} unverifiable."
sections_validated: <N>
total_items_validated: <N>
total_validated: <N>
total_mismatches: <N>
total_unverifiable: <N>
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: {sections_validated}/8 sections validated, {total_validated}/{total_items_validated} items confirmed. {total_mismatches} mismatches, {total_unverifiable} unverifiable."
```

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml absent | Return BLOCKED with MISSING_EVIDENCE_YAML |
| evidence.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_EVIDENCE_YAML |
| spec_local_dir absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| file_paths_changed missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| No SCs in evidence.yaml | Return BLOCKED — evidence.yaml must contain spec.sc_table |
| Test file not found at recorded path | Record as mismatch in test_file_validation — do NOT BLOCK |
| Test file unreadable | Record as mismatch in test_file_validation — do NOT BLOCK |
| SC not found in spec | Record as mismatch in sc_test_map_validation — do NOT BLOCK |
| Test function not found in file | Record as mismatch in sc_test_map_validation — do NOT BLOCK |
| Git history unavailable | Record as mismatch in git_history_validation — do NOT BLOCK |
| VbC artifact absent or unreadable | Record as mismatch in vbc_validation — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write reasoning.yaml |
| evidence.yaml missing required top-level keys | Return BLOCKED with MALFORMED_EVIDENCE and missing key name |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate Spec Evidence → INVALID if skipped
- [ ] 4. Validate Test File Evidence → INVALID if skipped
- [ ] 5. Validate Test Structure Evidence → INVALID if skipped
- [ ] 6. Validate SC-to-Test Mapping Evidence → INVALID if skipped
- [ ] 7. Validate Cross-Boundary Evidence → INVALID if skipped
- [ ] 8. Validate Git History Evidence → INVALID if skipped
- [ ] 9. Validate VbC Artifact Evidence → INVALID if skipped
- [ ] 10. Validate Edge Case Evidence → INVALID if skipped
- [ ] 11. Assemble reasoning.yaml → INVALID if skipped
- [ ] 12. Write reasoning.yaml → INVALID if skipped
- [ ] 13. Return Frugal Result Contract → INVALID if skipped

## Cross-References

- `tasks/test-quality-audit-investigator.md` — Investigator role (produces evidence.yaml consumed by this task)
- `tasks/test-quality-audit.md` — Evaluator role (consumes reasoning.yaml produced by this task)
- `tasks/cross-validate.md` — Arbiter role (reads all artifacts, writes judgment.yaml)
- Read [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations and enforcement matrix
- Read [Test Integrity Mandate](guidelines/080-code-standards.md) — no lobotomizing tests
- Read [Behavioral RED/GREEN as Primary Enforcement Gate](guidelines/080-code-standards.md)
- `verification-before-completion/SKILL.md` — VbC artifact format
- `000-critical-rules.md` — behavioral evidence mandate

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
