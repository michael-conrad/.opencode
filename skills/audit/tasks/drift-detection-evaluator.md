---
name: drift-detection-evaluator
description: "Evaluator role for the drift-detection DiMo chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection-evaluator

## Purpose

Evaluator role for the drift-detection DiMo chain. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each drift detection criterion against the spec and code, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This role produces judgments — it does NOT collect evidence or validate evidence. Those are upstream responsibilities.

> **DiMo Role: Evaluator.** This task evaluates drift between spec and code. Reads `evidence.yaml` + `reasoning.yaml` from upstream roles, evaluates each criterion, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. The upstream reasoning role has already validated it. Make the call.
>
>
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns", no INCONCLUSIVE
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-validate evidence that upstream reasoning role already validated — trust the `reasoning.yaml` validation status
> - MUST NOT collect new evidence — that is the Investigator's job
> - MUST write `verdict.yaml` as the primary output artifact
> - MUST apply the self-consistency gate: if a PASS verdict's explanation contains critique/hedging language, downgrade to FAIL

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from upstream roles are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against validated evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory containing `evidence.yaml` and `reasoning.yaml` from upstream roles
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `target_files`: Optional — specific file paths that were scanned. If absent, extracted from spec.

## Entry Criteria

- `evidence.yaml` exists at `{artifact_evidence_dir}/evidence.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the Investigator completed successfully and wrote `evidence.yaml` before dispatching the Evaluator. Dispatching without a valid `evidence.yaml` is a CRITICAL VIOLATION.
- `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — MUST be a file confirmed to exist before dispatch. The orchestrator MUST verify the upstream reasoning role completed successfully and wrote `reasoning.yaml` before dispatching the Evaluator. Dispatching without a valid `reasoning.yaml` is a CRITICAL VIOLATION.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for verdict artifacts)
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- `verdict.yaml` written to `{artifact_evidence_dir}/verdict.yaml`
- Every drift detection criterion evaluated with binary PASS/FAIL — no INCONCLUSIVE, no "PASS with concerns"
- All target files compared against spec requirements
- Drift classified as SPEC_DRIFT, CODE_DRIFT, or SYNC per criterion
- DD-STRUCTURAL-FAIL gate applied: structural evidence rejected for behavioral SC drift
- Self-consistency gate applied to all PASS verdicts
- Bidirectional findings generated for FAIL criteria with revision options
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
remediation: "evidence.yaml is required for drift-detection-evaluator. The orchestrator must ensure the Investigator completed successfully and wrote evidence.yaml before dispatching the Evaluator."
```

- [ ] 3. Verify `reasoning.yaml` exists at `{artifact_evidence_dir}/reasoning.yaml` — read the file to confirm it is non-empty and valid YAML
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "reasoning.yaml"
remediation: "reasoning.yaml is required for drift-detection-evaluator. The orchestrator must ensure the upstream reasoning role completed successfully and wrote reasoning.yaml before dispatching the Evaluator."
```

- [ ] 5. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 6. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for drift-detection-evaluator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 7. Verify `artifact_evidence_dir` is writable — create it if it does not exist

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately.

### Step 2: Load Upstream Artifacts

Read the Investigator's evidence and the upstream reasoning role's validated reasoning:

- [ ] 1. Read `{artifact_evidence_dir}/evidence.yaml` via `read` tool
- [ ] 2. Read `{artifact_evidence_dir}/reasoning.yaml` via `read` tool
- [ ] 3. Parse all top-level sections from both artifacts
- [ ] 4. Record metadata: `generator`, `knowledge_supporter`, `issue_number`, `generated_at`, `spec_local_dir`
- [ ] 5. If any expected top-level section is absent from either artifact, record as `section_missing` — do NOT BLOCK, but flag in the verdict
- [ ] 6. Note the upstream reasoning role's `overall_validation_status` — this informs evaluation confidence

### Step 3: Load Spec Content

Read the spec files to establish the authoritative baseline for evaluation:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract spec body and frontmatter metadata from each file
- [ ] 4. Extract the Success Criteria table — this is the authoritative list of SCs to evaluate
- [ ] 5. Extract file requirements — every file path mentioned in the spec
- [ ] 6. Extract function/class/symbol references — every function, class, or method name mentioned
- [ ] 7. Extract edge case descriptions

### Step 4: Build Evaluation Criteria

Define the drift detection criteria to evaluate:

| Criterion ID | Description | Expected Result | Evidence Source |
|--------------|-------------|-----------------|-----------------|
| DD-1 | All spec files implemented | Each file exists | `reasoning.yaml → raw_comparisons_validation.file_presence` |
| DD-2 | Implementation matches spec | Behavior aligns | `reasoning.yaml → raw_comparisons_validation.function_presence` + `signature_comparisons` |
| DD-3 | No extra implementation | No untracked files | `reasoning.yaml → untracked_files_validation` |
| DD-4 | Function signatures match | Spec API matches code API | `reasoning.yaml → raw_comparisons_validation.signature_comparisons` |
| DD-5 | Edge cases covered | All edge cases implemented | `reasoning.yaml → raw_comparisons_validation.edge_case_coverage` |
| DD-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SC drift | If drift evidence reports SC as PASS using structural-only evidence (grep/read/file-exists) when the SC describes behavior, return FAIL with `STRUCTURAL_EVIDENCE` classification. Structural checks do NOT verify behavioral correctness — they only verify existence. | `reasoning.yaml → raw_comparisons_validation` |

### Step 5: Evaluate DD-1 — File Presence

Evaluate whether all spec-required files exist in the codebase:

- [ ] 1. Read `raw_comparisons_validation.file_presence` from `reasoning.yaml`
- [ ] 2. For each file entry in the spec's file requirements:
  - If `code_file_exists` is `true` → PASS for that file
  - If `code_file_exists` is `false` → FAIL for that file with `SPEC_DRIFT` classification
- [ ] 3. If the upstream reasoning role flagged any file presence entry as `corrected`, use the corrected values
- [ ] 4. If the upstream reasoning role flagged any file presence entry as `unvalidated`, note the uncertainty but still render a verdict
- [ ] 5. Aggregate: DD-1 PASS if ALL spec-required files exist; FAIL if any spec-required file is missing

Record results:

```yaml
dd1_file_presence:
  status: "PASS|FAIL"
  total_files: <N>
  files_present: <N>
  files_missing: <N>
  missing_files:
    - spec_file: "<path>"
      drift_type: "SPEC_DRIFT"
      reason: "Spec requires file, but file not implemented"
```

### Step 6: Evaluate DD-2 — Implementation Matches Spec

Evaluate whether the implementation aligns with spec behavior:

- [ ] 1. Read `raw_comparisons_validation.function_presence` from `reasoning.yaml`
- [ ] 2. For each function reference in the spec:
  - If `found_in_code` is `true` → PASS for that function
  - If `found_in_code` is `false` → FAIL for that function with `SPEC_DRIFT` classification
- [ ] 3. Read `raw_comparisons_validation.signature_comparisons` from `reasoning.yaml`
- [ ] 4. For each function with an expected signature:
  - If `expected_signature` matches `actual_signature` → PASS
  - If signatures differ → FAIL with `SIGNATURE_MISMATCH` classification
- [ ] 5. If the upstream reasoning role flagged any entry as `corrected`, use the corrected values
- [ ] 6. Aggregate: DD-2 PASS if ALL spec functions exist and ALL signatures match; FAIL otherwise

Record results:

```yaml
dd2_implementation_match:
  status: "PASS|FAIL"
  total_functions: <N>
  functions_present: <N>
  functions_missing: <N>
  signature_matches: <N>
  signature_mismatches: <N>
  missing_functions:
    - spec_function: "<name>"
      drift_type: "SPEC_DRIFT"
      reason: "Spec function missing in code"
  signature_mismatches:
    - spec_function: "<name>"
      drift_type: "SIGNATURE_MISMATCH"
      expected: "<signature>"
      actual: "<signature>"
```

### Step 7: Evaluate DD-3 — No Extra Implementation

Evaluate whether code contains implementation not tracked in the spec:

- [ ] 1. Read `untracked_files_validation` from `reasoning.yaml`
- [ ] 2. If `scan_performed` is `false` or `scope_source` is `not_specified`:
  - Mark DD-3 as PASS with note that full scan was not performed — do NOT penalize for missing scope
- [ ] 3. If `scan_performed` is `true`:
  - For each untracked file, evaluate whether it represents meaningful drift
  - Utility/helper files that are clearly infrastructure → PASS (not drift)
  - Files with domain logic not in spec → FAIL with `CODE_DRIFT` classification
- [ ] 4. Read `raw_comparisons_validation.extra_code` from `reasoning.yaml`
- [ ] 5. For each extra code symbol:
  - If the upstream reasoning role flagged it as `false_extra` (actually in spec) → PASS
  - If genuinely not in spec → FAIL with `CODE_DRIFT` classification
- [ ] 6. If the upstream reasoning role flagged any entry as `corrected`, use the corrected values
- [ ] 7. Aggregate: DD-3 PASS if no meaningful untracked implementation exists; FAIL if code implements untracked domain logic

Record results:

```yaml
dd3_extra_implementation:
  status: "PASS|FAIL"
  scan_performed: true | false
  untracked_files:
    - path: "<file path>"
      drift_type: "CODE_DRIFT"
      reason: "Implementation not tracked in spec"
      severity: "LOW|MEDIUM"
  extra_symbols:
    - file: "<file path>"
      symbol_name: "<name>"
      drift_type: "CODE_DRIFT"
      reason: "Code function not in spec"
```

### Step 8: Evaluate DD-4 — Function Signatures Match

Evaluate whether spec API signatures match code API signatures:

- [ ] 1. Read `raw_comparisons_validation.signature_comparisons` from `reasoning.yaml`
- [ ] 2. For each function reference with both `spec_has_signature: true` and `code_has_signature: true`:
  - Compare `expected_signature` against `actual_signature`
  - Exact match → PASS
  - Any difference → FAIL with `SIGNATURE_MISMATCH` classification
- [ ] 3. For functions where the spec has a signature but code does not:
  - FAIL with `SPEC_DRIFT` — spec expects a function with a specific signature that does not exist
- [ ] 4. For functions where code has a signature but spec does not:
  - FAIL with `CODE_DRIFT` — code implements a function the spec does not document
- [ ] 5. If the upstream reasoning role flagged any entry as `corrected`, use the corrected values
- [ ] 6. Aggregate: DD-4 PASS if ALL spec-defined signatures match code; FAIL otherwise

Record results:

```yaml
dd4_signature_match:
  status: "PASS|FAIL"
  total_comparisons: <N>
  exact_matches: <N>
  mismatches: <N>
  mismatches_detail:
    - spec_function: "<name>"
      drift_type: "SIGNATURE_MISMATCH|SPEC_DRIFT|CODE_DRIFT"
      expected: "<signature>"
      actual: "<signature>"
```

### Step 9: Evaluate DD-5 — Edge Cases Covered

Evaluate whether spec edge cases are addressed in the implementation:

- [ ] 1. Read `raw_comparisons_validation.edge_case_coverage` from `reasoning.yaml`
- [ ] 2. For each edge case described in the spec:
  - If `related_code_found` is `true` → PASS for that edge case
  - If `related_code_found` is `false` → FAIL with `MISSING_EDGE_CASE` classification
- [ ] 3. If the upstream reasoning role flagged any entry as `corrected`, use the corrected values
- [ ] 4. If the upstream reasoning role flagged any entry as `unvalidated`, note the uncertainty but still render a verdict
- [ ] 5. Aggregate: DD-5 PASS if ALL edge cases have related code; FAIL if any edge case is unaddressed

Record results:

```yaml
dd5_edge_cases:
  status: "PASS|FAIL"
  total_edge_cases: <N>
  covered: <N>
  uncovered: <N>
  uncovered_detail:
    - edge_case: "<description>"
      drift_type: "MISSING_EDGE_CASE"
      reason: "Edge case not implemented"
```

### Step 10: Evaluate DD-STRUCTURAL-FAIL

Apply the structural evidence rejection gate:

- [ ] 1. For each SC in the spec that describes testable behavior (correctness, output, result, pass/fail, runtime logic):
  - Check the evidence type declared in the spec's SC table
  - If the declared type is `behavioral` or `semantic` but the drift evidence reports PASS using only structural checks (file existence, grep, read) → FAIL with `STRUCTURAL_EVIDENCE` classification
  - Structural checks do NOT verify behavioral correctness — they only verify existence
- [ ] 2. For each drift finding that reports SYNC based solely on file existence:
  - If the SC describes behavior, file existence is insufficient evidence of synchronization
  - Downgrade to FAIL with `STRUCTURAL_EVIDENCE` classification
- [ ] 3. Aggregate: DD-STRUCTURAL-FAIL PASS if no structural-only evidence is used for behavioral SCs; FAIL if any behavioral SC is evaluated using structural evidence only

Record results:

```yaml
dd_structural_fail:
  status: "PASS|FAIL"
  violations:
    - sc_id: "<SC-ID>"
      declared_evidence_type: "<type>"
      evidence_provided: "structural"
      reason: "Structural evidence (file existence) does not verify behavioral correctness"
```

### Step 11: Classify Drift Severity

For each FAIL criterion, classify drift severity:

| Drift Type | Severity | Classification |
|-----------|----------|----------------|
| SPEC_DRIFT | HIGH | Spec requires, code missing |
| CODE_DRIFT | MEDIUM | Code implements, spec unaware |
| SIGNATURE_MISMATCH | HIGH | API mismatch |
| UNTRACKED_FILE | LOW | May be utility/helper |
| MISSING_EDGE_CASE | MEDIUM | Edge case not implemented |
| STRUCTURAL_EVIDENCE | HIGH | Behavioral SC evaluated with structural evidence only |

- [ ] 1. For each FAIL finding across DD-1 through DD-5 and DD-STRUCTURAL-FAIL, assign a severity
- [ ] 2. HIGH severity findings block implementation — must be resolved before proceeding
- [ ] 3. MEDIUM severity findings require attention but may not block
- [ ] 4. LOW severity findings are informational

### Step 12: Generate Bidirectional Findings

Generate findings ONLY for FAIL criteria. PASS criteria MUST NOT appear in the findings table.

| Direction | Description |
|-----------|-------------|
| SPEC_DRIFT | Update code to match spec |
| CODE_DRIFT | Update spec to document implementation |
| SYNC | No action needed |

- [ ] 1. For each FAIL criterion, classify the direction
- [ ] 2. Present revision options for developer decision
- [ ] 3. Include specific remediation guidance for each FAIL

Record results:

```yaml
bidirectional_findings:
  - criterion_id: "<DD-N>"
    finding_type: "SPEC_DRIFT|CODE_DRIFT|SIGNATURE_MISMATCH|MISSING_EDGE_CASE|STRUCTURAL_EVIDENCE"
    direction: "spec→code|code→spec"
    description: "<description>"
    severity: "HIGH|MEDIUM|LOW"
    revision_options:
      - "<option 1>"
      - "<option 2>"
```

### Step 13: Process Verdicts

Compile all per-criterion verdicts and apply consensus rules:

- [ ] 1. Collect all verdicts from Steps 5-10 into a single `per_criterion` array
- [ ] 2. Each entry must include: `criterion_id`, `result`, `evidence`, `explanation`, `remediation`, `drift_type`, `severity`
- [ ] 3. Count total, pass, and fail verdicts
- [ ] 4. Determine overall verdict: PASS if ALL criteria pass; FAIL if any criterion fails

### Step 14: Apply Self-Consistency Gate

Apply a self-consistency check to every PASS verdict:

- [ ] 1. For each criterion with `result: "PASS"`:
  - Read the `explanation` field
  - If the explanation contains critique/hedging language ("should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally") → downgrade to FAIL
  - A PASS verdict must be strictly confirmatory with no critique or hedging
- [ ] 2. Re-count pass/fail after self-consistency downgrades

```yaml
for each entry in per_criterion:
  if entry.result == "PASS":
    hedging_patterns = [
      "should be", "needs", "missing", "could improve",
      "minor", "some issues", "mostly", "generally"
    ]
    for pattern in hedging_patterns:
      if pattern in entry.explanation.lower():
        entry.result = "FAIL"
        entry.self_consistency_note = (
          f"Downgraded from PASS to FAIL: explanation contains hedging "
          f"language ('{pattern}') that contradicts a PASS verdict. "
          f"A PASS verdict must be unequivocal — no critique, no hedging."
        )
        break
```

### Step 15: Write verdict.yaml

Write the complete verdict to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: drift-detection-evaluator
issue_number: <N>
generated_at: "<timestamp>"
evidence_source: "{artifact_evidence_dir}/evidence.yaml"
reasoning_source: "{artifact_evidence_dir}/reasoning.yaml"
spec_local_dir: "<path>"
summary:
  total_criteria: <N>
  pass: <N>
  fail: <N>
  all_criteria_pass: true | false
  remediation_required: true | false
per_criterion:
  - criterion_id: "<DD-N>"
    result: "PASS|FAIL"
    evidence: "<reference to reasoning.yaml section>"
    explanation: "<reasoning for verdict>"
    remediation: "<if FAIL, what to fix>"
    drift_type: "SPEC_DRIFT|CODE_DRIFT|SIGNATURE_MISMATCH|MISSING_EDGE_CASE|STRUCTURAL_EVIDENCE|SYNC"
    severity: "HIGH|MEDIUM|LOW"
dd1_file_presence: {...}
dd2_implementation_match: {...}
dd3_extra_implementation: {...}
dd4_signature_match: {...}
dd5_edge_cases: {...}
dd_structural_fail: {...}
drift_summary:
  spec_drift_count: <N>
  code_drift_count: <N>
  sync_count: <N>
  high_severity_count: <N>
  medium_severity_count: <N>
  low_severity_count: <N>
bidirectional_findings:
  - criterion_id: "<DD-N>"
    finding_type: "SPEC_DRIFT|CODE_DRIFT|SIGNATURE_MISMATCH|MISSING_EDGE_CASE|STRUCTURAL_EVIDENCE"
    direction: "spec→code|code→spec"
    description: "<description>"
    severity: "HIGH|MEDIUM|LOW"
    revision_options:
      - "<option 1>"
      - "<option 2>"
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `verdict.yaml` with the complete verdict structure
- [ ] 3. Verify the file was written and is non-empty

### Step 16: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | FAIL
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "Drift detection: {spec_drift_count} spec drift, {code_drift_count} code drift, {sync_count} sync. Verdict: {overall}."
all_criteria_pass: true | false
remediation_required: true | false
```

## Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{artifact_evidence_dir}/verdict.yaml"
summary: "Drift detection: {spec_drift_count} spec drift, {code_drift_count} code drift, {sync_count} sync. Verdict: {overall}."
all_criteria_pass: true | false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Build Evaluation Criteria → INVALID if skipped
- [ ] 5. Evaluate DD-1 — File Presence → INVALID if skipped
- [ ] 6. Evaluate DD-2 — Implementation Matches Spec → INVALID if skipped
- [ ] 7. Evaluate DD-3 — No Extra Implementation → INVALID if skipped
- [ ] 8. Evaluate DD-4 — Function Signatures Match → INVALID if skipped
- [ ] 9. Evaluate DD-5 — Edge Cases Covered → INVALID if skipped
- [ ] 10. Evaluate DD-STRUCTURAL-FAIL → INVALID if skipped
- [ ] 11. Classify Drift Severity → INVALID if skipped
- [ ] 12. Generate Bidirectional Findings → INVALID if skipped
- [ ] 13. Process Verdicts → INVALID if skipped
- [ ] 14. Apply Self-Consistency Gate → INVALID if skipped
- [ ] 15. Write verdict.yaml → INVALID if skipped
- [ ] 16. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| reasoning.yaml missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| evidence.yaml is not valid YAML | Return BLOCKED with INVALID_EVIDENCE_FORMAT |
| reasoning.yaml is not valid YAML | Return BLOCKED with INVALID_REASONING_FORMAT |
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| upstream reasoning role flagged evidence as unvalidated | Note uncertainty in explanation — still render verdict |
| upstream reasoning role flagged evidence as corrected | Use corrected values — do NOT use original evidence values |
| No target files identified in evidence | Return BLOCKED — need file paths |
| Code not parseable (from evidence) | Skip function, log warning in explanation |

## Cross-References

- `tasks/drift-detection-investigator.md` — Investigator role (produces the `evidence.yaml` consumed by this task)
- `tasks/drift-detection-validator.md` — upstream reasoning role role (produces the `reasoning.yaml` consumed by this task)
- `tasks/drift-detection.md` — Main drift-detection task (orchestrator-level dispatch)
- `tasks/cross-validate.md` — Arbiter role (consumes this task's `verdict.yaml`)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- Load [000-critical-rules.md](guidelines/000-critical-rules.md) — spec-code alignment
- Load [130-authority-source.md](guidelines/130-authority-source.md) — code as authoritative source
- Load [Hard Failure Discipline](guidelines/065-verification-honesty.md) — FAIL is a hard gate, never reclassifiable

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
