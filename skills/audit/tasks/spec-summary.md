<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-summary

## Purpose

Verify PR/spec consistency before merge. This task has been split into a DiMo 4-role chain. Each role is a separate file in this directory.

## DiMo Chain Flow

The orchestrator dispatches the 4 roles sequentially:

1. **Generator** (`spec-summary/generator.md`) — Fetches PR, loads spec, produces `evidence.yaml`
2. **Knowledge Supporter** (`spec-summary/knowledge-supporter.md`) — Validates evidence, produces `reasoning.yaml`
3. **Evaluator** (`spec-summary/evaluator.md`) — Evaluates criteria, produces `verdict.yaml`
4. **Path Provider** (`spec-summary/path-provider.md`) — Provides recommendations, produces final result contract

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- PR number provided
- Spec issue number provided (linked from PR)
- `github.owner`, `github.repo` available

## Exit Criteria

- PR description matches spec
- Success criteria documented in PR
- Spec issue properly closed
- PASS if consistent, FAIL if mismatch

## Cross-References

- **Generator:** `spec-summary/generator.md`
- **Knowledge Supporter:** `spec-summary/knowledge-supporter.md`
- **Evaluator:** `spec-summary/evaluator.md`
- **Path Provider:** `spec-summary/path-provider.md`
