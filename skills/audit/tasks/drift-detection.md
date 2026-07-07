<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection

## Purpose

Detect drift between spec/code reality and expected state. Identifies cases where implementation diverged from spec, or spec outpaced implementation, using independent verification.

> **DiMo Role: Evaluator.** This task evaluates drift between spec and code. Reads `evidence.yaml` (Generator), validates evidence → writes `reasoning.yaml`, evaluates → writes `verdict.yaml`.
>
> **Role Identity:** You are the Evaluator. You own the PASS/FAIL verdict for each criterion.
>
> **You own:** Per-criterion PASS/FAIL verdicts. **You do NOT own:** Final judgment, next_step decisions, evidence validation.
>
> **Rules:**
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns"
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-evaluate evidence that Knowledge Supporter already validated
> - MUST write `verdict.yaml` as the primary output artifact
>
> **Success:** Every criterion has a definitive PASS or FAIL. No caveats, no deferred decisions, no re-validation.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- Target file(s) specified OR full codebase scan requested
- Spec issue number provided
- `github.owner`, `github.repo` available

## Exit Criteria

- All target files compared against spec
- Drift classified as SPEC_DRIFT, CODE_DRIFT, or SYNC
- PASS if synchronized, FAIL if significant drift
- Bidirectional findings presented

## Procedure

## Drift Detection Checklist

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/drift-detection/`
- [ ] 1. Pre-Flight Validation Gate — validate required inputs before proceeding
- [ ] 2. Load Spec Requirements — glob spec_local_dir, extract problem, SCs, phases, files
- [ ] 3. Identify Target Files — specific files or full scan from spec
- [ ] 4. Build Evaluation Criteria — define DD table with evidence types
- [ ] 5. Scan Implementation — per-file existence, signatures, extra code
- [ ] 6. Check Untracked Files — code files not in spec
- [ ] 7. Classify Drift Severity — map drift to HIGH/MEDIUM/LOW
- [ ] 8. Generate Bidirectional Findings — SPEC_DRIFT/CODE_DRIFT with revision options
- [ ] 9. Write verdict.yaml — write verdict to `./tmp/{issue-N}/artifacts/drift-detection/verdict.yaml`
- [ ] 10. Build Result Contract — YAML verdict with drift summary

### Step 0a: Knowledge Supporter — Validate Evidence

- [ ] 0a. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/{task-name}/evidence.yaml`
- [ ] 0b. Validate each evidence item against source data — check accuracy, completeness, relevance
- [ ] 0c. Write validated evidence to `./tmp/{issue-N}/artifacts/{task-name}/reasoning.yaml`

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for drift-detection. The orchestrator must provide a valid local directory containing spec Markdown files."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Load Spec Requirements

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.
```python
spec_content = ""
for f in glob(pattern="**/*.md", path=f"<spec_local_dir>"):
    spec_content += read(filePath=f) + "\n"
requirements = extract_requirements(spec_content)
```

Requirements extraction:
- Problem Statement
- Success Criteria
- Phase Requirements
- File Requirements

### Step 2: Identify Target Files

If specific files provided:
```python
target_files = [f for f in args.files if exists(f)]
```

If full scan:
```python
# Extract file paths from spec
target_files = extract_file_paths_from_spec(spec["body"])
```

### Step 3: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| DD-1 | All spec files implemented | Each file exists |
| DD-2 | Implementation matches spec | Behavior aligns |
| DD-3 | No extra implementation | No untracked files |
| DD-4 | Function signatures match | Spec API matches code API |
| DD-5 | Edge cases covered | All edge cases implemented |
| DD-STRUCTURAL-FAIL | Structural evidence rejected for behavioral SC drift | If drift evidence reports SC as PASS using structural-only evidence (grep/read/file-exists) when the SC describes behavior, return FAIL with `STRUCTURAL_EVIDENCE` classification. Structural checks do NOT verify behavioral correctness — they only verify existence. |

### Step 4: Scan Implementation

For each file:

```python
for file in target_files:
    # Check file exists
    if not exists(file):
        drift.append({
            "type": "SPEC_DRIFT",
            "file": file,
            "reason": "Spec requires file, but file not implemented"
        })
        continue
    
    # Read implementation
    code = read(file)
    
    # Check function signatures
    spec_funcs = extract_spec_functions(spec["body"], file)
    code_funcs = extract_code_functions(code)
    
    for spec_func in spec_funcs:
        if spec_func["name"] not in code_funcs:
            drift.append({
                "type": "SPEC_DRIFT",
                "file": file,
                "function": spec_func["name"],
                "reason": "Spec function missing in code"
            })
        elif not signature_matches(spec_func, code_funcs[spec_func["name"]]):
            drift.append({
                "type": "SPEC_DRIFT",
                "file": file,
                "function": spec_func["name"],
                "reason": "Function signature mismatch"
            })
    
    # Check for extra implementation
    for code_func in code_funcs:
        if code_func not in spec_funcs:
            drift.append({
                "type": "CODE_DRIFT",
                "file": file,
                "function": code_func,
                "reason": "Code function not in spec"
            })
```

### Step 5: Check Untracked Files

```python
# Files implemented but not in spec
all_code_files = glob("src/**/*.py", recursive=True)
explicit_spec_files = [f for f in target_files if exists(f)]
untracked_files = [f for f in all_code_files if f not in explicit_spec_files]

for untracked in untracked_files:
    drift.append({
        "type": "CODE_DRIFT",
        "file": untracked,
        "reason": "Implementation not tracked in spec"
    })
```

### Step 7: Classify Drift Severity

| Drift Type | Severity | Classification |
|-----------|----------|----------------|
| SPEC_DRIFT | HIGH | Spec requires, code missing |
| CODE_DRIFT | MEDIUM | Code implements, spec unaware |
| SIGNATURE_MISMATCH | HIGH | API mismatch |
| UNTRACKED_FILE | LOW | May be utility/helper |
| MISSING_EDGE_CASE | MEDIUM | Edge case not implemented |

### Step 8: Generate Bidirectional Findings

For each drift:

| Direction | Description |
|-----------|-------------|
| SPEC_DRIFT | Update code to match spec |
| CODE_DRIFT | Update spec to document implementation |
| SYNC | No action needed |

Present options for developer decision.

### Step 9: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/drift-detection/verdict.yaml`

### Step 10: Build Result Contract

```yaml
{
  "status": "DONE",
  "audit_type": "drift-detection",
  "spec_issue": <N>,
  "files_scanned": <M>,
  "drift_summary": {
    "spec_drift_count": <count>,
    "code_drift_count": <count>,
    "sync_count": <count>
  },
  "drift_details": [
    {
      "type": "SPEC_DRIFT",
      "file": "<path>",
      "function": "<name>",
      "reason": "<description>",
      "severity": "HIGH",
      "bidirectional": {
        "direction": "spec→code",
        "revision_options": [...]
      }
    }
  ],
  "cross_validation": [...],
  "overall_verdict": "PASS | FAIL",
  "exec_summary": "Drift detection: {spec_drift} spec drift, {code_drift} code drift. Verdict: {overall}."
}
```

## Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-drift-detection-PASS-{timestamp}.yaml"
summary: "Drift detection: {spec_drift} spec drift, {code_drift} code drift. Verdict: {overall}."
all_criteria_pass: false
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

## Error Handling

| Error | Action |
|-------|--------|
| Spec issue not found | Return BLOCKED with issue number |
| No target files identified | Return BLOCKED — need file paths |
| Code not parseable | Skip function, log warning |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 0 (Pre-Flight Validation Gate) → INVALID if skipped
- Step 1 (Load Spec Requirements) → INVALID if skipped
- Step 2 (Identify Target Files) → INVALID if skipped
- Step 3 (Build Evaluation Criteria) → INVALID if skipped
- Step 4 (Scan Implementation) → INVALID if skipped
- Step 5 (Check Untracked Files) → INVALID if skipped
- Step 6 (Cross-Validate) → INVALID if skipped
- Step 7 (Classify Drift Severity) → INVALID if skipped
- Step 8 (Generate Bidirectional Findings) → INVALID if skipped
- Step 9 (Build Result Contract) → INVALID if skipped

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `verification-before-completion` skill — verification gate
- `srclight` tools — code analysis
- `000-critical-rules.md` — spec-code alignment

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: drift-detection-001
    title: "Spec drift must be reported before merge"
    conditions:
      all: ["spec_drift_count > 0", "merge_attempted == true"]
    actions: [HALT, REPORT_DRIFT]
    source: "drift-detection.md §Step 7"

  - id: drift-detection-002
    title: "Function signature mismatch is HIGH severity"
    conditions:
      all: ["signature_mismatch == true", "severity_reported != 'HIGH'"]
    actions: [CORRECT_SEVERITY]
    source: "drift-detection.md §Step 7"

  - id: drift-detection-003
    title: "Bidirectional findings require revision options"
    conditions:
      all: ["drift_found == true", "revision_options == null"]
    actions: [APPEND_DEFAULT_OPTIONS]
    source: "drift-detection.md §Step 8"
```