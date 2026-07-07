<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: cross-validate

## Purpose

Single-verdict sanity check on audit YAML artifacts. With single-agent dispatch (no dual-auditor cross-validation), this task reads the single verdict YAML from disk and performs a self-consistency check. Cross-validation of one agent against itself is not meaningful, so this task is a structural integrity check rather than a consensus computation.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path to directory containing the auditor YAML verdict artifact on disk

## Cross-Validate Checklist

- [ ] 1. Load Spec + extract SCs from spec_local_dir
- [ ] 2. Pre-Inspection Classification Gate — runtime-behavioral uplift check for each SC
- [ ] 3. Load the single auditor verdict artifact (artifact_evidence_dir)
- [ ] 4. Per-SC self-consistency check: does the verdict match the evidence?
- [ ] 5. Evidence Type Matrix enforcement — downgrade PASS with EVIDENCE_TYPE_MISMATCH to FAIL
- [ ] 6. Write unified verdict artifact to disk
- [ ] 7. Return frugal contract with verdict summary

### Step 0: Load Spec

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.

```python
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
spec_scs = []
spec_evidence_types = {}
for f in spec_files:
    content = read(filePath=f)
    extract_success_criteria(content, spec_scs)
    extract_evidence_types(content, spec_evidence_types)
```

Use the loaded spec SCs as the sole authoritative baseline for evidence type checks.

## Pre-Inspection Classification Gate (MANDATORY)

**Before evaluating any evidence, the auditor MUST classify each SC by asking: "Does this change affect runtime behavior? YES/NO."**

### Classification Question

For each success criterion in the audit scope:

- [ ] 1. Read the implementation diff for the files the SC covers
- [ ] 2. Ask: "Does this change affect runtime behavior?" — this is a substrate-determined question, not intent-determined
- [ ] 3. If YES → the SC's evidence type is UPLIFTED to `behavioral` regardless of how it was declared
- [ ] 4. If NO → the declared type stands

### What Affects Runtime Behavior

| Change Type | Affects Runtime Behavior? | Classification |
|-------------|---------------------------|----------------|
| Function logic changes | YES | Uplift to behavioral |
| Control flow changes | YES | Uplift to behavioral |
| API endpoint changes | YES | Uplift to behavioral |
| New code paths | YES | Uplift to behavioral |
| Config-only changes (no runtime effect) | NO | Declared type stands |
| Documentation-only changes | NO | Declared type stands |
| Style/formatting changes | NO | Declared type stands |
| Data schema changes with runtime effects | YES | Uplift to behavioral |

### Uplift Protocol

When an SC is uplifted:
- [ ] 1. Record the uplift in the audit report: `SC-N: uplifted from [declared_type] to behavioral (change affects runtime behavior: [reason])`
- [ ] 2. Evaluate ALL evidence against the `behavioral` tier
- [ ] 3. Structural or string evidence for an uplifted SC is classified as `EVIDENCE_TYPE_MISMATCH` with a FAIL verdict
- [ ] 4. The uplift is MANDATORY — no opt-out, no "close enough" exception

**🚫 FORBIDDEN:** Accepting structural evidence for an uplifted SC. The uplift is automatic and non-negotiable.

**Authority:** `guidelines/000-critical-rules.md` §critical-rules-BEH-EV, `guidelines/080-code-standards.md` §Evidence Type Taxonomy

## Exit Criteria

- Self-consistency check result array `[{ criterion_id, result, evidence, explanation }]` returned
- Each criterion has a definitive `PASS` or `FAIL` verdict
- Aggregate `overall_verdict`: `PASS` iff ALL criteria have `PASS`
- No fabricated verdicts — missing or unparseable auditor output is treated as `FAIL`
- Result contract includes `next_step` field: `"remediate then re-audit"` for FAIL, next pipeline continuation for PASS

## Non-Recovery Gates

The following states are **terminal BLOCKED states** with no fallback or recovery paths. When encountered, cross-validate MUST return `status: BLOCKED` immediately — no re-task, no retry, no workaround.

| Gate | Condition | Error Code | Action |
|------|-----------|------------|--------|
| MISSING_INPUT | `spec_local_dir` missing or empty, or no .md files readable | `MISSING_INPUT` | Return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }` |
| MISSING_EVIDENCE_DIR | `artifact_evidence_dir` missing, null, or empty | `MISSING_EVIDENCE_DIR` | Return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }` |
| ARTIFACT_UNREADABLE | Auditor YAML artifact file cannot be read or parsed | `ARTIFACT_UNREADABLE` | Return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }` |

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/cross-validate/`

### Step 0a: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with cross-validation:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for cross-validate. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 3. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for cross-validate. The orchestrator must provide a directory containing the auditor YAML verdict artifact."
```

### Step 1: Validate Input

Confirm `spec_local_dir` is present and non-empty. Glob `**/*.md` in `<spec_local_dir>/`, read all discovered files via `read` tool. If `spec_local_dir` is missing, empty, or no .md files can be read: return `{ status: "BLOCKED", error: "MISSING_INPUT", missing: "<field>" }`.

### Step 2: Validate Evidence Directory

Confirm `artifact_evidence_dir` is present, non-null, and non-empty. The sub-agent reads the auditor YAML verdict artifact from files discovered in the evidence directory via `glob`/`read`. The discovered YAML file MUST contain `{ criterion_id, result, evidence, explanation, remediation, next_step }`.

- If `artifact_evidence_dir` is missing or null: return `{ status: "BLOCKED", error: "MISSING_EVIDENCE_DIR" }`.
- If artifact file cannot be read: return `{ status: "BLOCKED", error: "ARTIFACT_UNREADABLE" }`.

### Step 3: Read and Parse Auditor Verdict from Disk

For each YAML file discovered via glob/read in `artifact_evidence_dir`, read the verdict file from disk using the `read` tool. Expected format per verdict file:

```
---
criterion_id: "SC-1"
result: "PASS"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: ""
next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
all_criteria_pass: false
---
---
criterion_id: "SC-2"
result: "FAIL"
evidence: "<tool-call reference>"
explanation: "<reasoning>"
remediation: "Add missing validation for X"
next_step: "re-evaluate"
---
```

Validation rules per verdict:
- `criterion_id` MUST match a criterion id from `evaluation_criteria`
- `result` MUST be: `PASS` or `FAIL`. These are the only valid verdicts.
- `evidence` MUST reference a live tool call (URL, file path, or command output) — memory-cached claims are FORBIDDEN
- `explanation` MUST be present and non-empty
- `remediation` MUST be present when result is not PASS
- `next_step` MUST be one of: `proceed`, `re-evaluate`, `escalate`

If the YAML artifact is unparseable, missing the expected fields, or contains no recognizable criterion ids: treat the entire contribution as `FAIL` for ALL criteria.

If the YAML artifact has extra criterion ids not in `evaluation_criteria`: ignore extra verdicts, flag in result contract as `EXTRA_VERDICTS` warning.

If the YAML artifact is missing a criterion id from `evaluation_criteria`: treat that criterion as `FAIL` with explanation `"MISSING_VERDICT"`.

### Step 4: Self-Consistency Check

For each criterion, verify the verdict is self-consistent:

| Check | Rule |
|---|---|
| PASS + critique language | If `result: "PASS"` while `explanation` contains finding/fix language ("should be", "needs", "missing", "could improve"), downgrade to FAIL |
| PASS + hedging evidence | If evidence contains "mostly", "generally", "largely", "essentially", downgrade to FAIL |
| Evidence-verdict alignment | If `result: "PASS"` but evidence references "minor concerns", "some issues", downgrade to FAIL |

### Step 5: Evidence Type Matrix Enforcement

For each criterion, verify the evidence type matches the declared type per the minimum acceptable method:

| Declared Type | Minimum Method | FAIL If |
|--------------|----------------|---------|
| behavioral | Test execution with output inspection | grep/read/file-exists used instead |
| semantic | Sub-agent read + analytical judgment | grep/string matching used instead |
| string | grep/pattern matching | file-existence used instead |
| structural | file existence | N/A |

If evidence type mismatch detected, downgrade the criterion to FAIL with `EVIDENCE_TYPE_MISMATCH` classification.

### Step 6: Compute Aggregate Verdict

`overall_verdict = PASS` iff `result == PASS` for ALL criteria. Any single `FAIL` cascades to `overall_verdict = FAIL`.

### Step 7: Write Findings YAML to Disk

Write the full cross-validate findings YAML to `{project_root}/tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml`:

```yaml
phase: cross-validate
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
summary:
  overall_verdict: PASS|FAIL
  next_step: "proceed|remediate then re-audit"
  total_criteria: N
  evidence_type_mismatches: N
findings:
  - criterion_id: "SC-1"
    declared_evidence_type: "structural|string|semantic|behavioral"
    result: PASS
    evidence_type_mismatch: false
warnings: []
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

### Step 8: Write judgment.yaml

Write final judgment to `./tmp/{issue-N}/artifacts/cross-validate/judgment.yaml`

## Remediation

If any step FAILs, restart from step 0 (pre-clean).

### Step 9: Return Frugal YAML Result Contract

Return ONLY this YAML as the final response — no preamble, no commentary, no markdown fences:

```yaml
status: DONE
overall_verdict: PASS|FAIL
next_step: "proceed|remediate then re-audit"
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-cross-validate-{STATUS}-{timestamp}.yaml"
summary: "N SCs: X pass, Y fail, Z evidence_type_mismatch"
all_criteria_pass: false
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

The `next_step` field:
- `overall_verdict == PASS` → `next_step: "proceed"` (next pipeline continuation)
- `overall_verdict == FAIL` → `next_step: "remediate then re-audit"` (orchestrator routes to recovery)

## Context Required

- `spec_local_dir`: Local directory containing Markdown spec files
- `artifact_evidence_dir`: Path to directory containing the auditor YAML verdict artifact
- `audit_type`: Current audit type for task context

## Red Flags

- Never task() auditors from within cross-validate — the orchestrator dispatches auditors, cross-validate discovers artifacts via evidence dir
- Never leak orchestrator reasoning into verdict parsing — clean-room means evidence + criteria ONLY
- Never fabricate verdicts when YAML artifact is unreadable or unparseable — missing data = FAIL
- Never accept memory-cached claims as evidence — every verdict must reference a live tool call
- Never pass YAML verdict content inline through orchestrator context — verdict artifacts stay on disk; only artifact_path reaches orchestrator

## Cross-References

- `audit/SKILL.md` — skill-level operating protocol and enforcement rules
- `audit/tasks/completion.md` — halt guarantee
- `065-verification-honesty.md` — live-source verification mandate, stale evidence prohibition
- `000-critical-rules.md` — clean-room task() protocol, orchestrator purity

## Sub-Agent Routing

### Task Rules

| Scope of Context | Exclusions | Pre-Analysis Contract | Includes Inline Work? |
|---|---|---|---|
| `spec_local_dir`, `artifact_evidence_dir`, `audit_type` | Implementation context, agent memory, orchestrator reasoning, prior verification, spec_body, evaluation_criteria, verdict content | N/A — cross-validate discovers artifacts via evidence dir | NO |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-07-07T00:00:00Z"
rules:
  - id: cross-validate-001
    title: "Input validation — spec_local_dir and artifact_evidence_dir must be non-empty"
    conditions:
      all: ["spec_local_dir_present == false OR artifact_evidence_dir_present == false"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_INPUT]
    source: "cross-validate.md §Step 1"

  - id: cross-validate-002
    title: "Evidence directory must be provided — cross-validate discovers artifacts via glob/read"
    conditions:
      all: ["artifact_evidence_dir == null OR artifact_evidence_dir_empty == true"]
    actions: [RETURN_BLOCKED, REPORT_MISSING_EVIDENCE_DIR]
    source: "cross-validate.md §Step 2"

  - id: cross-validate-003
    title: "Clean-room verdict parsing — orchestrator reasoning must not influence cross-validation"
    conditions:
      any: ["cross_validate_context contains 'expected_result' OR 'orchestrator_reasoning' OR 'should_find'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-004
    title: "Unparseable auditor output = FAIL for all criteria"
    conditions:
      all: ["auditor_verdict_parseable == false"]
    actions: [ASSIGN_FAIL_ALL]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-005
    title: "Missing criterion verdict = FAIL for that criterion"
    conditions:
      all: ["criterion_id not in auditor_verdict_ids"]
    actions: [ASSIGN_FAIL_PER_CRITERION, SET_EXPLANATION("MISSING_VERDICT")]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-006
    title: "Aggregate verdict cascades — single criterion FAIL = overall FAIL"
    conditions:
      any: ["any_criterion_result == 'FAIL'"]
      all: ["overall_verdict_reported_as == 'PASS'"]
    actions: [REJECT, DECLARE_OVERALL_FAIL]
    source: "cross-validate.md §Step 6"

  - id: cross-validate-007
    title: "Evidence must reference live tool call — memory-cached claims rejected"
    conditions:
      all: ["auditor_evidence matches 'from memory' OR 'as I recall' OR 'training data' OR missing_tool_call_reference"]
    actions: [REJECT_EVIDENCE, ASSIGN_FAIL]
    source: "cross-validate.md §Step 3"

  - id: cross-validate-008
    title: "Result contract must include next_step field"
    conditions:
      all: ["result_contract_next_step == null"]
    actions: [APPEND_NEXT_STEP]
    source: "cross-validate.md §Step 9"

  - id: cross-validate-009
    title: "next_step MUST be 'remediate' when result is 'FAIL', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_criterion[].result == 'FAIL' AND per_criterion[].next_step != 'remediate'"
        - "per_criterion[].result == 'PASS' AND per_criterion[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "cross-validate.md §Step 4 — conditional next_step enforcement"

  - id: cross-validate-010
    title: "all_criteria_pass MUST be true when every criterion result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(criterion.result == 'PASS' for criterion in per_criterion) AND all_criteria_pass != true"
        - "any(criterion.result == 'FAIL' for criterion in per_criterion) AND all_criteria_pass != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CRITERIA_PASS]
    source: "cross-validate.md §Step 4 — all_criteria_pass enforcement"
```
