---
name: content-audit-evaluator
description: "Evaluator role for the content-audit chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each claim, and writes verdict.yaml with per-claim PASS/FAIL/FABRICATED verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: content-audit-evaluator

## Purpose

Evaluator role for the content-audit chain. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each factual claim against the validated evidence, and writes `verdict.yaml` with per-claim PASS/FAIL/FABRICATED verdicts. This role produces judgments — it does NOT collect evidence or validate evidence. Those are upstream responsibilities.


> **Default assumption: FABRICATED.** The default verdict for every claim is FABRICATED unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FABRICATED. A clean PASS requires: (1) source data files are present and readable, (2) the claim is directly supported by source data, (3) no hedging language in the explanation, (4) all criteria evaluated against validated evidence.

## Dispatch Contract

- `document_section`: The generated content section containing claims to verify
- `source_data_paths`: Local file paths to source data that the claims reference
- `artifact_evidence_dir`: Directory containing `evidence.yaml` and `reasoning.yaml` from upstream roles

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Evaluator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the upstream reasoning role completed successfully and wrote `reasoning.yaml` before dispatching the Evaluator. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `document_section` provided — the generated content section containing claims to verify. MUST be non-empty text.
- `source_data_paths` provided — local file paths to source data that the claims reference. No GitHub routing fields — verification is against local source data only.
- `artifact_evidence_dir` provided — writable directory for verdict artifacts

## Exit Criteria

- `verdict.yaml` written to `{artifact_evidence_dir}/verdict.yaml`
- Every claim evaluated with binary PASS, FAIL, or FABRICATED — no INCONCLUSIVE, no "PASS with concerns"
- Evidence type compliance verified — each claim evaluated using the appropriate verification method per domain
- Source coverage evaluated — claims with no source data classified as FABRICATED
- Self-consistency gate applied to all PASS verdicts
- No new evidence collected — all evaluation based on upstream artifacts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `verdict.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for content-audit-evaluator. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Evaluator."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for content-audit-evaluator. The orchestrator must ensure the upstream reasoning role completed successfully and wrote reasoning.yaml before dispatching the Evaluator."
```

- [ ] 5. Verify `document_section` is present and non-empty — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "document_section"
remediation: "document_section is required for content-audit-evaluator. The orchestrator must provide the generated content section containing claims to verify."
```

- [ ] 6. Verify `source_data_paths` is present — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "source_data_paths"
remediation: "source_data_paths is required for content-audit-evaluator. The orchestrator must provide local file paths to source data that the claims reference."
```

- [ ] 7. Verify no GitHub routing fields (`github.owner`, `github.repo`) are present in context — if present, return BLOCKED:

```yaml
status: BLOCKED
error: PRELOADED_CONTEXT_REJECTED
reason: "content-audit-evaluator verifies against local source data only. GitHub routing fields are not permitted in content-audit-evaluator context."
```

- [ ] 8. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read the Investigator's evidence and the upstream reasoning role's validated reasoning:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Parse all top-level sections from both artifacts
- [ ] 4. Record metadata: `generator`, `knowledge_supporter`, `generated_at`, `evidence_generated_at`, `reasoning_generated_at`
- [ ] 5. Extract the claim list from `evidence.yaml` — `claims` array with claim_id, claim_text, domain, location
- [ ] 6. Extract the per-claim evidence from `evidence.yaml` — `per_claim_evidence` array
- [ ] 7. Extract the source coverage from `evidence.yaml` — `source_coverage` array
- [ ] 8. Extract the source data inventory from `evidence.yaml` — `source_data` section
- [ ] 9. Extract validation results from `reasoning.yaml`:
  - `numerical_evidence_validation`
  - `file_reference_evidence_validation`
  - `config_value_evidence_validation`
  - `code_behavior_evidence_validation`
  - `docs_claim_evidence_validation`
  - `source_coverage_validation`
  - `document_section_validation`
  - `issues`
- [ ] 10. Cross-reference: for each claim in `evidence.yaml`, locate its corresponding validation entries in `reasoning.yaml`
- [ ] 11. If any expected top-level section is absent from either artifact, record as `section_missing` — do NOT BLOCK, but flag in the verdict

### Step 3: Load Document Section

Read the generated content section to establish the authoritative baseline for evaluation:

- [ ] 1. Read `document_section` in full
- [ ] 2. Verify each claim's `claim_text` appears in the document section — cross-reference against `document_section_validation.claim_text_validation` from `reasoning.yaml`
- [ ] 3. Verify `document_section.length_chars` and `document_section.length_lines` match — cross-reference against `document_section_validation` from `reasoning.yaml`
- [ ] 4. If the upstream reasoning role flagged `CLAIM_TEXT_NOT_IN_DOCUMENT` for any claim, note this in the evaluation

### Step 4: Evaluate Numerical Claims

For each claim in `per_claim_evidence` with `domain: "numerical"`, evaluate against validated evidence:

- [ ] 1. Locate the corresponding entry in `reasoning.yaml` → `numerical_evidence_validation`
- [ ] 2. Apply the evaluation decision tree:

| Condition | Verdict |
|-----------|---------|
| `source_file_exists: false` | FABRICATED — source file does not exist |
| `measurement_reproducible: false` | FABRICATED — evidence cannot be reproduced |
| `value_matches: true` AND `measurement_reproducible: true` | PASS — claim matches source data |
| `value_matches: false` | FAIL — claim contradicts source data |
| No validation entry found for this claim | FABRICATED — no validated evidence exists |

- [ ] 3. For PASS verdicts: verify the `evidence_value` equals the `re_measured_value` and the `measurement_method` is reproducible
- [ ] 4. For FAIL verdicts: record the discrepancy between `evidence_value` and `re_measured_value`
- [ ] 5. For FABRICATED verdicts: record why no source evidence supports the claim

Record results:

```yaml
- claim_id: "C-1"
  claim_text: "<exact assertion>"
  domain: "numerical"
  result: "PASS | FAIL | FABRICATED"
  evidence: "reasoning.yaml → numerical_evidence_validation"
  evidence_value: <N>
  re_measured_value: <N>
  explanation: "<reasoning for verdict>"
  remediation: "<if FAIL or FABRICATED, what to fix>"
  next_step: "proceed | remediate"
```

### Step 5: Evaluate File Reference Claims

For each claim in `per_claim_evidence` with `domain: "file-reference"`, evaluate against validated evidence:

- [ ] 1. Locate the corresponding entry in `reasoning.yaml` → `file_reference_evidence_validation`
- [ ] 2. Apply the evaluation decision tree:

| Condition | Verdict |
|-----------|---------|
| `actual_exists: false` | FABRICATED — file does not exist |
| `exists_matches: true` AND `actual_exists: true` AND `size_matches: true` AND `modification_time_matches: true` | PASS — file reference is accurate |
| `exists_matches: false` | FAIL — evidence contradicts filesystem |
| `size_matches: false` OR `modification_time_matches: false` | FAIL — file exists but metadata does not match |
| No validation entry found for this claim | FABRICATED — no validated evidence exists |

- [ ] 3. For PASS verdicts: verify the file exists at the claimed path with matching metadata
- [ ] 4. For FAIL verdicts: record the specific metadata mismatch
- [ ] 5. For FABRICATED verdicts: record that the file does not exist

Record results:

```yaml
- claim_id: "C-2"
  claim_text: "<exact assertion>"
  domain: "file-reference"
  result: "PASS | FAIL | FABRICATED"
  evidence: "reasoning.yaml → file_reference_evidence_validation"
  claimed_path: "<path>"
  actual_exists: true | false
  explanation: "<reasoning for verdict>"
  remediation: "<if FAIL or FABRICATED, what to fix>"
  next_step: "proceed | remediate"
```

### Step 6: Evaluate Config-Value Claims

For each claim in `per_claim_evidence` with `domain: "config-value"`, evaluate against validated evidence:

- [ ] 1. Locate the corresponding entry in `reasoning.yaml` → `config_value_evidence_validation`
- [ ] 2. Apply the evaluation decision tree:

| Condition | Verdict |
|-----------|---------|
| `config_file_exists: false` | FABRICATED — config file does not exist |
| `actual_key_found: false` | FABRICATED — key does not exist in config |
| `key_found_matches: true` AND `value_matches: true` | PASS — config value matches claim |
| `value_matches: false` | FAIL — config value contradicts claim |
| `key_found_matches: false` | FAIL — evidence contradicts config state |
| No validation entry found for this claim | FABRICATED — no validated evidence exists |

- [ ] 3. For PASS verdicts: verify the key exists and the value matches the claim
- [ ] 4. For FAIL verdicts: record the actual value vs. the claimed value
- [ ] 5. For FABRICATED verdicts: record that the config file or key does not exist

Record results:

```yaml
- claim_id: "C-3"
  claim_text: "<exact assertion>"
  domain: "config-value"
  result: "PASS | FAIL | FABRICATED"
  evidence: "reasoning.yaml → config_value_evidence_validation"
  config_file: "<path>"
  key_searched: "<key>"
  evidence_value: "<value>"
  actual_value: "<value>"
  explanation: "<reasoning for verdict>"
  remediation: "<if FAIL or FABRICATED, what to fix>"
  next_step: "proceed | remediate"
```

### Step 7: Evaluate Code-Behavior Claims

For each claim in `per_claim_evidence` with `domain: "code-behavior"`, evaluate against validated evidence:

- [ ] 1. Locate the corresponding entry in `reasoning.yaml` → `code_behavior_evidence_validation`
- [ ] 2. Apply the evaluation decision tree:

| Condition | Verdict |
|-----------|---------|
| `unverifiable: true` | FABRICATED — cannot verify (tool unavailable) |
| `actual_found: false` | FABRICATED — symbol does not exist |
| `found_matches: true` AND `signature_matches: true` AND `source_file_exists: true` | PASS — code behavior matches claim |
| `signature_matches: false` | FAIL — signature contradicts claim |
| `found_matches: false` | FAIL — evidence contradicts code state |
| `source_file_exists: false` | FAIL — source file does not exist |
| No validation entry found for this claim | FABRICATED — no validated evidence exists |

- [ ] 3. For PASS verdicts: verify the symbol exists with the claimed signature
- [ ] 4. For FAIL verdicts: record the actual signature vs. the claimed behavior
- [ ] 5. For FABRICATED verdicts: record that the symbol does not exist or cannot be verified

Record results:

```yaml
- claim_id: "C-4"
  claim_text: "<exact assertion>"
  domain: "code-behavior"
  result: "PASS | FAIL | FABRICATED"
  evidence: "reasoning.yaml → code_behavior_evidence_validation"
  symbol: "<symbol>"
  evidence_signature: "<signature>"
  actual_signature: "<signature>"
  explanation: "<reasoning for verdict>"
  remediation: "<if FAIL or FABRICATED, what to fix>"
  next_step: "proceed | remediate"
```

### Step 8: Evaluate Documentation Claims

For each claim in `per_claim_evidence` with `domain: "docs-claim"`, evaluate against validated evidence:

- [ ] 1. Locate the corresponding entry in `reasoning.yaml` → `docs_claim_evidence_validation`
- [ ] 2. Apply the evaluation decision tree:

| Condition | Verdict |
|-----------|---------|
| `doc_file_exists: false` | FABRICATED — documentation file does not exist |
| `actual_topic_found: false` | FABRICATED — topic not found in documentation |
| `topic_found_matches: true` AND `relevant_text_matches: true` | PASS — documentation supports claim |
| `relevant_text_matches: false` | FAIL — documentation text contradicts claim |
| `topic_found_matches: false` | FAIL — evidence contradicts documentation state |
| No validation entry found for this claim | FABRICATED — no validated evidence exists |

- [ ] 3. For PASS verdicts: verify the topic is discussed and the text supports the claim
- [ ] 4. For FAIL verdicts: record the actual documentation text vs. the claimed text
- [ ] 5. For FABRICATED verdicts: record that the documentation file or topic does not exist

Record results:

```yaml
- claim_id: "C-5"
  claim_text: "<exact assertion>"
  domain: "docs-claim"
  result: "PASS | FAIL | FABRICATED"
  evidence: "reasoning.yaml → docs_claim_evidence_validation"
  doc_file: "<path>"
  evidence_relevant_text: "<excerpt>"
  actual_relevant_text: "<excerpt>"
  explanation: "<reasoning for verdict>"
  remediation: "<if FAIL or FABRICATED, what to fix>"
  next_step: "proceed | remediate"
```

### Step 9: Evaluate Source Coverage

Evaluate whether claims have corresponding source data:

- [ ] 1. Read `source_coverage_validation` from `reasoning.yaml`
- [ ] 2. For each claim in `source_coverage_validation`:
  - If `coverage_matches: false` — the Investigator's coverage assessment was inaccurate
  - If `actual_source_data_available: false` — no source data exists for this claim
- [ ] 3. For claims with `actual_source_data_available: false`:
  - If the claim is a factual assertion about the codebase → FABRICATED (no source evidence)
  - If the claim is a subjective statement or opinion → mark as `UNVERIFIABLE` (not a factual claim)
- [ ] 4. For claims with `actual_source_data_available: true` but no validation entry in reasoning.yaml:
  - The upstream reasoning role could not validate this claim → FABRICATED

Record results:

```yaml
source_coverage_evaluation:
  claims_with_source_data: <N>
  claims_without_source_data: <N>
  unverifiable_claims: <N>
  coverage_gaps:
    - claim_id: "<C-ID>"
      claim_text: "<exact assertion>"
      source_data_available: false
      classification: "FABRICATED | UNVERIFIABLE"
      reason: "<why no source data exists or why unverifiable>"
```

### Step 10: Evaluate Source Data Inventory

Cross-check the source data inventory validation from `reasoning.yaml`:

- [ ] 1. Read `source_data_validation` from `reasoning.yaml`
- [ ] 2. For each directory: if `exists: false`, record as `SOURCE_DIR_MISSING`
- [ ] 3. For each file: if `exists: false`, record as `SOURCE_FILE_MISSING`
- [ ] 4. For each file: if `size_matches: false` or `modification_time_matches: false`, record as `SOURCE_FILE_STALE`
- [ ] 5. For each file: if `frontmatter_matches: false`, `headings_match: false`, `key_value_pairs_match: false`, or `table_count_matches: false`, record as `SOURCE_FILE_METADATA_MISMATCH`
- [ ] 6. Source data inventory issues do NOT directly cause claim verdicts to change — they indicate evidence quality concerns

Record results:

```yaml
source_data_inventory_evaluation:
  directories_checked: <N>
  directories_missing: <N>
  files_checked: <N>
  files_missing: <N>
  files_stale: <N>
  files_metadata_mismatch: <N>
  issues:
    - type: "SOURCE_DIR_MISSING | SOURCE_FILE_MISSING | SOURCE_FILE_STALE | SOURCE_FILE_METADATA_MISMATCH"
      path: "<path>"
      detail: "<description>"
```

### Step 11: Evaluate Issues from upstream reasoning role

Review the `issues` array from `reasoning.yaml` for any validation problems that affect verdicts:

- [ ] 1. Read `issues` from `reasoning.yaml`
- [ ] 2. For each issue, determine if it affects a claim verdict:
  - `SOURCE_FILE_MISSING` — downgrade affected claims to FABRICATED
  - `VALUE_MISMATCH` — affected claim is already FAIL from per-domain evaluation
  - `MEASUREMENT_NOT_REPRODUCIBLE` — downgrade affected claims to FABRICATED
  - `KEY_NOT_FOUND` — downgrade affected claims to FABRICATED
  - `SYMBOL_NOT_FOUND` — downgrade affected claims to FABRICATED
  - `TOPIC_NOT_FOUND` — downgrade affected claims to FABRICATED
  - `COVERAGE_MISMATCH` — already handled in Step 9
  - `METADATA_MISMATCH` — informational only, does not change claim verdicts
  - `CLAIM_TEXT_NOT_IN_DOCUMENT` — downgrade affected claim to FABRICATED (claim text not found in document)
- [ ] 3. Apply any verdict downgrades from issues

Record results:

```yaml
issue_impact:
  issues_found: <N>
  verdicts_downgraded: <N>
  downgrades:
    - claim_id: "<C-ID>"
      original_result: "<verdict>"
      downgraded_to: "<verdict>"
      issue_type: "<ISSUE_TYPE>"
      reason: "<description>"
```

### Step 12: Process Verdicts

Compile all per-claim verdicts and apply consensus rules:

- [ ] 1. Collect all verdicts from Steps 4-8 into a single `per_claim` array
- [ ] 2. Each entry must include: `claim_id`, `claim_text`, `domain`, `result`, `evidence`, `explanation`, `remediation`, `next_step`
- [ ] 3. `next_step` is `"proceed"` when result is PASS, `"remediate"` when result is FAIL or FABRICATED
- [ ] 4. Count total, pass, fail, and fabricated verdicts
- [ ] 5. Compute `all_claims_pass: true` only if every claim is PASS

### Step 13: Apply Self-Consistency Gate

Apply a self-consistency check to every PASS verdict:

- [ ] 1. For each claim with `result: "PASS"`:
  - Read the `explanation` field
  - If the explanation contains critique/hedging language → downgrade to FAIL
  - Hedging patterns: "should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally", "largely", "essentially", "partially", "not ideal", "could be better", "incomplete", "lacking", "insufficient", "problematic", "requires attention", "needs work", "not fully"
  - A PASS verdict must be strictly confirmatory with no critique or hedging
- [ ] 2. Re-count pass/fail/fabricated after self-consistency downgrades
- [ ] 3. Log downgrades:

```yaml
self_consistency_downgrades:
  - claim_id: "<C-ID>"
    original_result: "PASS"
    downgraded_to: "FAIL"
    hedging_phrase: "<matched phrase>"
```

### Step 14: Write verdict.yaml

Write the complete verdict to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: content-audit-evaluator
generated_at: "<ISO timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
evidence_generated_at: "<timestamp from evidence.yaml>"
reasoning_generated_at: "<timestamp from reasoning.yaml>"
document_section:
  length_chars: <N>
  length_lines: <N>
summary:
  total_claims: <N>
  pass: <N>
  fail: <N>
  fabricated: <N>
  all_claims_pass: true | false
  remediation_required: true | false
per_claim:
  - claim_id: "C-1"
    claim_text: "<exact assertion from document>"
    domain: "numerical | file-reference | config-value | code-behavior | docs-claim"
    result: "PASS | FAIL | FABRICATED"
    evidence: "<reference to reasoning.yaml section>"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL or FABRICATED, what to fix>"
    next_step: "proceed | remediate"
source_coverage_evaluation:
  claims_with_source_data: <N>
  claims_without_source_data: <N>
  unverifiable_claims: <N>
  coverage_gaps: [...]
source_data_inventory_evaluation:
  directories_checked: <N>
  directories_missing: <N>
  files_checked: <N>
  files_missing: <N>
  files_stale: <N>
  files_metadata_mismatch: <N>
  issues: [...]
issue_impact:
  issues_found: <N>
  verdicts_downgraded: <N>
  downgrades: [...]
self_consistency_downgrades:
  - claim_id: "<C-ID>"
    original_result: "PASS"
    downgraded_to: "FAIL"
    hedging_phrase: "<matched phrase>"
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `verdict.yaml` with the complete verdict structure
- [ ] 3. Verify the file was written and is non-empty

### Step 14.5: Identify Behavioral SCs for Clean-Room Evaluation

- [ ] 14.5. From the evaluated criteria, collect SC IDs whose evidence type is `behavioral` (either declared or uplifted)
  - Add `needs_clean_room: [SC-IDs]` to the result contract
  - If no behavioral SCs, set `needs_clean_room: []`

### Step 15: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "<N> claims evaluated. <X> PASS, <Y> FAIL, <Z> FABRICATED."
all_claims_pass: true | false
remediation_required: true | false
needs_clean_room: [SC-IDs]
```

## Result Contract

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "<N> claims evaluated. <X> PASS, <Y> FAIL, <Z> FABRICATED."
all_claims_pass: true | false
remediation_required: true | false
needs_clean_room: [SC-IDs]
```

## Clean-Room Protocol

- **role chain**: Dispatched via sequential `task(subagent_type="general")` calls. Investigator → upstream reasoning role → Evaluator → Arbiter. Each role reads upstream artifacts and writes its own.
- **No orchestrator preload**: Sub-agents receive only `{ document_section, source_data_paths, artifact_evidence_dir }`. No orchestrator reasoning, expected outcomes, pre-loaded evidence, or cached verification results.
- **Sub-agent entry criteria**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.
- **Evidence artifacts on disk**: Each role writes full evidence artifacts to disk. The result contract carries only routing-significant data (`status`, `finding_summary`, `artifact_path`, `blocker_reason`).

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Document Section → INVALID if skipped
- [ ] 4. Evaluate Numerical Claims → INVALID if skipped
- [ ] 5. Evaluate File Reference Claims → INVALID if skipped
- [ ] 6. Evaluate Config-Value Claims → INVALID if skipped
- [ ] 7. Evaluate Code-Behavior Claims → INVALID if skipped
- [ ] 8. Evaluate Documentation Claims → INVALID if skipped
- [ ] 9. Evaluate Source Coverage → INVALID if skipped
- [ ] 10. Evaluate Source Data Inventory → INVALID if skipped
- [ ] 11. Evaluate Issues from upstream reasoning role → INVALID if skipped
- [ ] 12. Process Verdicts → INVALID if skipped
- [ ] 13. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 14. Write verdict.yaml → INVALID if skipped
- [ ] 14.5. Identify Behavioral SCs for Clean-Room Evaluation → INVALID if skipped
- [ ] 15. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| document_section absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| document_section empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| source_data_paths absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| GitHub routing fields present | Return BLOCKED with PRELOADED_CONTEXT_REJECTED |
| No claims in evidence.yaml | Return BLOCKED — evidence.yaml must contain claims |
| upstream reasoning role flagged evidence as unvalidated | Note uncertainty in explanation — still render verdict |
| upstream reasoning role flagged evidence as corrected | Use corrected values — do NOT use original evidence values |
| Claim has no validation entry in reasoning.yaml | Evaluate as FABRICATED — no validated evidence exists |
| Source data file not found | Evaluate affected claims as FABRICATED |
| Write permission denied | Return BLOCKED — cannot write verdict.yaml |
| Self-consistency gate triggers downgrade | Apply downgrade, recompute summary — do NOT override the gate |

## Cross-References

- `tasks/content-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/content-audit-validator.md` — upstream reasoning role role (produces the reasoning.yaml consumed by this task)
- `tasks/cross-validate.md` — Arbiter role (consumes this task's verdict.yaml)
- `verification-enforcement/tasks/verify.md` — pre-generation verification gate that dispatches content-audit
- `verification-enforcement/tasks/revisit.md` — post-generation resolution of UNVERIFIED markers
- `000-critical-rules.md` — behavioral evidence mandate, clean-room protocol
- `065-verification-honesty.md` — live-source verification mandate, hard failure discipline

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
