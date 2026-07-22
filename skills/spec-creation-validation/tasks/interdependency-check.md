# Task: interdependency-check

## Purpose

Check for interdependencies between this spec and other open issues.

## Entry Criteria

- `risk_artifact_path` is provided
- Risk assessment is complete

## Procedure

- [ ] 1. Read risk assessment from `risk_artifact_path`
- [ ] 2. Search for open issues with overlapping scope
- [ ] 3. Document interdependencies and potential conflicts
- [ ] 4. Write interdependency check artifact to `./tmp/{issue-N}/artifacts/interdependency-check.yaml`

## Exit Criteria

- Interdependency check artifact written with overlapping issues
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Checked N open issues, M interdependencies found" |
| artifact_path | `./tmp/{issue-N}/artifacts/interdependency-check.yaml` |
