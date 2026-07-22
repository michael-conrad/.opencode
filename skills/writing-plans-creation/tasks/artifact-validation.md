# Task: artifact-validation

## Purpose

Validate that all expected analytical artifacts from spec-creation exist, are non-empty, and are well-formed YAML. This is a hard gate — the pipeline MUST NOT proceed without PASS.

## Entry Criteria

- Spec issue number `{N}` is known
- `project_root` and `path` are available for artifact path resolution

## Exit Criteria

- All 7 analytical artifacts validated (exist, non-empty, well-formed YAML)
- Result contract contains `artifact_status` field with per-artifact PASS/FAIL
- If any artifact is missing, empty, or malformed: return BLOCKED with `MISSING_SPEC_ARTIFACT`

## Required Artifacts

| # | Artifact | Path | Required Keys |
|---|----------|------|---------------|
| 1 | Blast radius | `{project_root}/{path}/.issues/{N}/blast-radius.yaml` | `affected_files`, `impact_zones` |
| 2 | Concern map | `{project_root}/{path}/.issues/{N}/concern-map.yaml` | `concerns` |
| 3 | Code path inventory | `{project_root}/{path}/.issues/{N}/code-path-inventory.yaml` | `paths` |
| 4 | Cross-cutting matrix | `{project_root}/{path}/.issues/{N}/cross-cutting-matrix.yaml` | `cross_cutting_scs` |
| 5 | Interface compatibility | `{project_root}/{path}/.issues/{N}/interface-compatibility.yaml` | `interfaces` |
| 6 | State analysis | `{project_root}/{path}/.issues/{N}/state-analysis.yaml` | `states`, `transitions` |
| 7 | Testability assessment | `{project_root}/{path}/.issues/{N}/testability-assessment.yaml` | `scs` with `evidence_type` per entry |

## Procedure

- [ ] 1.  Validate blast radius artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/blast-radius.yaml")`
  - Expected: file exists, non-empty, valid YAML with `affected_files` (list) and `impact_zones` (list) keys
  - If missing/empty/malformed: record FAIL for blast-radius

- [ ] 2.  Validate concern map artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/concern-map.yaml")`
  - Expected: file exists, non-empty, valid YAML with `concerns` (list) key
  - If missing/empty/malformed: record FAIL for concern-map

- [ ] 3.  Validate code path inventory artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/code-path-inventory.yaml")`
  - Expected: file exists, non-empty, valid YAML with `paths` (list) key
  - If missing/empty/malformed: record FAIL for code-path-inventory

- [ ] 4.  Validate cross-cutting matrix artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/cross-cutting-matrix.yaml")`
  - Expected: file exists, non-empty, valid YAML with `cross_cutting_scs` (list) key
  - If missing/empty/malformed: record FAIL for cross-cutting-matrix

- [ ] 5.  Validate interface compatibility artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/interface-compatibility.yaml")`
  - Expected: file exists, non-empty, valid YAML with `interfaces` (list) key
  - If missing/empty/malformed: record FAIL for interface-compatibility

- [ ] 6.  Validate state analysis artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/state-analysis.yaml")`
  - Expected: file exists, non-empty, valid YAML with `states` (list) and `transitions` (list) keys
  - If missing/empty/malformed: record FAIL for state-analysis

- [ ] 7.  Validate testability assessment artifact
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/testability-assessment.yaml")`
  - Expected: file exists, non-empty, valid YAML with `scs` (list) key where each entry has `evidence_type`
  - If missing/empty/malformed: record FAIL for testability-assessment

- [ ] 8.  Aggregate results
  - Command: check all 7 artifact statuses
  - Expected: all PASS
  - If any FAIL: return BLOCKED with `MISSING_SPEC_ARTIFACT` and list of failed artifacts

- [ ] 9.  Return PASS with artifact_status
  - Command: produce result contract with `artifact_status` field containing per-artifact PASS/FAIL
  - Expected: all artifacts validated, PASS returned

## Context Required

- Related tasks: `create` (21-step pipeline)
- Related skills: `spec-creation`
- Related guidelines: `060-tool-usage.md`
