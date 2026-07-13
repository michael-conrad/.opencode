---
name: content-audit-path-provider
description: "Path Provider role for the content-audit DiMo chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: content-audit-path-provider

## Purpose

Path Provider role for the content-audit DiMo chain. Reads all upstream artifacts (`evidence.yaml` from Generator, `reasoning.yaml` from Knowledge Supporter, `verdict.yaml` from Evaluator) and produces the final `judgment.yaml` with final judgment and `next_step`. This role synthesizes — it does NOT evaluate, re-evaluate, or second-guess upstream roles.

> **DiMo Role: Path Provider.** This task produces the final judgment by synthesizing all upstream artifacts. Reads `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, writes `judgment.yaml`.
>
> You are the Path Provider. You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
>
>
> - MUST accept Evaluator's per-claim verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL/FABRICATED from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
> - MUST synthesize the per-claim verdicts, source coverage evaluation, source data inventory evaluation, issue impact, and self-consistency downgrades into a single coherent judgment

## Dispatch Contract

- `document_section`: The generated content section containing claims that were verified
- `source_data_paths`: Local file paths to source data that the claims reference
- `artifact_evidence_dir`: Directory containing `evidence.yaml`, `reasoning.yaml`, and `verdict.yaml` from upstream roles

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Generator completed successfully and wrote `evidence.yaml` before dispatching the Path Provider. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Knowledge Supporter completed successfully and wrote `reasoning.yaml` before dispatching the Path Provider. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Evaluator completed successfully and wrote `verdict.yaml` before dispatching the Path Provider. Dispatching without a valid `verdict.yaml` is a CRITICAL VIOLATION.
- `document_section` provided — the generated content section containing claims that were verified. MUST be non-empty text.
- `source_data_paths` provided — local file paths to source data that the claims reference. No GitHub routing fields — verification is against local source data only.
- `artifact_evidence_dir` provided (writable directory for judgment artifacts)

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts read and synthesized into a single coherent judgment
- Per-claim verdicts carried forward from Evaluator's verdict
- Source coverage evaluation carried forward from Evaluator's verdict
- Source data inventory evaluation carried forward from Evaluator's verdict
- Issue impact carried forward from Evaluator's verdict
- Self-consistency downgrades carried forward from Evaluator's verdict
- `next_step` determined: `"proceed"` if all claims PASS, `"remediate"` if any FAIL or FABRICATED
- No new evidence collected — all synthesis based on upstream artifacts
- No re-evaluation of any claim — Evaluator's verdicts are final

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `judgment.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "evidence.yaml is required for content-audit-path-provider. The orchestrator must ensure the Generator completed successfully and wrote evidence.yaml before dispatching the Path Provider."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for content-audit-path-provider. The orchestrator must ensure the Knowledge Supporter completed successfully and wrote reasoning.yaml before dispatching the Path Provider."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 6. If `verdict.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "verdict.yaml is required for content-audit-path-provider. The orchestrator must ensure the Evaluator completed successfully and wrote verdict.yaml before dispatching the Path Provider."
```

- [ ] 7. Verify `document_section` is present and non-empty — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "document_section"
remediation: "document_section is required for content-audit-path-provider. The orchestrator must provide the generated content section containing claims that were verified."
```

- [ ] 8. Verify `source_data_paths` is present — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "source_data_paths"
remediation: "source_data_paths is required for content-audit-path-provider. The orchestrator must provide local file paths to source data that the claims reference."
```

- [ ] 9. Verify no GitHub routing fields (`github.owner`, `github.repo`) are present in context — if present, return BLOCKED:

```yaml
status: BLOCKED
error: PRELOADED_CONTEXT_REJECTED
reason: "content-audit-path-provider verifies against local source data only. GitHub routing fields are not permitted in content-audit-path-provider context."
```

- [ ] 10. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Read `{artifact_evidence_dir}/verdict.yaml` via `read` tool
- [ ] 4. Parse all top-level sections from all three artifacts
- [ ] 5. Record metadata from each: `generator`, `knowledge_supporter`, `evaluator`, `generated_at`, `evidence_generated_at`, `reasoning_generated_at`
- [ ] 6. If any expected top-level section is absent from any artifact, record as `section_missing` — do NOT BLOCK, but flag in the judgment
- [ ] 7. Note the Knowledge Supporter's `validation_summary` — this informs synthesis confidence
- [ ] 8. Note the Evaluator's `summary` — this determines the overall claim verdict distribution

### Step 3: Load Document Section

Read the generated content section to establish the authoritative baseline for synthesis:

- [ ] 1. Read `document_section` in full
- [ ] 2. Verify `document_section.length_chars` and `document_section.length_lines` from `evidence.yaml` match the actual content — cross-reference against `document_section_validation` from `reasoning.yaml`
- [ ] 3. Extract the claim list from `evidence.yaml` — `claims` array with claim_id, claim_text, domain, location
- [ ] 4. Verify each claim's `claim_text` appears in the document section — cross-reference against `document_section_validation.claim_text_validation` from `reasoning.yaml`
- [ ] 5. If the Knowledge Supporter flagged `CLAIM_TEXT_NOT_IN_DOCUMENT` for any claim, note this in the synthesis

### Step 4: Synthesize Per-Claim Verdicts

Carry forward the Evaluator's per-claim verdicts without re-evaluation:

- [ ] 1. Read `per_claim` from `verdict.yaml`
- [ ] 2. For each claim, carry forward: `claim_id`, `claim_text`, `domain`, `result`, `evidence`, `explanation`, `remediation`, `next_step`
- [ ] 3. Count total, pass, fail, and fabricated verdicts
- [ ] 4. Cross-reference each claim's evidence source against the Knowledge Supporter's validation — note any `corrected` or `unvalidated` evidence that the Evaluator relied on
- [ ] 5. Do NOT re-evaluate any claim — the Evaluator's verdict is final
- [ ] 6. Do NOT apply self-consistency gate — the Evaluator already applied it

Record in judgment:

```yaml
per_claim_synthesis:
  total_claims: <N>
  pass: <N>
  fail: <N>
  fabricated: <N>
  all_claims_pass: true | false
  remediation_required: true | false
  per_claim:
    - claim_id: "<ID>"
      claim_text: "<exact assertion>"
      domain: "numerical | file-reference | config-value | code-behavior | docs-claim"
      result: "PASS | FAIL | FABRICATED"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed | remediate"
      knowledge_supporter_validation: "validated | corrected | unvalidated"
```

### Step 5: Synthesize Source Coverage Evaluation

Carry forward the Evaluator's source coverage evaluation without re-evaluation:

- [ ] 1. Read `source_coverage_evaluation` from `verdict.yaml`
- [ ] 2. Carry forward: `claims_with_source_data`, `claims_without_source_data`, `unverifiable_claims`, `coverage_gaps`
- [ ] 3. Cross-reference against `source_coverage_validation` from `reasoning.yaml` — note any `coverage_matches: false` entries
- [ ] 4. For claims classified as `FABRICATED` due to no source data, confirm the classification is consistent with the Knowledge Supporter's validation

Record in judgment:

```yaml
source_coverage_synthesis:
  claims_with_source_data: <N>
  claims_without_source_data: <N>
  unverifiable_claims: <N>
  evaluator_verdict: "<carried forward from verdict.yaml>"
  knowledge_supporter_alignment: "aligned | partial | misaligned"
  alignment_notes: "<observations from cross-referencing reasoning.yaml>"
  coverage_gaps:
    - claim_id: "<C-ID>"
      claim_text: "<exact assertion>"
      source_data_available: false
      classification: "FABRICATED | UNVERIFIABLE"
      reason: "<carried forward from verdict.yaml>"
```

### Step 6: Synthesize Source Data Inventory Evaluation

Carry forward the Evaluator's source data inventory evaluation without re-evaluation:

- [ ] 1. Read `source_data_inventory_evaluation` from `verdict.yaml`
- [ ] 2. Carry forward: `directories_checked`, `directories_missing`, `files_checked`, `files_missing`, `files_stale`, `files_metadata_mismatch`, `issues`
- [ ] 3. Cross-reference against `source_data_validation` from `reasoning.yaml` — note any discrepancies between the Evaluator's inventory and the Knowledge Supporter's validation
- [ ] 4. Source data inventory issues do NOT directly cause claim verdicts to change — they indicate evidence quality concerns

Record in judgment:

```yaml
source_data_inventory_synthesis:
  directories_checked: <N>
  directories_missing: <N>
  files_checked: <N>
  files_missing: <N>
  files_stale: <N>
  files_metadata_mismatch: <N>
  evaluator_verdict: "<carried forward from verdict.yaml>"
  knowledge_supporter_alignment: "aligned | partial | misaligned"
  issues:
    - type: "SOURCE_DIR_MISSING | SOURCE_FILE_MISSING | SOURCE_FILE_STALE | SOURCE_FILE_METADATA_MISMATCH"
      path: "<path>"
      detail: "<carried forward from verdict.yaml>"
```

### Step 7: Synthesize Issue Impact

Carry forward the Evaluator's issue impact assessment without re-evaluation:

- [ ] 1. Read `issue_impact` from `verdict.yaml`
- [ ] 2. Carry forward: `issues_found`, `verdicts_downgraded`, `downgrades`
- [ ] 3. Cross-reference each downgrade against the `issues` array in `reasoning.yaml` — confirm the issue type and affected claim match
- [ ] 4. For each downgrade, note the original result and the downgraded result

Record in judgment:

```yaml
issue_impact_synthesis:
  issues_found: <N>
  verdicts_downgraded: <N>
  evaluator_verdict: "<carried forward from verdict.yaml>"
  knowledge_supporter_alignment: "aligned | partial | misaligned"
  downgrades:
    - claim_id: "<C-ID>"
      original_result: "<verdict>"
      downgraded_to: "<verdict>"
      issue_type: "<ISSUE_TYPE>"
      reason: "<carried forward from verdict.yaml>"
```

### Step 8: Synthesize Self-Consistency Downgrades

Carry forward the Evaluator's self-consistency downgrades without re-evaluation:

- [ ] 1. Read `self_consistency_downgrades` from `verdict.yaml`
- [ ] 2. Carry forward each downgrade: `claim_id`, `original_result`, `downgraded_to`, `hedging_phrase`
- [ ] 3. Verify that each downgraded claim's `result` in `per_claim` reflects the downgrade — if a claim appears in `self_consistency_downgrades` but still has `result: "PASS"` in `per_claim`, flag as `SELF_CONSISTENCY_INCONSISTENCY`
- [ ] 4. Do NOT re-apply the self-consistency gate — the Evaluator already applied it

Record in judgment:

```yaml
self_consistency_synthesis:
  downgrades_applied: <N>
  evaluator_verdict: "<carried forward from verdict.yaml>"
  downgrades:
    - claim_id: "<C-ID>"
      original_result: "PASS"
      downgraded_to: "FAIL"
      hedging_phrase: "<carried forward from verdict.yaml>"
  inconsistencies: []
```

### Step 9: Synthesize Evidence Chain Integrity

Cross-reference the full evidence chain for integrity without re-validating:

- [ ] 1. Verify the Generator's `evidence.yaml` sections are all present in the Knowledge Supporter's `reasoning.yaml` validation — flag any Generator sections that were not validated
- [ ] 2. Verify the Knowledge Supporter's `reasoning.yaml` sections are all referenced in the Evaluator's `verdict.yaml` evidence sources — flag any reasoning sections the Evaluator did not reference
- [ ] 3. Verify the Evaluator's `verdict.yaml` per-claim entries all have corresponding evidence in `reasoning.yaml` — flag any verdicts with missing evidence sources
- [ ] 4. Record the evidence chain integrity status: `intact`, `partial`, or `broken`
- [ ] 5. If the chain is `broken`, note which links are missing — do NOT attempt to repair

Record in judgment:

```yaml
evidence_chain_integrity:
  status: "intact | partial | broken"
  generator_to_knowledge_supporter:
    validated_sections: ["<section>", ...]
    unvalidated_sections: ["<section>", ...]
  knowledge_supporter_to_evaluator:
    referenced_sections: ["<section>", ...]
    unreferenced_sections: ["<section>", ...]
  evaluator_evidence_sources:
    verdicts_with_evidence: <N>
    verdicts_without_evidence: <N>
    missing_evidence_verdicts: ["<claim_id>", ...]
```

### Step 10: Determine Final Judgment

Compute the final judgment from the synthesized data:

- [ ] 1. If all claims PASS: final judgment is `PASS`
- [ ] 2. If any claim FAILs: final judgment is `FAIL`
- [ ] 3. If any claim is FABRICATED: final judgment is `FAIL` with `FABRICATED_CLAIMS` classification
- [ ] 4. If evidence chain integrity is `broken`: final judgment is `FAIL` with `EVIDENCE_CHAIN_BROKEN` classification
- [ ] 5. If any self-consistency inconsistency is detected: final judgment is `FAIL` with `SELF_CONSISTENCY_INCONSISTENCY` classification
- [ ] 6. Determine `next_step`:
  - `PASS` → `next_step: "proceed"` — all claims verified, content is accurate
  - `FAIL` → `next_step: "remediate"` — content requires revision of failed or fabricated claims

Record in judgment:

```yaml
final_judgment:
  status: "PASS | FAIL"
  next_step: "proceed | remediate"
  summary: "<1-3 sentence synthesis of the overall judgment>"
  pass_count: <N>
  fail_count: <N>
  fabricated_count: <N>
  evidence_chain_status: "intact | partial | broken"
```

### Step 11: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: content-audit-path-provider
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
document_section:
  length_chars: <N>
  length_lines: <N>
per_claim_synthesis: {...}
source_coverage_synthesis: {...}
source_data_inventory_synthesis: {...}
issue_impact_synthesis: {...}
self_consistency_synthesis: {...}
evidence_chain_integrity: {...}
final_judgment: {...}
upstream_metadata:
  generator: "<from evidence.yaml>"
  knowledge_supporter: "<from reasoning.yaml>"
  evaluator: "<from verdict.yaml>"
  knowledge_supporter_validation_summary: "<from reasoning.yaml>"
```

### Step 12: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/judgment.yaml"
final_judgment: "PASS | FAIL"
next_step: "proceed | remediate"
summary: "<N> claims synthesized. <X> PASS, <Y> FAIL, <Z> FABRICATED. Evidence chain: <intact | partial | broken>."
all_claims_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Document Section → INVALID if skipped
- [ ] 4. Synthesize Per-Claim Verdicts → INVALID if skipped
- [ ] 5. Synthesize Source Coverage Evaluation → INVALID if skipped
- [ ] 6. Synthesize Source Data Inventory Evaluation → INVALID if skipped
- [ ] 7. Synthesize Issue Impact → INVALID if skipped
- [ ] 8. Synthesize Self-Consistency Downgrades → INVALID if skipped
- [ ] 9. Synthesize Evidence Chain Integrity → INVALID if skipped
- [ ] 10. Determine Final Judgment → INVALID if skipped
- [ ] 11. Write judgment.yaml → INVALID if skipped
- [ ] 12. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| verdict.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| verdict.yaml is not valid YAML | Return BLOCKED with INVALID_VERDICT_FORMAT |
| document_section missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| source_data_paths missing | Return BLOCKED with MISSING_REQUIRED_INPUT |
| GitHub routing fields present | Return BLOCKED with PRELOADED_CONTEXT_REJECTED |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Evaluator's verdict contains INCONCLUSIVE | Flag as `invalid_verdict` — INCONCLUSIVE is not a valid verdict per critical-rules-hard-fail |
| Evidence chain is broken | Record as `broken` in evidence chain integrity — do NOT BLOCK, but final judgment is FAIL |
| Self-consistency inconsistency detected | Record in self_consistency_synthesis.inconsistencies — do NOT BLOCK, but final judgment is FAIL |
| Upstream artifact section missing | Record as `section_missing` — do NOT BLOCK, but flag in evidence chain integrity |

## Cross-References

- `tasks/content-audit-generator.md` — Generator role (produces the evidence.yaml consumed by this task)
- `tasks/content-audit-knowledge-supporter.md` — Knowledge Supporter role (produces the reasoning.yaml consumed by this task)
- `tasks/content-audit-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/cross-validate.md` — Cross-validate Path Provider role (separate DiMo chain for cross-validation)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` §critical-rules-hard-fail — FAIL is a hard gate, never reclassifiable
- `065-verification-honesty.md` §Hard Failure Discipline — FAIL is a hard gate, never reclassifiable
