# Task: closure-verification/path-provider

## Purpose

Provide resolution paths and recommendations based on the Evaluator's verdict. Reads `verdict.yaml` (Evaluator) and produces the final result contract.

## Entry Criteria

- `verdict.yaml` exists at `artifact_evidence_dir`

## Exit Criteria

- `judgment.yaml` written with final verdict and `next_step`
- Resolution paths provided for each FAIL criterion
- Frugal result contract returned

## Procedure

### Step 1: Read Verdict

Read `verdict.yaml` from `./tmp/{issue-N}/artifacts/closure-verification/verdict.yaml`.

### Step 2: Classify Gaps

| Gap Type | Severity | Classification |
|---------|----------|----------------|
| ISSUE_NOT_CLOSED | HIGH | Spec issue still open |
| CRITERIA_UNVERIFIED | MEDIUM | Success criteria missing evidence |
| MISSING_CLOSING_COMMIT | LOW | Commit doesn't reference spec |
| OPEN_BLOCKERS | HIGH | Blocking issues remain |
| FOLLOW_UP_NOT_OPEN | MEDIUM | Follow-up issue closed |

### Step 3: Generate Recommendations

For each FAIL criterion, provide a resolution path:
- What needs to be done
- Who should do it
- Priority

### Step 4: Write Final Artifact

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-closure-verification-{STATUS}-{timestamp}.yaml`.

### Step 5: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-closure-verification-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
remediation_required: true
```
