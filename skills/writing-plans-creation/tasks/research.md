# Task: research

## Purpose

Load the `verification-enforcement` skill and execute `--task verify` inline, collecting live-source evidence for all factual claims before any plan content is written. This is a hard gate — the pipeline MUST NOT proceed without PASS.

## Entry Criteria

- Approved spec exists
- Spec has explicit approval

## Exit Criteria

- Evidence artifacts collected for all factual claims
- Result contract contains `evidence_artifacts` field (list of paths)
- If any claim is unverifiable: return BLOCKED with empty evidence_artifacts

## Procedure

- [ ] 1. Load `verification-enforcement` skill: `skill({name: "verification-enforcement"})`
- [ ] 1a.  Load blast radius artifact — read `.issues/{N}/blast-radius.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/blast-radius.yaml")`
  - Expected: file exists, non-empty, valid YAML with `affected_files` and `impact_zones` keys
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: blast-radius.yaml`
- [ ] 1b.  Load concern map artifact — read `.issues/{N}/concern-map.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/concern-map.yaml")`
  - Expected: file exists, non-empty, valid YAML with `concerns` list
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: concern-map.yaml`
- [ ] 1c.  Load code path inventory artifact — read `.issues/{N}/code-path-inventory.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/code-path-inventory.yaml")`
  - Expected: file exists, non-empty, valid YAML with `paths` list
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: code-path-inventory.yaml`
- [ ] 1d.  Load cross-cutting matrix artifact — read `.issues/{N}/cross-cutting-matrix.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/cross-cutting-matrix.yaml")`
  - Expected: file exists, non-empty, valid YAML with `cross_cutting_scs` list
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: cross-cutting-matrix.yaml`
- [ ] 1e.  Load interface compatibility artifact — read `.issues/{N}/interface-compatibility.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/interface-compatibility.yaml")`
  - Expected: file exists, non-empty, valid YAML with `interfaces` list
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: interface-compatibility.yaml`
- [ ] 1f.  Load state analysis artifact — read `.issues/{N}/state-analysis.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/state-analysis.yaml")`
  - Expected: file exists, non-empty, valid YAML with `states` and `transitions` keys
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: state-analysis.yaml`
- [ ] 1g.  Load testability assessment artifact — read `.issues/{N}/testability-assessment.yaml`
  - Command: `read(filePath="{project_root}/{path}/.issues/{N}/testability-assessment.yaml")`
  - Expected: file exists, non-empty, valid YAML with `scs` list containing `evidence_type` per entry
  - If missing: return BLOCKED with `MISSING_SPEC_ARTIFACT: testability-assessment.yaml`
- [ ] 2. Execute `--task verify` inline within this context
- [ ] 3. Collect evidence artifact paths from verification output
- [ ] 4. If all claims verified: return PASS with evidence_artifacts
- [ ] 5. If any claim unverifiable: return BLOCKED with empty evidence_artifacts — pipeline halts

## Context Required

- Related skills: `verification-enforcement`
- Related guidelines: `065-verification-honesty.md`

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "..." |
| artifact_path | ".../artifacts/research.yaml" |
| blocker_reason | "..." |
