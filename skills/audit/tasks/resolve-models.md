<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models (Path Provider — Reference)

> **DiMo Role: Path Provider.** This task resolves which models are available for the audit pipeline. It provides the path (model selection) for downstream roles.

## Purpose

Reference document for the Path Provider role in the DiMo role chain. Model selection is embedded in each task's sequential dispatch — no separate `resolve-models` invocation is needed.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files (passed through for pipeline consistency)
- `artifact_evidence_dir`: Directory for evidence artifacts (passed through for pipeline consistency)

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/resolve-models/`

### Step 1: Write reasoning.yaml

Write model selection and routing rationale to `./tmp/{issue-N}/artifacts/resolve-models/reasoning.yaml`:

```yaml
role: Path Provider
model_selection:
  evaluator_model: "<model>"
  judger_model: "<model>"
  rationale: "Cross-family auditor selection for independent evaluation"
artifact_paths:
  evidence_yaml: "./tmp/{issue-N}/artifacts/{task}/evidence.yaml"
  reasoning_yaml: "./tmp/{issue-N}/artifacts/resolve-models/reasoning.yaml"
  verdict_yaml: "./tmp/{issue-N}/artifacts/{task}/verdict.yaml"
  judgment_yaml: "./tmp/{issue-N}/artifacts/cross-validate/judgment.yaml"
```

### Step 2: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/{issue-N}/artifacts/resolve-models/reasoning.yaml"
summary: "Model selection and routing rationale written to reasoning.yaml"
```

## Remediation

If any step FAILs, restart from step 0 (pre-clean).
