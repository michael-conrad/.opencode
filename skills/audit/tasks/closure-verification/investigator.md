# Task: closure-verification/generator

## Purpose

Generate initial closure verification analysis. Fetches the merged PR, identifies the linked spec issue, loads spec files, and produces the initial evidence artifact.

## Entry Criteria

- `evidence.yaml` not present at `artifact_evidence_dir`
- `spec_local_dir` provided and readable
- `artifact_evidence_dir` writable

## Exit Criteria

- `evidence.yaml` written with raw evidence (PR merge status, spec issue state, closing commit SHA, spec body)
- No judgments applied — raw evidence only

## Procedure

### Step 1: Pre-clean

- [ ] 1. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/closure-verification/`

### Step 2: Pre-Flight Validation Gate

- [ ] 1. Verify PR number is provided and non-empty
- [ ] 2. Verify spec issue number is provided and non-empty
- [ ] 3. If PR number is missing or empty, return BLOCKED with `MISSING_REQUIRED_INPUT`
- [ ] 4. If spec issue number is missing or empty, return BLOCKED with `MISSING_REQUIRED_INPUT`

### Step 3: Fetch Merged PR

Fetch PR via `github_pull_request_read(method="get")`. Verify `state == "merged"` before proceeding.

### Step 4: Identify Linked Spec

Extract spec issue number from PR body using closing pattern `(Closes|Fixes|Resolves|Implements)\s+#(\d+)`.

### Step 5: Load Spec

Read spec files from `spec_local_dir`. Find the spec file with a `state:` field.

### Step 6: Verify Issue Closed

Check that the spec issue state is `closed`. If not, return BLOCKED.

### Step 7: Write Evidence Artifact

Write `evidence.yaml` to `./tmp/{issue-N}/artifacts/closure-verification/evidence.yaml` with:
- PR merge status
- Spec issue number and state
- Closing commit SHA
- Spec body content

## Output

```yaml
status: DONE|BLOCKED
artifact_path: "./tmp/{issue-N}/artifacts/closure-verification/evidence.yaml"
summary: "PR merged, spec issue identified, evidence collected"
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