# Task: coherence-extraction/path-provider

## Purpose

Provide resolution paths and recommendations based on the Evaluator's verdict. Reads `verdict.yaml` (Evaluator) and produces the final result contract.

## Entry Criteria

- `verdict.yaml` exists at `artifact_evidence_dir`

## Exit Criteria

- `judgment.yaml` written with final verdict and `next_step`
- Resolution paths provided for each FAIL criterion
- Frugal result contract returned

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