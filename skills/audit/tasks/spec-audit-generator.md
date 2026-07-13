---
name: spec-audit-generator
description: "Generator role for the spec-audit DiMo chain. Collects raw evidence about spec structure, determinism, and live documentation sources. Writes evidence.yaml with initial findings. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-audit-generator

## Purpose

Generator role for the spec-audit DiMo chain. Reads the spec file(s) from `spec_local_dir` and produces `evidence.yaml` with raw evidence about spec structure, determinism, and live documentation sources. This role collects evidence only — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.

> **DiMo Role: Generator.** This task generates raw evidence for spec-audit. Writes `evidence.yaml` with spec structure, determinism data, and live documentation source verification results.
>
> You are the Generator. Your job is to collect evidence — nothing more, nothing less. You are meticulous, exhaustive, and completely non-judgmental. Every piece of evidence you find gets recorded. You do not decide what matters. You do not decide what is correct. You just collect.
>
>
> - MUST extract all evidence without filtering by perceived relevance
> - MUST NOT produce any PASS/FAIL judgment
> - MUST NOT evaluate whether evidence is "correct" — record what exists
> - MUST write `evidence.yaml` as the only output artifact

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts
- `spec_issue_number`: Issue number for the spec being audited
- `github.owner`, `github.repo`: Repository identity
- `failure_description`: Optional — prior implementation failure description (triggers enhanced determinism evidence collection)

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch. The orchestrator MUST verify `spec_local_dir` is a valid directory before dispatching. If the spec is only on GitHub (not locally mirrored), the orchestrator MUST mirror it as .md files in `spec_local_dir/` first. Dispatching without a valid `spec_local_dir` is a CRITICAL VIOLATION.
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- `artifact_evidence_dir` provided (writable directory for evidence artifacts)
- Optional: `failure_description` from prior implementation attempt

## Exit Criteria

- `evidence.yaml` written to `{artifact_evidence_dir}/evidence.yaml`
- All spec files in `spec_local_dir` read and their content recorded
- Spec structure evidence collected (sections, SCs, phases, prose patterns)
- Determinism evidence collected (SC wording, fail patterns, ambiguity markers)
- Live documentation source evidence collected (URLs verified, API references checked)
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
remediation: "spec_local_dir is required for spec-audit-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 3. Verify `artifact_evidence_dir` is writable — create it if it does not exist

### Step 2: Load Spec Content

Read all spec files from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool
- [ ] 2. Read every discovered file in full
- [ ] 3. Record file paths, sizes, and modification timestamps
- [ ] 4. Extract spec body and frontmatter metadata from each file
- [ ] 5. If `spec_local_dir` contains multiple files, record each separately with its path

Record in evidence:

```yaml
spec_files:
  - path: "<relative path within spec_local_dir>"
    size_bytes: <N>
    modified_at: "<timestamp>"
    has_frontmatter: true | false
    frontmatter_keys: ["<key>", ...]
    body_length_lines: <N>
    body_length_chars: <N>
```

### Step 3: Collect Spec Structure Evidence

Extract structural elements from the spec body without evaluating quality:

- [ ] 1. **Section inventory** — List every markdown heading (`##`, `###`, `####`) with its text and line position
- [ ] 2. **SC table extraction** — If the spec contains a Success Criteria table, extract every row with all columns present (ID, Criterion, Evidence Type, Verification Method). Record exactly what is in the spec — do not infer missing columns
- [ ] 3. **Phase inventory** — If the spec defines phases, list each phase with its heading text and any sub-items
- [ ] 4. **Files Affected inventory** — If the spec has a Files Affected section, list every file path mentioned
- [ ] 5. **Preamble presence** — Record whether the spec has a "## Intent and Executive Summary" section and which of the 5 preamble fields are present (Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions)
- [ ] 6. **Documentation Sources inventory** — If the spec has a Documentation Sources section, list every URL, API reference, and documentation claim
- [ ] 7. **STATUS marker** — Record the spec's STATUS marker value if present
- [ ] 8. **Prose structure inventory** — Record presence of tables, code blocks, lists, and other structural elements

Record in evidence:

```yaml
spec_structure:
  headings:
    - level: 2 | 3 | 4
      text: "<heading text>"
      line: <N>
  success_criteria:
    present: true | false
    table_columns: ["<col1>", "<col2>", ...]
    rows:
      - id: "<SC-ID>"
        criterion: "<text>"
        evidence_type: "<type or empty>"
        verification_method: "<text or empty>"
  phases:
    present: true | false
    count: <N>
    items:
      - heading: "<phase heading>"
        sub_items_count: <N>
  files_affected:
    present: true | false
    paths: ["<path>", ...]
  preamble:
    present: true | false
    fields_present: ["<field>", ...]
    fields_missing: ["<field>", ...]
  documentation_sources:
    present: true | false
    sources: ["<URL or reference>", ...]
  status_marker: "<STATUS value or absent>"
  prose_elements:
    tables: <N>
    code_blocks: <N>
    ordered_lists: <N>
    unordered_lists: <N>
```

### Step 4: Collect Determinism Evidence

Extract determinism-relevant data from each SC without judging whether it is deterministic:

- [ ] 1. **SC wording extraction** — For each SC, record the exact criterion text verbatim
- [ ] 2. **Fail pattern detection** — For each SC, record presence of known fail patterns (do NOT judge — just record what patterns are present):
  - Adverbs without thresholds (e.g., "quickly", "efficiently", "properly")
  - Comparatives without baselines (e.g., "better", "faster", "more readable")
  - Open-ended quality terms (e.g., "good", "clean", "well-structured")
  - Missing expected values (e.g., "should match" without specifying what)
  - Implicit behavior (e.g., "should work correctly" without defining "correctly")
  - Either/or ambiguity (e.g., "or", "either", "alternatively" in Required Actions)
- [ ] 3. **Ambiguity markers** — Record presence of hedging language: "should", "may", "preferably", "ideally", "if possible", "as appropriate", "as needed", "consider", "optionally", "if desired", "TBD", "TODO", "to be determined"
- [ ] 4. **Evidence type declarations** — For each SC, record the declared evidence type (structural, string, semantic, behavioral) or note if absent
- [ ] 5. **Verification method presence** — For each SC, record whether a verification method is specified
- [ ] 6. **Failure description context** — If `failure_description` is provided, record it verbatim for downstream determinism evaluation

Record in evidence:

```yaml
determinism_evidence:
  sc_wording:
    - id: "<SC-ID>"
      text: "<exact criterion text>"
      word_count: <N>
  fail_patterns:
    - sc_id: "<SC-ID>"
      pattern: "adverb_without_threshold | comparative_without_baseline | open_ended_quality | missing_expected_values | implicit_behavior | either_or_ambiguity"
      matched_text: "<exact text matching the pattern>"
  ambiguity_markers:
    - sc_id: "<SC-ID>"
      marker: "should | may | preferably | ideally | if_possible | as_appropriate | as_needed | consider | optionally | if_desired | tbd | todo | to_be_determined"
      matched_text: "<exact text>"
  evidence_type_declarations:
    - sc_id: "<SC-ID>"
      declared_type: "structural | string | semantic | behavioral | absent"
  verification_methods:
    - sc_id: "<SC-ID>"
      has_verification_method: true | false
      method_text: "<text or absent>"
  failure_description_provided: true | false
  failure_description_text: "<text or absent>"
```

### Step 5: Collect Live Documentation Source Evidence

For each URL, API reference, or documentation claim in the spec, collect verification evidence against live sources:

- [ ] 1. **URL verification** — For each URL in the spec's Documentation Sources section or body:
  - Fetch the URL using `webfetch`
  - Record HTTP status, page title, and whether the page is accessible
  - Record whether the referenced content appears to exist on the page
  - Do NOT judge whether the content is correct — only record what was found
- [ ] 2. **API reference verification** — For each API function, method, or class reference:
  - Use `srclight_get_signature` to look up the referenced symbol
  - Record the actual signature found (or note if not found)
  - Do NOT compare against the spec's claim — only record what exists
- [ ] 3. **Environment variable verification** — For each environment variable reference:
  - Check `.env.example` or config schema for the variable
  - Record whether the variable is defined and its value format
- [ ] 4. **Library/framework pattern verification** — For each library or framework reference:
  - Check official docs or source for the referenced pattern
  - Record what the live source shows

Record in evidence:

```yaml
documentation_source_evidence:
  urls:
    - source: "<URL>"
      accessible: true | false
      http_status: <N>
      page_title: "<title or absent>"
      referenced_content_found: true | false | unable_to_determine
      fetch_method: "webfetch"
  api_references:
    - source: "<function/class/method name>"
      found: true | false
      actual_signature: "<signature or absent>"
      lookup_method: "srclight_get_signature"
  env_variables:
    - source: "<variable name>"
      found_in_config: true | false
      config_file: "<path or absent>"
      defined_format: "<format or absent>"
  library_patterns:
    - source: "<library/framework reference>"
      verified_against: "<official docs URL or source path>"
      pattern_exists: true | false | unable_to_determine
```

### Step 6: Collect Prose and Escape Hatch Evidence

Extract prose patterns and escape hatch language from the spec body without judging:

- [ ] 1. **Escape hatch inventory** — Record every instance of escape hatch language:
  - "Use best judgment", "implementer's discretion", "if time permits", "stretch goal"
  - "may be deferred", "simplify if needed", "reduce scope if complex"
  - "as appropriate", "as needed", "preferably", "ideally", "should"
  - "TBD", "TODO", "to be determined", "left to implementor"
  - "implementor's choice", "consider X", "optionally", "if desired"
- [ ] 2. **Tracking language inventory** — Record every instance of status/tracking language:
  - "implemented", "pending", "confirmed", "viable", "completed" used as status markers
- [ ] 3. **Prescriptive code inventory** — Record every instance of prescriptive code content:
  - Exact file paths with line numbers
  - Exact import strings
  - Exact assertion code
- [ ] 4. **Cost-frame language inventory** — For each SC, record whether cost-frame reformation language is present

Record in evidence:

```yaml
prose_evidence:
  escape_hatches:
    - phrase: "<exact text>"
      location: "<section or line reference>"
      category: "discretion | deferral | optional | tbd | choice"
  tracking_language:
    - phrase: "<exact text>"
      location: "<section or line reference>"
      marker_type: "implemented | pending | confirmed | viable | completed"
  prescriptive_code:
    - content: "<exact text>"
      location: "<section or line reference>"
      type: "line_number | import_string | assertion_code"
  cost_frame_language:
    - sc_id: "<SC-ID>"
      has_cost_frame: true | false
```

### Step 7: Collect Causal and Reasoning Evidence

Extract causal chain and reasoning structure from the spec without judging validity:

- [ ] 1. **Root Cause inventory** — Record every Root Cause element and its text
- [ ] 2. **Fix Approach inventory** — Record every Fix Approach element and its text
- [ ] 3. **SC-to-Root-Cause mapping** — For each SC, record which Root Cause element(s) it references (if any)
- [ ] 4. **Alternatives inventory** — Record any alternatives considered and why discarded
- [ ] 5. **Edge case inventory** — Record any edge cases or boundary conditions discussed
- [ ] 6. **Contradiction inventory** — Record any statements that appear to conflict (do NOT judge — just record pairs that could be contradictory)

Record in evidence:

```yaml
reasoning_evidence:
  root_causes:
    - text: "<exact text>"
      location: "<section reference>"
  fix_approaches:
    - text: "<exact text>"
      location: "<section reference>"
  sc_to_root_cause:
    - sc_id: "<SC-ID>"
      references_root_cause: true | false
      root_cause_text: "<text or absent>"
  alternatives_considered:
    present: true | false
    items:
      - alternative: "<text>"
        reason_discarded: "<text>"
  edge_cases:
    present: true | false
    items: ["<text>", ...]
  potential_contradictions:
    - statement_a: "<text>"
      statement_b: "<text>"
      location_a: "<section reference>"
      location_b: "<section reference>"
```

### Step 8: Collect Analytical Artifact Evidence

If analytical artifact paths are provided in the dispatch contract, collect evidence about their presence and content:

- [ ] 1. For each of `blast_radius_path`, `concern_map_path`, `code_path_inventory_path`, `cross_cutting_matrix_path`, `interface_compatibility_path`, `state_analysis_path`, `testability_assessment_path`:
  - If the field is present in the dispatch contract, check if the path exists and is non-empty
  - Record file existence, size, and modification timestamp
  - If the file exists, read and record its structure (keys, sections) without evaluating content
  - If the field is absent from the dispatch contract, record as `not_provided`

Record in evidence:

```yaml
analytical_artifact_evidence:
  blast_radius:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  concern_map:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  code_path_inventory:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  cross_cutting_matrix:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  interface_compatibility:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  state_analysis:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
  testability_assessment:
    provided: true | false
    path: "<path or absent>"
    exists: true | false
    size_bytes: <N or absent>
    modified_at: "<timestamp or absent>"
```

### Step 9: Collect Holistic Dimension Evidence

Collect raw data for each of the 11 holistic dimensions without evaluating:

- [ ] 1. **Implementability** — Record whether the spec defines a single approach, has unambiguous SCs, and whether output would be consistent across implementors
- [ ] 2. **Internal Consistency** — Record any cross-section references, preamble-to-body alignment, and SC-to-constraint relationships
- [ ] 3. **Completeness** — Record presence of undefined terms, missing SCs, implicit dependencies, TBD/TODO markers, and unspecified handoffs
- [ ] 4. **Scope Discipline** — Record stated scope boundaries and any elements that appear to exceed them
- [ ] 5. **Testability** — Record whether each SC references a verification method and whether any SC relies on subjective judgment
- [ ] 6. **Escape Hatches** — (Already collected in Step 6 — cross-reference here)
- [ ] 7. **Provenance** — Record whether the spec cites tool-call evidence, references verified files/functions, or makes unsupported assertions
- [ ] 8. **Feasibility** — Record references to files, functions, libraries, and whether they can be looked up
- [ ] 9. **Safety** — Record any destructive operations, data loss scenarios, or security-relevant changes mentioned
- [ ] 10. **Traceability** — Record SC-to-phase mappings, phase-to-step mappings, and any orphan elements
- [ ] 11. **Correctness** — Record the problem statement, root cause, and fix approach for alignment analysis

Record in evidence:

```yaml
holistic_dimension_evidence:
  implementability:
    single_approach_defined: true | false
    sc_count: <N>
    ambiguous_sc_count: <N>
  internal_consistency:
    cross_section_references: <N>
    preamble_body_alignment_notes: "<observations>"
  completeness:
    undefined_terms: ["<term>", ...]
    tbd_todo_markers: <N>
    implicit_dependencies: ["<description>", ...]
  scope_discipline:
    stated_boundaries: "<text or absent>"
    potential_scope_creep_elements: ["<description>", ...]
  testability:
    scs_with_verification_method: <N>
    scs_without_verification_method: <N>
    subjective_judgment_scs: ["<SC-ID>", ...]
  provenance:
    tool_call_evidence_cited: true | false
    unsupported_assertions: ["<text>", ...]
  feasibility:
    referenced_files: ["<path>", ...]
    referenced_functions: ["<name>", ...]
    referenced_libraries: ["<name>", ...]
  safety:
    destructive_operations: ["<description>", ...]
    data_loss_scenarios: ["<description>", ...]
    security_relevant_changes: ["<description>", ...]
  traceability:
    sc_to_phase_mapping: {<SC-ID>: "<phase or absent>", ...}
    orphan_scs: ["<SC-ID>", ...]
    orphan_phases: ["<phase>", ...]
  correctness:
    problem_statement: "<text or absent>"
    root_cause: "<text or absent>"
    fix_approach: "<text or absent>"
```

### Step 10: Write evidence.yaml

Write all collected evidence to `{artifact_evidence_dir}/evidence.yaml`:

```yaml
generator: spec-audit-generator
issue_number: <N>
generated_at: "<timestamp>"
spec_local_dir: "<path>"
spec_files: [...]
spec_structure: {...}
determinism_evidence: {...}
documentation_source_evidence: {...}
prose_evidence: {...}
reasoning_evidence: {...}
analytical_artifact_evidence: {...}
holistic_dimension_evidence: {...}
```

### Step 11: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{artifact_evidence_dir}/evidence.yaml"
summary: "Evidence collected: <N> spec files, <N> SCs, <N> documentation sources, <N> analytical artifacts. No judgments applied."
```

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load Spec Content → INVALID if skipped
- [ ] 3. Collect Spec Structure Evidence → INVALID if skipped
- [ ] 4. Collect Determinism Evidence → INVALID if skipped
- [ ] 5. Collect Live Documentation Source Evidence → INVALID if skipped
- [ ] 6. Collect Prose and Escape Hatch Evidence → INVALID if skipped
- [ ] 7. Collect Causal and Reasoning Evidence → INVALID if skipped
- [ ] 8. Collect Analytical Artifact Evidence → INVALID if skipped
- [ ] 9. Collect Holistic Dimension Evidence → INVALID if skipped
- [ ] 10. Write evidence.yaml → INVALID if skipped
- [ ] 11. Return Frugal Result Contract → INVALID if skipped

## Error Handling

| Error | Action |
|-------|--------|
| spec_local_dir missing or empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir contains no .md files | Return BLOCKED with SPEC_NOT_FOUND |
| artifact_evidence_dir not writable | Return BLOCKED with PERMISSION_DENIED |
| webfetch fails for a URL | Record as `accessible: false` with error — do NOT BLOCK |
| srclight_get_signature fails | Record as `found: false` — do NOT BLOCK |
| Analytical artifact path missing from dispatch | Record as `provided: false` — do NOT BLOCK |

## Cross-References

- `tasks/spec-audit.md` — Evaluator role (consumes this Generator's evidence.yaml)
- `tasks/cross-validate.md` — Path Provider role (consumes all upstream artifacts)
- `SKILL.md` — DiMo Role Chain Dispatch specification
- `.opencode/reference/holistic-dimensions.yaml` — 11 holistic dimensions definitions
- `080-code-standards.md` §Evidence Type Taxonomy — evidence type declarations

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
