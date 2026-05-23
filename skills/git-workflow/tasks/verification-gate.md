<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-gate

## Purpose

Verification-gate IS the gate between verified completion and unverified advancement. No valid advancement exists without clean PASS. Verification artifacts that don't exist on disk produce fabrication — fabrication IS the most expensive defect, not a soft downgrade.

Every artifact that bypasses this gate carries undetected defects into production. Every `PASS_WITH_CAVEATS`, `INCONCLUSIVE`, `FUNCTIONALLY_EQUIVALENT`, or `MISSING_EVIDENCE` IS FAIL — not a soft-pass, not a downgrade, not an advisory note.

## Entry Criteria

- `verification-before-completion` task has completed with `status: DONE`
- OR `adversarial-audit` task has completed with `status: DONE` (for post-audit verification)
- VbC or audit YAML artifacts exist at expected paths (verified by this task)
- Behavioral evidence logs referenced by YAML artifacts exist on disk (verified by this task)

## EXIT Criteria — TWO Possible Outcomes

| Result | Meaning | Next Step |
|--------|---------|-----------|
| `DONE` with `overall_result: PASS` | All SCs PASS, evidence chain intact | Proceed to `review-prep` |
| `BLOCKED` with remediation instructions | Any non-PASS result or broken evidence chain | HALT; remediate; re-enter verification-gate |

There IS no `DONE` outcome without clean PASS. `BLOCKED` IS terminal — no fallback paths exist.

## Procedure

### Step 1: Locate and Read VbC YAML Artifact

Locate the verification-before-completion result YAML at:
```
./tmp/artifacts/verification-<phase>-<issue>.yaml
```

If no VbC YAML exists:
- **RULE:** Missing VbC artifact IS BLOCKED — there IS no valid state called "implemented but unverified."
- **EXCEPTION:** None.
- **FAILURE:** `BLOCKED: VbC artifact not found at ./tmp/artifacts/verification-<phase>-<issue>.yaml. Run verification-before-completion first.`
- **REMEDIATION:** Run `verification-before-completion --task verify` to produce the missing artifact.
- **PROCEED:** Only after VbC YAML artifact exists and has been read.

Read the YAML artifact. Parse all success criteria rows.

### Step 2: Locate and Read Audit Cross-Validation YAML Artifact (If Present)

If an adversarial audit has been run for this issue, locate the cross-validation result at:
```
./tmp/artifacts/audit-cross-validate-<issue>.yaml
```

If present, read and parse the audit result. If not present (audit hasn't been run yet), skip this step — the enforcement-gate task will handle audit verification separately.

### Step 3: Classify Every SC Result

For each success criterion row in the VbC YAML, classify the result:

| VbC Result | Verification-Gate Classification | Action |
|------------|----------------------------------|--------|
| `PASS` | PASS | Proceed to Step 4 |
| `PASS_WITH_CAVEATS` | **FAIL** | Record as FAIL |
| `INCONCLUSIVE` | **FAIL** | Record as FAIL |
| `FUNCTIONALLY_EQUIVALENT` | **FAIL** | Record as FAIL |
| `MISSING_EVIDENCE` | **FAIL** | Record as FAIL |
| `FAIL` | **FAIL** | Record as FAIL |
| Any other non-`PASS` string | **FAIL** | Record as FAIL |

**RULE:** Only the exact string `PASS` IS PASS. Everything else IS FAIL.
**EXCEPTION:** None. No soft-passes, no downgrades, no advisory notes.
**FAILURE:** Any non-`PASS` result produces `BLOCKED` with the specific SC IDs and their non-PASS classifications.
**REMEDIATION:** Fix the underlying verification failure. Re-run `verification-before-completion --task verify`. Re-enter verification-gate.
**PROCEED:** Only when ALL SC rows have `result: PASS`.

### Step 4: Verify Evidence Chain Integrity

For each SC row with `result: PASS`, the `evidence` field references a behavioral evidence artifact on disk:

```
./tmp/behavioral-evidence-SC-<N>.log
```

For each referenced evidence path:
1. Check the file exists on disk using `ls` or equivalent
2. Check the file is non-empty (size > 0)

**RULE:** Evidence referenced in VbC YAML that doesn't exist on disk IS fabrication. Fabrication IS the most expensive defect — it IS not a missing-field warning.
**EXCEPTION:** None. Missing evidence IS fabrication.
**FAILURE:** `BLOCKED: Evidence chain broken. SC-<N> references ./tmp/behavioral-evidence-SC-<N>.log which does not exist on disk. Referenced evidence that doesn't exist IS fabrication.`
**REMEDIATION:** Re-run the behavioral test for the affected SC. Ensure the evidence artifact is written to the correct path. Re-enter verification-gate.
**PROCEED:** Only when ALL referenced evidence artifacts exist and are non-empty.

### Step 5: Classify Audit Cross-Validation Result (If Present)

If an audit cross-validation YAML was found in Step 2, classify the result:

| Audit Result | Verification-Gate Classification | Action |
|--------------|----------------------------------|--------|
| `consensus: PASS` | PASS | Proceed to Step 6 |
| `consensus: DISAGREE` | **FAIL** | Record as FAIL |
| `consensus: FAIL` | **FAIL** | Record as FAIL |
| `auditor verdict: FAIL` | **FAIL** | Record as FAIL |
| `auditor verdict: INCONCLUSIVE` | **FAIL** | Record as FAIL |
| `consensus: PASS` with any `auditor_verdict: FAIL` | **FAIL** | Record as FAIL (cross-model consensus IS required) |

**RULE:** Audit verification requires `consensus: PASS` with ALL auditor verdicts being `PASS`. A single auditor `FAIL` or `INCONCLUSIVE` verdict IS a pipeline failure, regardless of consensus.
**EXCEPTION:** None. Audit cross-validation IS dual-model verification — single-model results do not count.
**FAILURE:** `BLOCKED: Audit cross-validation failed. consensus=<value>, auditor_1=<verdict>, auditor_2=<verdict>. Dual-model verification IS required — single-model results do not count.`
**REMEDIATION:** Address audit findings. Re-run adversarial-audit. Re-enter verification-gate.
**PROCEED:** Only when `consensus: PASS` and both auditor verdicts are `PASS`.

### Step 6: Produce Result Contract

If ALL steps produced PASS:

```yaml
issue: <issue_number>
phase: <phase_name>
verification_gate_result: DONE
overall_result: PASS
sc_classifications:
  - id: SC-1
    classification: PASS
  - id: SC-2
    classification: PASS
  # ... one row per SC
evidence_chain_integrity: VERIFIED
audit_cross_validation: <VERIFIED | NOT_PRESENT>
timestamp: <ISO 8601>
```

If ANY step produced FAIL:

```yaml
issue: <issue_number>
phase: <phase_name>
verification_gate_result: BLOCKED
overall_result: FAIL
failed_classifications:
  - id: SC-<N>
    vbc_result: <original_result>
    classification: FAIL
    reason: <one of: NON_PASS_RESULT, EVIDENCE_CHAIN_BROKEN, AUDIT_CROSS_VALIDATION_FAILED>
remediation:
  - <specific remediation steps for each failure>
timestamp: <ISO 8601>
```

**RULE:** The result contract IS the sole output of this task. No advisory text, no suggestions, no "PASS with concerns."
**EXCEPTION:** None.
**FAILURE:** Not applicable — the result contract IS the output.
**REMEDIATION:** Not applicable — this IS the output step.
**PROCEED:** Return the result contract. The orchestrator routes based on `overall_result`.

### Step 7: Route Based on Result

| `overall_result` | Route |
|------------------|-------|
| `PASS` | Proceed to `review-prep` |
| `FAIL` | HALT. Return BLOCKED result contract. Remediate failures. Re-enter verification-gate. |

**RULE:** There IS no bypass. There IS no "PASS with concerns." There IS no `INCONCLUSIVE`. There IS no `FUNCTIONALLY_EQUIVALENT`. There IS only `PASS` and `FAIL`.
**EXCEPTION:** None.
**FAILURE:** Any attempt to bypass this gate IS a process-integrity violation per `000-critical-rules.md` §critical-rules-hard-fail.
**REMEDIATION:** Fix the underlying failures. Re-run verification. Re-enter this gate.
**PROCEED:** Only on clean `PASS`.

## BLOCKED Result Contract Format

When verification-gate returns `BLOCKED`, the result contract MUST contain:

1. **`failed_classifications`** — list of every non-PASS SC with its original result and FAIL classification
2. **`remediation`** — specific steps for each failure (NOT generic "try again")
3. **`evidence_chain_status`** — `INTACT` or `BROKEN` with specific missing paths
4. **`audit_status`** — `PASS`, `FAIL`, or `NOT_PRESENT`

Example BLOCKED result:

```yaml
issue: 842
phase: phase1
verification_gate_result: BLOCKED
overall_result: FAIL
failed_classifications:
  - id: SC-2
    vbc_result: PASS_WITH_CAVEATS
    classification: FAIL
    reason: NON_PASS_RESULT
  - id: SC-21
    vbc_result: PASS
    classification: FAIL
    reason: EVIDENCE_CHAIN_BROKEN
    missing_path: ./tmp/behavioral-evidence-SC-3.log
remediation:
  - "SC-2: Re-run verification-before-completion for SC-2 with correct PASS classification. PASS_WITH_CAVEATS IS not a valid result."
  - "SC-21: Re-run behavioral test for SC-3 to produce evidence at ./tmp/behavioral-evidence-SC-3.log."
evidence_chain_status: BROKEN
broken_paths:
  - ./tmp/behavioral-evidence-SC-3.log
audit_cross_validation: NOT_PRESENT
timestamp: "2026-05-23T12:00:00Z"
```

## Cross-References

- `000-critical-rules.md` §critical-rules-hard-fail — FAIL IS a hard gate, never reclassifiable
- `065-verification-honesty.md` §Hard Failure Discipline — PASS means clean PASS
- `080-code-standards.md` §Evidence Type Taxonomy — behavioral evidence IS primary
- `020-go-prohibitions.md` §1 ALWAYS DO — Cost-blind verification, no soft-passing
- `verification-before-completion` skill — produces the YAML artifacts this task reads
- `adversarial-audit` skill — produces audit cross-validation YAML

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-23T00:00:00Z"
rules:
  - id: verification-gate-001
    title: "Only exact string PASS is PASS — all other results are FAIL"
    conditions:
      all:
        - "sc_result in ['PASS_WITH_CAVEATS', 'INCONCLUSIVE', 'FUNCTIONALLY_EQUIVALENT', 'MISSING_EVIDENCE', 'FAIL']"
    actions:
      - HALT
      - CLASSIFY_AS_FAIL
      - RECORD_REMEDIATION
    source: "git-workflow/tasks/verification-gate.md Step 3"

  - id: verification-gate-002
    title: "Missing VbC artifact IS BLOCKED — no valid state called implemented-but-unverified"
    conditions:
      all:
        - "vbc_yaml_exists == false"
    actions:
      - HALT
      - RETURN_BLOCKED
    source: "git-workflow/tasks/verification-gate.md Step 1"

  - id: verification-gate-003
    title: "Broken evidence chain IS fabrication — missing referenced files on disk"
    conditions:
      all:
        - "evidence_path_referenced == true"
        - "evidence_path_exists == false"
    actions:
      - HALT
      - RETURN_BLOCKED
      - RECORD_FABRICATION
    source: "git-workflow/tasks/verification-gate.md Step 4"

  - id: verification-gate-004
    title: "Audit consensus must be PASS with all auditor verdicts PASS"
    conditions:
      any:
        - "audit_consensus == 'DISAGREE'"
        - "audit_consensus == 'FAIL'"
        - "any_auditor_verdict == 'FAIL'"
        - "any_auditor_verdict == 'INCONCLUSIVE'"
    actions:
      - HALT
      - RETURN_BLOCKED
    source: "git-workflow/tasks/verification-gate.md Step 5"

  - id: verification-gate-005
    title: "No bypass, no PASS-with-concerns, no INCONCLUSIVE — only PASS and FAIL"
    conditions:
      any:
        - "overall_result == 'PASS_WITH_CONCERNS'"
        - "overall_result == 'INCONCLUSIVE'"
        - "overall_result == 'FUNCTIONALLY_EQUIVALENT'"
    actions:
      - HALT
      - RECLASSIFY_AS_FAIL
    source: "git-workflow/tasks/verification-gate.md Step 6"
```