---
name: content-audit-generator
description: "Generator role for the content-audit DiMo chain. Reads generated content and source data, collects raw evidence about factual claims. Writes evidence.yaml — does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: content-audit-generator

## Purpose

Generator role for the content-audit DiMo chain. Reads the generated content section from `document_section` and source data from `source_data_paths`, extracts all factual claims, and collects raw evidence about each claim against local source data. This role collects evidence only — it does NOT evaluate, judge, or produce PASS/FAIL/FABRICATED verdicts.

> **DiMo Role: Generator.** This task generates raw evidence for content-audit. Writes `evidence.yaml` with extracted claims, source data inventory, and per-claim evidence collected from local files.
>
> You are the Generator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You do not decide what passes or fails. You just collect.
>
>
> - MUST extract all claims without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL/FABRICATED judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST NOT assess whether a claim is true or false — that is the Evaluator's job
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `document_section`: The generated content section containing claims to verify
- `source_data_paths`: Local file paths to source data (spec files, project files, evidence artifacts, config files) that the claims reference
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- `document_section` provided — the generated content section containing claims to verify. MUST be non-empty text.
- `source_data_paths` provided — local file paths to source data that the claims reference. No GitHub routing fields — verification is against local source data only.
- `artifact_evidence_dir` provided — writable directory for evidence artifacts

## Exit Criteria

- All factual claims extracted from `document_section` and classified by domain
- All source data files in `source_data_paths` read and catalogued
- Per-claim evidence collected: source data inspected, file existence checked, content compared
- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- No PASS/FAIL/FABRICATED judgments in the output — raw evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `document_section` is present and non-empty — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "document_section"
remediation: "document_section is required for content-audit-generator. The orchestrator must provide the generated content section containing claims to verify."
```

- [ ] 2. Verify `source_data_paths` is present — if missing, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "source_data_paths"
remediation: "source_data_paths is required for content-audit-generator. The orchestrator must provide local file paths to source data that the claims reference."
```

- [ ] 3. Verify no GitHub routing fields (`github.owner`, `github.repo`) are present in context — if present, return BLOCKED:

```yaml
status: BLOCKED
error: PRELOADED_CONTEXT_REJECTED
reason: "content-audit-generator verifies against local source data only. GitHub routing fields are not permitted in content-audit-generator context."
```

- [ ] 4. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Document Section

Read the generated content section and extract all factual claims:

- [ ] 1. Read `document_section` in full
- [ ] 2. Identify all quantitative claims — counts, percentages, durations, sizes, timestamps, version numbers
- [ ] 3. Identify all file references — file paths, directory paths, filenames
- [ ] 4. Identify all config-value claims — environment variables, configuration keys, setting values
- [ ] 5. Identify all code-behavior claims — function signatures, API behavior, code structure assertions
- [ ] 6. Identify all documentation claims — references to docs, specs, guidelines, or external sources
- [ ] 7. Classify each claim by domain: `numerical`, `file-reference`, `config-value`, `code-behavior`, `docs-claim`
- [ ] 8. Build a claim list with the exact assertion text and its location in the document

Record in evidence:

```yaml
document_section:
  length_chars: <N>
  length_lines: <N>
claims:
  - claim_id: "C-1"
    claim_text: "<exact assertion from document>"
    domain: "numerical | file-reference | config-value | code-behavior | docs-claim"
    location: "<section or paragraph reference>"
```

### Step 3: Load Source Data

Read source data files from `source_data_paths`:

- [ ] 1. Glob `**/*` in each `source_data_paths` directory via `glob` tool
- [ ] 2. For each discovered file, record: path, size, modification timestamp
- [ ] 3. Read relevant files — spec files, project files, evidence artifacts, config files
- [ ] 4. For each file, record its structure: frontmatter presence, section headings, key-value pairs, table structure
- [ ] 5. If a referenced source file does not exist, record that fact — do NOT judge

Record in evidence:

```yaml
source_data:
  directories: ["<path>", ...]
  files:
    - path: "<relative path>"
      size_bytes: <N>
      modified_at: "<timestamp>"
      has_frontmatter: true | false
      headings: ["<heading text>", ...]
      key_value_pairs: {<key>: "<value>", ...}
      table_count: <N>
```

### Step 4: Collect Per-Claim Evidence

For each claim extracted in Step 2, collect raw evidence from source data:

#### Numerical Claims

- [ ] 1. Identify the source data file(s) that should contain the relevant counts/measurements
- [ ] 2. Count or measure the actual value from source data
- [ ] 3. Record the actual value found and the method used to obtain it
- [ ] 4. Do NOT compare against the claim — only record what the source data shows

```yaml
- claim_id: "C-1"
  claim_text: "12 models were tested"
  domain: "numerical"
  evidence:
    source_file: "<path>"
    actual_value: <N>
    measurement_method: "<count | grep | glob | read>"
    measurement_detail: "<how the value was obtained>"
```

#### File Reference Claims

- [ ] 1. For each file path claimed, use `glob` or `ls` to check existence
- [ ] 2. If the file exists, record its path, size, and modification timestamp
- [ ] 3. If the file does not exist, record `exists: false`
- [ ] 4. Do NOT judge whether the claim is correct — only record what exists

```yaml
- claim_id: "C-2"
  claim_text: "The config file is at src/config.yaml"
  domain: "file-reference"
  evidence:
    claimed_path: "src/config.yaml"
    exists: true | false
    actual_path: "<resolved path or absent>"
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
```

#### Config-Value Claims

- [ ] 1. Read the referenced config file
- [ ] 2. Search for the claimed key or setting
- [ ] 3. Record the actual value found (or note if the key is absent)
- [ ] 4. Do NOT compare against the claim — only record what the config contains

```yaml
- claim_id: "C-3"
  claim_text: "The timeout is set to 30 seconds"
  domain: "config-value"
  evidence:
    config_file: "<path>"
    key_searched: "<key name>"
    key_found: true | false
    actual_value: "<value or absent>"
    value_location: "<line number or section>"
```

#### Code-Behavior Claims

- [ ] 1. Use `srclight_get_signature` to look up the referenced function or method
- [ ] 2. If the symbol is found, record its actual signature
- [ ] 3. If the symbol is not found, record `found: false`
- [ ] 4. Use `read` to inspect the source file for behavioral evidence
- [ ] 5. Do NOT judge whether the behavior matches the claim — only record what the code shows

```yaml
- claim_id: "C-4"
  claim_text: "The process_data() function accepts a timeout parameter"
  domain: "code-behavior"
  evidence:
    symbol: "process_data"
    found: true | false
    actual_signature: "<signature or absent>"
    source_file: "<path>"
    lookup_method: "srclight_get_signature"
```

#### Documentation Claims

- [ ] 1. Read the referenced documentation file
- [ ] 2. Search for the claimed statement or topic
- [ ] 3. Record whether the topic is discussed and what the documentation says
- [ ] 4. Do NOT judge whether the documentation supports the claim — only record what it contains

```yaml
- claim_id: "C-5"
  claim_text: "The spec requires behavioral evidence for all SCs"
  domain: "docs-claim"
  evidence:
    doc_file: "<path>"
    topic_found: true | false
    relevant_text: "<excerpt or absent>"
    lookup_method: "read | grep"
```

### Step 5: Collect Source Data Coverage Evidence

Record which claims have corresponding source data and which do not:

- [ ] 1. For each claim, record whether any source data file was found that could verify it
- [ ] 2. For claims with no discoverable source data, record `source_data_available: false`
- [ ] 3. Do NOT judge — only record availability

```yaml
source_coverage:
  - claim_id: "C-1"
    source_data_available: true | false
    source_files_checked: ["<path>", ...]
  - claim_id: "C-2"
    source_data_available: true | false
    source_files_checked: ["<path>", ...]
```

### Step 6: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: content-audit-generator
generated_at: "<ISO timestamp>"
document_section:
  length_chars: <N>
  length_lines: <N>
claims:
  - claim_id: "C-1"
    claim_text: "<exact assertion>"
    domain: "numerical | file-reference | config-value | code-behavior | docs-claim"
    location: "<section reference>"
source_data:
  directories: ["<path>", ...]
  files:
    - path: "<relative path>"
      size_bytes: <N>
      modified_at: "<timestamp>"
      has_frontmatter: true | false
      headings: ["<heading>", ...]
      key_value_pairs: {<key>: "<value>", ...}
      table_count: <N>
per_claim_evidence:
  - claim_id: "C-1"
    claim_text: "<exact assertion>"
    domain: "<domain>"
    evidence:
      source_file: "<path>"
      actual_value: <value or text>
      measurement_method: "<method>"
      measurement_detail: "<detail>"
      exists: true | false
      found: true | false
      key_found: true | false
      topic_found: true | false
      relevant_text: "<excerpt or absent>"
source_coverage:
  - claim_id: "C-1"
    source_data_available: true | false
    source_files_checked: ["<path>", ...]
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `evidence.yaml` with the complete evidence structure
- [ ] 3. Verify the file was written and is non-empty

### Step 7: Return Frugal Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: {N} claims extracted across {M} domains. {K} source data files catalogued. No judgments applied."
claim_count: <N>
source_file_count: <N>
domains_covered: ["<domain>", ...]
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: {N} claims extracted across {M} domains. {K} source data files catalogued. No judgments applied."
```

## Clean-Room Protocol

- **DiMo role chain**: Dispatched via sequential `task(subagent_type="general")` calls. Generator → Knowledge Supporter → Evaluator → Path Provider (Judger). Each role reads upstream artifacts and writes its own.
- **No orchestrator preload**: Sub-agents receive only `{ document_section, source_data_paths, artifact_evidence_dir }`. No orchestrator reasoning, expected outcomes, pre-loaded evidence, or cached verification results.
- **Sub-agent entry criteria**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.
- **Evidence artifacts on disk**: Each role writes full evidence artifacts to disk. The result contract carries only routing-significant data (`status`, `finding_summary`, `artifact_path`, `blocker_reason`).

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Document Section → INVALID if skipped
- [ ] 3. Load Source Data → INVALID if skipped
- [ ] 4. Collect Per-Claim Evidence → INVALID if skipped
- [ ] 5. Collect Source Data Coverage Evidence → INVALID if skipped
- [ ] 6. Write evidence.yaml → INVALID if skipped
- [ ] 7. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| `document_section` absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| `document_section` empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| `source_data_paths` absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| GitHub routing fields present | Return BLOCKED with PRELOADED_CONTEXT_REJECTED |
| Source data file not found | Record `exists: false` for affected claims — do NOT BLOCK |
| `srclight_get_signature` fails | Record `found: false` for affected claims — do NOT BLOCK |
| `glob` returns empty for a source path | Record directory as empty — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write evidence.yaml |

## Cross-References

- `tasks/content-audit.md` — Evaluator role (consumes this Generator's evidence.yaml)
- `tasks/cross-validate.md` — Path Provider (Judger) role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `verification-enforcement/tasks/verify.md` — pre-generation verification gate that dispatches content-audit
- `verification-enforcement/tasks/revisit.md` — post-generation resolution of UNVERIFIED markers
- `000-critical-rules.md` — behavioral evidence mandate, clean-room protocol
