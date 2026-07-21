# Task: closure-verification/evaluator

## Purpose

Evaluate closure evidence against criteria. Reads `reasoning.yaml` (Validator), evaluates each criterion, and writes `verdict.yaml`.

## Entry Criteria

- `evidence.yaml` exists at `artifact_evidence_dir`
- `reasoning.yaml` exists at `artifact_evidence_dir`
- `spec_local_dir` provided and readable

## Exit Criteria

- `verdict.yaml` written with per-criterion PASS/FAIL
- Self-consistency gate applied — hedging language downgrades PASS to FAIL
- `all_criteria_pass` field set

## Procedure

### Step 1: Read Reasoning

Read `reasoning.yaml` from `./tmp/{issue-N}/artifacts/closure-verification/reasoning.yaml`.

### Step 2: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| CV-1 | PR successfully merged | `merged` status |
| CV-2 | Spec issue closed | Issue state `closed` |
| CV-3 | Closing commit linked | Commit references spec issue |
| CV-4 | Success criteria verified | Tool-call evidence for each SC |
| CV-5 | Follow-up issues created | Future work documented |
| CV-6 | No open blocking issues | No open blockers |

### Step 3: Evaluate Each Criterion

For each criterion, produce PASS or FAIL based on validated evidence.

### Step 4: Self-Consistency Gate

Before writing the verdict, run a self-consistency check on every criterion:
- For each criterion where `result: "PASS"`, scan explanation for hedging language
- If hedging found (`"should be"`, `"needs"`, `"missing"`, `"could improve"`, `"minor"`, `"some issues"`, `"mostly"`, `"generally"`), downgrade to FAIL
- Document the downgrade in a `self_consistency` field

### Step 5: Write Verdict Artifact

Write `verdict.yaml` to `./tmp/{issue-N}/artifacts/closure-verification/verdict.yaml`.

### Step 6: Check for Open Blockers

Check issue comments for blocking language.

### Step 7: Check Follow-up Issues

Check for follow-up issue references in PR body and verify they exist and are open.

## Output

```yaml
status: DONE|FAIL
artifact_path: "./tmp/{issue-N}/artifacts/closure-verification/verdict.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
```
