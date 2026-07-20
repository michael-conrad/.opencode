# Plan: Behavioral SC evidence enforcement

**Issue:** #2011
**Spec:** `.opencode/.issues/2011/spec.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Goal

Fix behavioral SC evidence pipeline: add BEH-EV classification gate at spec-writing time, create clean-room evaluation task, fix all 8 evaluators to dispatch clean-room sub-agents for behavioral SCs, and add EVIDENCE_TYPE_MISMATCH detection in cross-validate.

## Architecture

Single-phase plan. 4 implementation items covering 12 files: spec-creation-validation/tasks/create.md, 9 evaluator tasks, cross-validate.md, and a new behavioral-sc-evaluator.md task.

## Files

| File | Change | SCs |
|------|--------|-----|
| `spec-creation-validation/tasks/create.md` | Add mandatory BEH-EV classification step with presumptive runtime-behavioral file types | SC-1 |
| `audit/tasks/behavioral-sc-evaluator.md` | New clean-room evaluation task — receives artifact dir only, reads stdout.log/stderr.log, renders binary PASS/FAIL | SC-3 |
| `audit/tasks/verification-audit-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/spec-audit-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/plan-fidelity-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/concern-separation-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/coherence-maintenance-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/drift-detection-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/test-quality-audit-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/content-audit-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/guideline-audit-evaluator.md` | Add clean-room sub-agent dispatch for behavioral SCs | SC-2 |
| `audit/tasks/cross-validate.md` | Add EVIDENCE_TYPE_MISMATCH detection for file-path-only behavioral verdicts | SC-4 |

## Phase Table

| Phase | File | Description | Steps | SCs |
|-------|------|-------------|-------|-----|
| 1 | `plan-01.md` | BEH-EV classification gate, clean-room evaluator task, fix 8 evaluators, fix cross-validate | 1-22 | SC-1 through SC-5 |

## Exit Criteria

| SC ID | Criterion | Evidence Type | Verification |
|-------|-----------|---------------|-------------|
| SC-1 | spec-creation-validation/tasks/create.md has mandatory BEH-EV classification step with presumptive file types | behavioral | `opencode run` → verify spec-creation agent includes BEH-EV classification step |
| SC-2 | ALL 9 evaluator tasks dispatch clean-room sub-agent for behavioral SCs | behavioral | `opencode run` → verify clean-room sub-agent dispatch in stderr |
| SC-3 | Clean-room sub-agent reads stdout.log/stderr.log, renders binary PASS/FAIL | behavioral | `opencode run` → verify clean-room sub-agent returns binary verdict |
| SC-4 | Cross-validate detects EVIDENCE_TYPE_MISMATCH on file-path-only behavioral verdicts | behavioral | `opencode run` → verify cross-validate FAILs on file-path-only verdict |
| SC-5 | All 5 SCs from #2009 remain satisfied | structural | `grep` for SC-1 through SC-5 in #2009 spec → all present |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — only file edits and new task file
- Rollback plan: `git checkout -- .opencode/skills/spec-creation/tasks/write.md .opencode/skills/audit/tasks/` to revert
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `spec-creation-validation/tasks/create.md` | ✅ | `ls` confirmed |
| 2 | `audit/tasks/` | ✅ | `ls` confirmed |
| 3-10 | Each evaluator file | ✅ | `ls` confirmed |
| 11 | `audit/tasks/cross-validate.md` | ✅ | `ls` confirmed |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | BEH-EV classification step in create.md | 1 | 4 (RED), 5 (GREEN) |
| SC-2 | All 8 evaluators dispatch clean-room sub-agent | 1 | 6-13 (RED/GREEN per evaluator) |
| SC-3 | Clean-room evaluator task created | 1 | 6 (GREEN) |
| SC-4 | Cross-validate EVIDENCE_TYPE_MISMATCH detection | 1 | 14 (RED), 15 (GREEN) |
| SC-5 | #2009 SCs remain satisfied | 1 | 16 (VbC) |
