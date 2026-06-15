# Task: check

## Purpose

Non-adversarial completeness check after RED/GREEN sub-agent returns. Verifies the deliverable against the spec's success criteria — checking existence, structural soundness, and criterion coverage. Runs once per handoff with no internal loop. Read-only: no remediation, no routing advice.

## Entry Criteria

- spec_local_dir received in task context (REQUIRED — local issue directories containing spec.md)
- artifact_evidence_dir received in task context (OPTIONAL — RED/GREEN sub-agent output directories)

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
spec_local_dir: <path> | [<path>, ...]     # REQUIRED — local issue directories
artifact_evidence_dir: <path> | [<path>, ...]  # OPTIONAL — behavioral evidence directories
```

### Routing Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Exit Criteria

- Completeness result returned (PASS/FAIL)
- Findings include evidence from live source inspection

## Input Contract

```yaml
spec_local_dir:
  - "<path to local issue directory>"
artifact_evidence_dir:
  - "<path to behavioral evidence directory>"
spec_success_criteria:
  - id: "SC-1"
    description: "<success criterion description>"
deliverable:
  paths: ["path/to/deliverable1", "path/to/deliverable2"]
  type: "file|PR|branch"
audit_readiness_criteria:
  - "deliverable exists and is non-empty"
  - "all spec SCs addressed"
  - "structure matches spec requirements"
```

## Output Contract

```yaml
status: DONE|BLOCKED
completeness_result: PASS|FAIL
findings:
  - id: "F-1"
    criterion: "SC-1"
    severity: "missing|partial|incorrect|present"
    evidence: "<tool-call artifact showing inspection result>"
    description: "<what was found>"
```

## Procedure

### Step 1: Verify Deliverable Existence

For each deliverable path in the input contract:

- [ ] 1. Use `glob` or `read` to verify the file/directory exists
- [ ] 2. If the deliverable is a PR or branch, verify via GitHub API
- [ ] 3. Record evidence of existence (file listing, API response)

### Step 2: Verify Spec SC Coverage

For each success criterion in the input:

- [ ] 1. Read `spec_local_dir` for the spec's success criteria definitions
- [ ] 2. Read the deliverable content relevant to the criterion
- [ ] 3. Inspect whether the criterion is addressed:
   - **present**: Deliverable includes content addressing this SC
   - **partial**: Some aspects covered, some missing
   - **missing**: No content found addressing this SC
   - **incorrect**: Content exists but does not match the SC requirement
- [ ] 3. Record evidence for each finding (code snippet, file path, line range)

### Step 3: Classify Completeness

Based on findings from Step 2:

- **PASS**: All SCs classified as `present`
- **FAIL**: Any SC classified as `missing`, `partial`, or `incorrect`


### Step 4: Return Result Contract

Return the structured output contract with completeness result and findings.

**Do NOT** include remediation suggestions, routing advice, or fix proposals. The gate is read-only.

## Behavioral Uplift in Non-Adversatorial Check

When running completeness checks, uplift SC evidence types to `behavioral` for changes that affect runtime behavior. The classification question ("Does this change affect runtime behavior?") is substrate-determined. If YES, structural evidence is `EVIDENCE_TYPE_MISMATCH` — per `guidelines/000-critical-rules.md` §critical-rules-BEH-EV.

## Single-Pass Enforcement

This is a single-pass gate. Do NOT loop back to re-check after findings. Each handoff from orchestrator to gate produces exactly one check run. If the orchestrator re-tasks the gate after remediation, that is a new handoff — not a loop within the gate.

## Non-Adversarial Boundary

This gate does NOT replace the adversarial auditor. It checks completeness — presence and coverage against SCs. Correctness depth, cross-validation, and model-family independence remain the adversarial auditor's domain.

```yaml+symbolic
  - id: completeness-gate-check-001
    title: "Single pass — no internal loop"
    conditions:
      all:
        - "completeness_check_completed == true"
        - "gate_invoked_again_within_same_handoff == true"
    actions:
      - HALT
      - RETURN(status=BLOCKED, reason="single-pass enforcement")
    conflicts_with: [completeness-gate-001]
    requires: []
    triggers: [implementation-pipeline]
    source: "completeness-gate/tasks/check.md §Single-Pass Enforcement"

  - id: completeness-gate-check-002
    title: "Read-only gate — no remediation or routing advice in findings"
    conditions:
      any:
        - "finding_contains == 'remediation_code'"
        - "finding_contains == 'routing_direction'"
    actions:
      - HALT
      - RETURN(status=BLOCKED, reason="prohibited content in completeness findings")
    conflicts_with: [completeness-gate-002]
    requires: []
    triggers: [implementation-pipeline]
    source: "completeness-gate/tasks/check.md §Non-Adversarial Boundary"
```
