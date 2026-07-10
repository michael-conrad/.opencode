---
number: 1666
title: "[SPEC-FIX] Add direct SC-to-plan coverage gate after plan creation"
status: draft
labels: ["[SPEC-FIX]"]
created: 2026-07-04T17:40:51Z
updated: 2026-07-10T02:39:13Z
---

> **Migrated from `michael-conrad/opencode-config#242`** — originally filed against the wrong repo. The plan-fidelity audit lives in this repo (`.opencode/skills/audit/tasks/plan-fidelity.md`).

## Problem

The current workflow has a gap: after plan creation, the `plan-fidelity` audit (criterion PF-3) claims to verify that the plan covers all spec success criteria, but it does so **indirectly** — by comparing the existing plan against a clean-room plan, not by directly cross-referencing the spec's SC table against the plan's step structure.

The `validate` step (check 02) checks plan completeness against the spec's problem statement, not against individual SCs. The `spec-to-plan-handoff` validates SC summary YAML is well-formed before plan creation but doesn't check the resulting plan against it. The `pre-red-baseline` (implementation-pipeline Step 2) checks SC-ID traceability in TDD headings, but this runs during implementation, not after plan creation.

Issue **#1062** (Handoff Gates) added a plan-to-pipeline handoff that checks SC-ID-to-plan-step traceability at the **pre-RED** stage. This is complementary — it catches gaps before implementation, but the plan has already been approved by that point. The gap this spec addresses is **before plan approval**: catching SC coverage gaps in the adversarial audit, before the plan is approved for implementation.

**Root cause:** PF-3's expected result says "Each SC has corresponding step — missing any is automatic FAIL" but the actual implementation compares the existing plan against a clean-room plan (which may itself be incomplete or miss SCs), not against the spec's SC table directly. This is an indirect check that can miss SC coverage gaps.

### Existing Infrastructure: Step 3a Gap Analysis

The `plan-fidelity.md` task file already has a **Step 3a (Gap Analysis)** that performs a direct SC coverage check:

> "Plan completeness — Verify the plan covers all SCs from the spec: Does every SC have a corresponding step in the plan? If an SC has no plan step, flag as `GAP_ANALYSIS` with `missing_sc_coverage`"

However, Step 3a has two limitations that this spec addresses:

1. **Advisory classification, not a hard FAIL gate.** Step 3a's findings are classified as `GAP_ANALYSIS` — an advisory finding, not a blocking FAIL. Missing SCs are flagged but do not block plan approval.
2. **No integration with PF-3.** PF-3 (the primary SC coverage criterion) still uses clean-room comparison as its mechanism, not Step 3a's direct SC table check. The two checks run independently.

This spec's recommended approach (Option A, revised) consolidates PF-3 with Step 3a: PF-3 references Step 3a's direct SC check as its primary mechanism, and Step 3a's classification is upgraded from `GAP_ANALYSIS` to FAIL for missing SCs.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | PF-3 references Step 3a's direct SC table comparison as its primary mechanism (not clean-room comparison) | `string` | grep for PF-3 description referencing "SC table" or "Step 3a" in plan-fidelity.md |
| SC-2 | Step 3a Gap Analysis classification upgraded from GAP_ANALYSIS to FAIL for missing SCs | `string` | grep for `missing_sc_coverage` classification in plan-fidelity.md — FAIL, not GAP_ANALYSIS |
| SC-3 | Gate produces PASS only when every spec SC-ID has a corresponding plan step | `behavioral` | `opencode-cli run` with a complete plan → gate verdict contains PASS |
| SC-4 | Gate produces FAIL with specific missing SC-IDs when coverage is incomplete | `behavioral` | `opencode-cli run` with a plan missing SC-3 → gate verdict contains FAIL and lists SC-3 |
| SC-5 | Clean-room structural comparison preserved as separate criterion (PF-3a or equivalent) | `string` | grep for clean-room structural comparison criterion in plan-fidelity.md — present with distinct ID |
| SC-6 | Behavioral enforcement test verifies the gate catches an incomplete plan | `behavioral` | `opencode-cli run` with a plan missing one SC → gate FAILs with the missing SC-ID |
| SC-7 | No duplicate SC coverage checks — PF-3 and Step 3a are consolidated, not parallel | `string` | grep for only one direct SC coverage criterion in plan-fidelity.md evaluation table |

## Design Options

### Option A (Recommended, Revised): Consolidate PF-3 with existing Step 3a Gap Analysis

Rather than creating a new gate or replacing PF-3 entirely, consolidate PF-3 with the existing Step 3a Gap Analysis:

1. **PF-3 description** changes from "Steps cover ALL success criteria; missing any is automatic FAIL per spec gate" to "Every spec SC-ID has a corresponding plan step — verified via Step 3a's direct SC table comparison"
2. **PF-3 expected result** changes from "Each SC has corresponding step — missing any is automatic FAIL" to "Every SC-ID from the spec's SC table has at least one plan step referencing it. Missing SC-IDs are listed in the FAIL verdict. Verified via Step 3a."
3. **Step 3a classification** changes from `GAP_ANALYSIS` to `FAIL` for missing SCs — missing SC coverage becomes a blocking finding, not advisory
4. **New criterion PF-3a**: "Clean-room plan comparison for structural fidelity" — preserves the existing clean-room comparison that PF-3 currently performs, now as a separate criterion

**Pros:** Minimal change — one criterion update, one classification change. No new task files. No pipeline restructuring. Leverages existing infrastructure (Step 3a already does the work). No duplication.
**Cons:** Changes the semantics of PF-3 from "plan vs clean-room plan" to "plan vs spec SCs". Must ensure the existing clean-room comparison is not lost (PF-3a preserves it).

### Option B: New standalone audit task in audit

Create a new `--task sc-coverage` in audit that reads the spec SC table and plan step structure independently.

**Pros:** Clean separation of concerns. No semantic drift on existing criteria.
**Cons:** New task file, new dispatch table entry, new pipeline step. More surface area. Would create a third SC coverage check (PF-3, Step 3a, new task) — duplication risk.

### Option C: New check in writing-plans/tasks/validate.md

Add a new validation check (check 19) to the validate step that reads the spec SC table and verifies plan coverage.

**Pros:** Close to the plan creation pipeline. Natural fit for a validation check.
**Cons:** The validate step runs at orchestrator level (inline), not as an adversarial audit. Loses the adversarial separation that makes audits reliable.

### Option D: New step in the writing-plans pipeline

Add a new step between Step 15 (validate) and Step 17 (audit-fidelity) in the writing-plans pipeline.

**Pros:** Explicit pipeline step. Clear position in the dependency chain.
**Cons:** Adds another step to an already long pipeline. Requires updating the pipeline numbering and Z3 checks.

## Recommended Approach: Option A (Revised)

Consolidate PF-3 with existing Step 3a Gap Analysis in `plan-fidelity.md`. The changes:

1. **PF-3 description** changes from "Steps cover ALL success criteria; missing any is automatic FAIL per spec gate" to "Every spec SC-ID has a corresponding plan step — verified via Step 3a's direct SC table comparison"
2. **PF-3 expected result** changes from "Each SC has corresponding step — missing any is automatic FAIL" to "Every SC-ID from the spec's SC table has at least one plan step referencing it. Missing SC-IDs are listed in the FAIL verdict. Verified via Step 3a."
3. **Step 3a classification** changes from `GAP_ANALYSIS` to `FAIL` for missing SCs — missing SC coverage becomes a blocking finding
4. **New criterion PF-3a**: "Clean-room plan comparison for structural fidelity" — preserves the existing clean-room comparison that PF-3 currently performs, now as a separate criterion

This avoids duplication: PF-3 references Step 3a's existing direct SC check, Step 3a is upgraded to a hard FAIL gate, and PF-3a preserves the clean-room structural comparison.

## Implementation Plan

### Phase 1: Design the consolidation

- Confirm Option A (Revised) as the approach
- Define the exact PF-3 replacement text (references Step 3a)
- Define PF-3a for clean-room structural comparison
- Define Step 3a classification change: `GAP_ANALYSIS` → `FAIL` for missing SCs
- Map the data flow: spec issue → SC table extraction (Step 3a) → plan step structure → cross-reference → FAIL verdict

### Phase 2: Implement the changes

- Update `plan-fidelity.md` Step 3 evaluation criteria table:
  - PF-3: change description to reference Step 3a's direct SC table comparison
  - Add PF-3a for clean-room structural comparison
- Update `plan-fidelity.md` Step 3a (Gap Analysis):
  - Change `missing_sc_coverage` classification from `GAP_ANALYSIS` to `FAIL`
  - Update the YAML template to reflect FAIL status
- Update Step 5 (Classify Discrepancies) to include `MISSING_SC` as a finding type (if not already present)
- Update the verdict artifact schema to include per-SC coverage results

### Phase 3: Add behavioral enforcement test

- Write RED behavioral test: plan missing SC-3 → gate FAILs with SC-3 listed
- Write GREEN behavioral test: complete plan → gate PASSes
- Write RED behavioral test: plan with all SCs but wrong approach → PF-3a catches it

### Phase 4: Verify no duplication

- Confirm PF-3 references Step 3a (not a parallel check)
- Confirm Step 3a is the sole direct SC coverage mechanism
- Confirm PF-3a is the sole clean-room structural comparison mechanism
- Update cross-references

## Constraints

- Must not duplicate existing checks (validate check 02, pre-red-baseline, #1062 handoff)
- Must not break the existing plan-fidelity audit (PF-1, PF-2, PF-4 through PF-SEQUENCE-MATCHES remain unchanged)
- Must consolidate with existing Step 3a Gap Analysis — not create a parallel check
- The clean-room plan comparison must be preserved as a separate criterion (PF-3a)
- Must be complementary to #1062's plan-to-pipeline handoff (which checks SC-ID traceability at pre-RED stage against `sc-summary.yaml`). This gate checks at post-plan-creation stage against the spec SC table directly.

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/audit/tasks/plan-fidelity.md` | Update PF-3 to reference Step 3a's direct SC table comparison; upgrade Step 3a classification from GAP_ANALYSIS to FAIL for missing SCs; add PF-3a for clean-room structural comparison |
| `.opencode/tests/behaviors/plan-fidelity-sc-coverage.sh` | NEW — behavioral test for SC-3, SC-4, SC-6 |

## Risks

- Low: PF-3 semantic change is contained to one criterion in one file
- The clean-room plan comparison is preserved as PF-3a, so no fidelity loss
- The plan-fidelity auditor already reads the spec (via `spec_local_dir`), so SC table extraction is additive, not new infrastructure
- Step 3a already performs the direct SC check — the change is a classification upgrade, not new logic

## Dependencies

- **#1062** (Handoff Gates) — complementary. #1062's plan-to-pipeline handoff checks SC-ID traceability at pre-RED stage against `sc-summary.yaml`. This spec's gate checks at post-plan-creation stage against the spec SC table directly. The two mechanisms are at different pipeline positions (pre-approval vs. pre-RED) against different source documents (spec SC table vs. `sc-summary.yaml`). Both are needed — no overlap, no conflict.

## Changelog

- v1 — Initial spec (migrated from opencode-config#242)
- v2 — Added #1062 dependency reference and complementary relationship clarification (per audit of #1666)
- v3 — Revised per deep DiMo audit: (1) Fixed stale `adversarial-audit` → `audit` references (skill was renamed). (2) Acknowledged existing Step 3a Gap Analysis infrastructure. (3) Revised Option A to consolidate PF-3 with Step 3a rather than creating a parallel check. (4) Upgraded Step 3a classification from GAP_ANALYSIS to FAIL for missing SCs. (5) Updated Implementation Plan, Files Affected, and Constraints accordingly.
