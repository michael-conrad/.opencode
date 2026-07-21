# Task: spec-summary/knowledge-supporter

## Purpose

Validate evidence produced by the Investigator against source data. Check accuracy, completeness, and relevance of each evidence item.

## Entry Criteria

- `evidence.yaml` exists at `artifact_evidence_dir`
- `spec_local_dir` provided and readable

## Exit Criteria

- `reasoning.yaml` written with validated evidence items
- Accuracy, completeness, and relevance assessments applied per item
- Corrections applied if evidence mismatches source data

## Procedure

### Step 1: Read Evidence

Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/spec-summary/evidence.yaml`.

### Step 2: Validate Each Evidence Item

For each evidence item:
- Check accuracy against source data (PR API, spec files)
- Check completeness (all required fields present)
- Check relevance (evidence relates to PR/spec consistency criteria)

### Step 3: Write Reasoning Artifact

Write validated evidence to `./tmp/{issue-N}/artifacts/spec-summary/reasoning.yaml`.

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/spec-summary/reasoning.yaml"
summary: "Evidence validated: X items accurate, Y items with issues"
```
