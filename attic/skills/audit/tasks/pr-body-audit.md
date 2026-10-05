# Task: pr-body-audit

## Purpose

Verify a generated PR body conforms to the standalone PR body template at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`. This task is dispatched as a single sub-agent audit (not DiMo chain) — the auditor reads the PR body and checks all 11 enumerated requirements.

## Entry Criteria

- PR body text is available (from file, variable, or API response)
- Template file exists at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`

## Procedure

- [ ] 1. **Read the canonical PR body template** — `Read [pr-body-template.md](skills/git-workflow-pr/reference/pr-body-template.md)`
- [ ] 2. **Extract required sections** — From the template, extract the list of required sections (headings) and content patterns
- [ ] 3. **Check each requirement** — For each required section and pattern from the template, check whether the PR body under audit contains it
- [ ] 4. **Record verdict** — Record PASS/FAIL per requirement

The template is the single source of truth for what a valid PR body must contain. Do not hardcode requirements — derive them dynamically from the template file.

## Exit Criteria

- All 11 items recorded as PASS or FAIL
- If any item FAILs, the PR body must be regenerated with corrections
- If all items PASS, the PR body is ready for submission

## Artifacts

- `pr-body-audit-verdict.yaml` — per-item PASS/FAIL with evidence excerpts
