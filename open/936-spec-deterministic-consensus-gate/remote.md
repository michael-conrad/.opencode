---
remote_issue: 936
remote_url: "https://github.com/michael-conrad/.opencode/issues/936"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Problem

Cross-validate computes auditor verdict consensus through LLM-mediated prose table lookup, producing false-PASS rationalizations.

## Changes

### 1. New consensus-gate tool
Deterministic bash script using yq for YAML parsing.

### 2. Restructure cross-validate.md
Remove deterministic steps, scope to semantic checks only.

### 3. Orchestrator routing
Orchestrator runs consensus-gate between auditor dispatch and cross-validate.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | consensus-gate exists and is executable | structural |
| SC-2 | Unknown values -> FAIL | string |
| SC-3 | Both PASS -> PASS | behavioral |
| SC-9 | Cross-validate cannot downgrade FAIL | behavioral |
| SC-10 | Orchestrator runs consensus-gate between auditors | behavioral |
| SC-12 | No UNVERIFIED -> PASS path exists | behavioral |

🤖 Co-authored with AI: DeepSeek V4 Flash