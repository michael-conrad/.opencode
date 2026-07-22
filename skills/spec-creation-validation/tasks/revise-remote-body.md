# Task: revise-remote-body

## Purpose

Update the remote issue body with the full spec content after local spec is finalized.

## Entry Criteria

- `create_artifact_path` is provided
- Local spec file exists at `.issues/{N}/spec.md`

## Procedure

- [ ] 1. Read create artifact from `create_artifact_path`
- [ ] 2. Read local spec from `.issues/{N}/spec.md`
- [ ] 3. Update remote issue body via `issue-operations --task body-edit`
- [ ] 4. Write revise-remote-body artifact to `./tmp/{issue-N}/artifacts/revise-remote-body.yaml`

## Exit Criteria

- Remote issue body updated with full spec content
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Remote issue body updated for #N" |
| artifact_path | `./tmp/{issue-N}/artifacts/revise-remote-body.yaml` |
