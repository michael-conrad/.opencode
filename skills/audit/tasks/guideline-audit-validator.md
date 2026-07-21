---
name: guideline-audit-knowledge-supporter
description: "Validator role for the guideline-audit DiMo chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge — validates and supports the evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: guideline-audit-knowledge-supporter

## Purpose

Validator role for the guideline-audit DiMo chain. Reads `evidence.yaml` produced by the Investigator, validates each evidence item against source data (the actual guideline files), and writes `reasoning.yaml` with validated evidence. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.



## Dispatch Contract

- `guideline_paths`: List of guideline file paths that were audited (same as passed to Investigator)
- `artifact_evidence_dir`: Directory containing `evidence.yaml` from the Investigator
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Validator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `guideline_paths` provided — either a non-empty list of file paths or a valid glob pattern matching the files the Investigator audited
- `artifact_evidence_dir` provided (writable directory for reasoning artifacts)
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

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
remediation: "evidence.yaml is required for guideline-audit-knowledge-supporter. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Validator."
```

- [ ] 3. Verify `guideline_paths` is provided and non-empty — expand glob if needed via `glob` tool
- [ ] 4. If `guideline_paths` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "guideline_paths"
remediation: "guideline_paths is required for guideline-audit-knowledge-supporter. The orchestrator must provide the same guideline file paths that were passed to the Investigator."
```

- [ ] 5. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load evidence.yaml

Read the Investigator's evidence artifact in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Parse all top-level sections: `guideline_files`, `guideline_structure`, `rule_condition_evidence`, `cross_reference_evidence`, `token_count_evidence`, `ambiguity_evidence`, `conflict_indicator_evidence`, `enforcement_pattern_evidence`, `file_organization_evidence`
- [ ] 3. Record the Investigator's metadata: `generator`, `generated_at`, `guideline_paths`
- [ ] 4. If any expected top-level section is absent, record as `section_missing` — do NOT BLOCK, but flag for the Evaluator

### Step 3: Validate Guideline Files Evidence

Cross-check the `guideline_files` section against the actual filesystem:

- [ ] 1. For each file entry in `guideline_files`, verify the file exists at the stated `path` via `read` tool
- [ ] 2. Verify `size_bytes` matches the actual file size
- [ ] 3. Verify `has_frontmatter` by reading the file and checking for YAML frontmatter delimiters (`---`)
- [ ] 4. Verify `frontmatter_keys` by extracting actual frontmatter keys from the file
- [ ] 5. Verify `line_count` by counting actual lines in the file
- [ ] 6. Verify `heading_count` by counting actual markdown headings in the file
- [ ] 7. If a file listed in evidence does not exist, flag as `corrected` with `file_not_found`
- [ ] 8. If any metadata field does not match, record the corrected value

Record in reasoning:

```yaml
guideline_files_validation:
  - path: "<relative path>"
    validation_status: "validated | corrected | unvalidated"
    checks:
      file_exists: true | false
      size_match: true | false
      frontmatter_match: true | false
      frontmatter_keys_match: true | false
      line_count_match: true | false
      heading_count_match: true | false
    corrections:
      - field: "<field name>"
        evidence_value: "<value from evidence.yaml>"
        actual_value: "<value from source>"
    unvalidated_reason: "<reason if unvalidated>"
```

### Step 4: Validate Guideline Structure Evidence

Cross-check the `guideline_structure` section against the actual guideline files:

- [ ] 1. **Headings validation** — Re-read all guideline files and extract every markdown heading. Compare against the `headings` list in evidence. Record any missing, extra, or mismatched headings (level, text, line).
- [ ] 2. **Sections validation** — Re-read all guideline files and extract top-level sections. Compare `subsection_count` and line ranges against actual section structure.
- [ ] 3. **Rule blocks validation** — Re-read all guideline files and identify rule-defining blocks. Compare `rule_id`, `line_start`, `line_end`, `block_type` against actual rule blocks. Record any missing or misidentified blocks.
- [ ] 4. **Tables validation** — Re-read all guideline files and extract markdown tables. Compare `columns`, `row_count`, and `line` against actual tables.
- [ ] 5. **Code blocks validation** — Re-read all guideline files and extract fenced code blocks. Compare `language`, `line_count`, and `line` against actual code blocks.
- [ ] 6. **Lists validation** — Re-read all guideline files and extract ordered/unordered lists. Compare `type`, `item_count`, and `line` against actual lists.
- [ ] 7. **Prose blocks validation** — Re-read all guideline files and identify prose paragraphs. Compare `word_count` and line ranges against actual prose blocks.

Record in reasoning:

```yaml
guideline_structure_validation:
  headings:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_heading: "<text>"
        actual_heading: "<text or absent>"
        type: "missing | extra | text_mismatch | level_mismatch | line_mismatch"
  sections:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - section: "<heading text>"
        field: "subsection_count | line_start | line_end"
        evidence_value: "<value>"
        actual_value: "<value>"
  rule_blocks:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - evidence_rule_id: "<critical-rules-XXX or absent>"
        field: "line_start | line_end | block_type"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_blocks:
      - rule_id: "<critical-rules-XXX or absent>"
        file: "<path>"
        line: <N>
        block_type: "critical_rule | checklist_item | numbered_rule | prose_rule"
  tables:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "columns | row_count | line"
        evidence_value: "<value>"
        actual_value: "<value>"
  code_blocks:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "language | line_count | line"
        evidence_value: "<value>"
        actual_value: "<value>"
  lists:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "type | item_count | line"
        evidence_value: "<value>"
        actual_value: "<value>"
  prose_blocks:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "word_count | line_start | line_end"
        evidence_value: "<value>"
        actual_value: "<value>"
```

### Step 5: Validate Rule Condition Evidence

Cross-check the `rule_condition_evidence` section against the actual guideline files:

- [ ] 1. **Condition text validation** — For each rule entry, re-read the guideline file at the stated line and verify the `condition_text` matches the actual text. Record any discrepancies.
- [ ] 2. **Action text validation** — For each rule entry, re-read the guideline file and verify the `action_text` matches the actual text.
- [ ] 3. **Enforceability marker validation** — For each rule entry, re-read the rule block and verify `has_concrete_action` is consistent with the actual content.
- [ ] 4. **Tier classification validation** — For each rule entry, re-read the guideline file and verify `declared_tier` matches the actual tier declaration.
- [ ] 5. **Trigger pattern validation** — For each rule entry, re-read the guideline file and verify `has_trigger_pattern` matches the actual presence of `trigger_on:` or `Triggers on:`.
- [ ] 6. **Symbolic ID validation** — For each rule entry, re-read the guideline file and verify `has_symbolic_id` matches the actual presence of a symbolic rule ID.
- [ ] 7. **Concrete values validation** — For each rule entry, re-read the rule block and verify `concrete_values.present` and `concrete_values.values` match the actual content. Check for concrete values the Investigator may have missed.

Record in reasoning:

```yaml
rule_condition_validation:
  - rule_id: "<critical-rules-XXX or absent>"
    file: "<path>"
    validation_status: "validated | corrected | unvalidated"
    checks:
      condition_text_match: true | false
      action_text_match: true | false
      has_concrete_action_match: true | false
      declared_tier_match: true | false
      has_trigger_pattern_match: true | false
      has_symbolic_id_match: true | false
      concrete_values_present_match: true | false
    corrections:
      - field: "<field name>"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_concrete_values: ["<value>", ...]
    unvalidated_reason: "<reason if unvalidated>"
```

### Step 6: Validate Cross-Reference Evidence

Cross-check the `cross_reference_evidence` section against the actual guideline files:

- [ ] 1. **Guideline-to-guideline references validation** — For each reference in `guideline_refs`, re-read the source file at the stated line and verify the `target_guideline` and `reference_text` match. Verify the target guideline file actually exists.
- [ ] 2. **Skill references validation** — For each reference in `skill_refs`, re-read the source file and verify the `target_skill` and `reference_text` match. Verify the target skill directory exists at `.opencode/skills/<target_skill>/`.
- [ ] 3. **Tool references validation** — For each reference in `tool_refs`, re-read the source file and verify the `target_tool` and `reference_text` match. Verify the target tool file exists.
- [ ] 4. **File path references validation** — For each reference in `file_path_refs`, re-read the source file and verify the `target_path` and `reference_text` match. Verify the target path exists on the filesystem.
- [ ] 5. **Section cross-references validation** — For each reference in `section_refs`, re-read the source file and verify the `target_section` and `reference_text` match.
- [ ] 6. **Issue references validation** — For each reference in `issue_refs`, re-read the source file and verify the `issue_number` and `reference_text` match.
- [ ] 7. **Duplicate source validation** — For each entry in `duplicate_sources`, re-read all referenced locations and verify the source is indeed referenced from each stated file and line. Check for duplicate sources the Investigator may have missed.

Record in reasoning:

```yaml
cross_reference_validation:
  guideline_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "target_guideline | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    broken_refs:
      - source_file: "<path>"
        target_guideline: "<filename>"
        reason: "target_file_not_found"
    missed_refs:
      - source_file: "<path>"
        target_guideline: "<filename>"
        reference_text: "<exact text>"
  skill_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "target_skill | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    broken_refs:
      - source_file: "<path>"
        target_skill: "<skill name>"
        reason: "skill_directory_not_found"
    missed_refs:
      - source_file: "<path>"
        target_skill: "<skill name>"
        reference_text: "<exact text>"
  tool_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "target_tool | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    broken_refs:
      - source_file: "<path>"
        target_tool: "<tool path>"
        reason: "tool_file_not_found"
    missed_refs:
      - source_file: "<path>"
        target_tool: "<tool path>"
        reference_text: "<exact text>"
  file_path_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "target_path | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    broken_refs:
      - source_file: "<path>"
        target_path: "<path>"
        reason: "path_not_found"
    missed_refs:
      - source_file: "<path>"
        target_path: "<path>"
        reference_text: "<exact text>"
  section_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "target_section | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_refs:
      - source_file: "<path>"
        target_section: "<section reference>"
        reference_text: "<exact text>"
  issue_refs:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - source_file: "<path>"
        field: "issue_number | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_refs:
      - source_file: "<path>"
        issue_number: <N>
        reference_text: "<exact text>"
  duplicate_sources:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_duplicates:
      - source: "<name>"
        evidence_referenced_from: ["<path>", ...]
        reason: "<why it is not a duplicate>"
    missed_duplicates:
      - source: "<name>"
        referenced_from:
          - file: "<path>"
            line: <N>
          - file: "<path>"
            line: <N>
```

### Step 7: Validate Token Count Evidence

Cross-check the `token_count_evidence` section against the actual guideline files:

- [ ] 1. **Per-file token count validation** — For each file entry, re-read the file and verify `word_count`, `estimated_tokens`, and `char_count` match actual counts.
- [ ] 2. **Per-section token count validation** — For each section entry, re-read the section and verify `word_count` and `estimated_tokens` match.
- [ ] 3. **Per-rule token count validation** — For each rule entry, re-read the rule block and verify `word_count` and `estimated_tokens` match.
- [ ] 4. **Total corpus validation** — Verify `total_words`, `total_estimated_tokens`, and `file_count` match the sum of per-file counts.
- [ ] 5. **Largest sections validation** — Verify the `largest_sections` list is correctly ordered by token count.

Record in reasoning:

```yaml
token_count_validation:
  per_file:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<path>"
        field: "word_count | estimated_tokens | char_count"
        evidence_value: <N>
        actual_value: <N>
  per_section:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<path>"
        section: "<heading text>"
        field: "word_count | estimated_tokens"
        evidence_value: <N>
        actual_value: <N>
  per_rule:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - rule_id: "<critical-rules-XXX or absent>"
        file: "<path>"
        field: "word_count | estimated_tokens"
        evidence_value: <N>
        actual_value: <N>
  total_corpus:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - field: "total_words | total_estimated_tokens | file_count"
        evidence_value: <N>
        actual_value: <N>
  largest_sections:
    validation_status: "validated | corrected | unvalidated"
    ordering_correct: true | false
    mismatches:
      - rank: <N>
        evidence_section: "<heading text>"
        actual_section: "<heading text>"
```

### Step 8: Validate Ambiguity Marker Evidence

Cross-check the `ambiguity_evidence` section against the actual guideline files:

- [ ] 1. **Hedging language validation** — For each hedging instance, re-read the guideline file at the stated line and verify the `marker`, `matched_text`, and `context` match. Check for hedging language the Investigator may have missed.
- [ ] 2. **Vague terms validation** — For each vague term instance, re-read the guideline file and verify the `term`, `matched_text`, and `context` match. Check for missed vague terms.
- [ ] 3. **Open-ended conditions validation** — For each open-ended condition, re-read the guideline file and verify the `condition_text` and `missing_concrete_value` are accurate. Check for missed open-ended conditions.
- [ ] 4. **Either/or ambiguity validation** — For each either/or instance, re-read the guideline file and verify the `matched_text` is accurate. Check for missed either/or patterns.
- [ ] 5. **TBD/TODO markers validation** — For each TBD/TODO instance, re-read the guideline file and verify the `marker` and `matched_text` match. Check for missed TBD/TODO markers.
- [ ] 6. **Implicit behavior validation** — For each implicit behavior instance, re-read the guideline file and verify the `desired_outcome` and `missing_mechanism` are accurate. Check for missed implicit behaviors.

Record in reasoning:

```yaml
ambiguity_validation:
  hedging_language:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_matches:
      - file: "<path>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
    missed_instances:
      - file: "<path>"
        line: <N>
        marker: "<marker type>"
        matched_text: "<exact text>"
  vague_terms:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_matches:
      - file: "<path>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
    missed_instances:
      - file: "<path>"
        line: <N>
        term: "<term type>"
        matched_text: "<exact text>"
  open_ended_conditions:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX or absent>"
        field: "condition_text | missing_concrete_value"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_conditions:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX or absent>"
        condition_text: "<exact text>"
        missing_concrete_value: "<what is missing>"
  either_or_ambiguity:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_matches:
      - file: "<path>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
    missed_instances:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX or absent>"
        matched_text: "<exact text>"
  tbd_todo_markers:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_matches:
      - file: "<path>"
        evidence_matched_text: "<text>"
        reason: "<why it is a false match>"
    missed_instances:
      - file: "<path>"
        line: <N>
        marker: "<marker type>"
        matched_text: "<exact text>"
  implicit_behavior:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX or absent>"
        field: "desired_outcome | missing_mechanism"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_instances:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX or absent>"
        desired_outcome: "<exact text>"
        missing_mechanism: "<what is unspecified>"
```

### Step 9: Validate Conflict Indicator Evidence

Cross-check the `conflict_indicator_evidence` section against the actual guideline files:

- [ ] 1. **Within-file conflicts validation** — For each within-file conflict, re-read the guideline file at both stated lines and verify both statements exist and the `conflict_type` is plausible. Check for within-file conflicts the Investigator may have missed.
- [ ] 2. **Cross-file conflicts validation** — For each cross-file conflict, re-read both files at the stated lines and verify both statements exist and the `conflict_type` is plausible. Check for cross-file conflicts the Investigator may have missed.
- [ ] 3. **Tier vs. override conflicts validation** — For each tier/override conflict, re-read the guideline file and verify the `declared_tier` and `override_behavior` match. Check for missed tier/override conflicts.
- [ ] 4. **Scope boundary conflicts validation** — For each scope boundary conflict, re-read both files and verify the `scope_a` and `scope_b` text match. Check for missed scope boundary conflicts.

Record in reasoning:

```yaml
conflict_indicator_validation:
  within_file:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_conflicts:
      - file: "<path>"
        statement_a_text: "<text>"
        statement_b_text: "<text>"
        reason: "<why it is not a conflict>"
    missed_conflicts:
      - file: "<path>"
        statement_a:
          line: <N>
          text: "<exact text>"
          rule_id: "<critical-rules-XXX or absent>"
        statement_b:
          line: <N>
          text: "<exact text>"
          rule_id: "<critical-rules-XXX or absent>"
        conflict_type: "contradictory_claim | scope_overlap | exception_negates_rule"
  cross_file:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_conflicts:
      - file_a: "<path>"
        file_b: "<path>"
        statement_a_text: "<text>"
        statement_b_text: "<text>"
        reason: "<why it is not a conflict>"
    missed_conflicts:
      - file_a: "<path>"
        statement_a:
          line: <N>
          text: "<exact text>"
          rule_id: "<critical-rules-XXX or absent>"
        file_b: "<path>"
        statement_b:
          line: <N>
          text: "<exact text>"
          rule_id: "<critical-rules-XXX or absent>"
        conflict_type: "contradictory_claim | scope_overlap | exception_negates_rule"
  tier_override_conflicts:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX>"
        field: "declared_tier | override_behavior"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_conflicts:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX>"
        declared_tier: <N>
        override_behavior: "<text>"
        inconsistency_note: "<observation>"
  scope_boundary_conflicts:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file_a: "<path>"
        rule_a: "<critical-rules-XXX or absent>"
        field: "scope_a | scope_b"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_conflicts:
      - file_a: "<path>"
        rule_a: "<critical-rules-XXX or absent>"
        scope_a: "<text>"
        file_b: "<path>"
        rule_b: "<critical-rules-XXX or absent>"
        scope_b: "<text>"
        overlap_description: "<observation>"
```

### Step 10: Validate Enforcement Pattern Evidence

Cross-check the `enforcement_pattern_evidence` section against the actual guideline files:

- [ ] 1. **Tier distribution validation** — For each file entry, re-read the guideline file and verify `tier_1_count`, `tier_2_count`, `tier_3_count`, and `undeclared_count` match actual tier declarations.
- [ ] 2. **Violation classification validation** — For each violation classification, re-read the guideline file at the stated line and verify the `rule_id`, `classification`, and `violation_text` match.
- [ ] 3. **Required/Forbidden block validation** — For each block, re-read the guideline file and verify the `type`, `rule_id`, and `content_preview` match. Check for missed required/forbidden blocks.
- [ ] 4. **Enforcement mechanism validation** — For each mechanism reference, re-read the guideline file and verify the `mechanism` and `reference_text` match. Check for missed enforcement mechanism references.
- [ ] 5. **Halt condition validation** — For each halt condition, re-read the guideline file and verify the `rule_id`, `trigger_text`, and `halt_type` match. Check for missed halt conditions.
- [ ] 6. **Override permission validation** — For each override permission, re-read the guideline file and verify the `rule_id`, `override_condition`, and `override_by` match. Check for missed override permissions.
- [ ] 7. **Load condition validation** — For each load condition, re-read the guideline file and verify the `load_when` and `target_rule` match. Check for missed load conditions.

Record in reasoning:

```yaml
enforcement_pattern_validation:
  tier_distribution:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - file: "<path>"
        field: "tier_1_count | tier_2_count | tier_3_count | undeclared_count"
        evidence_value: <N>
        actual_value: <N>
  violation_classifications:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX>"
        field: "classification | violation_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_classifications:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX>"
        classification: "<classification>"
        violation_text: "<exact text>"
  required_forbidden_blocks:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "type | rule_id | content_preview"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_blocks:
      - file: "<path>"
        line: <N>
        type: "required | forbidden"
        rule_id: "<critical-rules-XXX or absent>"
  enforcement_mechanisms:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "mechanism | reference_text"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_mechanisms:
      - file: "<path>"
        line: <N>
        mechanism: "<mechanism type>"
        reference_text: "<exact text>"
  halt_conditions:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX or absent>"
        field: "trigger_text | halt_type"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_conditions:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX or absent>"
        trigger_text: "<exact text>"
        halt_type: "<halt type>"
  override_permissions:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        rule_id: "<critical-rules-XXX or absent>"
        field: "override_condition | override_by"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_permissions:
      - file: "<path>"
        line: <N>
        rule_id: "<critical-rules-XXX or absent>"
        override_condition: "<exact text>"
        override_by: "<override authority>"
  load_conditions:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    mismatches:
      - file: "<path>"
        field: "load_when | target_rule"
        evidence_value: "<value>"
        actual_value: "<value>"
    missed_conditions:
      - file: "<path>"
        line: <N>
        load_when: "<value>"
        target_rule: "<critical-rules-XXX or absent>"
```

### Step 11: Validate File Organization Evidence

Cross-check the `file_organization_evidence` section against the actual filesystem:

- [ ] 1. **Naming pattern validation** — Verify the `naming_pattern` description matches the actual file naming convention in `.opencode/guidelines/`.
- [ ] 2. **INDEX.md validation** — If `index_file.present` is true, verify the INDEX.md file exists, has the stated `entry_count` and `columns`. If `index_file.present` is false, verify INDEX.md does not exist.
- [ ] 3. **Related rules validation** — For each entry in `related_rules`, re-read the guideline file and verify the `sibling_rules` list matches the actual rules in the same section.
- [ ] 4. **File groupings validation** — For each grouping in `file_groupings`, verify the `files` list matches the actual files that share the stated `topic`.
- [ ] 5. **Coverage gaps validation** — For each gap in `coverage_gaps`, verify the `referenced_file` does not exist and is referenced from each stated `referenced_by` file. Check for coverage gaps the Investigator may have missed.

Record in reasoning:

```yaml
file_organization_validation:
  naming_pattern:
    validation_status: "validated | corrected | unvalidated"
    evidence_description: "<text>"
    actual_description: "<text>"
  index_file:
    validation_status: "validated | corrected | unvalidated"
    evidence_present: true | false
    actual_present: true | false
    mismatches:
      - field: "entry_count | columns"
        evidence_value: "<value>"
        actual_value: "<value>"
  related_rules:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - rule_id: "<critical-rules-XXX or absent>"
        file: "<path>"
        field: "sibling_rules"
        evidence_value: ["<rule_id>", ...]
        actual_value: ["<rule_id>", ...]
  file_groupings:
    validation_status: "validated | corrected | unvalidated"
    mismatches:
      - topic: "<topic>"
        field: "files"
        evidence_value: ["<path>", ...]
        actual_value: ["<path>", ...]
    missed_groupings:
      - topic: "<topic>"
        files: ["<path>", ...]
  coverage_gaps:
    validation_status: "validated | corrected | unvalidated"
    evidence_count: <N>
    actual_count: <N>
    false_gaps:
      - referenced_file: "<path>"
        reason: "file_exists | not_referenced"
    missed_gaps:
      - referenced_file: "<path>"
        referenced_by: ["<path>", ...]
        exists: false
```

### Step 12: Write reasoning.yaml

Write all validated evidence to `{artifact_evidence_dir}/reasoning.yaml`:

```yaml
knowledge_supporter: guideline-audit-knowledge-supporter
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
guideline_paths: ["<path>", ...]
overall_validation_status: "validated | partial | corrected"
guideline_files_validation: {...}
guideline_structure_validation: {...}
rule_condition_validation: [...]
cross_reference_validation: {...}
token_count_validation: {...}
ambiguity_validation: {...}
conflict_indicator_validation: {...}
enforcement_pattern_validation: {...}
file_organization_validation: {...}
unvalidated_items:
  - section: "<section name>"
    item: "<item description>"
    reason: "<why it could not be validated>"
corrections_summary:
  total_corrections: <N>
  sections_affected: ["<section>", ...]
```

### Step 13: Return Frugal Result Contract

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
- [ ] 3. Validate Guideline Files Evidence → INVALID if skipped
- [ ] 4. Validate Guideline Structure Evidence → INVALID if skipped
- [ ] 5. Validate Rule Condition Evidence → INVALID if skipped
- [ ] 6. Validate Cross-Reference Evidence → INVALID if skipped
- [ ] 7. Validate Token Count Evidence → INVALID if skipped
- [ ] 8. Validate Ambiguity Marker Evidence → INVALID if skipped
- [ ] 9. Validate Conflict Indicator Evidence → INVALID if skipped
- [ ] 10. Validate Enforcement Pattern Evidence → INVALID if skipped
- [ ] 11. Validate File Organization Evidence → INVALID if skipped
- [ ] 12. Write reasoning.yaml → INVALID if skipped
- [ ] 13. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| guideline_paths missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| Glob expansion returns no files | Return BLOCKED with NO_GUIDELINE_FILES_FOUND |
| Target guideline file not found | Record as `corrected` with `file_not_found` — do NOT BLOCK |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Evidence item references a file that does not exist | Record as `corrected` with `file_not_found` — do NOT BLOCK |
| Evidence section is missing from evidence.yaml | Record as `section_missing` — do NOT BLOCK |
| Cross-reference target (skill, tool, guideline) not found | Record as `broken_ref` — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write reasoning.yaml |

## Cross-References

- `tasks/guideline-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/guideline-audit.md` — Evaluator role (consumes this task's reasoning.yaml)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — guideline standards and critical rule definitions
- `065-verification-honesty.md` — live verification requirement
- `080-code-standards.md` — enforcement test mandate and evidence type taxonomy

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.
