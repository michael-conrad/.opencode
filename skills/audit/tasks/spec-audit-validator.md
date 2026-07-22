---
name: spec-audit-knowledge-supporter
description: "Validator role for the spec-audit chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge — validates and supports the evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit-knowledge-supporter

## Purpose

Validator role for the spec-audit chain. Reads `evidence.yaml` produced by the Investigator, validates each evidence item against source data, and writes `reasoning.yaml` with validated evidence. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.


## Dispatch Contract

- `artifact_evidence_dir`: Directory containing `evidence.yaml` from the Investigator
- `spec_local_dir`: Local directory containing spec files (for cross-referencing evidence)
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Validator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for reasoning artifacts)

## Exit Criteria

- `reasoning.yaml` written to `{artifact_evidence_dir}/reasoning.yaml`
- Every evidence item in `evidence.yaml` validated against source data
- Validation results recorded per evidence item: `validated`, `corrected`, or `unvalidated` with reason
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
remediation: "evidence.yaml is required for spec-audit-knowledge-supporter. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Validator."
```

- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 4. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for spec-audit-knowledge-supporter. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 5. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load evidence.yaml

Read the Investigator's evidence artifact in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Parse all top-level sections: `spec_files`, `spec_structure`, `determinism_evidence`, `documentation_source_evidence`, `prose_evidence`, `reasoning_evidence`, `analytical_artifact_evidence`, `holistic_dimension_evidence`
- [ ] 3. Record the Investigator's metadata: `generator`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 4. If any expected top-level section is absent, record as `section_missing` — do NOT BLOCK, but flag for the Evaluator

### Step 3: Validate Spec Files Evidence

Cross-check the `spec_files` section against the actual filesystem:

- [ ] 1. For each file entry in `spec_files`, verify the file exists at `<spec_local_dir>/<path>` via `read` tool
- [ ] 2. Verify `size_bytes` matches the actual file size
- [ ] 3. Verify `has_frontmatter` by reading the file and checking for YAML frontmatter delimiters (`---`)
- [ ] 4. Verify `frontmatter_keys` by extracting actual frontmatter keys from the file
- [ ] 5. Verify `body_length_lines` and `body_length_chars` by counting actual lines and characters
- [ ] 6. If a file listed in evidence does not exist, flag as `corrected` with `file_not_found`
- [ ] 7. If any metadata field does not match, record the corrected value

Record in reasoning:

```yaml
spec_files_validation:
  - path: "<relative path within spec_local_dir>"
    validation_status: "validated | corrected | unvalidated"
    checks:
      file_exists: true | false
      size_match: true | false
      frontmatter_match: true | false
      frontmatter_keys_match: true | false
      body_length_lines_match: true | false
      body_length_chars_match: true | false
    corrections:
      - field: "<field name>"
        evidence_value: "<value from evidence.yaml>"
        actual_value: "<value from source>"
    unvalidated_reason: "<reason if unvalidated>"
```

### Step 4: Validate Spec Structure Evidence

Cross-check the `spec_structure` section against the actual spec files:

- [ ] 1. **Headings validation** — Re-read all spec files and extract every markdown heading. Compare against the `headings` list in evidence. Record any missing, extra, or mismatched headings.
- [ ] 2. **Success criteria validation** — Re-read the spec and extract the SC table. Compare `table_columns` and each `row` against the actual table content. Verify SC IDs, criterion text, evidence types, and verification methods match.
- [ ] 3. **Phases validation** — Re-read the spec and extract phase headings. Compare `count` and `items` against actual phase structure.
- [ ] 4. **Files affected validation** — Re-read the spec and extract file paths from the Files Affected section. Compare against the `paths` list.
- [ ] 5. **Preamble validation** — Re-read the spec and check for the "## Intent and Executive Summary" section. Verify `fields_present` and `fields_missing` match actual content.
- [ ] 6. **Documentation sources validation** — Re-read the spec and extract all URLs and references from the Documentation Sources section. Compare against the `sources` list.
- [ ] 7. **STATUS marker validation** — Re-read the spec and extract the STATUS marker. Compare against `status_marker`.
- [ ] 8. **Prose elements validation** — Re-read the spec and count tables, code blocks, ordered lists, and unordered lists. Compare against `prose_elements` counts.

Record in reasoning:

```yaml
spec_structure_validation:
  headings:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_heading: "<text>"
        actual_heading: "<text or absent>"
        type: "missing | extra | text_mismatch | level_mismatch"
  success_criteria:
    validation_status: "validated | corrected | unvalidated"
    evidence_row_count: <N>
    actual_row_count: <N>
    mismatches:
      - sc_id: "<SC-ID>"
        field: "<field name>"
        evidence_value: "<value>"
        actual_value: "<value>"
  phases:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches: ["<description>", ...]
  files_affected:
    validation_status: "validated | corrected | unvalidated"
    evidence_paths: ["<path>", ...]
    actual_paths: ["<path>", ...]
    mismatches: ["<description>", ...]
  preamble:
    validation_status: "validated | corrected | unvalidated"
    evidence_fields_present: ["<field>", ...]
    actual_fields_present: ["<field>", ...]
    mismatches: ["<description>", ...]
  documentation_sources:
    validation_status: "validated | corrected | unvalidated"
    evidence_sources: ["<source>", ...]
    actual_sources: ["<source>", ...]
    mismatches: ["<description>", ...]
  status_marker:
    validation_status: "validated | corrected | unvalidated"
    evidence_value: "<value>"
    actual_value: "<value>"
  prose_elements:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - element: "tables | code_blocks | ordered_lists | unordered_lists"
        evidence_count: <N>
        actual_count: <N>
```

### Step 5: Validate Determinism Evidence

Cross-check the `determinism_evidence` section against the actual spec content:

- [ ] 1. **SC wording validation** — For each SC in `sc_wording`, re-read the spec and verify the exact criterion text matches. Record any discrepancies.
- [ ] 2. **Fail pattern validation** — For each fail pattern in `fail_patterns`, re-read the spec and verify the `matched_text` actually appears in the SC. Check for fail patterns the Investigator may have missed.
- [ ] 3. **Ambiguity marker validation** — For each ambiguity marker in `ambiguity_markers`, re-read the spec and verify the `matched_text` actually appears. Check for markers the Investigator may have missed.
- [ ] 4. **Evidence type declaration validation** — For each SC in `evidence_type_declarations`, re-read the spec and verify the `declared_type` matches what the spec actually declares.
- [ ] 5. **Verification method validation** — For each SC in `verification_methods`, re-read the spec and verify `has_verification_method` and `method_text` match.
- [ ] 6. **Failure description validation** — If `failure_description_provided` is true, verify the `failure_description_text` is non-empty and matches the dispatch contract.

Record in reasoning:

```yaml
determinism_validation:
  sc_wording:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - sc_id: "<SC-ID>"
        evidence_text: "<text>"
        actual_text: "<text>"
  fail_patterns:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    missed_patterns:
      - sc_id: "<SC-ID>"
        pattern: "<pattern type>"
        matched_text: "<exact text>"
    false_patterns:
      - sc_id: "<SC-ID>"
        pattern: "<pattern type>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
  ambiguity_markers:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    missed_markers:
      - sc_id: "<SC-ID>"
        marker: "<marker type>"
        matched_text: "<exact text>"
    false_markers:
      - sc_id: "<SC-ID>"
        marker: "<marker type>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
  evidence_type_declarations:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - sc_id: "<SC-ID>"
        evidence_declared_type: "<type>"
        actual_declared_type: "<type>"
  verification_methods:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - sc_id: "<SC-ID>"
        field: "has_verification_method | method_text"
        evidence_value: "<value>"
        actual_value: "<value>"
  failure_description:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    actual_provided: true | false
```

### Step 6: Validate Documentation Source Evidence

Cross-check the `documentation_source_evidence` section against live sources:

- [ ] 1. **URL validation** — For each URL in `urls`, re-fetch using `webfetch` and verify:
  - `accessible` matches the actual fetch result
  - `http_status` matches the actual HTTP status
  - `page_title` matches the actual page title
  - `referenced_content_found` is consistent with the actual page content
- [ ] 2. **API reference validation** — For each API reference in `api_references`, re-lookup using `srclight_get_signature` and verify:
  - `found` matches the actual lookup result
  - `actual_signature` matches the actual signature returned
- [ ] 3. **Environment variable validation** — For each env variable in `env_variables`, re-check `.env.example` or config schema and verify:
  - `found_in_config` matches the actual check result
  - `config_file` and `defined_format` match
- [ ] 4. **Library pattern validation** — For each library pattern in `library_patterns`, re-verify against official docs or source and check:
  - `pattern_exists` is consistent with the actual verification result

Record in reasoning:

```yaml
documentation_source_validation:
  urls:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<URL>"
        field: "accessible | http_status | page_title | referenced_content_found"
        evidence_value: "<value>"
        actual_value: "<value>"
  api_references:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<function/class/method name>"
        field: "found | actual_signature"
        evidence_value: "<value>"
        actual_value: "<value>"
  env_variables:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<variable name>"
        field: "found_in_config | config_file | defined_format"
        evidence_value: "<value>"
        actual_value: "<value>"
  library_patterns:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - source: "<library/framework reference>"
        field: "pattern_exists"
        evidence_value: "<value>"
        actual_value: "<value>"
```

### Step 7: Validate Prose and Escape Hatch Evidence

Cross-check the `prose_evidence` section against the actual spec content:

- [ ] 1. **Escape hatch validation** — For each escape hatch in `escape_hatches`, re-read the spec and verify the `phrase` actually appears at the stated `location`. Check for escape hatches the Investigator may have missed.
- [ ] 2. **Tracking language validation** — For each tracking language instance in `tracking_language`, re-read the spec and verify the `phrase` actually appears. Check for missed instances.
- [ ] 3. **Prescriptive code validation** — For each prescriptive code instance in `prescriptive_code`, re-read the spec and verify the `content` actually appears. Check for missed instances.
- [ ] 4. **Cost-frame language validation** — For each SC in `cost_frame_language`, re-read the spec and verify `has_cost_frame` matches.

Record in reasoning:

```yaml
prose_validation:
  escape_hatches:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    missed_hatches:
      - phrase: "<exact text>"
        location: "<section or line reference>"
        category: "discretion | deferral | optional | tbd | choice"
    false_hatches:
      - evidence_phrase: "<text>"
        reason: "<why it is a false match>"
  tracking_language:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    missed_instances:
      - phrase: "<exact text>"
        location: "<section or line reference>"
        marker_type: "implemented | pending | confirmed | viable | completed"
    false_instances:
      - evidence_phrase: "<text>"
        reason: "<why it is a false match>"
  prescriptive_code:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    missed_instances:
      - content: "<exact text>"
        location: "<section or line reference>"
        type: "line_number | import_string | assertion_code"
    false_instances:
      - evidence_content: "<text>"
        reason: "<why it is a false match>"
  cost_frame_language:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - sc_id: "<SC-ID>"
        evidence_has_cost_frame: true | false
        actual_has_cost_frame: true | false
```

### Step 8: Validate Causal and Reasoning Evidence

Cross-check the `reasoning_evidence` section against the actual spec content:

- [ ] 1. **Root cause validation** — For each root cause in `root_causes`, re-read the spec and verify the `text` actually appears at the stated `location`. Check for root causes the Investigator may have missed.
- [ ] 2. **Fix approach validation** — For each fix approach in `fix_approaches`, re-read the spec and verify the `text` actually appears. Check for missed fix approaches.
- [ ] 3. **SC-to-root-cause validation** — For each mapping in `sc_to_root_cause`, re-read the spec and verify `references_root_cause` and `root_cause_text` match.
- [ ] 4. **Alternatives validation** — Re-read the spec and verify `alternatives_considered.present` and each `item` matches.
- [ ] 5. **Edge case validation** — Re-read the spec and verify `edge_cases.present` and each `item` matches. Check for missed edge cases.
- [ ] 6. **Contradiction validation** — For each potential contradiction in `potential_contradictions`, re-read the spec and verify both statements actually appear at the stated locations. Check for contradictions the Investigator may have missed.

Record in reasoning:

```yaml
reasoning_validation:
  root_causes:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_text: "<text>"
        actual_text: "<text or absent>"
  fix_approaches:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_text: "<text>"
        actual_text: "<text or absent>"
  sc_to_root_cause:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - sc_id: "<SC-ID>"
        field: "references_root_cause | root_cause_text"
        evidence_value: "<value>"
        actual_value: "<value>"
  alternatives_considered:
    validation_status: "validated | corrected | unvalidated"
    evidence_present: true | false
    actual_present: true | false
    mismatches: ["<description>", ...]
  edge_cases:
    validation_status: "validated | corrected | unvalidated"
    evidence_present: true | false
    actual_present: true | false
    evidence_count: <N>
    actual_count: <N>
    missed_cases: ["<text>", ...]
  potential_contradictions:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_contradictions:
      - evidence_statement_a: "<text>"
        evidence_statement_b: "<text>"
        reason: "<why it is not a contradiction>"
    missed_contradictions:
      - statement_a: "<text>"
        statement_b: "<text>"
        location_a: "<section reference>"
        location_b: "<section reference>"
```

### Step 9: Validate Analytical Artifact Evidence

Cross-check the `analytical_artifact_evidence` section against the actual filesystem:

- [ ] 1. For each of `blast_radius`, `concern_map`, `code_path_inventory`, `cross_cutting_matrix`, `interface_compatibility`, `state_analysis`, `testability_assessment`:
  - If `provided` is true, verify the `path` exists and is non-empty via `read` tool
  - Verify `exists` matches the actual filesystem state
  - Verify `size_bytes` matches the actual file size
  - Verify `modified_at` matches the actual modification timestamp
  - If `provided` is false, verify no path was supplied in the dispatch contract
- [ ] 2. If an artifact path exists but the Investigator reported it as missing, flag as `corrected`
- [ ] 3. If an artifact path does not exist but the Investigator reported it as present, flag as `corrected`

Record in reasoning:

```yaml
analytical_artifact_validation:
  blast_radius:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches:
      - field: "exists | size_bytes | modified_at"
        evidence_value: "<value>"
        actual_value: "<value>"
  concern_map:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
  code_path_inventory:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
  cross_cutting_matrix:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
  interface_compatibility:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
  state_analysis:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
  testability_assessment:
    validation_status: "validated | corrected | unvalidated"
    evidence_provided: true | false
    evidence_exists: true | false
    actual_exists: true | false
    mismatches: ["<description>", ...]
```

### Step 10: Validate Holistic Dimension Evidence

Cross-check the `holistic_dimension_evidence` section against the actual spec content:

- [ ] 1. **Implementability validation** — Re-read the spec and verify `single_approach_defined`, `sc_count`, and `ambiguous_sc_count` match.
- [ ] 2. **Internal consistency validation** — Re-read the spec and verify `cross_section_references` count and `preamble_body_alignment_notes` are consistent.
- [ ] 3. **Completeness validation** — Re-read the spec and verify `undefined_terms`, `tbd_todo_markers` count, and `implicit_dependencies` match. Check for missed items.
- [ ] 4. **Scope discipline validation** — Re-read the spec and verify `stated_boundaries` and `potential_scope_creep_elements` match.
- [ ] 5. **Testability validation** — Re-read the spec and verify `scs_with_verification_method`, `scs_without_verification_method`, and `subjective_judgment_scs` match.
- [ ] 6. **Provenance validation** — Re-read the spec and verify `tool_call_evidence_cited` and `unsupported_assertions` match.
- [ ] 7. **Feasibility validation** — Re-read the spec and verify `referenced_files`, `referenced_functions`, and `referenced_libraries` match. Check for missed references.
- [ ] 8. **Safety validation** — Re-read the spec and verify `destructive_operations`, `data_loss_scenarios`, and `security_relevant_changes` match.
- [ ] 9. **Traceability validation** — Re-read the spec and verify `sc_to_phase_mapping`, `orphan_scs`, and `orphan_phases` match.
- [ ] 10. **Correctness validation** — Re-read the spec and verify `problem_statement`, `root_cause`, and `fix_approach` match.

Record in reasoning:

```yaml
holistic_dimension_validation:
  implementability:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "single_approach_defined | sc_count | ambiguous_sc_count"
        evidence_value: "<value>"
        actual_value: "<value>"
  internal_consistency:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "cross_section_references"
        evidence_value: <N>
        actual_value: <N>
  completeness:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "undefined_terms | tbd_todo_markers | implicit_dependencies"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_undefined_terms: ["<term>", ...]
    missed_implicit_dependencies: ["<description>", ...]
  scope_discipline:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "stated_boundaries | potential_scope_creep_elements"
        evidence_value: "<value>"
        actual_value: "<value>"
  testability:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "scs_with_verification_method | scs_without_verification_method | subjective_judgment_scs"
        evidence_value: "<value>"
        actual_value: "<value>"
  provenance:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "tool_call_evidence_cited | unsupported_assertions"
        evidence_value: "<value>"
        actual_value: "<value>"
  feasibility:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "referenced_files | referenced_functions | referenced_libraries"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_referenced_files: ["<path>", ...]
    missed_referenced_functions: ["<name>", ...]
  safety:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "destructive_operations | data_loss_scenarios | security_relevant_changes"
        evidence_value: "<value>"
        actual_value: "<value>"
  traceability:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "sc_to_phase_mapping | orphan_scs | orphan_phases"
        evidence_value: "<value>"
        actual_value: "<value>"
  correctness:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "problem_statement | root_cause | fix_approach"
        evidence_value: "<value>"
        actual_value: "<value>"
```

### Step 11: Write reasoning.yaml

Write all validated evidence to `{artifact_evidence_dir}/reasoning.yaml`:

```yaml
knowledge_supporter: spec-audit-knowledge-supporter
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
spec_local_dir: "<path>"
overall_validation_status: "validated | partial | corrected"
spec_files_validation: {...}
spec_structure_validation: {...}
determinism_validation: {...}
documentation_source_validation: {...}
prose_validation: {...}
reasoning_validation: {...}
analytical_artifact_validation: {...}
holistic_dimension_validation: {...}
unvalidated_items:
  - section: "<section name>"
    item: "<item description>"
    reason: "<why it could not be validated>"
corrections_summary:
  total_corrections: <N>
  sections_affected: ["<section>", ...]
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: <N> sections checked, <N> corrections applied, <N> items unvalidated. No judgments applied."
overall_validation_status: "validated | partial | corrected"
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate Spec Files Evidence → INVALID if skipped
- [ ] 4. Validate Spec Structure Evidence → INVALID if skipped
- [ ] 5. Validate Determinism Evidence → INVALID if skipped
- [ ] 6. Validate Documentation Source Evidence → INVALID if skipped
- [ ] 7. Validate Prose and Escape Hatch Evidence → INVALID if skipped
- [ ] 8. Validate Causal and Reasoning Evidence → INVALID if skipped
- [ ] 9. Validate Analytical Artifact Evidence → INVALID if skipped
- [ ] 10. Validate Holistic Dimension Evidence → INVALID if skipped
- [ ] 11. Write reasoning.yaml → INVALID if skipped
- [ ] 12. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| webfetch fails during URL re-verification | Record as `unvalidated` with error — do NOT BLOCK |
| srclight_get_signature fails during API re-verification | Record as `unvalidated` with error — do NOT BLOCK |
| Evidence item references a file that does not exist | Record as `corrected` with `file_not_found` — do NOT BLOCK |
| Evidence section is missing from evidence.yaml | Record as `section_missing` — do NOT BLOCK |

## Cross-References

- `tasks/spec-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/spec-audit.md` — Evaluator role (consumes this task's reasoning.yaml)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `.opencode/reference/holistic-dimensions.yaml` — 11 holistic dimensions definitions
- Read [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
