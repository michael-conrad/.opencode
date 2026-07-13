# Task: closure-verification/knowledge-supporter

## Purpose

Validate evidence produced by the Generator against source data. Check accuracy, completeness, and relevance of each evidence item.

## DiMo Role: Knowledge Supporter

You are the Knowledge Supporter. You validate evidence against source data. You read `evidence.yaml` (Generator), validate each item, and write `reasoning.yaml`.

## Procedure

### Step 1: Read Evidence

Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/closure-verification/evidence.yaml`.

### Step 2: Validate Each Evidence Item

For each evidence item:
- Check accuracy against source data (PR API, issue API)
- Check completeness (all required fields present)
- Check relevance (evidence relates to closure criteria)

### Step 3: Write Reasoning Artifact

Write validated evidence to `./tmp/{issue-N}/artifacts/closure-verification/reasoning.yaml` with:
- Validated evidence items
- Accuracy assessment per item
- Completeness assessment
- Relevance assessment

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/closure-verification/reasoning.yaml"
summary: "Evidence validated: X items accurate, Y items with issues"
```
