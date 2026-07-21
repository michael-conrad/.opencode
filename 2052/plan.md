# Plan: Canonical Skill Card Structure Template (T-1)

## Overview

This is a **template spec (T-1)** that produces no file changes. It is a reference document consumed by fix specs F-1 through F-7. The spec is already written and complete.

## Phase Table

| Phase | Description | Status | SCs |
|-------|-------------|--------|-----|
| 1 | Write template spec (T-1) | ✅ COMPLETE | All SC-1 through SC-9 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | No global `## Invocation` section | 1 | Spec written (complete) |
| SC-2 | No global `## DISPATCH_GATE` section | 1 | Spec written (complete) |
| SC-3 | `## Pre-Flight Gate` as first content section | 1 | Spec written (complete) |
| SC-4 | TDT Dispatch uses valid patterns only | 1 | Spec written (complete) |
| SC-5 | Enumerated workflows with per-step dispatch | 1 | Spec written (complete) |
| SC-6 | No "dispatch via task()" in lead-in text | 1 | Spec written (complete) |
| SC-7 | Pre-Flight Gate blocking message matches canonical format | 1 | Spec written (complete) |
| SC-8 | Orchestrator stops on BLOCKED from pre-flight gate | 1 | Spec written (complete) |
| SC-9 | Orchestrator dispatches individual task files, not entire SKILL.md | 1 | Spec written (complete) |

## Safety/Rollback Considerations

**No destructive operations in any phase.** This is a reference-only template spec.

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | Spec body (issue.yaml) | ✅ | Read from `.opencode/.issues/2052/issue.yaml` |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Spec exists and is complete | `read(.opencode/.issues/2052/issue.yaml)` | ✅ |
| Spec produces no file changes | Spec body: "produces no file changes — it is a reference document" | ✅ |

## Implementation Gate Steps

This template spec has no implementation phases. All fix specs (F-1 through F-7) will implement the template's structure against actual SKILL.md files.

## Exit Criteria

- [x] Plan index stored at `.opencode/.issues/2052/plan.md`
- [x] No phase files needed (single phase, already complete)
- [x] Spec is a reference document — no implementation required
- [x] Authorization scope: `for_pr` — auto-approved
