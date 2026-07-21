---
title: "SPEC-FIX: 42 orphaned task card files not referenced by any Trigger Dispatch Table"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2039
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order.

## Problem

42 task card files exist in `tasks/` directories but are not referenced by any SKILL.md Trigger Dispatch Table or Invocation section. These orphaned files are dead code — the orchestrator never dispatches them, and no sub-agent ever reads them.

## Affected Skills and Orphaned Files

| Skill | Orphaned Files |
|-------|---------------|
| `implementation-pipeline` | `pipeline-executor.md`, `pre-flight-handoff.md`, `sc-closeout.md` |
| `executing-plans` | `progress.md`, `start.md`, `step.md`, `verify.md`, `operating-protocol.md` |
| `spec-creation-validation` | `create-remote-stub.md`, `holistic-self-check.md`, `pipeline-readiness-gate.md`, `pre-spec-inspection.md`, `revise-remote-body.md`, `risk.md`, `traceability.md` |
| `spec-creation-decomposition` | `analytical-artifacts.md`, `blast-radius.md`, `code-path-analysis.md`, `concern-analysis.md`, `cross-cutting.md`, `decompose.md`, `interface-compatibility.md`, `state-analysis.md`, `testability-assessment.md` |
| `spec-creation-requirements` | `requirements.md` |
| `spec-creation-change-control` | `change-control.md` |
| `writing-plans-creation` | All 16 task files |
| `writing-plans-holistic` | `holistic-self-check.md` |

## Root Cause

Task cards were created as part of the skill decomposition but the SKILL.md Trigger Dispatch Table was never updated to reference them. The task cards exist on disk but are unreachable by the orchestrator.

## Fix

For each orphaned task card, either:
1. Add a TDT entry in the parent SKILL.md that references it, OR
2. Delete the orphaned file if the task is no longer needed

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 42 orphaned task cards are either TDT-referenced or deleted | `string` | Cross-reference all task files against all TDTs |
| SC-2 | No unreferenced task card files remain in any `tasks/` directory | `string` | grep for all task files not in any TDT |

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
