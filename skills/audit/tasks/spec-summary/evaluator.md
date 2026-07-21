# Task: spec-summary/evaluator

## Purpose

Evaluate PR/spec consistency against criteria. Reads `reasoning.yaml` (Validator), evaluates each criterion, and writes `verdict.yaml`.

## Entry Criteria

- `evidence.yaml` exists at `artifact_evidence_dir`
- `reasoning.yaml` exists at `artifact_evidence_dir`
- `spec_local_dir` provided and readable

## Exit Criteria

- `verdict.yaml` written with per-criterion PASS/FAIL
- Self-consistency gate applied — hedging language downgrades PASS to FAIL
- `overall_verdict` field set

## Procedure

### Step 1: Read Reasoning

Read `reasoning.yaml` from `./tmp/{issue-N}/artifacts/spec-summary/reasoning.yaml`.

### Step 2: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SS-1 | PR title matches spec title | Same or equivalent title |
| SS-2 | PR body describes success criteria | All SC documented |
| SS-3 | PR files match spec requirements | All specified files present |
| SS-4 | PR scope matches spec scope | No extra/missing changes |
| SS-5 | Spec issue linked from PR | Issue reference in body |
| SS-6 | Closing keywords present | "Closes #<issue>" in commit/PR |

### Step 3: Evaluate Each Criterion

Compare PR content to spec requirements. Produce PASS or FAIL per criterion.

### Step 4: Verify Closing Keywords

Check for `Closes`, `Fixes`, `Resolves`, `Implements` in PR body and commits.

### Step 5: Check Spec Issue Status

If closing keywords present, verify spec issue will be auto-closed.

### Step 6: Write Verdict Artifact

Write `verdict.yaml` to `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`.

## Output

```yaml
status: DONE|FAIL
artifact_path: "./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
overall_verdict: "PASS|FAIL"
```
