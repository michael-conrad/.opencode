# Task: spec-summary/generator

## Purpose

Generate initial PR/spec consistency analysis. Fetches the PR, loads the spec, and produces the initial evidence artifact.

## Entry Criteria

- `evidence.yaml` not present at `artifact_evidence_dir`
- `spec_local_dir` provided and readable
- `artifact_evidence_dir` writable

## Exit Criteria

- `evidence.yaml` written with raw evidence (spec requirements, PR content)
- No judgments applied — raw evidence only

## Procedure

### Step 1: Pre-clean

- [ ] 1. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/spec-summary/`

### Step 2: Pre-Flight Validation Gate

- [ ] 1. Verify PR number is provided and non-empty
- [ ] 2. Verify spec issue number is provided and non-empty
- [ ] 3. If either is missing, return BLOCKED with `MISSING_REQUIRED_INPUT`

### Step 3: Fetch PR and Load Spec

Fetch PR via `github_pull_request_read(method="get")`. Read spec files from `spec_local_dir`.

### Step 4: Extract Spec Requirements

Extract problem statement, success criteria, phases, and affected files from spec body.

### Step 5: Extract PR Content

Extract PR title, body, files, and commits.

### Step 6: Write Evidence Artifact

Write `evidence.yaml` to `./tmp/{issue-N}/artifacts/spec-summary/evidence.yaml` with spec requirements and PR content.

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/spec-summary/evidence.yaml"
summary: "PR and spec loaded, evidence collected"
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