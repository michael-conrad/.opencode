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