---
name: drift-detection-path-provider
description: "Path Provider role for the drift-detection DiMo chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection-path-provider

## Purpose

Path Provider role for the drift-detection DiMo chain. Reads all upstream artifacts — `evidence.yaml` (Generator), `reasoning.yaml` (Knowledge Supporter), `verdict.yaml` (Evaluator) — and produces the final `judgment.yaml` with final judgment and `next_step`. This role synthesizes, not evaluates. It does NOT re-evaluate criteria, re-validate evidence, or second-guess upstream roles.

> **DiMo Role: Path Provider.** This task produces the final judgment for drift-detection by cross-referencing all upstream artifacts. Reads `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, writes `judgment.yaml`.
>
> You are the Path Provider. You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
>
>
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST NOT re-classify drift as SPEC_DRIFT, CODE_DRIFT, or SYNC
> - MUST write `judgment.yaml` as the only output artifact
> - MUST produce a `next_step` field: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts (contains `evidence.yaml`, `reasoning.yaml`, `verdict.yaml` from upstream roles)
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` (produced by Generator)
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` (produced by Knowledge Supporter)
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` (produced by Evaluator)
- `spec_local_dir` provided (local issue directory containing Markdown spec files)
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (readable directory containing all upstream artifacts)

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts loaded and cross-referenced
- Evaluator's per-criterion verdicts (DD-1 through DD-5, DD-STRUCTURAL-FAIL) accepted as final — no re-evaluation
- Evidence-to-verdict consistency verified (verdict backed by evidence, evidence validated by reasoning)
- Self-consistency gate applied — no hedging language in PASS explanations
- Overall judgment computed: PASS if all criteria PASS, FAIL otherwise
- `next_step` field set: `"proceed"` for PASS, `"remediate then re-audit"` for FAIL
- Drift summary synthesized from upstream artifacts
- Bidirectional findings synthesized from upstream artifacts
- No re-evaluation of criteria — synthesis only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Remove any existing `judgment.yaml` from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. If `evidence.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "evidence.yaml"
remediation: "No evidence.yaml found in {artifact_evidence_dir}/. Run drift-detection-generator first to produce evidence."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml`
- [ ] 4. If `reasoning.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "No reasoning.yaml found in {artifact_evidence_dir}/. Run drift-detection-knowledge-supporter first to validate evidence."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml`
- [ ] 6. If `verdict.yaml` not found, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "No verdict.yaml found in {artifact_evidence_dir}/. Run drift-detection-evaluator first to produce verdicts."
```

- [ ] 7. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 8. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for drift-detection-path-provider. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 9. Verify `artifact_evidence_dir` is writable

### Step 2: Load Upstream Artifacts

Read and parse all three upstream artifacts:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml`
- [ ] 2. Parse the YAML content
- [ ] 3. Verify required top-level keys exist: `spec_requirements`, `target_files`, `code_implementation`, `raw_comparisons`, `untracked_files`, `documentation_sources`
- [ ] 4. If any required key is missing, return BLOCKED with `MALFORMED_EVIDENCE` and the missing key name
- [ ] 5. Read `{artifact_evidence_dir}/reasoning.yaml`
- [ ] 6. Parse the YAML content
- [ ] 7. Verify required top-level keys exist: `spec_requirements_validation`, `target_files_validation`, `code_implementation_validation`, `raw_comparisons_validation`, `untracked_files_validation`, `documentation_sources_validation`, `overall_validation_status`
- [ ] 8. If any required key is missing, return BLOCKED with `MALFORMED_REASONING` and the missing key name
- [ ] 9. Read `{artifact_evidence_dir}/verdict.yaml`
- [ ] 10. Parse the YAML content
- [ ] 11. Verify required top-level keys exist: `per_criterion` (with DD-1 through DD-5 and DD-STRUCTURAL-FAIL), `drift_summary`, `bidirectional_findings`, `summary`
- [ ] 12. If any required key is missing, return BLOCKED with `MALFORMED_VERDICT` and the missing key name
- [ ] 13. Record artifact metadata: generator name, knowledge supporter name, evaluator name, issue number, timestamps

### Step 3: Cross-Reference Evidence-to-Verdict Consistency

Verify that each criterion verdict is backed by evidence and that evidence was validated:

- [ ] 1. For each criterion (DD-1 through DD-5, DD-STRUCTURAL-FAIL) in `verdict.yaml` → `per_criterion`:
  - [ ] 1a. Verify the criterion's `evidence` fields reference data that exists in `evidence.yaml`
  - [ ] 1b. Verify the referenced evidence was validated in `reasoning.yaml` (check corresponding validation section)
  - [ ] 1c. If evidence referenced in the verdict has a `mismatch` or `unverifiable` status in reasoning, flag as `EVIDENCE_INTEGRITY_CONCERN`
  - [ ] 1d. If the verdict's `result` is PASS but the referenced evidence has validation mismatches, flag as `VERDICT_EVIDENCE_MISALIGNMENT`
- [ ] 2. **DD-1 (File Presence):** Cross-check verdict's file presence findings against `evidence.yaml` → `raw_comparisons.file_presence` and `reasoning.yaml` → `raw_comparisons_validation.file_presence`
- [ ] 3. **DD-2 (Implementation Matches Spec):** Cross-check verdict's function presence and signature findings against `evidence.yaml` → `raw_comparisons.function_presence` + `signature_comparisons` and `reasoning.yaml` → `raw_comparisons_validation.function_presence` + `signature_comparisons`
- [ ] 4. **DD-3 (No Extra Implementation):** Cross-check verdict's untracked file findings against `evidence.yaml` → `untracked_files` and `reasoning.yaml` → `untracked_files_validation`
- [ ] 5. **DD-4 (Function Signatures Match):** Cross-check verdict's signature mismatch findings against `evidence.yaml` → `raw_comparisons.signature_comparisons` and `reasoning.yaml` → `raw_comparisons_validation.signature_comparisons`
- [ ] 6. **DD-5 (Edge Cases Covered):** Cross-check verdict's edge case findings against `evidence.yaml` → `raw_comparisons.edge_case_coverage` and `reasoning.yaml` → `raw_comparisons_validation.edge_case_coverage`
- [ ] 7. **DD-STRUCTURAL-FAIL:** Cross-check verdict's structural evidence violations against `evidence.yaml` → `raw_comparisons` and `reasoning.yaml` → `raw_comparisons_validation`
- [ ] 8. Record cross-reference results:

```yaml
evidence_verdict_consistency:
  DD-1:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  DD-2:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  DD-3:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  DD-4:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  DD-5:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  DD-STRUCTURAL-FAIL:
    evidence_backed: true | false
    evidence_validated: true | false
    integrity_concerns: <N>
    alignment: "aligned | misaligned"
  overall_alignment: "aligned | misaligned"
```

**Note:** Evidence-to-verdict misalignment is recorded as a finding but does NOT override the Evaluator's verdict. The Evaluator's verdict stands. Misalignment is reported in the judgment for transparency.

### Step 4: Synthesize Drift Summary

Synthesize the drift picture from all three upstream artifacts:

- [ ] 1. From `evidence.yaml` → `raw_comparisons`, collect raw comparison counts
- [ ] 2. From `reasoning.yaml` → `raw_comparisons_validation`, collect validation status for each comparison category
- [ ] 3. From `verdict.yaml` → `drift_summary`, collect the Evaluator's drift classification
- [ ] 4. Synthesize into a unified drift picture:

```yaml
synthesized_drift:
  total_files_scanned: <N>
  spec_drift_count: <N>
  code_drift_count: <N>
  sync_count: <N>
  by_category:
    file_presence:
      spec_required: <N>
      code_present: <N>
      code_missing: <N>
      validated: <N>
      mismatches: <N>
    function_presence:
      spec_required: <N>
      code_present: <N>
      code_missing: <N>
      validated: <N>
      mismatches: <N>
    signature_comparisons:
      total: <N>
      exact_matches: <N>
      mismatches: <N>
      validated: <N>
      mismatches: <N>
    extra_code:
      untracked_files: <N>
      extra_symbols: <N>
      false_extra: <N>
      validated: <N>
      mismatches: <N>
    edge_case_coverage:
      total: <N>
      covered: <N>
      uncovered: <N>
      validated: <N>
      mismatches: <N>
    structural_evidence_violations: <N>
  evidence_validation_rate: <float 0.0-1.0>
  drift_severity: "none | low | medium | high | critical"
```

- [ ] 5. Compute `drift_severity`:
  - `none`: Zero drift findings, all evidence validated
  - `low`: 1-2 drift findings, all evidence validated
  - `medium`: 3-5 drift findings, or evidence validation rate < 0.95
  - `high`: 6-10 drift findings, or evidence validation rate < 0.85
  - `critical`: >10 drift findings, or evidence validation rate < 0.70

### Step 5: Synthesize Bidirectional Findings

Synthesize the bidirectional findings from upstream artifacts:

- [ ] 1. From `verdict.yaml` → `bidirectional_findings`, collect the Evaluator's directional classifications
- [ ] 2. From `evidence.yaml` → `raw_comparisons`, collect the raw data behind each finding
- [ ] 3. From `reasoning.yaml` → `raw_comparisons_validation`, collect validation status for each finding's evidence
- [ ] 4. Synthesize into a unified bidirectional picture:

```yaml
synthesized_bidirectional_findings:
  total_findings: <N>
  spec_to_code: <N>
  code_to_spec: <N>
  by_severity:
    high: <N>
    medium: <N>
    low: <N>
  findings:
    - criterion_id: "<DD-N>"
      finding_type: "SPEC_DRIFT | CODE_DRIFT | SIGNATURE_MISMATCH | MISSING_EDGE_CASE | STRUCTURAL_EVIDENCE"
      direction: "spec→code | code→spec"
      description: "<synthesized from Evaluator verdict>"
      severity: "HIGH | MEDIUM | LOW"
      evidence_validated: true | false
      revision_options:
        - "<option 1>"
        - "<option 2>"
  high_severity_blockers: <N>
  medium_severity_attention: <N>
  low_severity_informational: <N>
```

### Step 6: Apply Self-Consistency Gate

Before accepting the judgment, run a self-consistency check on every criterion entry from the Evaluator's verdict:

- [ ] 1. Define hedging patterns that indicate a PASS verdict is inconsistent with the explanation:

```python
hedging_patterns = [
    "should be", "needs", "missing", "could improve",
    "minor", "some issues", "mostly", "generally",
    "not ideal", "could be better", "incomplete",
    "lacking", "insufficient", "problematic",
    "requires attention", "needs work", "not fully"
]
```

- [ ] 2. For each criterion with `result: PASS` in `verdict.yaml` → `per_criterion`:
  - [ ] 2a. Check if the `explanation` field contains any hedging pattern
  - [ ] 2b. If a hedging pattern is found, record as `SELF_CONSISTENCY_CONCERN`
  - [ ] 2c. Note: The Evaluator already applied its own self-consistency gate. This is a second-pass check for synthesis integrity.
- [ ] 3. If the Evaluator's `self_consistency_note` field already recorded downgrades, verify they were applied to the criteria
- [ ] 4. Record self-consistency results:

```yaml
synthesized_self_consistency:
  evaluator_downgrades: <N>
  evaluator_downgrade_details:
    - criterion: "<criterion-id>"
      original_result: PASS
      downgraded_to: FAIL
      hedging_pattern_found: "<pattern>"
  path_provider_concerns: <N>
  path_provider_concern_details:
    - criterion: "<criterion-id>"
      evaluator_result: PASS
      concern: "explanation contains hedging language: '<pattern>'"
  overall_consistent: true | false
```

**Note:** The Path Provider does NOT downgrade verdicts. It records concerns for transparency. The Evaluator's verdicts are final.

### Step 7: Synthesize Evidence Chain Integrity

Cross-reference the full evidence chain for integrity without re-validating:

- [ ] 1. Verify the Generator's `evidence.yaml` sections are all present in the Knowledge Supporter's `reasoning.yaml` validation — flag any Generator sections that were not validated
- [ ] 2. Verify the Knowledge Supporter's `reasoning.yaml` sections are all referenced in the Evaluator's `verdict.yaml` evidence sources — flag any reasoning sections the Evaluator did not reference
- [ ] 3. Verify the Evaluator's `verdict.yaml` per-criterion entries all have corresponding evidence in `reasoning.yaml` — flag any verdicts with missing evidence sources
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
    missing_evidence_verdicts: ["<criterion_id>", ...]
```

### Step 8: Compute Final Judgment

Compute the final judgment from all synthesized data:

- [ ] 1. Collect all criterion verdicts from `verdict.yaml` → `per_criterion` (DD-1 through DD-5, DD-STRUCTURAL-FAIL)
- [ ] 2. **Overall PASS:** ALL six criteria are PASS AND evidence-verdict consistency is aligned AND self-consistency gate is clean
- [ ] 3. **Overall FAIL:** ANY criterion is FAIL, OR evidence-verdict consistency is misaligned, OR self-consistency concerns exist
- [ ] 4. Determine `next_step`:
  - `overall_judgment == PASS` → `next_step: "proceed"`
  - `overall_judgment == FAIL` → `next_step: "remediate then re-audit"`
- [ ] 5. Compose executive summary:

```yaml
final_judgment:
  overall: PASS | FAIL
  next_step: "proceed | remediate then re-audit"
  passing_criteria: <N>
  failing_criteria: <N>
  failing_criterion_ids: ["<criterion-id>", ...]
  evidence_verdict_alignment: "aligned | misaligned"
  self_consistency_clean: true | false
  drift_severity: "none | low | medium | high | critical"
  evidence_chain_status: "intact | partial | broken"
  executive_summary: "Drift detection judgment: <N>/6 criteria PASS. Spec drift: <N>, code drift: <N>, sync: <N>. Severity: <severity>. Verdict: <PASS|FAIL>. Next step: <next_step>."
```

### Step 9: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: drift-detection-path-provider
issue_number: <N>
generated_at: "<timestamp>"
artifact_evidence_dir: "<path>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
evidence_generated_at: "<timestamp from evidence.yaml>"
reasoning_generated_at: "<timestamp from reasoning.yaml>"
verdict_generated_at: "<timestamp from verdict.yaml>"
upstream_roles:
  generator: "<generator name from evidence.yaml>"
  knowledge_supporter: "<knowledge supporter name from reasoning.yaml>"
  evaluator: "<evaluator name from verdict.yaml>"
criteria:
  DD-1:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  DD-2:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  DD-3:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  DD-4:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  DD-5:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
  DD-STRUCTURAL-FAIL:
    evaluator_verdict: PASS | FAIL
    evidence_backed: true | false
    evidence_validated: true | false
    explanation: "<from verdict.yaml>"
evidence_verdict_consistency: {...}
synthesized_drift: {...}
synthesized_bidirectional_findings: {...}
synthesized_self_consistency: {...}
evidence_chain_integrity: {...}
final_judgment: {...}
```

### Step 10: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/judgment.yaml"
summary: "Drift detection judgment: <N>/6 criteria PASS. Spec drift: <N>, code drift: <N>, sync: <N>. Severity: <severity>. Verdict: <PASS|FAIL>. Next step: <next_step>."
overall_judgment: PASS | FAIL
next_step: "proceed | remediate then re-audit"
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Cross-Reference Evidence-to-Verdict Consistency → INVALID if skipped
- [ ] 4. Synthesize Drift Summary → INVALID if skipped
- [ ] 5. Synthesize Bidirectional Findings → INVALID if skipped
- [ ] 6. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 7. Synthesize Evidence Chain Integrity → INVALID if skipped
- [ ] 8. Compute Final Judgment → INVALID if skipped
- [ ] 9. Write judgment.yaml → INVALID if skipped
- [ ] 10. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml not found | Return BLOCKED — run `drift-detection-generator` first |
| reasoning.yaml not found | Return BLOCKED — run `drift-detection-knowledge-supporter` first |
| verdict.yaml not found | Return BLOCKED — run `drift-detection-evaluator` first |
| evidence.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_EVIDENCE` and missing key name |
| reasoning.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_REASONING` and missing key name |
| verdict.yaml malformed (missing required keys) | Return BLOCKED with `MALFORMED_VERDICT` and missing key name |
| Verdict references evidence not in evidence.yaml | Record as `EVIDENCE_INTEGRITY_CONCERN` — do NOT BLOCK |
| Evidence referenced in verdict has validation mismatch | Record as `VERDICT_EVIDENCE_MISALIGNMENT` — do NOT BLOCK |
| Evaluator self-consistency downgrades not applied to criteria | Record as `SELF_CONSISTENCY_CONCERN` — do NOT BLOCK |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Upstream artifact YAML unparseable | Return BLOCKED with `ARTIFACT_UNREADABLE` and file path |

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths:

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | Any upstream artifact missing | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<file>" }` |
| ARTIFACT_UNREADABLE | Upstream YAML artifact cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE", file: "<path>" }` |
| MALFORMED_ARTIFACT | Upstream YAML artifact missing required keys | `MALFORMED_EVIDENCE` / `MALFORMED_REASONING` / `MALFORMED_VERDICT` | Return `{ status: "BLOCKED", error: "<code>", missing_key: "<key>" }` |

## Red Flags

- Never re-evaluate criteria — the Evaluator's verdicts are final
- Never re-validate evidence — the Knowledge Supporter's validation is final
- Never re-collect evidence — the Generator's evidence is final
- Never override a PASS/FAIL from the Evaluator
- Never re-classify drift as SPEC_DRIFT, CODE_DRIFT, or SYNC — the Evaluator's classification is final
- Never produce new evidence or findings beyond what upstream roles produced
- Never fabricate verdicts when upstream artifacts are unreadable — missing data = BLOCKED
- Never accept memory-cached claims as evidence — every reference must trace to an upstream artifact
- Never pass YAML artifact content inline through orchestrator context — artifacts stay on disk

## Cross-References

- `tasks/drift-detection-generator.md` — Generator role (produces the evidence.yaml consumed by this task)
- `tasks/drift-detection-knowledge-supporter.md` — Knowledge Supporter role (produces the reasoning.yaml consumed by this task)
- `tasks/drift-detection-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/drift-detection.md` — Main drift-detection task (orchestrator-level dispatch)
- `tasks/cross-validate.md` — Cross-validate Path Provider role (analogous role, different domain)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — spec-code alignment, hard failure discipline
- `130-authority-source.md` — code as authoritative source
- `065-verification-honesty.md` — live-source verification mandate, hard failure discipline

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
