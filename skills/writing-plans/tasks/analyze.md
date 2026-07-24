<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: analyze

## Purpose

Verify spec exists locally, check approval from frontmatter, validate analytical artifacts exist.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `{issues_prefix}/{N}/spec.md` must exist
  - If missing: return BLOCKED with `SPEC_NOT_FOUND` and the resolved path
- The spec frontmatter `approved` field must be present and truthy
  - If not approved: return BLOCKED with `SPEC_NOT_APPROVED`
- The issue number `{N}` must be provided
- The project root and issues prefix must be set

## Procedure

1. Verify the spec file exists at `{issues_prefix}/{N}/spec.md`.
   - If missing: return BLOCKED with `SPEC_NOT_FOUND` and the resolved path.
2. Read the spec file and extract the frontmatter.
   - Verify the `approved` field is present and truthy.
   - If not approved: return BLOCKED with `SPEC_NOT_APPROVED`.
3. Read the spec body and extract the success criteria table.
   - Verify at least one SC is defined.
   - If no SCs: return BLOCKED with `NO_SUCCESS_CRITERIA`.
4. Check for existing analytical artifacts at `{issues_prefix}/{N}/artifacts/`.
   - Verify the following artifacts exist: `blast-radius.yaml`, `concern-map.yaml`, `code-path-inventory.yaml`, `cross-cutting-matrix.yaml`, `interface-compatibility.yaml`, `state-analysis.yaml`, `testability-assessment.yaml`.
   - For each missing artifact: record as a finding.
5. Check scope boundaries by reading the spec's affected files section.
   - Verify all referenced files exist in the codebase.
   - If any file is missing: record as a finding.
6. Write the analysis summary to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`.
   - Include: spec path, approval status, SC count, artifact presence per artifact, scope boundary findings.
7. Return the result contract.

## Exit Criteria

- The spec file has been verified to exist and be approved
- Analytical artifact presence has been checked and recorded
- Scope boundary findings have been recorded
- The analysis summary has been written to `{issues_prefix}/{N}/artifacts/analysis-summary.yaml`
- The artifact path has been set in the result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences summarizing spec approval, artifact coverage, and scope findings>"
artifact_path: "<{issues_prefix}/{N}/artifacts/analysis-summary.yaml>"
blocker_reason: "<reason if BLOCKED>"
```
