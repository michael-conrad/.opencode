# Task: spec-summary/path-provider

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

Read `verdict.yaml` from `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`.

### Step 2: Classify Mismatches

| Mismatch Type | Classification |
|--------------|----------------|
| TITLE_MISMATCH | PR title does not match spec title |
| CRITERIA_MISSING | Success criteria must be documented |
| FILES_MISSMATCH | Extra/missing files need explanation |
| SCOPE_EXPANSION | PR exceeds spec scope |
| SCOPE_INCOMPLETE | PR doesn't address full spec |
| LINK_MISSING | Should reference spec issue |
| CLOSING_MISSING | PR won't auto-close spec issue |

### Step 3: Generate Recommendations

For each FAIL criterion, provide a resolution path.

### Step 4: Write Final Artifact

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-summary-{STATUS}-{timestamp}.yaml`.

### Step 5: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-summary-PASS-{timestamp}.yaml"
summary: "PR/Spec consistency: {match_percentage}% matched. Verdict: {overall}."
remediation_required: true
```
