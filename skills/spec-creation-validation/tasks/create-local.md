# Task: create-local

## Purpose

Create the local spec file at `.issues/{N}/spec.md` with full spec content.

## Entry Criteria

- `interdependency_artifact_path` is provided
- Interdependency check is complete

## Procedure

- [ ] 1. Read interdependency check from `interdependency_artifact_path`
- [ ] 2. Assemble full spec content with all sections
- [ ] 3. Write spec to `.issues/{N}/spec.md`
- [ ] 4. Write create-local artifact to `./tmp/{issue-N}/artifacts/create-local.yaml`

## Exit Criteria

- Local spec file created at `.issues/{N}/spec.md`
- Artifact path returned

## Related Guidelines

- `065-verification-honesty.md` §Cost Model — death spiral / break dynamics for evidence type cost rationale. Read [§Cost Model](065-verification-honesty.md) for why behavioral evidence is the cheapest (lowest DDL) and structural evidence is the most expensive (death spiral).

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Local spec created at .issues/{N}/spec.md" |
| artifact_path | `./tmp/{issue-N}/artifacts/create-local.yaml` |
