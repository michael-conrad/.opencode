# Task: coherence-extraction/knowledge-supporter

## Purpose

Validate coherence evidence produced by the Investigator against source data. Check accuracy, completeness, and relevance of extracted rules and behaviors.

## Entry Criteria

- `evidence.yaml` exists at `artifact_evidence_dir`
- `spec_local_dir` provided and readable

## Exit Criteria

- `reasoning.yaml` written with validated evidence items
- Accuracy, completeness, and relevance assessments applied per item
- Corrections applied if evidence mismatches source data

## Procedure

### Step 1: Read Evidence

Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/coherence-extraction/evidence.yaml`.

### Step 2: Validate Each Evidence Item

For each evidence item:
- Check accuracy against source guideline/skill files
- Check completeness (all rules and behaviors extracted)
- Check relevance (evidence relates to coherence criteria)

### Step 3: Write Reasoning Artifact

Write validated evidence to `./tmp/{issue-N}/artifacts/coherence-extraction/reasoning.yaml`.

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/coherence-extraction/reasoning.yaml"
summary: "Evidence validated: X items accurate, Y items with issues"
```
