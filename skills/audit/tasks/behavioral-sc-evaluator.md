---
name: behavioral-sc-evaluator
description: "Clean-room evaluator for behavioral SCs. Receives ONLY artifact directory path. Reads stdout.log/stderr.log from behavioral test output. Renders binary PASS/FAIL per SC. File-existence alone returns FAIL."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: behavioral-sc-evaluator

## Purpose

Clean-room evaluator for behavioral success criteria. Receives ONLY an artifact directory path containing behavioral test output (stdout.log, stderr.log, session.yaml, timeline.yaml). Reads the raw artifacts and renders a binary PASS/FAIL verdict per SC. File-existence alone is FAIL — the evaluator MUST read and judge the actual agent output.

## Entry Criteria

- `artifact_evidence_dir` provided — directory containing behavioral test output files
- `spec_local_dir` provided — directory containing spec files with SC definitions
- No orchestrator context, no expected outcomes, no cached results

## Procedure

### Step 1: Pre-Flight Validation

- [ ] 1. Verify `artifact_evidence_dir` is present and non-empty
- [ ] 2. If missing or empty, return BLOCKED with `MISSING_EVIDENCE_DIR`
- [ ] 3. Verify `spec_local_dir` is present and non-empty
- [ ] 4. If missing or empty, return BLOCKED with `MISSING_SPEC_DIR`

### Step 2: Load Spec SCs

- [ ] 1. Read spec files from `spec_local_dir`
- [ ] 2. Extract all SCs with their IDs, descriptions, and evidence types
- [ ] 3. Filter to behavioral SCs only

### Step 3: Read Behavioral Test Artifacts

- [ ] 1. Read `stdout.log` from `artifact_evidence_dir` — full agent output
- [ ] 2. Read `stderr.log` from `artifact_evidence_dir` — tool dispatch trace
- [ ] 3. Read `session.yaml` or `timeline.yaml` if present — structured session data
- [ ] 4. If no behavioral test artifacts exist, return FAIL for all SCs with `NO_ARTIFACTS`

### Step 4: Evaluate Each Behavioral SC

For each behavioral SC:

- [ ] 1. Read the SC criterion from the spec
- [ ] 2. Evaluate the agent's actual output (stdout + stderr) against the criterion
- [ ] 3. Does the agent's tool dispatch trace show the required behavior?
- [ ] 4. Does the agent's output satisfy the criterion?
- [ ] 5. Render PASS if the agent's behavior satisfies the criterion
- [ ] 6. Render FAIL if the agent's behavior does NOT satisfy the criterion
- [ ] 7. File-existence alone (artifacts exist but not read) → FAIL

### Step 5: Write verdict.yaml

Write `verdict.yaml` to `{artifact_evidence_dir}/verdict.yaml`:

```yaml
evaluator: behavioral-sc-evaluator
artifact_evidence_dir: "<path>"
spec_local_dir: "<path>"
per_sc:
  - sc_id: "SC-N"
    result: PASS|FAIL
    evidence: "<reference to specific artifact content>"
    explanation: "<reasoning based on actual agent output>"
summary:
  total: <N>
  pass: <N>
  fail: <N>
  all_pass: true|false
```

## Exit Criteria

- `verdict.yaml` written with per-SC binary PASS/FAIL verdicts
- Each verdict backed by evidence from actual artifact content (not file-existence)
- No orchestrator context, expected outcomes, or cached results used

## Cross-References

- Dispatched by: `*-evaluator.md` tasks for behavioral SC evaluation
- Consumed by: `cross-validate.md` for EVIDENCE_TYPE_MISMATCH detection
