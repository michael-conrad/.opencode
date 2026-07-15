---
name: spec-audit-path-provider
description: "Arbiter role for the spec-audit DiMo chain. Reads all upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml) and produces the final judgment.yaml with final judgment and next_step. Synthesizes, does not evaluate."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit-path-provider

## Purpose

Arbiter role for the spec-audit DiMo chain. Reads all upstream artifacts (`evidence.yaml` from Investigator, `reasoning.yaml` from Validator, `verdict.yaml` from Evaluator) and produces the final `judgment.yaml` with final judgment and `next_step`. This role synthesizes — it does NOT evaluate, re-evaluate, or second-guess upstream roles.

> **DiMo Role: Arbiter.** This task produces the final judgment by synthesizing all upstream artifacts. Reads `evidence.yaml`, `reasoning.yaml`, `verdict.yaml`, writes `judgment.yaml`.
>
> You are the Arbiter. You are a synthesizer, not an evaluator. Your job is to read what upstream roles produced and assemble the final picture. You do not second-guess their work. You do not re-open their decisions. You take their outputs and produce the final judgment.
>
>
> - MUST accept Evaluator's per-criterion verdicts as final — do NOT re-evaluate
> - MUST NOT overrule a PASS/FAIL from the Evaluator
> - MUST NOT produce new evidence or re-validate existing evidence
> - MUST write `judgment.yaml` as the only output artifact
> - MUST synthesize the holistic evaluation, narrow criteria, and analytical findings into a single coherent judgment

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory containing `evidence.yaml`, `reasoning.yaml`, and `verdict.yaml` from upstream roles
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Arbiter. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Validator completed successfully and wrote `reasoning.yaml` before dispatching the Arbiter. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Evaluator completed successfully and wrote `verdict.yaml` before dispatching the Arbiter. Dispatching without a valid `verdict.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for judgment artifacts)

## Exit Criteria

- `judgment.yaml` written to `{artifact_evidence_dir}/judgment.yaml`
- All upstream artifacts read and synthesized into a single coherent judgment
- Holistic evaluation status carried forward from Evaluator's verdict
- Narrow criteria verdicts carried forward from Evaluator's verdict
- Analytical findings synthesized from Evaluator's verdict
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
remediation: "evidence.yaml is required for spec-audit-path-provider. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Arbiter."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for spec-audit-path-provider. The orchestrator must ensure the Validator completed successfully and wrote reasoning.yaml before dispatching the Arbiter."
```

- [ ] 5. Verify `verdict.yaml` exists at `{artifact_evidence_dir}/verdict.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 6. If `verdict.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "verdict.yaml"
remediation: "verdict.yaml is required for spec-audit-path-provider. The orchestrator must ensure the Evaluator completed successfully and wrote verdict.yaml before dispatching the Arbiter."
```

- [ ] 7. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 8. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for spec-audit-path-provider. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 9. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Upstream Artifacts

Read all three upstream artifacts in full:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Read `{artifact_evidence_dir}/verdict.yaml` via `read` tool
- [ ] 4. Parse all top-level sections from all three artifacts
- [ ] 5. Record metadata from each: `generator`, `knowledge_supporter`, `evaluator`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 6. If any expected top-level section is absent from any artifact, record as `section_missing` — do NOT BLOCK, but flag in the judgment
- [ ] 7. Note the Validator's `overall_validation_status` — this informs synthesis confidence
- [ ] 8. Note the Evaluator's `holistic_evaluation.status` — this determines whether narrow criteria were evaluated

### Step 3: Load Spec Content

Read the spec files to establish the authoritative baseline for synthesis:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract spec body and frontmatter metadata from each file
- [ ] 4. Extract the Success Criteria table — this is the authoritative list of SCs
- [ ] 5. Extract the STATUS marker if present
- [ ] 6. Record the spec's declared evidence types for each SC

### Step 4: Synthesize Holistic Evaluation

Carry forward the Evaluator's holistic evaluation without re-evaluation:

- [ ] 1. Read `holistic_evaluation` from `verdict.yaml`
- [ ] 2. Record the overall holistic status: `PASS` or `DRAFT`
- [ ] 3. For each of the 11 dimensions, carry forward the Evaluator's `result` and `finding`
- [ ] 4. If the holistic status is `DRAFT`, note that narrow criteria were not evaluated — the judgment is limited to holistic dimensions only
- [ ] 5. Cross-reference the holistic findings against the Validator's `holistic_dimension_validation` to confirm evidence alignment — do NOT re-evaluate, only note alignment or misalignment
- [ ] 6. If the Validator flagged any holistic dimension evidence as `corrected` or `unvalidated`, note this in the synthesis

Record in judgment:

```yaml
holistic_synthesis:
  status: "PASS|DRAFT"
  evaluator_verdict: "<carried forward from verdict.yaml>"
  knowledge_supporter_alignment: "aligned|partial|misaligned"
  alignment_notes: "<observations from cross-referencing reasoning.yaml>"
  dimensions:
    - id: 1
      name: "Implementability"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 2
      name: "Internal Consistency"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 3
      name: "Completeness"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 4
      name: "Scope Discipline"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 5
      name: "Testability"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 6
      name: "Escape Hatches"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 7
      name: "Provenance"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 8
      name: "Feasibility"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 9
      name: "Safety"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 10
      name: "Traceability"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
    - id: 11
      name: "Correctness"
      result: "PASS|FAIL"
      finding: "<carried forward from verdict.yaml>"
```

### Step 5: Synthesize Narrow Criteria Verdicts

Carry forward the Evaluator's per-criterion verdicts without re-evaluation:

- [ ] 1. Read `per_criterion` from `verdict.yaml`
- [ ] 2. For each criterion, carry forward: `criterion_id`, `declared_evidence_type`, `result`, `explanation`, `remediation`, `next_step`
- [ ] 3. Count total, pass, and fail verdicts
- [ ] 4. If the holistic status is `DRAFT`, narrow criteria were not evaluated — mark all narrow criteria as `NOT_EVALUATED` with explanation `"Holistic gate failed — narrow criteria not evaluated"`
- [ ] 5. Cross-reference each criterion's evidence source against the Validator's validation — note any `corrected` or `unvalidated` evidence that the Evaluator relied on
- [ ] 6. Do NOT re-evaluate any criterion — the Evaluator's verdict is final
- [ ] 7. Do NOT apply self-consistency gate — the Evaluator already applied it

Record in judgment:

```yaml
narrow_criteria_synthesis:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  not_evaluated: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
  per_criterion:
    - criterion_id: "<ID>"
      declared_evidence_type: "<type>"
      result: "PASS|FAIL|FABRICATED|N/A|NOT_EVALUATED"
      explanation: "<carried forward from verdict.yaml>"
      remediation: "<carried forward from verdict.yaml or absent>"
      next_step: "proceed|remediate"
      knowledge_supporter_validation: "validated|corrected|unvalidated"
```

### Step 6: Synthesize Analytical Findings

Carry forward the Evaluator's analytical findings without re-evaluation:

- [ ] 1. Read `reasoning_soundness` from `verdict.yaml` — carry forward causal chain, SC traceability, and contradiction findings
- [ ] 2. Read `claim_accuracy` from `verdict.yaml` — carry forward fabricated claims, negation verifications, and interface verifications
- [ ] 3. Read `blast_radius` from `verdict.yaml` — carry forward impact completeness and non-code impact findings
- [ ] 4. Read `research_adequacy` from `verdict.yaml` — carry forward evidence provenance, investigation breadth, edge case discovery, and recency check findings
- [ ] 5. Read `gap_analysis` from `verdict.yaml` — carry forward missing coverage and implicit conditions findings
- [ ] 6. Read `scope_creep` from `verdict.yaml` — carry forward traceability enforcement and proportionality findings
- [ ] 7. Read `scope_narrowness` from `verdict.yaml` — carry forward root cause depth, systemic implication, and minimum viable scope findings
- [ ] 8. Read `cross_reference_completeness` from `verdict.yaml` — carry forward citation completeness and reference sufficiency findings
- [ ] 9. Read `analytical_artifact_evaluation` from `verdict.yaml` — carry forward per-artifact findings
- [ ] 10. Read `bidirectional_findings` from `verdict.yaml` — carry forward all FAIL/DISAGREE findings with their types and revision options
- [ ] 11. If the holistic status is `DRAFT`, analytical findings were not evaluated — mark all as `NOT_EVALUATED`

Record in judgment:

```yaml
analytical_synthesis:
  reasoning_soundness:
    status: "<carried forward or NOT_EVALUATED>"
    causal_chain: "<carried forward>"
    sc_traceability: "<carried forward>"
    contradictions: "<carried forward>"
  claim_accuracy:
    status: "<carried forward or NOT_EVALUATED>"
    fabricated_claims: "<carried forward>"
    negation_verifications: "<carried forward>"
    interface_verifications: "<carried forward>"
  blast_radius:
    status: "<carried forward or NOT_EVALUATED>"
    impact_completeness: "<carried forward>"
    non_code_impact: "<carried forward>"
  research_adequacy:
    status: "<carried forward or NOT_EVALUATED>"
    evidence_provenance: "<carried forward>"
    investigation_breadth: "<carried forward>"
    edge_case_discovery: "<carried forward>"
    recency_check: "<carried forward>"
  gap_analysis:
    status: "<carried forward or NOT_EVALUATED>"
    missing_coverage: "<carried forward>"
    implicit_conditions: "<carried forward>"
  scope_creep:
    status: "<carried forward or NOT_EVALUATED>"
    traceability_enforcement: "<carried forward>"
    proportionality: "<carried forward>"
  scope_narrowness:
    status: "<carried forward or NOT_EVALUATED>"
    root_cause_depth: "<carried forward>"
    systemic_implication: "<carried forward>"
    minimum_viable_scope: "<carried forward>"
  cross_reference_completeness:
    status: "<carried forward or NOT_EVALUATED>"
    citation_completeness: "<carried forward>"
    reference_sufficiency: "<carried forward>"
  analytical_artifact_evaluation:
    status: "<carried forward or NOT_EVALUATED>"
    artifacts: "<carried forward>"
  bidirectional_findings:
    status: "<carried forward or NOT_EVALUATED>"
    findings: "<carried forward>"
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

- [ ] 1. If holistic status is `DRAFT`: final judgment is `DRAFT` — spec requires holistic revision before narrow criteria can be evaluated
- [ ] 2. If holistic status is `PASS` and all narrow criteria PASS: final judgment is `PASS`
- [ ] 3. If holistic status is `PASS` and any narrow criterion FAILs: final judgment is `FAIL`
- [ ] 4. If any analytical finding has a FAIL status: final judgment is `FAIL`
- [ ] 5. If evidence chain integrity is `broken`: final judgment is `FAIL` with `EVIDENCE_CHAIN_BROKEN` classification
- [ ] 6. Determine `next_step`:
  - `PASS` → `next_step: "proceed"` — spec is ready for implementation
  - `DRAFT` → `next_step: "remediate_holistic"` — spec requires holistic revision
  - `FAIL` → `next_step: "remediate"` — spec requires revision of failed criteria

Record in judgment:

```yaml
final_judgment:
  status: "PASS|DRAFT|FAIL"
  next_step: "proceed|remediate_holistic|remediate"
  summary: "<1-3 sentence synthesis of the overall judgment>"
  pass_count: <N>
  fail_count: <N>
  not_evaluated_count: <N>
  evidence_chain_status: "intact|partial|broken"
```

### Step 9: Write judgment.yaml

Write the complete judgment to `{artifact_evidence_dir}/judgment.yaml`:

```yaml
path_provider: spec-audit-path-provider
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
verdict_source: "{artifact_evidence_dir}/verdict.yaml"
spec_local_dir: "<path>"
holistic_synthesis: {...}
narrow_criteria_synthesis: {...}
analytical_synthesis: {...}
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
final_judgment: "PASS|DRAFT|FAIL"
next_step: "proceed|remediate_holistic|remediate"
summary: "<N> criteria synthesized. <X> PASS, <Y> FAIL, <Z> NOT_EVALUATED. Holistic: <PASS|DRAFT>. Evidence chain: <intact|partial|broken>."
all_criteria_pass: true | false
remediation_required: true | false
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Synthesize Holistic Evaluation → INVALID if skipped
- [ ] 5. Synthesize Narrow Criteria Verdicts → INVALID if skipped
- [ ] 6. Synthesize Analytical Findings → INVALID if skipped
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
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| Evaluator's verdict contains INCONCLUSIVE | Flag as `invalid_verdict` — INCONCLUSIVE is not a valid verdict per critical-rules-hard-fail |
| Evidence chain is broken | Record as `broken` in evidence chain integrity — do NOT BLOCK, but final judgment is FAIL |
| Holistic status is DRAFT (narrow criteria not evaluated) | Mark narrow criteria as NOT_EVALUATED — do NOT BLOCK |
| Upstream artifact section missing | Record as `section_missing` — do NOT BLOCK, but flag in evidence chain integrity |

## Cross-References

- `tasks/spec-audit-investigator.md` — Investigator role (produces the evidence.yaml consumed by this task)
- `tasks/spec-audit-validator.md` — Validator role (produces the reasoning.yaml consumed by this task)
- `tasks/spec-audit-evaluator.md` — Evaluator role (produces the verdict.yaml consumed by this task)
- `tasks/cross-validate.md` — Cross-validate Arbiter role (separate DiMo chain for cross-validation)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `.opencode/reference/holistic-dimensions.yaml` — 11 holistic dimensions definitions
- Read [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations
- Read [critical-rules-hard-fail](guidelines/000-critical-rules.md) — FAIL is a hard gate, never reclassifiable
- Read [Hard Failure Discipline](guidelines/065-verification-honesty.md) — FAIL is a hard gate, never reclassifiable

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
