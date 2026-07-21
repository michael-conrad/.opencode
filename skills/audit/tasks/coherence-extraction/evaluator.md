# Task: coherence-extraction/evaluator

## Purpose

Evaluate coherence metrics against criteria. Reads `reasoning.yaml` (Validator), computes coherence metrics, runs Z3 solve check, evaluates prose vs evidence type mismatches, and writes `verdict.yaml`.

## Entry Criteria

- `evidence.yaml` exists at `artifact_evidence_dir`
- `reasoning.yaml` exists at `artifact_evidence_dir`
- `spec_local_dir` provided and readable

## Exit Criteria

- `verdict.yaml` written with per-criterion PASS/FAIL
- Coherence metrics computed (coverage ratio, orphan count, alignment score)
- Z3 solve check completed
- Prose vs evidence type mismatch check completed

## Procedure

### Step 1: Read Reasoning

Read `reasoning.yaml` from `./tmp/{issue-N}/artifacts/coherence-extraction/reasoning.yaml`.

### Step 2: Compute Coherence Metrics

- Guideline coverage ratio
- Orphan rule count
- Skill-guideline alignment score
- Total rules count

### Step 3: Run Z3 Solve Check

Run Z3 solve check against pipeline state machine to validate structural consistency of SC evidence type constraints.

On PASS (SAT + no contradictions): proceed to Step 4.
On FAIL (UNSAT or any contradiction found): write FAIL artifact, return BLOCKED.

### Step 4: Evaluate Prose vs Evidence Type Mismatch

For each SC, compare prose description against declared evidence type. Flag mismatches where prose describes behavioral/runtime outcomes but SC is declared as `structural` or `string`.

On PASS (no mismatches): proceed to Step 5.
On FAIL (any mismatch): write FAIL artifact, return BLOCKED.

### Step 5: Write Baseline File

Write baseline coherence JSON to `{project_root}/tmp/{issue-N}/artifacts/baseline-coherence-{date}.json`.

### Step 6: Write Verdict Artifact

Write `verdict.yaml` to `./tmp/{issue-N}/artifacts/coherence-extraction/verdict.yaml`.

## Output

```yaml
status: DONE|FAIL
artifact_path: "./tmp/{issue-N}/artifacts/coherence-extraction/verdict.yaml"
summary: "Coherence metrics computed. Coverage: X%, Orphans: Y"
baseline_path: "{project_root}/tmp/{issue-N}/artifacts/baseline-coherence-{date}.json"
```
