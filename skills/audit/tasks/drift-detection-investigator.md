---
name: drift-detection-generator
description: "Investigator role for the drift-detection DiMo chain. Collects raw evidence about documentation-code drift by reading spec requirements and scanning code implementation. Writes evidence.yaml with initial findings. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: drift-detection-generator

## Purpose

Investigator role for the drift-detection DiMo chain. Reads spec requirements from `spec_local_dir` and scans code implementation to collect raw evidence about documentation-code drift. Writes `evidence.yaml` with file existence data, function signature comparisons, untracked file inventory, and raw drift observations. This role collects evidence only — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.

> **DiMo Role: Investigator.** This task generates raw evidence for drift-detection. Writes `evidence.yaml` with spec requirements, code implementation scan results, and raw comparison data.
>
> You are the Investigator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You do not decide what constitutes drift. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST NOT classify drift severity — that is the Evaluator's job
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `target_files`: Optional — specific file paths to scan. If absent, extract from spec.

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch. The orchestrator MUST verify `spec_local_dir` is a valid directory before dispatching. If the spec is only on GitHub (not locally mirrored), the orchestrator MUST mirror it as .md files in `spec_local_dir/` first. Dispatching without a valid `spec_local_dir` is a CRITICAL VIOLATION.
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for evidence artifacts)
- Optional: `target_files` list of specific file paths to scan
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- All spec files in `spec_local_dir` read and their requirements extracted
- All target code files scanned for existence, function signatures, and content
- Untracked code files (not in spec) inventoried
- Raw comparison data collected (file presence, function presence, signature data)
- No PASS/FAIL judgments in the output — raw evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `{artifact_evidence_dir}/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for drift-detection-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 3. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Spec Requirements

Read all spec files from `spec_local_dir/` and extract requirements relevant to drift detection:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Extract the following from the spec body:
  - Problem Statement
  - Success Criteria (SC table with IDs, criteria text, evidence types)
  - Phase Requirements (phase headings and sub-items)
  - File Requirements (every file path mentioned in the spec)
  - Function/class/symbol references (every function, class, or method name mentioned)
  - API signature expectations (any expected signatures, parameters, return types)
  - Edge case descriptions
- [ ] 4. Record spec metadata: file paths, sizes, modification timestamps

Record in evidence:

```yaml
spec_requirements:
  spec_files:
    - path: "<relative path within spec_local_dir>"
      size_bytes: <N>
      modified_at: "<timestamp>"
  problem_statement: "<text or absent>"
  success_criteria:
    - id: "<SC-ID>"
      criterion: "<exact text>"
      evidence_type: "<type or absent>"
  phases:
    - heading: "<phase heading>"
      sub_items: ["<text>", ...]
  file_requirements:
    - path: "<file path from spec>"
      mentioned_in_section: "<section heading>"
      expected_functions: ["<name>", ...]
      expected_classes: ["<name>", ...]
  function_references:
    - name: "<function/class/method name>"
      mentioned_in_section: "<section heading>"
      expected_signature: "<signature text or absent>"
  edge_cases:
    - description: "<text>"
      mentioned_in_section: "<section heading>"
```

### Step 3: Identify Target Files

Determine which code files to scan for drift evidence:

- [ ] 1. If `target_files` is provided in the dispatch contract, use those paths directly
- [ ] 2. If `target_files` is absent, extract file paths from the spec's file requirements
- [ ] 3. For each target file, verify it exists on the filesystem using `glob` or `read`
- [ ] 4. Record which files exist and which do not

Record in evidence:

```yaml
target_files:
  source: "dispatch_contract | spec_extraction"
  files:
    - path: "<file path>"
      exists: true | false
      source: "dispatch_contract | spec_requirement"
```

### Step 4: Scan Code Implementation — File Existence and Content

For each target file that exists, collect raw implementation evidence:

- [ ] 1. **File existence check** — For each file path from spec requirements, record whether the file exists
- [ ] 2. **File content read** — For each existing file, read its full content
- [ ] 3. **Symbol extraction** — Use `srclight_symbols_in_file` to extract all functions, classes, and methods defined in the file
- [ ] 4. **Signature extraction** — For each function/class/method, use `srclight_get_signature` to record the actual signature
- [ ] 5. **File size and metadata** — Record file size, line count, and modification timestamp
- [ ] 6. Do NOT judge whether the implementation is correct — record what exists

Record in evidence:

```yaml
code_implementation:
  files:
    - path: "<file path>"
      exists: true | false
      size_bytes: <N or absent>
      line_count: <N or absent>
      modified_at: "<timestamp or absent>"
      symbols:
        - name: "<symbol name>"
          kind: "function | class | method | enum | struct"
          signature: "<actual signature from srclight_get_signature>"
          line: <N>
      raw_content_hash: "<sha256 or absent>"
```

### Step 5: Collect Raw Comparison Data

For each spec requirement, collect the raw comparison against code implementation without judging:

- [ ] 1. **File presence comparison** — For each file path in spec requirements, record whether a corresponding file exists in code
- [ ] 2. **Function presence comparison** — For each function reference in the spec, record whether a symbol with that name exists in the code
- [ ] 3. **Signature comparison data** — For each function reference with an expected signature, record both the expected signature (from spec) and the actual signature (from code) side by side
- [ ] 4. **Extra code inventory** — For each scanned file, record any symbols that exist in code but are NOT mentioned in the spec
- [ ] 5. **Edge case coverage data** — For each edge case described in the spec, record whether corresponding handling code appears to exist (do NOT judge — record presence/absence of related code patterns)
- [ ] 6. Do NOT produce any drift classification — record raw comparison data only

Record in evidence:

```yaml
raw_comparisons:
  file_presence:
    - spec_file: "<path from spec>"
      code_file_exists: true | false
      matching_code_path: "<actual path or absent>"
  function_presence:
    - spec_function: "<name from spec>"
      found_in_code: true | false
      found_in_file: "<file path or absent>"
      symbol_kind: "<kind or absent>"
  signature_comparisons:
    - spec_function: "<name>"
      expected_signature: "<text from spec or absent>"
      actual_signature: "<text from srclight_get_signature or absent>"
      spec_has_signature: true | false
      code_has_signature: true | false
  extra_code:
    - file: "<file path>"
      symbol_name: "<name>"
      symbol_kind: "function | class | method | enum | struct"
      signature: "<actual signature>"
      not_in_spec: true
  edge_case_coverage:
    - edge_case: "<description from spec>"
      related_code_found: true | false
      related_file: "<path or absent>"
      related_symbol: "<name or absent>"
```

### Step 6: Collect Untracked File Evidence

Scan for code files that exist but are not referenced in the spec:

- [ ] 1. If the spec defines a scope (e.g., specific directories or file patterns), glob those directories for all code files
- [ ] 2. If no scope is defined, record that full-repo scan was not performed (scope not specified)
- [ ] 3. For each discovered file, check whether it is mentioned in the spec's file requirements
- [ ] 4. Record files not in spec as untracked — do NOT judge whether they should be tracked

Record in evidence:

```yaml
untracked_files:
  scan_performed: true | false
  scan_scope: "<directory pattern or full_repo>"
  scope_source: "spec_defined | not_specified"
  files:
    - path: "<file path>"
      size_bytes: <N>
      symbol_count: <N>
      reason_not_tracked: "not_in_spec_file_requirements"
```

### Step 7: Collect Documentation Source Evidence

For any documentation URLs, API references, or external sources cited in the spec, collect verification evidence:

- [ ] 1. **URL verification** — For each URL in the spec, fetch using `webfetch` and record accessibility
- [ ] 2. **API reference verification** — For each API reference, use `srclight_get_signature` to record the actual signature
- [ ] 3. Do NOT judge whether the documentation is correct — record what exists

Record in evidence:

```yaml
documentation_sources:
  urls:
    - source: "<URL>"
      accessible: true | false
      http_status: <N>
      page_title: "<title or absent>"
  api_references:
    - source: "<function/class/method name>"
      found: true | false
      actual_signature: "<signature or absent>"
      lookup_method: "srclight_get_signature"
```

### Step 8: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: drift-detection-generator
issue_number: <N>
generated_at: "<timestamp>"
spec_local_dir: "<path>"
spec_requirements: {...}
target_files: {...}
code_implementation: {...}
raw_comparisons: {...}
untracked_files: {...}
documentation_sources: {...}
```

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p {artifact_evidence_dir}/`
- [ ] 2. Write `evidence.yaml` with the complete evidence structure
- [ ] 3. Verify the file was written and is non-empty

### Step 9: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: <N> spec files read, <N> target files scanned, <N> function comparisons, <N> untracked files. No judgments applied."
spec_file_count: <N>
target_file_count: <N>
function_comparison_count: <N>
untracked_file_count: <N>
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: {spec_file_count} spec files read, {target_file_count} target files scanned, {function_comparison_count} function comparisons, {untracked_file_count} untracked files. No judgments applied."
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Spec Requirements → INVALID if skipped
- [ ] 3. Identify Target Files → INVALID if skipped
- [ ] 4. Scan Code Implementation — File Existence and Content → INVALID if skipped
- [ ] 5. Collect Raw Comparison Data → INVALID if skipped
- [ ] 6. Collect Untracked File Evidence → INVALID if skipped
- [ ] 7. Collect Documentation Source Evidence → INVALID if skipped
- [ ] 8. Write evidence.yaml → INVALID if skipped
- [ ] 9. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| No target files identified | Return BLOCKED — need file paths or spec with file requirements |
| Code file not parseable | Record as `exists: true` with `parse_error: "<message>"` — do NOT BLOCK |
| srclight_get_signature fails | Record as `found: false` — do NOT BLOCK |
| srclight_symbols_in_file fails | Record as `symbols: []` with `extraction_error: "<message>"` — do NOT BLOCK |
| webfetch fails for a URL | Record as `accessible: false` with error — do NOT BLOCK |

## Cross-References

- `tasks/drift-detection.md` — Evaluator role (consumes this Investigator's evidence.yaml)
- `tasks/cross-validate.md` — Arbiter role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `000-critical-rules.md` — spec-code alignment
- `130-authority-source.md` — code as authoritative source

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
