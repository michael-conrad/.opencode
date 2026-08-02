# Task: pr-body-audit

## Purpose

Verify a generated PR body conforms to the standalone PR body template at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`. This task is dispatched as a single sub-agent audit (not DiMo chain) — the auditor reads the PR body and checks all 11 enumerated requirements.

## Entry Criteria

- PR body text is available (from file, variable, or API response)
- Template file exists at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`

## Audit Checklist

Verify each of the following 11 requirements. Record PASS/FAIL per item.

### Section Presence

- [ ] a. **Summary section present** — PR body contains a `**Summary:**` section
- [ ] b. **Outcome section present** — PR body contains an `**Outcome:**` section
- [ ] c. **Verification Attestation section present** — PR body contains a `**Verification Attestation:**` section
- [ ] d. **VbC Table section present** — PR body contains `**Detail: VbC Table**`
- [ ] e. **DiMo Chain Attestation section present** — PR body contains `**Detail: DiMo Chain Attestation**`
- [ ] f. **Spec-Card-Mapped Commits section present** — PR body contains `**Detail: Spec-Card-Mapped Commits**`
- [ ] g. **Closing keywords present** — PR body contains at least one closing keyword line (`Fixes #`, `Closes #`, `Resolves #`, or `Implements #`)

### Content Correctness

- [ ] h. **DiMo Chain Attestation table uses correct columns** — Table header contains: Criterion, Evidence Type, Investigator, Validator, Evaluator, Arbiter
- [ ] i. **Attestation line references DiMo 4-role chain** — Verification Attestation line contains "DiMo 4-role audit chain" (not "Dual independent auditors")
- [ ] j. **Attestation line states no synthesis corrections** — Attestation line contains "no synthesis corrections were needed or applied"
- [ ] k. **Byline present in correct format** — PR body ends with `🤖 Co-authored with AI: <AgentName> (<ModelId>)` or equivalent byline format

## Exit Criteria

- All 11 items recorded as PASS or FAIL
- If any item FAILs, the PR body must be regenerated with corrections
- If all items PASS, the PR body is ready for submission

## Artifacts

- `pr-body-audit-verdict.yaml` — per-item PASS/FAIL with evidence excerpts
