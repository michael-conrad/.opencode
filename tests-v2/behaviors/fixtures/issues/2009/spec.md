# Spec: Add Pipeline Completeness Check to Plan-Fidelity Evaluator

## Problem
The plan-fidelity evaluator (`audit/tasks/plan-fidelity-evaluator.md`) evaluates plan fidelity against spec but has no check for whether the plan includes all mandatory implementation pipeline stages. A plan that omits critical pipeline steps (assemble-work, sc-coherence-gate, pre-red-baseline, RED/GREEN per item, VbC, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary) passes the evaluator without detection.

## Success Criteria
| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Plan-fidelity evaluator checks for mandatory pipeline stages | behavioral |
| SC-2 | Plan missing pipeline stages produces FAIL verdict | behavioral |
| SC-3 | All mandatory stages from implementation-pipeline SKILL.md are enumerated | string |
