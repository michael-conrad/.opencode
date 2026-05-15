<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection

## Purpose

Detect drift between spec/code reality and expected state. Identifies cases where implementation diverged from spec, or spec outpaced implementation, using dual-adversarial verification.

## Entry Criteria

- Target file(s) specified OR full codebase scan requested
- Spec issue number provided
- `audit_phase: implementation_verification`
- `github.owner`, `github.repo` available

## Exit Criteria

- All target files compared against spec
- Drift classified as SPEC_DRIFT, CODE_DRIFT, or SYNC
- PASS if synchronized, FAIL if significant drift
- Bidirectional findings presented

## Procedure

### Step 1: Load Spec Requirements

Fetch spec issue and extract requirements:
```python
spec = github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>)
requirements = extract_requirements(spec["body"])
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

### Step 6: Cross-Validate via task()

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

evidence_payload:
---
SPEC REQUIREMENTS:
{requirements_summary}

IMPLEMENTATION SCAN:
{implementation_summary}

DRIFT DETECTED:
{drift_summary}

evaluation_criteria: <criteria_json>
audit_phase: implementation_verification
authorization_scope: {authorization_scope}
halt_at: {halt_at}
pr_strategy: {pr_strategy}
pipeline_phase: {pipeline_phase}

# NOTE: cross-validate does NOT dispatch auditors — it receives
# pre-resolved auditor_verdicts and computes consensus.
auditor_verdicts: {auditor_verdicts}

worktree.path: {worktree.path}
github.owner: {github.owner}
github.repo: {github.repo}
"""
)
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

### Step 9: Build Result Contract

```json
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
  "overall_consensus": "PASS | FAIL",
  "exec_summary": "Drift detection: {spec_drift} spec drift, {code_drift} code drift. Consensus: {overall}."
}
```

## Error Handling

| Error | Action |
|-------|--------|
| Spec issue not found | Return BLOCKED with issue number |
| No target files identified | Return BLOCKED — need file paths |
| Code not parseable | Skip function, log warning |

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_verdicts`

This task MUST NOT be read and executed inline. Reading this file and performing the described steps via raw tool calls is a CRITICAL VIOLATION per critical-rules-048.

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 1 (Load Spec Requirements) → INVALID if skipped
- Step 2 (Identify Target Files) → INVALID if skipped
- Step 3 (Build Evaluation Criteria) → INVALID if skipped
- Step 4 (Scan Implementation) → INVALID if skipped
- Step 5 (Check Untracked Files) → INVALID if skipped
- Step 6 (Cross-Validate) → INVALID if skipped
- Step 7 (Classify Drift Severity) → INVALID if skipped
- Step 8 (Generate Bidirectional Findings) → INVALID if skipped
- Step 9 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After drift-detection completes:
- If consensus PASS: proceed to concern-separation or next pipeline step
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

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