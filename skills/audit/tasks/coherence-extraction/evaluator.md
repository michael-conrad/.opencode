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

## Dispatch Contract

The orchestrator MUST provide the following context fields when dispatching this task:

| Field | Required | Description |
|-------|----------|-------------|
| `spec_local_dir` | Yes | Local directory containing spec files |
| `artifact_evidence_dir` | Yes | Directory for evidence artifacts |

**Missing required context:** If any required field is absent, return:

```yaml
status: BLOCKED
reason: MISSING_REQUIRED_CONTEXT
message: "Required context field(s) missing: <field_names>"
```

**Preloaded context rejection:** If the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences in the dispatch prompt, return:

```yaml
status: BLOCKED
reason: PRELOADED_CONTEXT_REJECTED
message: "Orchestrator preloaded context detected. Dispatch with canonical string only."
```

**Expected-determination rejection:** If the orchestrator includes an expected PASS/FAIL determination or expected verdict in the dispatch context, return:

```yaml
status: BLOCKED
reason: EXPECTED_DETERMINATION_REJECTED
message: "Expected determination detected. Dispatch without pre-judgment."
```


## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.