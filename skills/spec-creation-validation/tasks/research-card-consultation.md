# Task: research-card-consultation

## Purpose

Consult research cards for existing findings relevant to the spec being created.

## Entry Criteria

- `inspection_artifact_path` is provided
- Research cards directory exists at `.issues/research-cards/`

## Procedure

- [ ] 1. Glob `*.md` in `.issues/research-cards/`
- [ ] 2. Grep frontmatter for matching research questions
- [ ] 3. If matching card with `confidence >= 0.7`, incorporate findings
- [ ] 4. Write consultation artifact to `./tmp/{issue-N}/artifacts/research-card-consultation.yaml`

## Exit Criteria

- Consultation artifact written with matched cards and incorporated findings
- Artifact path returned

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Consulted N research cards, M matched" |
| artifact_path | `./tmp/{issue-N}/artifacts/research-card-consultation.yaml` |
