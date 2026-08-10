# Task: closure-verification/generator

## Purpose

Generate initial closure verification analysis. Fetches the merged PR, identifies the linked spec issue, loads spec files, and produces the initial evidence artifact.

## Entry Criteria

- `evidence.yaml` does not exist in artifact directory
- `spec_local_dir` is provided and points to a valid spec directory
- PR number is provided and non-empty

## Exit Criteria

- `evidence.yaml` written to `./tmp/{issue-N}/artifacts/closure-verification/evidence.yaml`
- Evidence contains PR merge status, spec issue number, closing commit SHA, and spec body content

## Role: Investigator

You are the Investigator. You produce initial analysis artifacts. You fetch data, read files, and write `evidence.yaml` for downstream roles.

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
