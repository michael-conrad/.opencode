---
name: guideline-audit-path-provider
description: "Arbiter role for the guideline-audit chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: guideline-audit-path-provider

## Purpose

Arbiter role for the guideline-audit chain. Reads all upstream artifacts (`evidence.yaml` from Investigator, `reasoning.yaml` from Validator, `verdict.yaml` from Evaluator) and produces the final `judgment.yaml` with final judgment and `next_step`. This role synthesizes — it does NOT evaluate, re-evaluate, or second-guess upstream roles.


## Dispatch Contract

- `guideline_paths`: List of guideline file paths that were audited (same as passed to Investigator, Validator, and Evaluator)
- `artifact_evidence_dir`: Directory containing `evidence.yaml`, `reasoning.yaml`, and `verdict.yaml` from upstream roles
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Arbiter. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Validator completed successfully and wrote `reasoning.yaml` before dispatching the Arbiter. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Evaluator completed successfully and wrote `verdict.yaml` before dispatching the Arbiter. Dispatching without a valid `verdict.yaml` is a CRITICAL VIOLATION.
- `guideline_paths` provided — either a non-empty list of file paths or a valid glob pattern matching the files the Investigator audited
- `artifact_evidence_dir` provided (writable directory for judgment artifacts)
- `github.owner`, `github.repo` available

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts read and synthesized into a single coherent judgment
- Per-criterion verdicts (GA-1 through GA-6) carried forward from Evaluator's verdict
- Bidirectional findings synthesized from Evaluator's verdict
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
remediation: "evidence.yaml is required for guideline-audit-path-provider. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Arbiter."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for guideline-audit-path-provider. The orchestrator must ensure the Validator completed successfully and wrote reasoning.yaml before dispatching the Arbiter."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 6. If `verdict.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "verdict.yaml is required for guideline-audit-path-provider. The orchestrator must ensure the Evaluator completed successfully and wrote verdict.yaml before dispatching the Arbiter."
```

- [ ] 7. Verify `guideline_paths` is provided and non-empty — expand glob if needed via `glob` tool
- [ ] 8. If `guideline_paths` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "guideline_paths"
remediation: "guideline_paths is required for guideline-audit-path-provider. The orchestrator must provide the same guideline file paths that were passed to the Investigator, Validator, and Evaluator."
```

- [ ] 9. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Read `{artifact_evidence_dir}/verdict.yaml` via `read` tool
- [ ] 4. Parse all top-level sections from all three artifacts
- [ ] 5. Record metadata from each: `generator`, `knowledge_supporter`, `evaluator`, `generated_at`, `guideline_paths`
- [ ] 6. If any expected top-level section is absent from any artifact, record as `section_missing` — do NOT BLOCK, but flag in the judgment
- [ ] 7. Note the Validator's `overall_validation_status` — this informs synthesis confidence
- [ ] 8. Note the Evaluator's `summary.all_criteria_pass` — this determines the overall judgment direction

### Step 3: Load Guideline Files

Read the guideline files to establish the authoritative baseline for synthesis:

- [ ] 1. Resolve the file list from `guideline_paths` (expand glob if needed)
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract file-level metadata: frontmatter presence, heading count, line count
- [ ] 4. Record the file inventory for cross-reference against the Investigator's `guideline_files` evidence

### Step 4: Synthesize Per-Criterion Verdicts

Carry forward the Evaluator's per-criterion verdicts without re-evaluation:

- [ ] 1. Read `per_criterion` from `verdict.yaml`
- [ ] 2. For each criterion (GA-1 through GA-6), carry forward: `criterion_id`, `result`, `evidence`, `explanation`, `remediation`, `next_step`
- [ ] 3. Count total, pass, and fail verdicts
- [ ] 4. Cross-reference each criterion's evidence source against the Validator's validation — note any `corrected` or `unvalidated` evidence that the Evaluator relied on
- [ ] 5. Do NOT re-evaluate any criterion — the Evaluator's verdict is final
- [ ] 6. Do NOT apply self-consistency gate — the Evaluator already applied it

Record in judgment:

```yaml
per_criterion_synthesis:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
  per_criterion:
    - criterion_id: "GA-1"
      description: "Rule conditions are unambiguous"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "GA-2"
      description: "No conflicting rules"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "GA-3"
      description: "Actions are LLM-enforceable"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "GA-4"
      description: "No redundant cross-file references"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "GA-5"
      description: "Context fits in LLM window"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
    - criterion_id: "GA-6"
      description: "File organization logical"
      result: "PASS|FAIL"
      evidence: "<carried forward from verdict.yaml>"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
```

### Step 5: Synthesize Detailed Evaluation Results

Carry forward the Evaluator's detailed per-criterion evaluation blocks without re-evaluation:

- [ ] 1. Read `ga_1_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 2. Read `ga_2_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 3. Read `ga_3_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 4. Read `ga_4_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 5. Read `ga_5_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 6. Read `ga_6_evaluation` from `verdict.yaml` — carry forward all sub-checks and their results
- [ ] 7. For each evaluation block, cross-reference the `evidence_source` against the Validator's corresponding validation section to confirm evidence alignment — do NOT re-evaluate, only note alignment or misalignment
- [ ] 8. If the Validator flagged any evidence as `corrected` or `unvalidated`, note this in the synthesis

Record in judgment:

```yaml
detailed_evaluation_synthesis:
  ga_1:
    criterion_id: "GA-1"
    description: "Rule conditions are unambiguous"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      hedging_in_rule_condition:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      vague_term_in_rule_condition:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      open_ended_condition:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      either_or_in_required_action:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      no_concrete_action:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      no_concrete_values:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
  ga_2:
    criterion_id: "GA-2"
    description: "No conflicting rules"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      within_file_conflict:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      cross_file_conflict:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      tier_override_conflict:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      scope_boundary_conflict:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      missed_conflict:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
  ga_3:
    criterion_id: "GA-3"
    description: "Actions are LLM-enforceable"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      unenforceable_action:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      implicit_behavior_no_mechanism:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      no_enforcement_mechanism:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      vague_halt_condition:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      tbd_in_rule_action:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
  ga_4:
    criterion_id: "GA-4"
    description: "No redundant cross-file references"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      duplicate_source_reference:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      missed_duplicate_reference:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      broken_cross_reference:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      reference_consolidation_needed:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
  ga_5:
    criterion_id: "GA-5"
    description: "Context fits in LLM window"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      file_exceeds_token_limit:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      section_exceeds_token_limit:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      rule_exceeds_token_limit:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      corpus_exceeds_token_limit:
        result: "PASS|FAIL"
        findings: ["<carried forward>", ...]
      disproportionate_section_size:
        result: "PASS|FAIL"
        findings: ["<carried forward>", ...]
  ga_6:
    criterion_id: "GA-6"
    description: "File organization logical"
    result: "<carried forward from verdict.yaml>"
    evaluator_verdict: "<carried forward>"
    knowledge_supporter_alignment: "aligned|partial|misaligned"
    alignment_notes: "<observations from cross-referencing reasoning.yaml>"
    sub_checks:
      inconsistent_naming:
        result: "PASS|FAIL"
        findings: ["<carried forward>", ...]
      missing_index_file:
        result: "PASS|FAIL"
        findings: ["<carried forward>", ...]
      unrelated_rules_grouped:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      incoherent_file_grouping:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      coverage_gap:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
      missed_file_grouping:
        result: "PASS|FAIL"
        count: <N>
        findings: ["<carried forward>", ...]
```

### Step 6: Synthesize Bidirectional Findings

Carry forward the Evaluator's bidirectional findings without re-evaluation:

- [ ] 1. Read `bidirectional_findings` from `verdict.yaml`
- [ ] 2. For each finding, carry forward: `criterion_id`, `finding_type`, `description`, `revision_option`
- [ ] 3. Classify findings by type: `GUIDELINE_AMBIGUOUS`, `GUIDELINE_CONFLICTING`, `GUIDELINE_UNENFORCEABLE`, `GUIDELINE_REDUNDANT`, `GUIDELINE_OVERFLOW`, `GUIDELINE_DISORGANIZED`
- [ ] 4. Count findings per type
- [ ] 5. Cross-reference each finding's criterion against the Validator's validation to confirm the evidence chain — do NOT re-evaluate

Record in judgment:

```yaml
bidirectional_findings_synthesis:
  total_findings: <N>
  by_type:
    GUIDELINE_AMBIGUOUS: <N>
    GUIDELINE_CONFLICTING: <N>
    GUIDELINE_UNENFORCEABLE: <N>
    GUIDELINE_REDUNDANT: <N>
    GUIDELINE_OVERFLOW: <N>
    GUIDELINE_DISORGANIZED: <N>
  findings:
    - criterion_id: "<ID>"
      finding_type: "GUIDELINE_AMBIGUOUS|GUIDELINE_CONFLICTING|GUIDELINE_UNENFORCEABLE|GUIDELINE_REDUNDANT|GUIDELINE_OVERFLOW|GUIDELINE_DISORGANIZED"
      description: "<carried forward from verdict.yaml>"
      revision_option: "<carried forward from verdict.yaml>"
      knowledge_supporter_alignment: "aligned|partial|misaligned"
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

- [ ] 1. If all GA-1 through GA-6 criteria PASS: final judgment is `PASS`
- [ ] 2. If any criterion FAILs: final judgment is `FAIL`
- [ ] 3. If evidence chain integrity is `broken`: final judgment is `FAIL` with `EVIDENCE_CHAIN_BROKEN` classification
- [ ] 4. Determine `next_step`:
  - `PASS` → `next_step: "proceed"` — guidelines are ready
  - `FAIL` → `next_step: "remediate"` — guidelines require revision of failed criteria

Record in judgment:

```yaml
final_judgment:
  status: "PASS|FAIL"
  next_step: "proceed|remediate"
  summary: "<1-3 sentence synthesis of the overall judgment>"
  pass_count: <N>
  fail_count: <N>
  evidence_chain_status: "intact|partial|broken"
```

### Step 9: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: guideline-audit-path-provider
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
guideline_paths: ["<path>", ...]
per_criterion_synthesis: {...}
detailed_evaluation_synthesis: {...}
bidirectional_findings_synthesis: {...}
evidence_chain_integrity: {...}
final_judgment: {...}
upstream_metadata:
  generator: "<from evidence.yaml>"
  knowledge_supporter: "<from reasoning.yaml>"
  evaluator: "<from verdict.yaml>"
  knowledge_supporter_validation_status: "<validated|partial|corrected>"
```

### Step 10: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/judgment.yaml"
final_judgment: "PASS|FAIL"
next_step: "proceed|remediate"
summary: "<N> criteria synthesized. <X> PASS, <Y> FAIL. Evidence chain: <intact|partial|broken>."
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Guideline Files → INVALID if skipped
- [ ] 4. Synthesize Per-Criterion Verdicts → INVALID if skipped
- [ ] 5. Synthesize Detailed Evaluation Results → INVALID if skipped
- [ ] 6. Synthesize Bidirectional Findings → INVALID if skipped
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
| guideline_paths missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| Glob expansion returns no files | Return BLOCKED with NO_GUIDELINE_FILES_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Evaluator's verdict contains INCONCLUSIVE | Flag as `invalid_verdict` — INCONCLUSIVE is not a valid verdict per critical-rules-hard-fail |
| Evidence chain is broken | Record as `broken` in evidence chain integrity — do NOT BLOCK, but final judgment is FAIL |
| Upstream artifact section missing | Record as `section_missing` — do NOT BLOCK, but flag in evidence chain integrity |
| Write permission denied | Return BLOCKED — cannot write judgment.yaml |

## Cross-References

- `tasks/guideline-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/guideline-audit-validator.md` — Validator role (produces the reasoning.yaml consumed by this task)
- `tasks/guideline-audit-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/spec-audit-arbiter.md` — Spec-audit Arbiter role (reference implementation)
- `tasks/plan-fidelity-arbiter.md` — Plan-fidelity Arbiter role (reference implementation)
- `000-critical-rules.md` — guideline standards and critical rule definitions
- Read [critical-rules-hard-fail](guidelines/000-critical-rules.md) — FAIL is a hard gate, never reclassifiable
- Read [Hard Failure Discipline](guidelines/065-verification-honesty.md) — FAIL is a hard gate, never reclassifiable
- `080-code-standards.md` — enforcement test mandate and evidence type taxonomy

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
