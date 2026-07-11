---
title: "Direct SC-to-Plan Coverage Gate in Plan-Fidelity Audit"
created: 2026-07-11
confidence: 1.0
tags: [plan-fidelity, sc-coverage, gap-analysis, plan-fidelity-pf-3]
sources:
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md
    section: "Step 3a Gap Analysis"
    verified: 2026-07-11
    relevance: "Target file for the spec-fix. Step 3a currently classifies missing_sc_coverage as GAP_ANALYSIS (advisory). PF-3 still uses indirect clean-room comparison. Both must be updated per #1666."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md
    section: "Step 3 Evaluation Criteria (PF-3)"
    verified: 2026-07-11
    relevance: "PF-3 currently says 'Steps cover ALL success criteria; missing any is automatic FAIL per spec gate' with expected result 'Each SC has corresponding step — missing any is automatic FAIL'. Must be updated to reference Step 3a's direct SC table comparison."
  - url: https://github.com/michael-conrad/.opencode/blob/main/reference/holistic-dimensions.yaml
    section: "Cross-reference table"
    verified: 2026-07-11
    relevance: "Central cross-reference file tracking all sync locations for the 11-dimension holistic gate. The plan-fidelity.md file is listed as an audit_gate consumer. This spec's changes must be compatible with the holistic gate structure."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md
    section: "Trigger Dispatch Table"
    verified: 2026-07-11
    relevance: "Defines the canonical gate sequence. The pre-red-baseline step (Step 2) checks SC-ID traceability at pre-RED stage against sc-summary.yaml. Complementary to this spec's post-plan-creation gate."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/tasks/validate.md
    section: "Check 02"
    verified: 2026-07-11
    relevance: "Check 02 validates plan completeness against the spec's problem statement, not against individual SCs. Confirms the gap this spec addresses."
  - url: https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/SKILL.md
    section: "Pipeline Steps"
    verified: 2026-07-11
    relevance: "Step 15 (validate), Step 16 (Z3), Step 17 (audit-fidelity) confirmed as the plan creation pipeline. The audit-fidelity step is where PF-3 fires."
---

# Direct SC-to-Plan Coverage Gate in Plan-Fidelity Audit

## Summary

The plan-fidelity audit's PF-3 criterion claims to verify that the plan covers all spec success criteria, but does so indirectly — by comparing the existing plan against a clean-room plan, not by directly cross-referencing the spec's SC table against the plan's step structure. Step 3a (Gap Analysis) already performs a direct SC table check but classifies findings as advisory (GAP_ANALYSIS) rather than blocking (FAIL).

## Authoritative Sources

### 1. Target File — `audit/tasks/plan-fidelity.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/audit/tasks/plan-fidelity.md

The file to be modified. Key sections:
- **Step 3 Evaluation Criteria (PF-3)**: Currently uses indirect clean-room comparison. Must be updated to reference Step 3a's direct SC table comparison.
- **Step 3a Gap Analysis**: Currently classifies `missing_sc_coverage` as `GAP_ANALYSIS` (advisory). Must be upgraded to `FAIL` for missing SCs.
- **Step 5 Classify Discrepancies**: Must add `MISSING_SC` as a finding type.

### 2. Holistic Dimensions Cross-Reference — `reference/holistic-dimensions.yaml`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/reference/holistic-dimensions.yaml

The central cross-reference file tracks plan-fidelity.md as an audit_gate consumer. The spec's changes must be compatible with the Step 0 holistic gate that already exists in plan-fidelity.md.

### 3. Implementation Pipeline — `implementation-pipeline/SKILL.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/implementation-pipeline/SKILL.md

The pre-red-baseline step (Step 2) checks SC-ID traceability at pre-RED stage against `sc-summary.yaml`. This is complementary to #1666's post-plan-creation gate — different pipeline position, different source document.

### 4. Writing Plans Validate — `writing-plans/tasks/validate.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/tasks/validate.md

Check 02 validates plan completeness against the spec's problem statement, not against individual SCs. Confirms the gap this spec addresses.

### 5. Writing Plans Pipeline — `writing-plans/SKILL.md`

**Live URL:** https://github.com/michael-conrad/.opencode/blob/main/skills/writing-plans/SKILL.md

Step 15 (validate), Step 16 (Z3), Step 17 (audit-fidelity) confirmed as the plan creation pipeline. The audit-fidelity step is where PF-3 fires.

## Required Changes

1. **PF-3 description**: Change from "Steps cover ALL success criteria; missing any is automatic FAIL per spec gate" to "Every spec SC-ID has a corresponding plan step — verified via Step 3a's direct SC table comparison"
2. **PF-3 expected result**: Change from "Each SC has corresponding step — missing any is automatic FAIL" to "Every SC-ID from the spec's SC table has at least one plan step referencing it. Missing SC-IDs are listed in the FAIL verdict. Verified via Step 3a."
3. **Step 3a classification**: Change `missing_sc_coverage` from `GAP_ANALYSIS` to `FAIL`
4. **New criterion PF-3a**: "Clean-room plan comparison for structural fidelity" — preserves the existing clean-room comparison
5. **Step 5**: Add `MISSING_SC` as a finding type
