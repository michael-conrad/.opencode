# Task: coherence-extraction/path-provider

## Purpose

Provide resolution paths and recommendations based on the Evaluator's verdict. Reads `verdict.yaml` (Evaluator) and produces the final result contract.

## Procedure

### Step 1: Read Verdict

Read `verdict.yaml` from `./tmp/{issue-N}/artifacts/coherence-extraction/verdict.yaml`.

### Step 2: Generate Recommendations

For each FAIL criterion, provide a resolution path:
- What needs to be done
- Which guideline or skill needs updating
- Priority

### Step 3: Write Final Artifact

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-coherence-extraction-{STATUS}-{timestamp}.yaml`.

### Step 4: Return Frugal Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-coherence-extraction-PASS-{timestamp}.yaml"
summary: "Coherence extraction complete. X guidelines, Y skills, Z rules."
remediation_required: true
```
