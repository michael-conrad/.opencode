---
name: verification-audit-evaluator
description: "Evaluator role for the verification-audit chain. Reads evidence.yaml and reasoning.yaml from upstream roles, evaluates each criterion, and writes verdict.yaml with per-criterion PASS/FAIL verdicts. Produces judgments, not just evidence."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-audit-evaluator

## Purpose

Evaluator role for the verification-audit chain. Reads `evidence.yaml` (Investigator) and `reasoning.yaml` (upstream reasoning role), evaluates each success criterion against the validated evidence, and writes `verdict.yaml` with per-criterion PASS/FAIL verdicts. This role produces judgments — it does NOT collect evidence or validate evidence. It evaluates.


> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory containing behavioral evidence artifacts from the implementation run
- `spec_issue_number`: Issue number for artifact path construction
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_EVIDENCE_YAML.
- `reasoning.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_REASONING_YAML.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `artifact_evidence_dir` provided — MUST be present and non-empty
- `spec_issue_number` provided
- `github.owner`, `github.repo` available

## Exit Criteria

- All SCs evaluated against validated evidence from `reasoning.yaml`
- Each SC receives a binary PASS or FAIL verdict
- Evidence type compliance verified — each SC evaluated using minimum acceptable method per declared type
- Implementation completeness assessed — does the code satisfy the spec?
- `verdict.yaml` written to `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml`
- No hedging, no "PASS with concerns", no INCONCLUSIVE verdicts

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove `verdict.yaml` if it exists from a prior run at `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — read the file and confirm it is non-empty
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
remediation: "evidence.yaml is required for verification-audit-evaluator. The Investigator must produce evidence.yaml before the Evaluator can produce verdicts."
```

- [ ] 3. Verify `reasoning.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` — read the file and confirm it is non-empty
- [ ] 4. If `reasoning.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REASONING_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
remediation: "reasoning.yaml is required for verification-audit-evaluator. The upstream reasoning role must produce reasoning.yaml before the Evaluator can produce verdicts."
```

- [ ] 5. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 6. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for verification-audit-evaluator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 7. Verify `artifact_evidence_dir` is present and non-empty — glob for evidence files
- [ ] 8. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit-evaluator. The orchestrator must provide a directory containing behavioral evidence artifacts from the implementation run."
```

### Step 2: Load Upstream Artifacts

Read the Investigator's `evidence.yaml` and the upstream reasoning role's `reasoning.yaml`:

- [ ] 1. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` via `read` tool
- [ ] 2. Parse the evidence structure: `spec`, `evidence_artifacts`, `sc_evidence_map`
- [ ] 3. Extract the list of SCs with their declared evidence types and mapped evidence artifacts
- [ ] 4. Read `reasoning.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml` via `read` tool
- [ ] 5. Parse the reasoning structure: `sc_validation`, `artifact_metadata_validation`, `spec_metadata_validation`, `evidence_type_validation`, `issues`
- [ ] 6. Cross-reference: for each SC in `evidence.yaml`, locate its corresponding validation entries in `reasoning.yaml`

### Step 3: Load Spec Content

Read spec from `spec_local_dir/` to obtain the authoritative SC declarations:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract SC table with evidence type declarations
- [ ] 3. Identify behavioral SCs requiring execution evidence
- [ ] 4. Record each SC: ID, criterion text, declared evidence type, verification method

### Step 4: Build Evaluation Criteria

Map spec SCs to validated evidence from `reasoning.yaml`. For each SC, construct the evaluation context:

| Criterion ID | Description | Declared Evidence Type | Evidence Artifacts | Validation Status |
|-------------|-------------|------------------------|-------------------|-------------------|
| SC-1 through SC-N | Per spec SC declaration | From spec | From evidence.yaml | From reasoning.yaml |

For each SC, determine:
- Whether the upstream reasoning role found any validation issues (from `sc_validation` and `issues`)
- Whether evidence artifacts exist and are readable (from `artifact_metadata_validation`)
- Whether evidence type compliance is satisfied (from `evidence_type_validation`)
- Whether the SC exists in the spec and the criterion text matches (from `sc_validation`)

### Step 5: Evaluate Each Criterion

For each SC, produce a binary PASS or FAIL verdict. The evaluation follows a strict decision tree:

#### Decision Tree

1. **SC not found in spec** → FAIL. Reason: `SC_NOT_IN_SPEC`.
2. **Evidence status is "missing"** → FAIL. Reason: `MISSING_EVIDENCE`.
3. **Evidence artifacts exist but are unreadable** → FAIL. Reason: `UNREADABLE_EVIDENCE`.
4. **Evidence type gap detected** (e.g., structural evidence for behavioral SC) → FAIL. Reason: `EVIDENCE_TYPE_MISMATCH`.
5. **Evidence type compliance satisfied, evidence present and readable** → Evaluate the evidence content against the SC criterion.

#### Evidence Content Evaluation

For each SC with valid evidence, evaluate whether the evidence demonstrates the SC is satisfied:

- **Structural SC**: Verify the file exists with expected content. Read the evidence artifact and confirm the file path, existence, and content match the SC criterion.
- **String SC**: Verify the expected pattern is present. Read the evidence artifact and confirm the grep/pattern match result satisfies the SC criterion.
- **Semantic SC**: Read the evidence artifact and apply analytical judgment. Does the implementation's intent and meaning satisfy the SC criterion? This requires reading the evidence content and reasoning about whether the implementation achieves the SC's intent.
- **Behavioral SC**: Read the behavioral test output (session logs, stderr/stdout captures, YAML verdicts). Does the test execution output confirm the agent's behavior matches the SC criterion? Look for tool-call evidence, dispatch traces, and behavioral assertions in the test output.

#### Verdict Rules

| Condition | Verdict |
|-----------|---------|
| Evidence 100% confirms SC is satisfied, no caveats | PASS |
| Evidence partially confirms, any uncertainty, any caveat | FAIL |
| Evidence contradicts the SC criterion | FAIL |
| Evidence is absent for this SC | FAIL |
| Evidence type does not match declared type | FAIL |
| upstream reasoning role flagged validation issues for this SC | FAIL |
| Any hedging language in evidence explanation | FAIL |

### Step 6: Verify Evidence Type Compliance

For each SC, verify that the evidence method matches the declared evidence type per the minimum acceptable method:

| Declared Type | Minimum Method | FAIL If |
|--------------|----------------|---------|
| behavioral | Test execution with output inspection | grep/read/file-exists used instead |
| semantic | Sub-agent read + analytical judgment | grep/string matching used instead |
| string | grep/pattern matching | file-existence used instead |
| structural | file existence | N/A |

Cross-reference with `evidence_type_validation` from `reasoning.yaml`. If the upstream reasoning role flagged an `EVIDENCE_TYPE_GAP` for this SC, the verdict is FAIL with `EVIDENCE_TYPE_MISMATCH`.

### Step 7: Generate Per-Criterion Findings

For each SC, produce a finding entry:

```yaml
- criterion_id: "SC-N"
  declared_evidence_type: "behavioral | semantic | string | structural"
  result: "PASS | FAIL"
  evidence: "<reference to evidence artifact from evidence.yaml>"
  explanation: "<reasoning for the verdict>"
  remediation: "<specific remediation if FAIL, empty string if PASS>"
  next_step: "proceed | remediate"
```

For FAIL criteria, the `explanation` MUST state:
- What was expected (from the SC criterion)
- What was found (from the evidence)
- Why the evidence does not satisfy the criterion

For PASS criteria, the `explanation` MUST state:
- What the evidence demonstrates
- Why it satisfies the SC criterion
- No hedging, no caveats, no "minor concerns"

### Step 8: Write verdict.yaml

Assemble the complete verdict structure and write to `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml`:

```yaml
verdict:
  generated_at: "<ISO timestamp>"
  spec_issue_number: <N>
  evidence_source: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
  reasoning_source: "./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
  evidence_generated_at: "<timestamp from evidence.yaml>"
  reasoning_generated_at: "<timestamp from reasoning.yaml>"
  summary:
    total_criteria: <N>
    pass: <N>
    fail: <N>
    all_criteria_pass: false | true
  per_criterion:
    - criterion_id: "SC-N"
      declared_evidence_type: "behavioral"
      result: "PASS"
      evidence: "<reference>"
      explanation: "<reasoning>"
      remediation: ""
      next_step: "proceed"
    - criterion_id: "SC-M"
      declared_evidence_type: "behavioral"
      result: "FAIL"
      evidence: "<reference>"
      explanation: "<reasoning>"
      remediation: "<specific remediation>"
      next_step: "remediate"
  remediation_required: false | true
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p ./tmp/{issue-N}/artifacts/verification-audit/`
- [ ] 2. Write `verdict.yaml` with the complete verdict structure
- [ ] 3. Verify the file was written and is non-empty

### Step 9: Self-Consistency Gate

After writing the verdict YAML, run a self-consistency check on every `per_criterion` entry where `result: "PASS"`:

- [ ] 1. Scan `explanation` for critique/hedging language: "should be", "needs", "missing", "could improve", "minor", "some issues", "mostly", "generally", "largely", "essentially", "partially"
- [ ] 2. If ANY hedging language is found, downgrade `result` to `"FAIL"` and set `remediation` to `"Self-consistency gate: explanation contains hedging language despite PASS result."`
- [ ] 3. Recompute `summary.all_criteria_pass` and `summary.remediation_required` after downgrades
- [ ] 4. Log the downgrade in the verdict YAML under a `self_consistency_downgrades` field:

```yaml
self_consistency_downgrades:
  - criterion_id: "SC-N"
    original_result: "PASS"
    downgraded_to: "FAIL"
    hedging_phrase: "<matched phrase>"
```

- [ ] 5. Re-write `verdict.yaml` with the corrected verdicts

### Step 9.5: Identify Behavioral SCs for Clean-Room Evaluation

- [ ] 9.5. From the evaluated criteria, collect SC IDs whose evidence type is `behavioral` (either declared or uplifted)
  - Add `needs_clean_room: [SC-IDs]` to the result contract
  - If no behavioral SCs, set `needs_clean_room: []`

### Step 10: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/verdict.yaml"
summary: "{total_criteria} criteria evaluated. {pass} PASS, {fail} FAIL."
all_criteria_pass: false | true
remediation_required: false | true
needs_clean_room: [SC-IDs]
```

## Result Contract

```yaml
status: DONE | FAIL | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/verdict.yaml"
summary: "{total_criteria} criteria evaluated. {pass} PASS, {fail} FAIL."
all_criteria_pass: false | true
remediation_required: false | true
needs_clean_room: [SC-IDs]
```

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml absent | Return BLOCKED with MISSING_EVIDENCE_YAML |
| evidence.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_EVIDENCE_YAML |
| reasoning.yaml absent | Return BLOCKED with MISSING_REASONING_YAML |
| reasoning.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_REASONING_YAML |
| spec_local_dir absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir absent | Return BLOCKED with MISSING_EVIDENCE_DIR |
| artifact_evidence_dir empty | Return BLOCKED with MISSING_EVIDENCE_DIR |
| No SCs in evidence.yaml | Return BLOCKED — evidence.yaml must contain SC mappings |
| SC in evidence.yaml not found in spec | Record as FAIL with SC_NOT_IN_SPEC — do NOT BLOCK |
| Evidence artifact unreadable | Record as FAIL with UNREADABLE_EVIDENCE — do NOT BLOCK |
| Evidence type gap detected | Record as FAIL with EVIDENCE_TYPE_MISMATCH — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write verdict.yaml |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Upstream Artifacts → INVALID if skipped
- [ ] 3. Load Spec Content → INVALID if skipped
- [ ] 4. Build Evaluation Criteria → INVALID if skipped
- [ ] 5. Evaluate Each Criterion → INVALID if skipped
- [ ] 6. Verify Evidence Type Compliance → INVALID if skipped
- [ ] 7. Generate Per-Criterion Findings → INVALID if skipped
- [ ] 8. Write verdict.yaml → INVALID if skipped
- [ ] 9. Self-Consistency Gate → INVALID if skipped
- [ ] 9.5. Identify Behavioral SCs for Clean-Room Evaluation → INVALID if skipped
- [ ] 10. Return Frugal Result Contract → INVALID if skipped

## Cross-References

- `tasks/verification-audit-investigator.md` — Investigator role (produces evidence.yaml consumed by this task)
- `tasks/verification-audit-validator.md` — upstream reasoning role role (produces reasoning.yaml consumed by this task)
- `tasks/cross-validate.md` — Arbiter role (reads verdict.yaml produced by this task, writes judgment.yaml)
- `audit/SKILL.md` — DiMo Role Chain Dispatch (Investigator → upstream reasoning role → Evaluator → Arbiter)
- Read [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations and enforcement matrix
- Read [implementation-pipeline SKILL.md](skills/implementation-pipeline/SKILL.md) — Trigger Dispatch Table (dispatches verification-audit)
- Read [000-critical-rules.md](guidelines/000-critical-rules.md) — behavioral evidence mandate, hard failure discipline
- Read [065-verification-honesty.md](guidelines/065-verification-honesty.md) — live-source verification mandate, stale evidence prohibition

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
