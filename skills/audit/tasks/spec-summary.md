<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-summary

## Purpose

Verify PR/spec consistency before merge.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- PR number provided
- Spec issue number provided (linked from PR)
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- PR description matches spec
- Success criteria documented in PR
- Spec issue properly closed
- PASS if consistent, FAIL if mismatch

## Cross-References

- **Investigator:** `spec-summary/investigator.md`
- **Validator:** `spec-summary/validator.md`
- **Evaluator:** `spec-summary/evaluator.md`
- **Arbiter:** `spec-summary/arbiter.md`
