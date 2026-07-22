---
name: drift-detection-knowledge-supporter
description: "Validator role for the drift-detection chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge — validates and supports the evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection-knowledge-supporter

## Purpose

Validator role for the drift-detection chain. Reads `evidence.yaml` produced by the Investigator, validates each evidence item against source data (spec files, code files, live tool calls), and writes `reasoning.yaml` with validated evidence and source references. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory for evidence artifacts — contains `evidence.yaml` from Investigator
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `target_files`: Optional — specific file paths that were scanned. If absent, extracted from spec.

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Validator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for reasoning artifacts)

## Exit Criteria

- `reasoning.yaml` written to `{artifact_evidence_dir}/reasoning.yaml`
- Every evidence item in `evidence.yaml` validated against source data
- Validation results recorded per evidence item: `validated`, `corrected`, or `unverifiable` with reason
- Source data references recorded for each validation check
- No PASS/FAIL judgments in the output — validated evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `reasoning.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for drift-detection-knowledge-supporter. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Validator."
```

- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 4. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for drift-detection-knowledge-supporter. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 5. Verify `artifact_evidence_dir` is writable — create it if it does not exist

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load evidence.yaml

Read the Investigator's evidence artifact in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Parse all top-level sections: `spec_requirements`, `target_files`, `code_implementation`, `raw_comparisons`, `untracked_files`, `documentation_sources`
- [ ] 3. Record the Investigator's metadata: `generator`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 4. If any expected top-level section is absent, record as `section_missing` — do NOT BLOCK, but flag for the Evaluator

### Step 3: Validate Spec Requirements Evidence

Cross-check the `spec_requirements` section against the actual spec files:

- [ ] 1. **Spec files validation** — For each file entry in `spec_requirements.spec_files`, verify the file exists at `<spec_local_dir>/<path>` via `read` tool. Verify `size_bytes` and `modified_at` match the actual file.
- [ ] 2. **Problem statement validation** — Re-read the spec and verify `problem_statement` matches the actual problem statement text in the spec body.
- [ ] 3. **Success criteria validation** — Re-read the spec and extract the SC table. For each SC in `success_criteria`, verify the `id`, `criterion` text, and `evidence_type` match the actual spec content.
- [ ] 4. **Phases validation** — Re-read the spec and extract phase headings. For each phase in `phases`, verify the `heading` and `sub_items` match the actual spec content.
- [ ] 5. **File requirements validation** — Re-read the spec and extract all file paths mentioned. For each entry in `file_requirements`, verify the `path`, `mentioned_in_section`, `expected_functions`, and `expected_classes` match the actual spec content. Check for file paths the Investigator may have missed.
- [ ] 6. **Function references validation** — Re-read the spec and extract all function/class/method references. For each entry in `function_references`, verify the `name`, `mentioned_in_section`, and `expected_signature` match the actual spec content. Check for references the Investigator may have missed.
- [ ] 7. **Edge cases validation** — Re-read the spec and extract all edge case descriptions. For each entry in `edge_cases`, verify the `description` and `mentioned_in_section` match the actual spec content. Check for edge cases the Investigator may have missed.

Record in reasoning:

```yaml
spec_requirements_validation:
  spec_files:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - path: "<relative path>"
        field: "size_bytes | modified_at"
        evidence_value: "<value>"
        actual_value: "<value>"
  problem_statement:
    validation_status: "validated | corrected | unvalidated"
    evidence_text: "<text>"
    actual_text: "<text>"
  success_criteria:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - sc_id: "<SC-ID>"
        field: "criterion | evidence_type"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_scs:
      - id: "<SC-ID>"
        criterion: "<text>"
  phases:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_heading: "<text>"
        actual_heading: "<text or absent>"
        type: "missing | extra | text_mismatch"
  file_requirements:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_path: "<path>"
        field: "mentioned_in_section | expected_functions | expected_classes"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_files:
      - path: "<path>"
        mentioned_in_section: "<section>"
  function_references:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_name: "<name>"
        field: "mentioned_in_section | expected_signature"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_references:
      - name: "<name>"
        mentioned_in_section: "<section>"
  edge_cases:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_description: "<text>"
        field: "mentioned_in_section"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_edge_cases:
      - description: "<text>"
        mentioned_in_section: "<section>"
```

### Step 4: Validate Target Files Evidence

Cross-check the `target_files` section against the actual filesystem:

- [ ] 1. Verify `target_files.source` matches the dispatch contract — if `target_files` was provided in dispatch, source should be `dispatch_contract`; otherwise `spec_extraction`
- [ ] 2. For each file entry in `target_files.files`, verify `exists` by checking the actual filesystem via `glob` or `read` tool
- [ ] 3. If a file the Investigator reported as existing does not exist, flag as `corrected`
- [ ] 4. If a file the Investigator reported as missing actually exists, flag as `corrected`
- [ ] 5. If `target_files` was extracted from spec, verify all spec file requirements are represented

Record in reasoning:

```yaml
target_files_validation:
  validation_status: "validated | corrected | unvalidated"
  evidence_source: "<value>"
  actual_source: "<value>"
  evidence_file_count: <N>
  actual_file_count: <N>
  mismatches:
    - path: "<file path>"
      evidence_exists: true | false
      actual_exists: true | false
  missed_files:
    - path: "<file path from spec not in evidence>"
```

### Step 5: Validate Code Implementation Evidence

Cross-check the `code_implementation` section against the actual code files:

- [ ] 1. **File existence validation** — For each file entry in `code_implementation.files`, verify `exists` by checking the actual filesystem via `glob` or `read` tool
- [ ] 2. **File metadata validation** — For each existing file, verify `size_bytes`, `line_count`, and `modified_at` match the actual file
- [ ] 3. **Symbol validation** — For each symbol in `symbols`, re-lookup using `srclight_get_signature` and verify:
  - `name` matches the actual symbol name
  - `kind` matches the actual symbol kind
  - `signature` matches the actual signature returned
  - `line` matches the actual line number
- [ ] 4. **Symbol completeness** — For each existing file, use `srclight_symbols_in_file` to extract all symbols and verify the Investigator captured all of them. Record any missed symbols.
- [ ] 5. **Content hash validation** — If `raw_content_hash` is present, verify it matches the actual file content hash

If `srclight_get_signature` or `srclight_symbols_in_file` is unavailable, mark affected items as `unverifiable: true` with reason `TOOL_UNAVAILABLE`.

Record in reasoning:

```yaml
code_implementation_validation:
  files:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - path: "<file path>"
        field: "exists | size_bytes | line_count | modified_at"
        evidence_value: "<value>"
        actual_value: "<value>"
  symbols:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<file path>"
        symbol_name: "<name>"
        field: "kind | signature | line"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_symbols:
      - file: "<file path>"
        symbol_name: "<name>"
        kind: "<kind>"
        signature: "<signature>"
  content_hashes:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<file path>"
        evidence_hash: "<hash>"
        actual_hash: "<hash>"
```

### Step 6: Validate Raw Comparison Data

Cross-check the `raw_comparisons` section against source data:

- [ ] 1. **File presence validation** — For each entry in `raw_comparisons.file_presence`, verify:
  - `spec_file` exists in the spec's file requirements (validated in Step 3)
  - `code_file_exists` matches the actual filesystem state (validated in Step 5)
  - `matching_code_path` is the correct path if the file exists
- [ ] 2. **Function presence validation** — For each entry in `raw_comparisons.function_presence`, verify:
  - `spec_function` exists in the spec's function references (validated in Step 3)
  - `found_in_code` matches the actual symbol presence (validated in Step 5)
  - `found_in_file` and `symbol_kind` match the actual code
- [ ] 3. **Signature comparison validation** — For each entry in `raw_comparisons.signature_comparisons`, verify:
  - `spec_function` exists in the spec's function references
  - `expected_signature` matches the spec's expected signature
  - `actual_signature` matches the actual code signature from `srclight_get_signature`
  - `spec_has_signature` and `code_has_signature` are consistent with the actual data
- [ ] 4. **Extra code validation** — For each entry in `raw_comparisons.extra_code`, verify:
  - The symbol actually exists in the stated file via `srclight_get_signature`
  - The symbol is genuinely not mentioned in the spec (cross-check against spec function references)
  - `not_in_spec` is accurate
- [ ] 5. **Edge case coverage validation** — For each entry in `raw_comparisons.edge_case_coverage`, verify:
  - `edge_case` exists in the spec's edge cases (validated in Step 3)
  - `related_code_found` is consistent with the actual code scan
  - `related_file` and `related_symbol` are accurate if present

Record in reasoning:

```yaml
raw_comparisons_validation:
  file_presence:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - spec_file: "<path>"
        field: "code_file_exists | matching_code_path"
        evidence_value: "<value>"
        actual_value: "<value>"
  function_presence:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - spec_function: "<name>"
        field: "found_in_code | found_in_file | symbol_kind"
        evidence_value: "<value>"
        actual_value: "<value>"
  signature_comparisons:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - spec_function: "<name>"
        field: "expected_signature | actual_signature | spec_has_signature | code_has_signature"
        evidence_value: "<value>"
        actual_value: "<value>"
  extra_code:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<file path>"
        symbol_name: "<name>"
        field: "symbol_kind | signature | not_in_spec"
        evidence_value: "<value>"
        actual_value: "<value>"
    false_extra:
      - file: "<file path>"
        symbol_name: "<name>"
        reason: "<why it is actually in the spec>"
  edge_case_coverage:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - edge_case: "<description>"
        field: "related_code_found | related_file | related_symbol"
        evidence_value: "<value>"
        actual_value: "<value>"
```

### Step 7: Validate Untracked Files Evidence

Cross-check the `untracked_files` section against the actual filesystem and spec:

- [ ] 1. Verify `scan_performed` is consistent with the dispatch contract — if `target_files` was provided, scan may be limited
- [ ] 2. Verify `scan_scope` and `scope_source` are consistent with the spec's defined scope
- [ ] 3. For each file entry in `untracked_files.files`, verify:
  - The file actually exists on the filesystem via `glob` or `read` tool
  - `size_bytes` matches the actual file size
  - `symbol_count` is consistent with `srclight_symbols_in_file` output
  - The file is genuinely not mentioned in the spec's file requirements (cross-check against validated spec file requirements from Step 3)
- [ ] 4. If a file the Investigator reported as untracked is actually mentioned in the spec, flag as `corrected` with `false_untracked`
- [ ] 5. If the spec defines a scope and the Investigator missed files within that scope, record as `missed_untracked`

Record in reasoning:

```yaml
untracked_files_validation:
  validation_status: "validated | corrected | unvalidated"
  evidence_scan_performed: true | false
  evidence_scan_scope: "<scope>"
  evidence_file_count: <N>
  actual_file_count: <N>
  mismatches:
    - path: "<file path>"
      field: "size_bytes | symbol_count"
      evidence_value: "<value>"
      actual_value: "<value>"
  false_untracked:
    - path: "<file path>"
      reason: "<where it is mentioned in the spec>"
  missed_untracked:
    - path: "<file path>"
      size_bytes: <N>
      symbol_count: <N>
```

### Step 8: Validate Documentation Source Evidence

Cross-check the `documentation_sources` section against live sources:

- [ ] 1. **URL validation** — For each URL in `documentation_sources.urls`, re-fetch using `webfetch` and verify:
  - `accessible` matches the actual fetch result
  - `http_status` matches the actual HTTP status
  - `page_title` matches the actual page title
- [ ] 2. **API reference validation** — For each API reference in `documentation_sources.api_references`, re-lookup using `srclight_get_signature` and verify:
  - `found` matches the actual lookup result
  - `actual_signature` matches the actual signature returned
  - `lookup_method` is recorded

If `webfetch` or `srclight_get_signature` is unavailable, mark affected items as `unverifiable: true` with reason `TOOL_UNAVAILABLE`.

Record in reasoning:

```yaml
documentation_sources_validation:
  urls:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<URL>"
        field: "accessible | http_status | page_title"
        evidence_value: "<value>"
        actual_value: "<value>"
  api_references:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<function/class/method name>"
        field: "found | actual_signature"
        evidence_value: "<value>"
        actual_value: "<value>"
```

### Step 9: Write reasoning.yaml

Write all validated evidence to `{artifact_evidence_dir}/reasoning.yaml`:

```yaml
knowledge_supporter: drift-detection-knowledge-supporter
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
spec_local_dir: "<path>"
overall_validation_status: "validated | partial | corrected"
spec_requirements_validation: {...}
target_files_validation: {...}
code_implementation_validation: {...}
raw_comparisons_validation: {...}
untracked_files_validation: {...}
documentation_sources_validation: {...}
unverifiable_items:
  - section: "<section name>"
    item: "<item description>"
    reason: "<why it could not be validated>"
corrections_summary:
  total_corrections: <N>
  sections_affected: ["<section>", ...]
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `reasoning.yaml` with the complete validation structure
- [ ] 3. Verify the file was written and is non-empty

### Step 10: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: <N> sections checked, <N> corrections applied, <N> items unverifiable. No judgments applied."
overall_validation_status: "validated | partial | corrected"
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: {section_count} sections checked, {correction_count} corrections applied, {unverifiable_count} items unverifiable. No judgments applied."
overall_validation_status: "validated | partial | corrected"
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate Spec Requirements Evidence → INVALID if skipped
- [ ] 4. Validate Target Files Evidence → INVALID if skipped
- [ ] 5. Validate Code Implementation Evidence → INVALID if skipped
- [ ] 6. Validate Raw Comparison Data → INVALID if skipped
- [ ] 7. Validate Untracked Files Evidence → INVALID if skipped
- [ ] 8. Validate Documentation Source Evidence → INVALID if skipped
- [ ] 9. Write reasoning.yaml → INVALID if skipped
- [ ] 10. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| srclight_get_signature unavailable | Mark symbol and signature items as `unverifiable: true` with reason `TOOL_UNAVAILABLE` — do NOT BLOCK |
| srclight_symbols_in_file unavailable | Mark symbol completeness items as `unverifiable: true` with reason `TOOL_UNAVAILABLE` — do NOT BLOCK |
| webfetch fails during URL re-verification | Record as `unverifiable` with error — do NOT BLOCK |
| Evidence item references a file that does not exist | Record as `corrected` with `file_not_found` — do NOT BLOCK |
| Evidence section is missing from evidence.yaml | Record as `section_missing` — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write reasoning |

## Cross-References

- `tasks/drift-detection-investigator.md` — Investigator role (produces the `evidence.yaml` consumed by this task)
- `tasks/drift-detection.md` — Evaluator role (consumes this task's `reasoning.yaml`)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — spec-code alignment
- `130-authority-source.md` — code as authoritative source

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
