# Task: coherence-extraction/knowledge-supporter

## Purpose

Validate coherence evidence produced by the Investigator against source data. Check accuracy, completeness, and relevance of extracted rules and behaviors.

## DiMo Role: Validator

You are the Validator. You validate evidence against source data. You read `evidence.yaml` (Investigator), validate each item, and write `reasoning.yaml`.

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
