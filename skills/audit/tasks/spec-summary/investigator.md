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
