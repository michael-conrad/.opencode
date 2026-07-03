<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models

Invoke `.opencode/tools/resolve-models` to select two auditors from different model families.

Flags: `--orchestrator-model <model>` (required), `--re-task` (fresh randomization), `--excluded-pair <fam1>,<fam2>` (exclude specific families), `--test-insufficient-families` (force error for testing).

Output is YAML with 4 keys on success (`auditor_1`, `auditor_2`, `family_1`, `family_2`) or 3 keys on error (`error`, `reason`, `eligible_count`). The orchestrator uses `auditor_1` and `auditor_2` as `subagent_type` values for task() dispatch. Each auditor sub-agent writes its YAML verdict artifact to disk and returns a frugal contract with `artifact_path`. The orchestrator passes these `artifact_path` values to `cross-validate`.

resolve-models is the ONLY authorized entry point for auditor model resolution per adversarial-audit-013.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-15T00:00:00Z"
rules:
  - id: resolve-models-001
    title: "resolve-models tool command is the single source of truth"
    conditions:
      all: ["resolve_models_invoked == false"]
    actions: [HALT, CALL(.opencode/tools/resolve-models)]
    source: "resolve-models.md"
```
