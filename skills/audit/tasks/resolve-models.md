<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: resolve-models (Reference — N/A with Single-Agent Dispatch)

## Purpose

Reference document for model selection. With single-agent dispatch (all audits use `task(subagent_type="general")`), model selection is N/A — there is no Path Provider role, no cross-family auditor selection, and no separate model resolution step. The orchestrator dispatches a single sub-agent for each audit task, and the sub-agent uses whatever model the orchestrator provides.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files (passed through for pipeline consistency)
- `artifact_evidence_dir`: Directory for evidence artifacts (passed through for pipeline consistency)

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/resolve-models/`

### Step 1: Write reasoning.yaml

Write a minimal routing note to `./tmp/{issue-N}/artifacts/resolve-models/reasoning.yaml`:

```yaml
role: N/A — single-agent dispatch
note: "Model selection is N/A with single-agent dispatch. All audit tasks use task(subagent_type='general'). No cross-family auditor selection needed."
```

### Step 2: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/{issue-N}/artifacts/resolve-models/reasoning.yaml"
summary: "Model selection is N/A with single-agent dispatch. No Path Provider role needed."
```

## Remediation

If any step FAILs, restart from step 0 (pre-clean).
