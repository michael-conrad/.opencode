---
name: verification-audit-generator
description: "Investigator role for the verification-audit DiMo chain. Collects raw evidence from spec SCs and behavioral evidence artifacts. Writes evidence.yaml — does NOT evaluate or judge."
license: MIT
compatibility: opencode
---

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verification-audit-generator

## Purpose

Collect raw evidence for verification-audit. Reads spec success criteria and behavioral evidence artifacts, maps SCs to evidence, and writes `evidence.yaml`. This is the Investigator role in the DiMo 4-role chain — it collects, it does NOT evaluate or judge.


>

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec Markdown files
- `artifact_evidence_dir`: Directory containing behavioral evidence artifacts from the implementation run
- `spec_issue_number`: Issue number for artifact path construction

## Entry Criteria

- `spec_local_dir` provided (local issue directory containing Markdown spec files) — MUST be a filesystem directory confirmed to exist before dispatch
- `artifact_evidence_dir` provided — MUST be present and non-empty. Behavioral evidence artifacts from the implementation run MUST exist. If absent: return BLOCKED with MISSING_EVIDENCE_DIR.
- `spec_issue_number` provided
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- All spec SCs extracted with evidence type declarations
- All behavioral evidence artifacts collected and catalogued
- SC-to-evidence mapping built
- `evidence.yaml` written to `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml`
- No PASS/FAIL judgments in output — raw evidence only

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/verification-audit/`

### Step 1: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding:

- [ ] 1. Verify `spec_local_dir` is present and non-empty — glob `**/*.md` in `<spec_local_dir>/`
- [ ] 2. Verify `artifact_evidence_dir` is present and non-empty — glob for evidence files

If `spec_local_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec_local_dir"
remediation: "spec_local_dir is required for verification-audit-generator. The orchestrator must provide a valid local directory containing spec Markdown files."
```

If `artifact_evidence_dir` is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_EVIDENCE_DIR
missing: "artifact_evidence_dir"
remediation: "artifact_evidence_dir is required for verification-audit-generator. The orchestrator must provide a directory containing behavioral evidence artifacts from the implementation run."
```

### Step 2: Load Spec Content

Read spec from `spec_local_dir/`:

- [ ] 1. Glob `**/*.md` in `<spec_local_dir>/` via `glob` tool, read all discovered files
- [ ] 2. Extract SC table with evidence type declarations
- [ ] 3. Record each SC: ID, criterion text, declared evidence type, verification method
- [ ] 4. Identify behavioral SCs (those requiring execution evidence)

### Step 3: Collect Behavioral Evidence Artifacts

Scan `artifact_evidence_dir/` for evidence artifacts:

- [ ] 1. Glob all files in `<artifact_evidence_dir>/`
- [ ] 2. For each artifact, record: filename, path, size, modification time
- [ ] 3. Categorize artifacts by type: behavioral test output, session logs, stderr/stdout captures, YAML verdicts
- [ ] 4. Do NOT evaluate artifact content — record existence and metadata only

### Step 4: Map SCs to Evidence Artifacts

Build the SC-to-evidence mapping:

- [ ] 1. For each SC from the spec, identify which evidence artifacts correspond to it
- [ ] 2. Record the mapping: SC ID → evidence artifact path(s)
- [ ] 3. Flag any SC that has no corresponding evidence artifact (record as `evidence: missing`)
- [ ] 4. Do NOT judge whether the mapping is sufficient — record what exists

### Step 5: Build Evidence Structure

Assemble the evidence structure:

```yaml
evidence:
  generated_at: "<ISO timestamp>"
  spec_issue_number: <N>
  spec_source: "<spec_local_dir>"
  evidence_source: "<artifact_evidence_dir>"
  spec:
    files: ["<path>", ...]
    sc_count: <N>
    behavioral_sc_count: <N>
    string_sc_count: <N>
    structural_sc_count: <N>
    semantic_sc_count: <N>
  evidence_artifacts:
    - filename: "<name>"
      path: "<full path>"
      size_bytes: <N>
      modified: "<ISO timestamp>"
      category: "behavioral_test_output | session_log | stderr_capture | stdout_capture | yaml_verdict | other"
  sc_evidence_map:
    - sc_id: "SC-1"
      criterion: "<criterion text>"
      declared_evidence_type: "behavioral | semantic | string | structural"
      evidence_artifacts: ["<path>", ...]
      evidence_status: "present | missing"
    - sc_id: "SC-N"
      criterion: "<criterion text>"
      declared_evidence_type: "behavioral"
      evidence_artifacts: []
      evidence_status: "missing"
```

### Step 6: Write evidence.yaml

Write the assembled evidence structure to `./tmp/{issue-N}/artifacts/verification-audit/evidence.yaml`:

- [ ] 1. Create artifact directory if it does not exist: `mkdir -p ./tmp/{issue-N}/artifacts/verification-audit/`
- [ ] 2. Write `evidence.yaml` with the complete evidence structure
- [ ] 3. Verify the file was written and is non-empty

### Step 7: Return Frugal Result Contract

Return only routing-significant data:

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
summary: "Evidence collected: {sc_count} SCs extracted, {behavioral_sc_count} behavioral, {evidence_count} evidence artifacts catalogued. {missing_count} SCs have no evidence."
sc_count: <N>
behavioral_sc_count: <N>
evidence_artifact_count: <N>
missing_evidence_count: <N>
```

## Result Contract

```yaml
status: DONE | BLOCKED
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/verification-audit/evidence.yaml"
summary: "Evidence collected: {sc_count} SCs extracted, {behavioral_sc_count} behavioral, {evidence_count} evidence artifacts catalogued. {missing_count} SCs have no evidence."
```

## Error Handling

| Error | Action |
|-------|--------|
| spec_local_dir absent | Return BLOCKED with MISSING_REQUIRED_INPUT |
| spec_local_dir empty | Return BLOCKED with MISSING_REQUIRED_INPUT |
| artifact_evidence_dir absent | Return BLOCKED with MISSING_EVIDENCE_DIR |
| artifact_evidence_dir empty | Return BLOCKED with MISSING_EVIDENCE_DIR |
| No SCs found in spec | Return BLOCKED — spec must contain SC table |
| Write permission denied | Return BLOCKED — cannot write evidence.yaml |
| Malformed spec file | Return BLOCKED with parse error details |

## Cross-References

- `tasks/verification-audit.md` — Evaluator role (reads evidence.yaml, writes verdict.yaml)
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

