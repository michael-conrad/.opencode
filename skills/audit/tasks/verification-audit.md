<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-audit

## Purpose

Verify implementation against spec success criteria. Each SC is evaluated against live behavioral evidence. Unlike spec-audit (which reviews spec quality), verification-audit confirms the implemented code satisfies the spec's declared acceptance criteria.

> **DiMo Role: Evaluator.** This task evaluates implementation against spec SCs. Reads `evidence.yaml` (Generator), validates evidence → writes `reasoning.yaml`, evaluates → writes `verdict.yaml`.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) all criteria evaluated against evidence.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `artifact_evidence_dir` — REQUIRED. MUST be present and non-empty. Behavioral evidence artifacts from the implementation run MUST exist for all behavioral SCs. If absent: return BLOCKED with MISSING_EVIDENCE_DIR. If present but directory not found: return BLOCKED with EVIDENCE_NOT_FOUND.
- `spec_issue_number` provided
- `github.owner`, `github.repo` available

## Exit Criteria

- All SCs evaluated against behavioral evidence
- Implementation completeness assessed — does the code satisfy the spec?
- Verdict artifact written to disk
- Consensus PASS/FAIL per SC

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/verification-audit/`

### Step 0a: Knowledge Supporter — Validate Evidence

- [ ] 0a. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/{task-name}/evidence.yaml`
- [ ] 0b. Validate each evidence item against source data — check accuracy, completeness, relevance
- [ ] 0c. Write validated evidence to `./tmp/{issue-N}/artifacts/{task-name}/reasoning.yaml`

### Step 0b: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. Verify `artifact_evidence_dir` is present and non-empty — if empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit. The orchestrator must provide a directory containing upstream YAML verdict artifacts."
```

- [ ] 3. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for verification-audit. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 4. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit. The orchestrator must provide a directory containing auditor YAML verdict artifacts."
```

## Verification Audit Checklist

- [ ] 1. Load Spec Content — glob spec_local_dir, read spec SCs and evidence type declarations
- [ ] 2. Load Behavioral Evidence — read artifact_evidence_dir for per-SC evidence files
- [ ] 3. Build Evaluation Criteria — map spec SCs to evidence artifacts
- [ ] 4. Verify Implementation Completeness — does implemented code satisfy each SC?
- [ ] 5. Verify Evidence Type Compliance — each SC verified using minimum acceptable method per declared type
- [ ] 6. Generate Findings — per-SC PASS/FAIL with evidence references
- [ ] 7. Write verdict.yaml — write verdict to `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml`
- [ ] 8. Dispatch Judger → reads all artifacts, writes `judgment.yaml`
- [ ] 10. Return Frugal Result Contract

### Step 1: Load Spec Content

Read spec from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract SC table with evidence type declarations
- [ ] 3. Identify behavioral SCs requiring execution evidence

### Step 2: Load Behavioral Evidence

`artifact_evidence_dir` is REQUIRED and MUST be non-empty. If absent during verification phase, return BLOCKED immediately:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
reason: "Verification audit requires behavioral evidence artifacts. artifact_evidence_dir is required."
```

If present, glob and read evidence artifacts. Each behavioral SC MUST have at least one corresponding evidence artifact. If evidence is missing for any behavioral SC, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE
missing: "<SC-ID>"
evidence_path: "<artifact_evidence_dir>"
reason: "Behavioral SC requires evidence artifact. Evidence not found for this SC."
```

### Step 3: Build Evaluation Criteria

Map spec SCs to evidence artifacts. For each SC:

| Criterion ID | Description | Evidence Source | Expected Result |
|-------------|-------------|-----------------|-----------------|
| SC-1 through SC-N | Per spec SC declaration | Behavioral evidence artifact + codebase inspection | PASS if satisfied |
| SC-EVIDENCE-TYPE | Evidence type matches declared type | Evidence artifacts | PASS if evidence methods match SC declaration |
| SC-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SCs | Evidence artifacts | PASS if behavioral SCs have behavioral evidence |
| SC-COMPLETENESS | All spec SCs addressed | Codebase + evidence artifacts | PASS if no SC left unverified |

### Step 4: Verify Implementation Completeness

For each SC in the spec, verify the implemented code against the SC criterion:

- Structural SC: file exists with expected content (glob + read)
- String SC: grep for expected pattern
- Semantic SC: sub-agent read + analytical judgment of implementation
- Behavioral SC: execution evidence artifact confirms correct behavior

Record PASS/FAIL per SC with tool-call evidence.

### Step 6: Verify Evidence Type Compliance

For each SC, verify that the evidence method matches the declared evidence type per the minimum acceptable method:

| Declared Type | Minimum Method | FAIL If |
|--------------|----------------|---------|
| behavioral | Test execution with output inspection | grep/read/file-exists used instead |
| semantic | Sub-agent read + analytical judgment | grep/string matching used instead |
| string | grep/pattern matching | file-existence used instead |
| structural | file existence | N/A |

### Step 7: Generate Findings

For each FAIL criterion, produce a finding with evidence reference:

```yaml
- criterion_id: "SC-N"
  declared_evidence_type: "behavioral"
  result: "FAIL"
  evidence: "<tool-call reference to evidence artifact>"
  explanation: "Implementation does not satisfy SC criterion. Expected: <expected>. Found: <actual>."
  remediation: "Update implementation to satisfy: <specific remediation>"
  next_step: "remediate"
```

### Step 7: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/verification-audit/verdict.yaml`

### Step 8: Write Verdict Artifact to Disk (Legacy — kept for backward compatibility)

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-verification-audit-{STATUS}-{timestamp}.yaml`:

```yaml
auditor_type: verification-audit
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
summary:
  total_criteria: N
  pass: N
  fail: N
per_criterion:
  - criterion_id: "SC-N"
    declared_evidence_type: "behavioral"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
all_criteria_pass: false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

### Step 11: Return Frugal Result Contract

## Remediation


```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-verification-audit-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 1. Load spec content → INVALID if skipped
- [ ] 2. Load behavioral evidence → INVALID if skipped
- [ ] 3. Build evaluation criteria → INVALID if skipped
- [ ] 4. Cross-validate with verdicts → INVALID if skipped
- [ ] 5. Verify implementation completeness → INVALID if skipped
- [ ] 6. Verify evidence type compliance → INVALID if skipped
- [ ] 7. Generate findings → INVALID if skipped
- [ ] 8. Build result contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| artifact_evidence_dir absent | Return BLOCKED with MISSING_EVIDENCE_DIR |
| artifact_evidence_dir empty | Return BLOCKED with MISSING_EVIDENCE |
| Behavioral SC missing evidence | Return BLOCKED with per-SC MISSING_EVIDENCE |
| Cross-validate fails | Return OVERFLOW, log error |
| Auditor unavailable | Use fallback chain per multimodal-dispatch |

## Cross-References

- `tasks/spec-audit.md` — spec-phase audit (pre-implementation)
- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `080-code-standards.md` §Evidence Type Taxonomy — evidence type declarations and enforcement matrix
- `implementation-pipeline/SKILL.md` — Trigger Dispatch Table (dispatches verification-audit)
- `000-critical-rules.md` — behavioral evidence mandate

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-06-01T00:00:00Z"
rules:
  - id: verification-audit-001
    title: "Behavioral evidence required — BLOCK on absent artifact_evidence_dir"
    conditions:
      all: ["artifact_evidence_dir_absent == true"]
    actions: [BLOCKED(MISSING_EVIDENCE_DIR)]
    source: "verification-audit.md §Step 2"

  - id: verification-audit-002
    title: "Per-SC evidence must exist for behavioral SCs"
    conditions:
      all: ["behavioral_sc_evidence_missing == true"]
    actions: [BLOCKED(MISSING_EVIDENCE)]
    source: "verification-audit.md §Step 2"

  - id: verification-audit-003
    title: "Dual auditors required — no single-auditor evaluation"
    conditions:
      all: ["auditor_count < 2"]
    actions: [HALT, RESOLVE_SECOND_AUDITOR]
    source: "verification-audit.md §Step 4"

  - id: verification-audit-004
    title: "Clean-room task() — no orchestrator reasoning leaked to auditors"
    conditions:
      all: ["auditor_context contains 'expected' OR 'should' OR 'correct'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "verification-audit.md §Step 4"

  - id: verification-audit-005
    title: "next_step MUST be 'remediate' when result is 'FAIL', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_criterion[].result == 'FAIL' AND per_criterion[].next_step != 'remediate'"
        - "per_criterion[].result == 'PASS' AND per_criterion[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "verification-audit.md §Step 8 — conditional next_step enforcement"

  - id: verification-audit-006
    title: "all_criteria_pass MUST be true when every criterion result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(criterion.result == 'PASS' for criterion in per_criterion) AND all_criteria_pass != true"
        - "any(criterion.result == 'FAIL' for criterion in per_criterion) AND all_criteria_pass != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CRITERIA_PASS]
    source: "verification-audit.md §Step 8 — all_criteria_pass enforcement"
```
