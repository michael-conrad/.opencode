# Task: readiness

## Purpose

Pipeline-readiness gate check and spec-to-plan handoff verification. Ensures the spec has passed all pre-plan validation gates before any plan content is written.

## Entry Criteria

- Research step completed with PASS
- Research evidence artifacts available

## Exit Criteria

- Pipeline-readiness status determined (PASS/FAIL)
- Spec-to-plan handoff verified
- Result contract contains status field

## Procedure

1. Read `.issues/{issue-N}/sc-pipeline-readiness.yaml`
2. Assert `status: PASS`
3. If status is FAIL or file does not exist: return BLOCKED with `SPEC_NOT_READY_FOR_PIPELINE`
4. If PASS: extract `sc_summary` (total_scs, atomic, with_dependencies, single_concern) and phase dependency declarations
5. Return PASS with readiness data

## Context Required

- Related tasks: `create/plan-structure`
- Related skills: `approval-gate`
