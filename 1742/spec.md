# [SPEC] Replace gap-fill cascade with state-verification checklist model

STATUS: open
LOCAL ARTIFACTS: `.opencode/.issues/4/`

## Problem
The gap-fill cascade is a flat action list that agents interpret as a skip-list rather than a state-verification checklist, bypassing all quality gates.

## Scope
Replace the cascade with a routing dispatcher that loads per-scope state-verification checklist files. Each item verifies a state and, if missing, reports which action to dispatch next.

## Local Artifacts
- spec.md: exists (full spec with Intent and Executive Summary, Objective, Problem, Scope sections)
- plan.md: missing
- Other: remote-exec-summary.md, revision-re-entry-contract.yaml, sc-summary.yaml, spec-to-plan-handoff.yaml, verification-consistency-contract.yaml

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/4/`*