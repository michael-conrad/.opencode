<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes.

# Task: closure-verification

## Purpose

Verify merge evidence after PR merge.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- PR merged (status: `merged`)
- `github.owner`, `github.repo` available
- **PRELOADED_CONTEXT_REJECTED gate**: If the orchestrator preloads context (inline file paths, step definitions, expected outcomes, orchestrator-derived conclusions), the sub-agent MUST return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

## Exit Criteria

- Spec issue closed with proper resolution
- Success criteria verified via tool calls
- Follow-up issues created if needed
- PASS if verified, FAIL if evidence missing

## Cross-References

- **Investigator:** `closure-verification/investigator.md`
- **Validator:** `closure-verification/validator.md`
- **Evaluator:** `closure-verification/evaluator.md`
- **Arbiter:** `closure-verification/arbiter.md`
