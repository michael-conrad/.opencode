<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate factual claims in generated content and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.
>
> **Auditors are read-only evaluators.** You inspect generated content sections and verify claims against local source data. You do NOT run behavioral tests yourself. Reading source data files with `read` is valid evidence inspection.

# Task: content-audit

## Purpose

Adversarial audit of factual claims in generated content (reports, runbooks, correspondence, documentation). Each claim is independently verified by two cross-family auditors against local source data. Catches fabricated claims — numerical padding, invented file references, false assertions — that a single sub-agent could produce with fabricated evidence artifacts.

> **Default assumption: FABRICATED.** The default verdict for every claim is FABRICATED unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FABRICATED. A clean PASS requires: (1) source data files are present and readable, (2) the claim is directly supported by source data, (3) no hedging language in the explanation, (4) both auditors independently agree.

## Entry Criteria

- `document_section` provided — the generated content section containing claims to verify
- `source_data_paths` provided — local file paths to source data (spec files, project files, evidence artifacts, config files) that the claims reference. No GitHub routing fields — verification is against local source data only.
- Audit phase context: `audit_phase: content`

## Exit Criteria

- All claims in the document section evaluated against source data
- Per-claim verdicts: PASS (verified), FAIL (contradicted by source), or FABRICATED (no source evidence exists)
- Verdict artifact written to disk
- Consensus PASS/FAIL/FABRICATED per claim

## Procedure

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify `document_section` is present and non-empty — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "document_section"
remediation: "document_section is required for content-audit. The orchestrator must provide the generated content section containing claims to verify."
```

- [ ] 2. Verify `source_data_paths` is present — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "source_data_paths"
remediation: "source_data_paths is required for content-audit. The orchestrator must provide local file paths to source data that the claims reference."
```

- [ ] 3. Verify no GitHub routing fields (`github.owner`, `github.repo`) are present in context — if present, return BLOCKED:

```yaml
status: BLOCKED
error: PRELOADED_CONTEXT_REJECTED
reason: "content-audit verifies against local source data only. GitHub routing fields are not permitted in content-audit context."
```

### Step 1: Load Document Section

Read the generated content section and extract all factual claims:

- [ ] 1. Read `document_section` — identify all quantitative claims (counts, percentages, durations, sizes), file references, and factual assertions
- [ ] 2. Classify each claim by domain: numerical, file-reference, config-value, code-behavior, docs-claim
- [ ] 3. Build a claim list with the exact assertion text for verification

### Step 2: Load Source Data

Read source data files from `source_data_paths`:

- [ ] 1. Glob `**/*` in each `source_data_paths` directory via `glob` tool
- [ ] 2. Read relevant files — spec files, project files, evidence artifacts, config files
- [ ] 3. If a referenced source file does not exist, record that as evidence of FABRICATED

### Step 3: Verify Each Claim

For each claim in the document section, verify against source data:

| Claim Type | Verification Method | PASS | FAIL | FABRICATED |
|------------|---------------------|------|------|------------|
| Numerical | Count/measure from source data | Exact match | Contradicted by source | No source data supports the number |
| File reference | `glob` or `ls` for the file path | File exists | File exists but content doesn't match | File does not exist |
| Config value | `read` the config file | Value matches | Value differs | Config file doesn't contain the field |
| Code behavior | `srclight_get_signature` or `read` source | Behavior matches | Behavior differs | No code path supports the claim |
| Docs claim | `read` the referenced doc | Docs support claim | Docs contradict claim | No doc supports the claim |

Record PASS/FAIL/FABRICATED per claim with tool-call evidence.

### Step 4: Generate Findings

For each claim, produce a finding with evidence reference:

```yaml
- claim_id: "C-1"
  claim_text: "12 models were tested"
  domain: "numerical"
  result: "FABRICATED"
  evidence: "<tool-call reference to source data inspection>"
  explanation: "Source data shows only 8 models were tested. The claim of 12 is unsupported."
  remediation: "Correct the count to match source data, or add the missing 4 models to the test run."
  next_step: "remediate"
```

### Step 5: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `./tmp/{issue-N}/artifacts/pipeline-audit-content-audit-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: content
auditor_type: content-audit
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
summary:
  total_claims: N
  pass: N
  fail: N
  fabricated: N
per_claim:
  - claim_id: "C-1"
    claim_text: "<exact assertion from document>"
    domain: "numerical"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"
all_claims_verified: false
mandatory_remediation: "Remit for mandatory remediation. Any FABRICATED or FAIL claim requires remediation before content ships. Default assumption is FABRICATED unless 100% clean PASS with no caveats, concerns, or notes."
```

### Step 6: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-content-audit-PASS-{timestamp}.yaml"
summary: "N claims evaluated. X PASS, Y FAIL, Z FABRICATED."
all_claims_verified: false
mandatory_remediation: "Remit for mandatory remediation. Any FABRICATED or FAIL claim requires remediation before content ships. Default assumption is FABRICATED unless 100% clean PASS with no caveats, concerns, or notes."
```

## Clean-Room Protocol

- **Dual cross-family auditors**: Dispatched via `resolve-models`. Each auditor is a clean-room sub-agent from a different model family. No single model family can dominate the verdict.
- **No orchestrator preload**: Auditors receive only `{ document_section, source_data_paths }`. No orchestrator reasoning, expected outcomes, pre-loaded evidence, or cached verification results.
- **Sub-agent entry criteria**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the auditor MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.
- **Independent verification**: Each auditor independently runs tool calls against source data to verify claims. The two auditors do not share context, reasoning, or intermediate results.
- **Cross-validation**: After both auditors return verdicts, `cross-validate` computes consensus. Disagreement (PASS vs FAIL/FABRICATED) blocks the claim from shipping and escalates to the developer.
- **Evidence artifacts on disk**: Each auditor writes full evidence artifacts to disk. The result contract carries only routing-significant data (`status`, `finding_summary`, `artifact_path`, `blocker_reason`).

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 1. Load document section → INVALID if skipped
- [ ] 2. Load source data → INVALID if skipped
- [ ] 3. Verify each claim → INVALID if skipped
- [ ] 4. Generate findings → INVALID if skipped
- [ ] 5. Write verdict artifact → INVALID if skipped
- [ ] 6. Return result contract → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After content-audit completes:
- If consensus PASS on all claims: proceed to `cross-validate` or next pipeline step
- If any claim is FAIL or FABRICATED: remediate findings, then re-run content-audit

## Error Handling

| Error | Action |
|-------|--------|
| `document_section` absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| `source_data_paths` absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| GitHub routing fields present | Return BLOCKED with PRELOADED_CONTEXT_REJECTED |
| Source data file not found | Record as FABRICATED evidence for affected claims |
| Cross-validate fails | Return OVERFLOW, log error |
| Auditor unavailable | Use fallback chain per multimodal-dispatch |

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `tasks/resolve-models.md` — cross-family selection
- `verification-enforcement/tasks/verify.md` — pre-generation verification gate that dispatches content-audit
- `verification-enforcement/tasks/revisit.md` — post-generation resolution of UNVERIFIED markers
- `000-critical-rules.md` — behavioral evidence mandate, clean-room protocol

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-07-01T00:00:00Z"
rules:
  - id: content-audit-001
    title: "document_section required — BLOCK on absent input"
    conditions:
      all: ["document_section_absent == true"]
    actions: [BLOCKED(MISSING_REQUIRED_INPUT)]
    source: "content-audit.md §Step 0"

  - id: content-audit-002
    title: "source_data_paths required — BLOCK on absent input"
    conditions:
      all: ["source_data_paths_absent == true"]
    actions: [BLOCKED(MISSING_REQUIRED_INPUT)]
    source: "content-audit.md §Step 0"

  - id: content-audit-003
    title: "No GitHub routing fields — BLOCK on PRELOADED_CONTEXT_REJECTED"
    conditions:
      all: ["github_routing_fields_present == true"]
    actions: [BLOCKED(PRELOADED_CONTEXT_REJECTED)]
    source: "content-audit.md §Step 0"

  - id: content-audit-004
    title: "Dual auditors required — no single-auditor evaluation"
    conditions:
      all: ["auditor_count < 2"]
    actions: [HALT, RESOLVE_SECOND_AUDITOR]
    source: "content-audit.md §Clean-Room Protocol"

  - id: content-audit-005
    title: "Clean-room task() — no orchestrator reasoning leaked to auditors"
    conditions:
      all: ["auditor_context contains 'expected' OR 'should' OR 'correct'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "content-audit.md §Clean-Room Protocol"

  - id: content-audit-006
    title: "next_step MUST be 'remediate' when result is 'FAIL' or 'FABRICATED', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_claim[].result in ['FAIL', 'FABRICATED'] AND per_claim[].next_step != 'remediate'"
        - "per_claim[].result == 'PASS' AND per_claim[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "content-audit.md §Step 5 — conditional next_step enforcement"

  - id: content-audit-007
    title: "all_claims_verified MUST be true when every claim result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(claim.result == 'PASS' for claim in per_claim) AND all_claims_verified != true"
        - "any(claim.result in ['FAIL', 'FABRICATED'] for claim in per_claim) AND all_claims_verified != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CLAIMS_VERIFIED]
    source: "content-audit.md §Step 5 — all_claims_verified enforcement"
```
