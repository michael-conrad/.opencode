---
name: verification-audit-knowledge-supporter
description: "Validator role for the verification-audit DiMo chain. Reads evidence.yaml from the Investigator, validates each evidence item against source data, and writes reasoning.yaml with validated evidence. Does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-audit-knowledge-supporter

## Purpose

Validator role for the verification-audit DiMo chain. Reads `evidence.yaml` produced by the Investigator, validates each evidence item against source data (spec files, behavioral evidence artifacts), and writes `reasoning.yaml` with validated evidence. This role validates and supports — it does NOT evaluate, judge, or produce PASS/FAIL verdicts.


>

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory containing behavioral evidence artifacts from the implementation run
- `spec_issue_number`: Issue number for artifact path construction
- `github.owner`, `github.repo`: Repository identity

## Entry Criteria

- `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — MUST be present and non-empty. If absent: return BLOCKED with MISSING_EVIDENCE_YAML.
- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `artifact_evidence_dir` provided — MUST be present and non-empty
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- All evidence items from `evidence.yaml` validated against source data
- Each SC-to-evidence mapping verified — evidence artifacts exist and are readable
- Evidence type declarations cross-checked against spec source
- Evidence artifact metadata validated (size, modification time, readability)
- `reasoning.yaml` written to `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml`
- No PASS/FAIL judgments in output — validated evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove `reasoning.yaml` if it exists from a prior run at `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `evidence.yaml` exists at `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml` — read the file and confirm it is non-empty
- [ ] 2. If `evidence.yaml` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_YAML
missing: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
remediation: "evidence.yaml is required for verification-audit-knowledge-supporter. The Investigator must produce evidence.yaml before the Validator can validate it."
```

- [ ] 3. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 4. If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for verification-audit-knowledge-supporter. The orchestrator must provide a valid local directory containing spec Markdown files."
```

- [ ] 5. Verify `artifact_evidence_dir` is present and non-empty — glob for evidence files
- [ ] 6. If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit-knowledge-supporter. The orchestrator must provide a directory containing behavioral evidence artifacts from the implementation run."
```

### Step 2: Load evidence.yaml

Read the Investigator's `evidence.yaml` from `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml`:

- [ ] 1. Read the full YAML file via `read` tool
- [ ] 2. Parse the evidence structure: `spec`, `evidence_artifacts`, `sc_evidence_map`
- [ ] 3. Extract the list of SCs with their declared evidence types and mapped evidence artifacts
- [ ] 4. Extract the list of evidence artifacts with their metadata (filename, path, size, modification time, category)
- [ ] 5. Record the `generated_at` timestamp and `spec_issue_number` from the evidence

### Step 3: Validate SC-to-Evidence Mappings

For each SC entry in `sc_evidence_map`, validate the mapping against source data:

- [ ] 1. **SC existence check** — For each SC ID in the evidence map, verify the SC exists in the spec files at `spec_local_dir/`. Read the spec files and confirm the SC ID and criterion text match.
- [ ] 2. **Evidence type cross-check** — For each SC, read the declared evidence type from the spec source and compare against the `declared_evidence_type` in the evidence map. Record any mismatch.
- [ ] 3. **Evidence artifact existence check** — For each evidence artifact path listed in the SC's `evidence_artifacts` array, verify the file exists on disk at the specified path. Use `glob` or `read` to confirm.
- [ ] 4. **Evidence artifact readability check** — For each evidence artifact, attempt to read the file. Record whether it is readable and non-empty.
- [ ] 5. **Evidence status validation** — For each SC, verify that `evidence_status` in the evidence map is consistent with the actual presence of evidence artifacts. If `evidence_status` is `"present"` but no artifacts exist, flag as `EVIDENCE_STATUS_MISMATCH`. If `evidence_status` is `"missing"` but artifacts do exist, flag as `EVIDENCE_STATUS_MISMATCH`.

Record validation results:

```yaml
sc_validation:
  - sc_id: "SC-1"
    sc_exists_in_spec: true | false
    criterion_text_matches: true | false
    declared_evidence_type_matches_spec: true | false
    spec_declared_type: "<type from spec>"
    evidence_declared_type: "<type from evidence.yaml>"
    evidence_artifacts_exist: true | false
    evidence_artifacts_readable: true | false
    evidence_status_valid: true | false
    evidence_status_issue: "<description or null>"
    missing_artifacts: ["<path>", ...]
    unreadable_artifacts: ["<path>", ...]
```

### Step 4: Validate Evidence Artifact Metadata

For each evidence artifact in the `evidence_artifacts` list, validate the metadata against the actual files on disk:

- [ ] 1. **Size validation** — For each artifact, compare the `size_bytes` in the evidence map against the actual file size on disk. Record any discrepancy.
- [ ] 2. **Modification time validation** — For each artifact, compare the `modified` timestamp in the evidence map against the actual file modification time. Record any discrepancy.
- [ ] 3. **Category validation** — For each artifact, verify that the `category` assignment is consistent with the file content. Read the file and confirm the category is appropriate.
- [ ] 4. **Path validation** — For each artifact, verify the `path` in the evidence map resolves to the actual file. Record any path mismatch.

Record validation results:

```yaml
artifact_metadata_validation:
  - filename: "<name>"
    path_in_evidence: "<path from evidence.yaml>"
    path_exists: true | false
    size_matches: true | false
    evidence_size: <N>
    actual_size: <N>
    modification_time_matches: true | false
    evidence_modified: "<timestamp>"
    actual_modified: "<timestamp>"
    category_valid: true | false
    evidence_category: "<category>"
    observed_content_type: "<description>"
```

### Step 5: Validate Spec Metadata

Cross-check the spec metadata in `evidence.yaml` against the actual spec files:

- [ ] 1. **Spec file count validation** — Verify the `spec.files` list matches the actual files in `spec_local_dir/`. Record any missing or extra files.
- [ ] 2. **SC count validation** — Verify the `spec.sc_count` matches the actual number of SCs found in the spec files. Record any discrepancy.
- [ ] 3. **SC type count validation** — Verify the `spec.behavioral_sc_count`, `spec.string_sc_count`, `spec.structural_sc_count`, and `spec.semantic_sc_count` match the actual counts from the spec's evidence type declarations. Record any discrepancy.

Record validation results:

```yaml
spec_metadata_validation:
  file_count_matches: true | false
  evidence_file_count: <N>
  actual_file_count: <N>
  missing_files: ["<path>", ...]
  extra_files: ["<path>", ...]
  sc_count_matches: true | false
  evidence_sc_count: <N>
  actual_sc_count: <N>
  behavioral_sc_count_matches: true | false
  evidence_behavioral_count: <N>
  actual_behavioral_count: <N>
  string_sc_count_matches: true | false
  evidence_string_count: <N>
  actual_string_count: <N>
  structural_sc_count_matches: true | false
  evidence_structural_count: <N>
  actual_structural_count: <N>
  semantic_sc_count_matches: true | false
  evidence_semantic_count: <N>
  actual_semantic_count: <N>
```

### Step 6: Validate Evidence Type Compliance

For each SC, validate that the evidence artifacts provided are appropriate for the declared evidence type:

- [ ] 1. **Behavioral SC check** — For each SC declared as `behavioral`, verify that at least one evidence artifact is a behavioral test output (session log, stderr capture, stdout capture, or YAML verdict from test execution). If only structural evidence (file existence) is provided, flag as `EVIDENCE_TYPE_GAP`.
- [ ] 2. **Semantic SC check** — For each SC declared as `semantic`, verify that evidence goes beyond string matching. Flag if only grep/pattern evidence is provided.
- [ ] 3. **String SC check** — For each SC declared as `string`, verify that evidence includes pattern matching or content verification. Flag if only file existence is provided.
- [ ] 4. **Structural SC check** — For each SC declared as `structural`, verify that evidence includes file existence or structure checks.

Record validation results:

```yaml
evidence_type_validation:
  - sc_id: "SC-1"
    declared_type: "behavioral"
    has_behavioral_evidence: true | false
    has_only_structural_evidence: true | false
    evidence_type_gap: true | false
    gap_description: "<description or null>"
```

### Step 7: Assemble reasoning.yaml

Assemble the validated evidence into the reasoning structure:

```yaml
reasoning:
  generated_at: "<ISO timestamp>"
  spec_issue_number: <N>
  evidence_source: "./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
  evidence_generated_at: "<timestamp from evidence.yaml>"
  validation_summary:
    total_scs: <N>
    scs_validated: <N>
    scs_with_issues: <N>
    total_evidence_artifacts: <N>
    artifacts_validated: <N>
    artifacts_with_issues: <N>
  sc_validation: [...]
  artifact_metadata_validation: [...]
  spec_metadata_validation: {...}
  evidence_type_validation: [...]
  issues:
    - type: "EVIDENCE_STATUS_MISMATCH | EVIDENCE_TYPE_GAP | MISSING_ARTIFACT | UNREADABLE_ARTIFACT | METADATA_MISMATCH | SC_NOT_IN_SPEC | TYPE_DECLARATION_MISMATCH"
      sc_id: "<SC-ID or null>"
      artifact: "<path or null>"
      description: "<description>"
```

### Step 8: Write reasoning.yaml

Write the assembled reasoning structure to `./tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml`:

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p ./tmp/{issue-N}/artifacts/verification-audit/`
- [ ] 2. Write `reasoning.yaml` with the complete reasoning structure
- [ ] 3. Verify the file was written and is non-empty

### Step 9: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
summary: "Evidence validated: {scs_validated}/{total_scs} SCs validated, {artifacts_validated}/{total_artifacts} artifacts validated. {issue_count} issues found."
scs_validated: <N>
total_scs: <N>
artifacts_validated: <N>
total_artifacts: <N>
issue_count: <N>
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/reasoning.yaml"
summary: "Evidence validated: {scs_validated}/{total_scs} SCs validated, {artifacts_validated}/{total_artifacts} artifacts validated. {issue_count} issues found."
```

## Error Handling

| Error | Action |
|-------|--------|
| evidence.yaml absent | Return BLOCKED with MISSING_EVIDENCE_YAML |
| evidence.yaml empty or unparseable | Return BLOCKED with UNPARSEABLE_EVIDENCE_YAML |
| spec_local_dir absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir absent | Return BLOCKED with MISSING_EVIDENCE_DIR |
| artifact_evidence_dir empty | Return BLOCKED with MISSING_EVIDENCE_DIR |
| No SCs in evidence.yaml | Return BLOCKED — evidence.yaml must contain SC mappings |
| Evidence artifact path mismatch | Record as issue in reasoning.yaml — do NOT BLOCK |
| Evidence artifact unreadable | Record as issue in reasoning.yaml — do NOT BLOCK |
| SC not found in spec | Record as issue in reasoning.yaml — do NOT BLOCK |
| Write permission denied | Return BLOCKED — cannot write reasoning.yaml |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:

- [ ] 0. Pre-clean → INVALID if skipped
- [ ] 1. Pre-Flight Validation Gate → INVALID if skipped
- [ ] 2. Load evidence.yaml → INVALID if skipped
- [ ] 3. Validate SC-to-Evidence Mappings → INVALID if skipped
- [ ] 4. Validate Evidence Artifact Metadata → INVALID if skipped
- [ ] 5. Validate Spec Metadata → INVALID if skipped
- [ ] 6. Validate Evidence Type Compliance → INVALID if skipped
- [ ] 7. Assemble reasoning.yaml → INVALID if skipped
- [ ] 8. Write reasoning.yaml → INVALID if skipped
- [ ] 9. Return Frugal Result Contract → INVALID if skipped

## Cross-References

- `tasks/verification-audit-investigator.md` — Investigator role (produces evidence.yaml consumed by this task)
- `tasks/verification-audit.md` — Evaluator role (consumes reasoning.yaml produced by this task)
- `tasks/cross-validate.md` — Arbiter role (reads all artifacts, writes judgment.yaml)
- `audit/SKILL.md` — DiMo Role Chain Dispatch (Investigator → Validator → Evaluator → Arbiter)
- Load [Evidence Type Taxonomy](guidelines/080-code-standards.md) — evidence type declarations and enforcement matrix
- Load [implementation-pipeline SKILL.md](skills/implementation-pipeline/SKILL.md) — Trigger Dispatch Table (dispatches verification-audit)
- Load [000-critical-rules.md](guidelines/000-critical-rules.md) — behavioral evidence mandate

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

## Output Contract

| Field | Required | Format | Description |
|-------|----------|--------|-------------|
| `artifact_path` | Yes | `{project_root}/tmp/{issue-N}/artifacts/{chain}/...` | Path to the output artifact file |
| `artifact_format` | Yes | `yaml` | Format of the output artifact |
| `status` | Yes | `DONE | BLOCKED` | Task completion status |
| `summary` | Yes | `string` | 1-3 sentence summary of findings |

The output artifact MUST be written to `artifact_path` before returning.

## Frugal Contract

The sub-agent MUST return only the following fields to the orchestrator:

| Field | Required | Description |
|-------|----------|-------------|
| `status` | Yes | `DONE` / `BLOCKED` / `OVERFLOW` |
| `finding_summary` | Yes | 1-3 sentences of routing-significant output |
| `artifact_path` | Yes | Path to the full evidence artifact on disk |
| `blocker_reason` | If BLOCKED | Why the task was blocked |

Full evidence artifacts go to disk at `artifact_path`. The orchestrator reads only this contract — it does NOT re-read the artifact.

## Clean-Room Validation

This task requires independence from orchestrator bias. The sub-agent MUST:

1. **Reject preloaded context** — return `PRELOADED_CONTEXT_REJECTED` if the orchestrator includes inline reasoning, expected outcomes, file paths, or step sequences
2. **Discover scope independently** — read source files, run analysis tools, and determine the scope without orchestrator hints
3. **Produce evidence independently** — write full evidence artifacts to disk before returning
4. **Render binary judgment** — PASS (100% clean, no caveats) or FAIL (any caveat, any concern, any non-100% clean pass)

