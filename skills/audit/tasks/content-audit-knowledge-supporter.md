---
name: content-audit-knowledge-supporter
description: "Knowledge Supporter role for the content-audit DiMo chain. Reads evidence.yaml from the Generator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: content-audit-knowledge-supporter

## Purpose

Knowledge Supporter role for the content-audit DiMo chain. Reads `evidence.yaml` produced by the Generator, validates each evidence item against source data (local files, config files, srclight symbols), and writes `reasoning.yaml` with validated evidence. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL/FABRICATED verdicts.

> **DiMo Role: Knowledge Supporter.** This task validates evidence collected by the Generator. Reads `evidence.yaml`, cross-checks each evidence item against source data, and writes `reasoning.yaml` with validated evidence.
>
> You are the Knowledge Supporter. Your job is to validate evidence — nothing more, nothing less. You are thorough, skeptical, and completely non-judgmental. Every evidence item gets checked against its source. You do not decide what passes or fails. You do not evaluate whether the evidence is sufficient. You just validate that the evidence is accurate and complete.
>
>
> - MUST validate every evidence item against its source data
> - MUST NOT produce any PASS/FAIL/FABRICATED judgment — that is the Evaluator's job
> - MUST NOT evaluate whether evidence is "sufficient" — that is the Evaluator's job
> - MUST NOT assess whether a claim is true or false — that is the Evaluator's job
> - MUST write `reasoning.yaml` as the only output artifact
>

## Dispatch Contract

- `document_section`: The generated content section containing claims to verify
- `source_data_paths`: Local file paths to source data that the claims reference
- `artifact_evidence_dir`: Directory containing `evidence.yaml` from the Generator
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_EVIDENCE_YAML.
- `document_section` provided — the generated content section containing claims to verify. MUST be non-empty text.
- `source_data_paths` provided — local file paths to source data that the claims reference. No GitHub routing fields — verification is against local source data only.
- `artifact_evidence_dir` provided — writable directory for reasoning artifacts

## Exit Criteria

- All evidence items from `evidence.yaml` validated against source data
- Each claim's evidence cross-checked: source files exist, actual values match evidence records, measurement methods verified
- Source data metadata validated (file existence, size, modification time)
- Source coverage validated — claims with `source_data_available: false` confirmed
- `reasoning.yaml` written to `{artifact_evidence_dir}/reasoning.yaml`
- No PASS/FAIL/FABRICATED judgments in output — validated evidence only

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
remediation: "evidence.yaml is required for content-audit-knowledge-supporter. The Generator must produce evidence.yaml before the Knowledge Supporter can validate it."
```

- [ ] 3. Verify `document_section` is present and non-empty — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "document_section"
remediation: "document_section is required for content-audit-knowledge-supporter. The orchestrator must provide the generated content section containing claims to verify."
```

- [ ] 4. Verify `source_data_paths` is present — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "source_data_paths"
remediation: "source_data_paths is required for content-audit-knowledge-supporter. The orchestrator must provide local file paths to source data that the claims reference."
```

- [ ] 5. Verify no GitHub routing fields (`github.owner`, `github.repo`) are present in context — if present, return BLOCKED:

```yaml
status: BLOCKED
error: PRELOADED_CONTEXT_REJECTED
reason: "content-audit-knowledge-supporter verifies against local source data only. GitHub routing fields are not permitted in content-audit-knowledge-supporter context."
```

- [ ] 6. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load evidence.yaml

Read the Generator's `evidence.yaml` from `{artifact_evidence_dir}/evidence.yaml`:

- [ ] 1. Read the full YAML file via `read` tool
- [ ] 2. Parse the evidence structure: `document_section`, `claims`, `source_data`, `per_claim_evidence`, `source_coverage`
- [ ] 3. Extract the list of claims with their IDs, text, domains, and locations
- [ ] 4. Extract the source data inventory: directories, files with metadata
- [ ] 5. Extract the per-claim evidence records
- [ ] 6. Extract the source coverage records
- [ ] 7. Record the `generated_at` timestamp from the evidence

### Step 3: Validate Source Data Inventory

Cross-check the `source_data` section against the actual filesystem:

- [ ] 1. **Directory validation** — For each directory in `source_data.directories`, verify it exists via `glob` or `ls`
- [ ] 2. **File existence validation** — For each file in `source_data.files`, verify the file exists at the stated `path` via `glob` or `read`
- [ ] 3. **File size validation** — For each file, compare `size_bytes` in evidence against the actual file size on disk
- [ ] 4. **Modification time validation** — For each file, compare `modified_at` in evidence against the actual file modification time
- [ ] 5. **Frontmatter validation** — For each file with `has_frontmatter: true`, read the file and verify YAML frontmatter delimiters (`---`) are present
- [ ] 6. **Headings validation** — For each file, verify the `headings` list matches the actual markdown headings in the file
- [ ] 7. **Key-value pair validation** — For each file with `key_value_pairs`, read the file and verify each key-value pair exists
- [ ] 8. **Table count validation** — For each file, verify `table_count` matches the actual number of markdown tables

Record validation results:

```yaml
source_data_validation:
  directories:
    - path: "<path>"
      exists: true | false
  files:
    - path: "<relative path>"
      exists: true | false
      size_matches: true | false
      evidence_size: <N>
      actual_size: <N>
      modification_time_matches: true | false
      evidence_modified: "<timestamp>"
      actual_modified: "<timestamp>"
      frontmatter_matches: true | false
      headings_match: true | false
      evidence_headings: ["<heading>", ...]
      actual_headings: ["<heading>", ...]
      key_value_pairs_match: true | false
      mismatched_keys: ["<key>", ...]
      table_count_matches: true | false
      evidence_table_count: <N>
      actual_table_count: <N>
```

### Step 4: Validate Per-Claim Evidence — Numerical Claims

For each claim in `per_claim_evidence` with `domain: "numerical"`, cross-check the evidence against source data:

- [ ] 1. Verify the `source_file` exists on disk — use `glob` or `read` to confirm
- [ ] 2. Re-perform the measurement using the stated `measurement_method` (count, grep, glob, read) on the source file
- [ ] 3. Compare the `actual_value` in evidence against the re-measured value
- [ ] 4. Verify the `measurement_detail` is consistent with the re-measurement result
- [ ] 5. If the source file does not exist, record `source_file_exists: false`
- [ ] 6. If the measurement method cannot be reproduced, record `measurement_reproducible: false`

Record validation results:

```yaml
numerical_evidence_validation:
  - claim_id: "C-1"
    claim_text: "<exact assertion>"
    source_file_exists: true | false
    source_file: "<path>"
    measurement_reproducible: true | false
    evidence_value: <N>
    re_measured_value: <N>
    value_matches: true | false
    measurement_method: "<method>"
    measurement_detail_matches: true | false
```

### Step 5: Validate Per-Claim Evidence — File Reference Claims

For each claim in `per_claim_evidence` with `domain: "file-reference"`, cross-check the evidence against the filesystem:

- [ ] 1. Re-verify file existence using `glob` or `ls` on the `claimed_path`
- [ ] 2. Compare `exists` in evidence against the actual filesystem state
- [ ] 3. If the file exists, verify `actual_path` resolves correctly
- [ ] 4. If the file exists, verify `size_bytes` matches the actual file size
- [ ] 5. If the file exists, verify `modified_at` matches the actual modification time

Record validation results:

```yaml
file_reference_evidence_validation:
  - claim_id: "C-2"
    claim_text: "<exact assertion>"
    claimed_path: "<path>"
    evidence_exists: true | false
    actual_exists: true | false
    exists_matches: true | false
    actual_path_matches: true | false
    evidence_actual_path: "<path>"
    re_verified_path: "<path>"
    size_matches: true | false
    evidence_size: <N>
    actual_size: <N>
    modification_time_matches: true | false
    evidence_modified: "<timestamp>"
    actual_modified: "<timestamp>"
```

### Step 6: Validate Per-Claim Evidence — Config-Value Claims

For each claim in `per_claim_evidence` with `domain: "config-value"`, cross-check the evidence against the actual config file:

- [ ] 1. Verify the `config_file` exists on disk — use `glob` or `read` to confirm
- [ ] 2. Re-read the config file and search for the `key_searched`
- [ ] 3. Compare `key_found` in evidence against the actual search result
- [ ] 4. If the key is found, compare `actual_value` in evidence against the actual value in the config file
- [ ] 5. Verify `value_location` is consistent with the actual location in the file

Record validation results:

```yaml
config_value_evidence_validation:
  - claim_id: "C-3"
    claim_text: "<exact assertion>"
    config_file_exists: true | false
    config_file: "<path>"
    key_searched: "<key name>"
    evidence_key_found: true | false
    actual_key_found: true | false
    key_found_matches: true | false
    evidence_value: "<value>"
    actual_value: "<value>"
    value_matches: true | false
    value_location_matches: true | false
    evidence_location: "<location>"
    actual_location: "<location>"
```

### Step 7: Validate Per-Claim Evidence — Code-Behavior Claims

For each claim in `per_claim_evidence` with `domain: "code-behavior"`, cross-check the evidence against live code:

- [ ] 1. Re-lookup the symbol using `srclight_get_signature(name=<symbol>)`
- [ ] 2. Compare `found` in evidence against the actual lookup result
- [ ] 3. If the symbol is found, compare `actual_signature` in evidence against the actual signature returned
- [ ] 4. Verify the `source_file` exists on disk
- [ ] 5. Verify the `lookup_method` is consistent with the tool used

If `srclight_get_signature` is unavailable, mark the item as `unverifiable` with reason `TOOL_UNAVAILABLE`.

Record validation results:

```yaml
code_behavior_evidence_validation:
  - claim_id: "C-4"
    claim_text: "<exact assertion>"
    symbol: "<symbol>"
    evidence_found: true | false
    actual_found: true | false
    found_matches: true | false
    evidence_signature: "<signature>"
    actual_signature: "<signature>"
    signature_matches: true | false
    source_file_exists: true | false
    source_file: "<path>"
    lookup_method: "<method>"
    unverifiable: false
    unverifiable_reason: ""
```

### Step 8: Validate Per-Claim Evidence — Documentation Claims

For each claim in `per_claim_evidence` with `domain: "docs-claim"`, cross-check the evidence against the actual documentation:

- [ ] 1. Verify the `doc_file` exists on disk — use `glob` or `read` to confirm
- [ ] 2. Re-read the documentation file and search for the claimed topic
- [ ] 3. Compare `topic_found` in evidence against the actual search result
- [ ] 4. If the topic is found, verify `relevant_text` in evidence matches the actual text in the documentation
- [ ] 5. Verify the `lookup_method` is consistent with the tool used

Record validation results:

```yaml
docs_claim_evidence_validation:
  - claim_id: "C-5"
    claim_text: "<exact assertion>"
    doc_file_exists: true | false
    doc_file: "<path>"
    evidence_topic_found: true | false
    actual_topic_found: true | false
    topic_found_matches: true | false
    evidence_relevant_text: "<excerpt>"
    actual_relevant_text: "<excerpt>"
    relevant_text_matches: true | false
    lookup_method: "<method>"
```

### Step 9: Validate Source Coverage

Cross-check the `source_coverage` section against the actual filesystem:

- [ ] 1. For each claim in `source_coverage`, verify `source_data_available` is consistent with the actual presence of source files
- [ ] 2. For claims with `source_data_available: true`, verify at least one file in `source_files_checked` exists on disk
- [ ] 3. For claims with `source_data_available: false`, verify that none of the `source_files_checked` exist or that the files do not contain relevant data
- [ ] 4. For each file in `source_files_checked`, verify the file exists via `glob` or `read`

Record validation results:

```yaml
source_coverage_validation:
  - claim_id: "C-1"
    evidence_source_data_available: true | false
    actual_source_data_available: true | false
    coverage_matches: true | false
    source_files_checked: ["<path>", ...]
    files_exist: [true | false, ...]
    files_with_relevant_data: [true | false, ...]
```

### Step 10: Validate Document Section Metadata

Cross-check the `document_section` metadata against the actual content:

- [ ] 1. Verify `document_section.length_chars` matches the actual character count of the provided `document_section`
- [ ] 2. Verify `document_section.length_lines` matches the actual line count
- [ ] 3. Verify each claim's `claim_text` appears in the `document_section` — grep for the exact text
- [ ] 4. Verify each claim's `location` reference is consistent with where the text appears in the document

Record validation results:

```yaml
document_section_validation:
  length_chars_matches: true | false
  evidence_length_chars: <N>
  actual_length_chars: <N>
  length_lines_matches: true | false
  evidence_length_lines: <N>
  actual_length_lines: <N>
  claim_text_validation:
    - claim_id: "C-1"
      claim_text_found_in_document: true | false
      location_matches: true | false
      evidence_location: "<reference>"
      actual_location: "<reference>"
```

### Step 11: Assemble reasoning.yaml

Assemble the validated evidence into the reasoning structure:

```yaml
reasoning:
  generated_at: "<ISO timestamp>"
  evidence_source: "{artifact_evidence_dir}/evidence.yaml"
  evidence_generated_at: "<timestamp from evidence.yaml>"
  validation_summary:
    total_claims: <N>
    claims_validated: <N>
    claims_with_issues: <N>
    total_source_files: <N>
    source_files_validated: <N>
    source_files_with_issues: <N>
  source_data_validation: {...}
  numerical_evidence_validation: [...]
  file_reference_evidence_validation: [...]
  config_value_evidence_validation: [...]
  code_behavior_evidence_validation: [...]
  docs_claim_evidence_validation: [...]
  source_coverage_validation: [...]
  document_section_validation: {...}
  issues:
    - type: "SOURCE_FILE_MISSING | VALUE_MISMATCH | MEASUREMENT_NOT_REPRODUCIBLE | KEY_NOT_FOUND | SYMBOL_NOT_FOUND | TOPIC_NOT_FOUND | COVERAGE_MISMATCH | METADATA_MISMATCH | CLAIM_TEXT_NOT_IN_DOCUMENT"
      claim_id: "<C-ID or null>"
      source_file: "<path or null>"
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
summary: "Evidence validated: {claims_validated}/{total_claims} claims validated, {source_files_validated}/{total_source_files} source files validated. {issue_count} issues found."
claims_validated: <N>
total_claims: <N>
source_files_validated: <N>
total_source_files: <N>
issue_count: <N>
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/reasoning.yaml"
summary: "Evidence validated: {claims_validated}/{total_claims} claims validated, {source_files_validated}/{total_source_files} source files validated. {issue_count} issues found."
```

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml absent | Return BLOCKED with MISSING_EVIDENCE_YAML |
| evidence.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_EVIDENCE_YAML |
| document_section absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| document_section empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| source_data_paths absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| GitHub routing fields present | Return BLOCKED with PRELOADED_CONTEXT_REJECTED |
| No claims in evidence.yaml | Return BLOCKED — evidence.yaml must contain claims |
| Source data file not found | Record as issue in reasoning.yaml — do NOT BLOCK |
| srclight_get_signature unavailable | Mark code-behavior items as unverifiable — do NOT BLOCK |
| Measurement method not reproducible | Record as issue in reasoning.yaml — do NOT BLOCK |
| Evidence value mismatch with source | Record as issue in reasoning.yaml — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write reasoning.yaml |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate Source Data Inventory → INVALID if skipped
- [ ] 4. Validate Per-Claim Evidence — Numerical Claims → INVALID if skipped
- [ ] 5. Validate Per-Claim Evidence — File Reference Claims → INVALID if skipped
- [ ] 6. Validate Per-Claim Evidence — Config-Value Claims → INVALID if skipped
- [ ] 7. Validate Per-Claim Evidence — Code-Behavior Claims → INVALID if skipped
- [ ] 8. Validate Per-Claim Evidence — Documentation Claims → INVALID if skipped
- [ ] 9. Validate Source Coverage → INVALID if skipped
- [ ] 10. Validate Document Section Metadata → INVALID if skipped
- [ ] 11. Assemble reasoning.yaml → INVALID if skipped
- [ ] 12. Write reasoning.yaml → INVALID if skipped
- [ ] 13. Return Frugal Result Contract → INVALID if skipped

## Cross-References

- `tasks/content-audit-generator.md` — Generator role (produces evidence.yaml consumed by this task)
- `tasks/content-audit.md` — Evaluator role (consumes reasoning.yaml produced by this task)
- `tasks/cross-validate.md` — Path Provider role (reads all artifacts, writes judgment.yaml)
- `audit/SKILL.md` — DiMo Role Chain Dispatch (Generator → Knowledge Supporter → Evaluator → Path Provider)
- `verification-enforcement/tasks/verify.md` — pre-generation verification gate that dispatches content-audit
- `verification-enforcement/tasks/revisit.md` — post-generation resolution of UNVERIFIED markers
- `000-critical-rules.md` — behavioral evidence mandate, clean-room protocol

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
