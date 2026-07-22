---
name: test-quality-audit-path-provider
description: "Arbiter role for the test-quality-audit chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: test-quality-audit-path-provider

## Purpose

Arbiter role for the test-quality-audit chain. Reads all upstream artifacts — `evidence.yaml` (Investigator), `reasoning.yaml` (Validator), and `verdict.yaml` (Evaluator) — and produces the final `judgment.yaml` with final judgment and `next_step`. This is the fourth and final role in the 4-role chain. It synthesizes, not evaluates.


## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory containing `evidence.yaml`, `reasoning.yaml`, and `verdict.yaml` from upstream roles
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `file_paths_changed`: List of file paths changed in the implementation
- `vbc_artifact_path`: Path to VbC (Verification-before-Completion) artifact (optional)

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Arbiter. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Validator completed successfully and wrote `reasoning.yaml` before dispatching the Arbiter. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Evaluator completed successfully and wrote `verdict.yaml` before dispatching the Arbiter. Dispatching without a valid `verdict.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for judgment artifacts)
- `file_paths_changed` provided and non-empty

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts read and synthesized into a single coherent judgment
- Six test quality criteria verdicts carried forward from Evaluator's verdict
- Evidence type compliance findings carried forward from Evaluator's verdict
- Self-consistency downgrades accepted as final
- Evidence chain integrity cross-referenced across all three upstream artifacts
- `next_step` determined: `"proceed"` if all criteria PASS, `"remediate"` if any FAIL
- No new evidence collected — all synthesis based on upstream artifacts
- No re-evaluation of any criterion — Evaluator's verdicts are final

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
remediation: "evidence.yaml is required for test-quality-audit-path-provider. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Arbiter."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for test-quality-audit-path-provider. The orchestrator must ensure the Validator completed successfully and wrote reasoning.yaml before dispatching the Arbiter."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 6. If `verdict.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "verdict.yaml is required for test-quality-audit-path-provider. The orchestrator must ensure the Evaluator completed successfully and wrote verdict.yaml before dispatching the Arbiter."
```

- [ ] 7. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 8. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for test-quality-audit-path-provider. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 9. Verify `file_paths_changed` is provided and non-empty
- [ ] 10. If `file_paths_changed` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "file_paths_changed"
remediation: "file_paths_changed is required for test-quality-audit-path-provider. The orchestrator must pass the list of changed file paths from the implementation diff."
```

- [ ] 11. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Read `{artifact_evidence_dir}/verdict.yaml` via `read` tool
- [ ] 4. Parse all top-level sections from all three artifacts
- [ ] 5. Record metadata from each: `generator`, `knowledge_supporter`, `evaluator`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 6. If any expected top-level section is absent from any artifact, record as `section_missing` — do NOT BLOCK, but flag in the judgment
- [ ] 7. Note the Validator's validation summary — this informs synthesis confidence
- [ ] 8. Note the Evaluator's `summary.all_criteria_pass` — this determines the starting point for final judgment

### Step 3: Load Spec Content

Read the spec files to establish the authoritative baseline for synthesis:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract spec body and frontmatter metadata from each file
- [ ] 4. Extract the Success Criteria table — this is the authoritative list of SCs
- [ ] 5. Extract the STATUS marker if present
- [ ] 6. Record the spec's declared evidence types for each SC

### Step 4: Synthesize Test Quality Criteria Verdicts

Carry forward the Evaluator's per-criterion verdicts without re-evaluation:

- [ ] 1. Read `per_criterion` from `verdict.yaml`
- [ ] 2. For each of the six test quality criteria, carry forward: `criterion_id`, `result`, `evidence_source`, `finding`, `remediation`, `recommendation`
- [ ] 3. Count total, pass, and fail verdicts across the six criteria
- [ ] 4. Cross-reference each criterion's evidence source against the Validator's validation — note any `corrected` or `unvalidated` evidence that the Evaluator relied on
- [ ] 5. Do NOT re-evaluate any criterion — the Evaluator's verdict is final
- [ ] 6. Do NOT apply self-consistency gate — the Evaluator already applied it (accept `self_consistency_downgrades` from `verdict.yaml` as final)

Record in judgment:

```yaml
test_quality_synthesis:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
  per_criterion:
    - criterion_id: "assertion_plausibility"
      result: "PASS|FAIL"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_TEST|FIX_CODE|SPEC_GAP"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "cross_boundary_coverage"
      result: "PASS|FAIL|N/A"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_CODE|N/A"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "edge_case_completeness"
      result: "PASS|FAIL"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_TEST|SPEC_GAP"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "assertion_weakening"
      result: "PASS|FAIL"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_TEST"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "red_evidence"
      result: "PASS|FAIL"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_TEST|SPEC_GAP"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "sequential_tdd"
      result: "PASS|FAIL|N/A"
      evidence_source: "<carried forward from verdict.yaml>"
      finding: "<carried forward from verdict.yaml>"
      remediation: "FIX_TEST|SPEC_GAP"
      recommendation: "<carried forward from verdict.yaml>"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
```

### Step 5: Synthesize Evidence Type Compliance

Carry forward the Evaluator's evidence type compliance findings without re-evaluation:

- [ ] 1. Read `evidence_type_compliance` from `verdict.yaml`
- [ ] 2. For each SC with evidence type compliance data, carry forward: `sc_id`, `declared_type`, `evidence_type_matches`, `result`, `finding`
- [ ] 3. Count total SCs with evidence type compliance checks, pass, and fail
- [ ] 4. Cross-reference each SC's declared type against the spec's authoritative SC table — flag any mismatch between the spec's declared type and the type used in the verdict
- [ ] 5. Do NOT re-evaluate any evidence type compliance finding — the Evaluator's verdict is final

Record in judgment:

```yaml
evidence_type_compliance_synthesis:
  total_scs_checked: <N>
  pass: <N>
  fail: <N>
  all_compliant: true | false
  per_sc:
    - sc_id: "SC-N"
      declared_type: "<type>"
      evidence_type_matches: true | false
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
```

### Step 6: Synthesize Self-Consistency Downgrades

Carry forward the Evaluator's self-consistency downgrades as final:

- [ ] 1. Read `self_consistency_downgrades` from `verdict.yaml`
- [ ] 2. For each downgrade, record: `criterion_id`, `original_result`, `downgraded_to`, `hedging_phrase`
- [ ] 3. Verify that the downgraded criteria in `per_criterion` reflect the downgraded result (FAIL), not the original result (PASS)
- [ ] 4. If a criterion appears in `self_consistency_downgrades` but `per_criterion` still shows PASS, flag as `DOWNGRADE_NOT_APPLIED` — do NOT re-apply, but note the inconsistency
- [ ] 5. Do NOT re-evaluate any downgrade — the Evaluator's self-consistency gate is final

Record in judgment:

```yaml
self_consistency_synthesis:
  downgrades_applied: <N>
  downgrades:
    - criterion_id: "<ID>"
      original_result: "PASS"
      downgraded_to: "FAIL"
      hedging_phrase: "<matched phrase>"
      applied_in_per_criterion: true | false
```

### Step 7: Synthesize Evidence Chain Integrity

Cross-reference the full evidence chain for integrity without re-validating:

- [ ] 1. Verify the Investigator's `evidence.yaml` sections are all present in the Validator's `reasoning.yaml` validation — flag any Investigator sections that were not validated
- [ ] 2. Verify the Validator's `reasoning.yaml` sections are all referenced in the Evaluator's `verdict.yaml` evidence sources — flag any reasoning sections the Evaluator did not reference
- [ ] 3. Verify the Evaluator's `verdict.yaml` per-criterion entries all have corresponding evidence in `reasoning.yaml` — flag any verdicts with missing evidence sources
- [ ] 4. Record the evidence chain integrity status: `intact`, `partial`, or `broken`
- [ ] 5. If the chain is `broken`, note which links are missing — do NOT attempt to repair

Record in judgment:

```yaml
evidence_chain_integrity:
  status: "intact|partial|broken"
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

### Step 8: Determine Final Judgment

Compute the final judgment from the synthesized data:

- [ ] 1. If all six test quality criteria PASS and all evidence type compliance checks PASS: final judgment is `PASS`
- [ ] 2. If any test quality criterion FAILs: final judgment is `FAIL`
- [ ] 3. If any evidence type compliance check FAILs: final judgment is `FAIL`
- [ ] 4. If evidence chain integrity is `broken`: final judgment is `FAIL` with `EVIDENCE_CHAIN_BROKEN` classification
- [ ] 5. If the Evaluator's `verdict.yaml` contains `INCONCLUSIVE` for any criterion: flag as `invalid_verdict` — INCONCLUSIVE is not a valid verdict per critical-rules-hard-fail
- [ ] 6. Determine `next_step`:
  - `PASS` → `next_step: "proceed"` — test quality is acceptable
  - `FAIL` → `next_step: "remediate"` — test quality requires remediation of failed criteria

Record in judgment:

```yaml
final_judgment:
  status: "PASS|FAIL"
  next_step: "proceed|remediate"
  summary: "<1-3 sentence synthesis of the overall judgment>"
  test_quality_pass_count: <N>
  test_quality_fail_count: <N>
  evidence_type_pass_count: <N>
  evidence_type_fail_count: <N>
  evidence_chain_status: "intact|partial|broken"
```

### Step 9: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: test-quality-audit-path-provider
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
spec_local_dir: "<path>"
test_quality_synthesis: {...}
evidence_type_compliance_synthesis: {...}
self_consistency_synthesis: {...}
evidence_chain_integrity: {...}
final_judgment: {...}
upstream_metadata:
  generator: "<from evidence.yaml>"
  knowledge_supporter: "<from reasoning.yaml>"
  evaluator: "<from verdict.yaml>"
  knowledge_supporter_validation_summary:
    sections_validated: <N>
    total_validated: <N>
    total_mismatches: <N>
    total_unverifiable: <N>
```

### Step 10: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/judgment.yaml"
final_judgment: "PASS|FAIL"
next_step: "proceed|remediate"
summary: "<N> test quality criteria synthesized. <X> PASS, <Y> FAIL. Evidence type compliance: <A> PASS, <B> FAIL. Evidence chain: <intact|partial|broken>."
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Synthesize Test Quality Criteria Verdicts → INVALID if skipped
- [ ] 5. Synthesize Evidence Type Compliance → INVALID if skipped
- [ ] 6. Synthesize Self-Consistency Downgrades → INVALID if skipped
- [ ] 7. Synthesize Evidence Chain Integrity → INVALID if skipped
- [ ] 8. Determine Final Judgment → INVALID if skipped
- [ ] 9. Write judgment.yaml → INVALID if skipped
- [ ] 10. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| verdict.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| verdict.yaml is not valid YAML | Return BLOCKED with INVALID_VERDICT_FORMAT |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| file_paths_changed missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Evaluator's verdict contains INCONCLUSIVE | Flag as `invalid_verdict` — INCONCLUSIVE is not a valid verdict per critical-rules-hard-fail |
| Evidence chain is broken | Record as `broken` in evidence chain integrity — do NOT BLOCK, but final judgment is FAIL |
| Upstream artifact section missing | Record as `section_missing` — do NOT BLOCK, but flag in evidence chain integrity |
| Self-consistency downgrade not applied in per_criterion | Flag as `DOWNGRADE_NOT_APPLIED` — do NOT BLOCK, but note the inconsistency |
| Criterion in evidence.yaml but missing from verdict.yaml | Treat as FAIL with `MISSING_VERDICT` |

## Cross-References

- `tasks/test-quality-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/test-quality-audit-validator.md` — Validator role (produces the reasoning.yaml consumed by this task)
- `tasks/test-quality-audit-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/test-quality-audit.md` — Main task file (orchestrator-level test-quality-audit)
- `tasks/cross-validate.md` — Cross-validate Arbiter role (separate chain for cross-validation)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- Read [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations
- Read [Test Integrity Mandate](guidelines/080-code-standards.md) — no lobotomizing tests
- Read [Behavioral RED/GREEN as Primary Enforcement Gate](guidelines/080-code-standards.md)
- Read [critical-rules-hard-fail](guidelines/000-critical-rules.md) — FAIL is a hard gate, never reclassifiable
- Read [Hard Failure Discipline](guidelines/065-verification-honesty.md) — FAIL is a hard gate, never reclassifiable

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
