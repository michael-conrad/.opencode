# SPEC-FIX: change-control task must mandate re-audit after fixing audit findings

**STATUS: 1.0 (DRAFT - NEEDS APPROVAL)**
**Created: 2026-07-10**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

The change-control task (`spec-creation/tasks/change-control.md`) does not mandate re-audit after fixing audit findings. Step 3 asks "Whether the change requires re-audit" as an advisory question — the sub-agent classified the fixes as non-substantive and skipped re-audit. But when a revision is triggered by spec-audit FAILs, re-audit must be mandatory to confirm the fixes actually resolved the findings.

## Root Cause

`spec-creation/tasks/change-control.md` line 41 — "Whether the change requires re-audit" is advisory, not mandatory. The exit criteria (line 17) requires `STATUS updated to REVISED - NEEDS APPROVAL` but does not require `Re-audit passes with no FAILs` when the revision was triggered by audit findings.

## Context

The change-control task is invoked when a spec is revised after audit or feedback. The current procedure documents changes, versions the spec, performs impact analysis, and halts for re-authorization. But it does not enforce re-audit when the revision was triggered by spec-audit FAILs — meaning a sub-agent can fix audit findings, skip re-audit, and the fixes are never independently verified.

## Scope

**In scope:**
- Add mandatory re-audit step to change-control task when revision was audit-triggered
- Update exit criteria to require "All prior audit FAILs resolved to PASS" for audit-triggered revisions
- The re-audit step dispatches `audit --task spec-audit` and confirms all prior FAILs are now PASS

**Out of scope:**
- Changes to the audit skill itself
- Changes to how spec-audit works
- Changes to non-audit-triggered revisions (user feedback, scope adjustments)

## Approach

Add a mandatory re-audit step between Step 3 (Impact Analysis) and Step 4 (HALT) in the change-control task. When the revision was triggered by spec-audit FAILs, the change-control task MUST dispatch a re-audit via `audit --task spec-audit` and confirm all prior FAILs are now PASS before completing. The exit criteria must include "All prior audit FAILs resolved to PASS" when the revision was audit-triggered.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/tasks/change-control.md` | Add mandatory re-audit step, update exit criteria |

## Dependencies

None — change-control already has access to the audit skill.

## Risk

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| None | — | — | This is a procedural addition, not a behavioral change |

## Edge Cases

| Case | Handling |
|------|----------|
| Revision NOT triggered by audit findings | Re-audit is NOT required — existing behavior preserved |
| Re-audit produces new FAILs | HALT — the fixes did not resolve the original findings |
| Re-audit produces different FAILs than original | HALT — the fixes introduced new issues |

## Interdependency

None — this is a standalone procedural fix.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | change-control.md exit criteria includes "All prior audit FAILs resolved to PASS" when revision was audit-triggered | `string` | `grep` for "All prior audit FAILs resolved to PASS" in change-control.md exit criteria section | Add the exit criterion to the exit criteria list | red-green | `.opencode/skills/spec-creation/tasks/change-control.md` | Exit criteria completeness | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-2 | change-control.md has a mandatory re-audit step between Step 3 and Step 4 that dispatches `audit --task spec-audit` when revision was audit-triggered | `string` | `grep` for "audit --task spec-audit" in change-control.md between Step 3 and Step 4 | Add the re-audit step to the procedure | red-green | `.opencode/skills/spec-creation/tasks/change-control.md` | Procedure completeness | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | Re-audit step is conditional — only required when revision was triggered by spec-audit FAILs | `string` | `grep` for conditional language ("audit-triggered", "spec-audit FAILs") in the re-audit step | Add conditional guard to the re-audit step | red-green | `.opencode/skills/spec-creation/tasks/change-control.md` | Conditional enforcement | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-4 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | `opencode-cli run` → semantic inspector verifies no SC lobotomization occurred | Re-implement the SC at the correct evidence type | red-green | `.opencode/tests/behaviors/` | Test integrity mandate | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1845/plan.md` before implementation begins.

**Documentation Sources:**
| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read .opencode/skills/spec-creation/tasks/change-control.md` | Verify current task content and identify the advisory re-audit question |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
