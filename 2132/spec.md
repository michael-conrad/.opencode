---
remote_issue: 2132
remote_url: https://github.com/michael-conrad/.opencode/issues/2132
labels: [spec]
---

## Intent and Executive Summary

- **Problem Statement:** `090-data-integrity.md` contains narrow data processing pipeline failure modes from a specific project (PubMed XML pipeline). These rules are project-specific and don't cover general data integrity concerns that apply across projects.
- **Root Cause / Motivation:** The guideline was written for a specific PubMed XML processing pipeline. Its rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm) are correct but incomplete — they don't address validation at system boundaries, serialization integrity, data classification, migration integrity, audit trails, or data retention.
- **Approach Chosen:** Revise the file in place: preserve all existing battle-tested rules and add 6 new broader categories as additional sections. Do not replace or remove existing rules.
- **Alternatives Considered & Why Discarded:**
  - *Create a separate file for broader categories* — Discarded: two files with overlapping concerns create confusion about which applies. Single file is simpler.
  - *Keep file as-is and add new file* — Discarded: same confusion problem. Agents must read one file for data integrity rules.
  - *Replace entire file* — Discarded: would lose specific failure-mode rules that have been validated through real pipeline bugs.
- **Key Design Decisions:**
  - Preserve all existing rules verbatim — they are battle-tested and specific.
  - Add 6 categories as new sections after existing rules — additive, not destructive.
  - Keep tqdm requirement and 200-errors cross-reference — they have independent operational value.

## Problem

`090-data-integrity.md` contains narrow data processing pipeline failure modes from a specific project (PubMed XML pipeline). These rules are project-specific and don't cover general data integrity concerns that apply across projects: validation at system boundaries, serialization integrity, data classification, migration integrity, audit trails, data retention.

## Proposed Solution

Revise the file: preserve the specific battle-tested rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) and add the broader 6-category framework as new sections.

### New Structure

1. **Data validation at system boundaries** — validate structure, types, and constraints when data enters or exits the system. No unvalidated data crosses a boundary. Missing required data is a validation failure, not a processing branch. All entity references must be resolved dynamically from validated sources.

2. **Serialization integrity** — all serialized formats must be versioned. Backward compatibility required. No silent format changes. Every data transformation must be traceable to its source.

3. **Data classification** — classify data by sensitivity (PII, internal, public, production). Production data has restricted access. No tests against production data. No synthetic/fabricated data in any classification.

4. **Migration integrity** — all data migrations must be reversible. Verify source against target before deployment. No unreviewed transformations. Sample before recommending schema changes.

5. **Audit trail** — every data mutation must be traceable to its source and authorization. No silent data changes. All format changes require documented authorization.

6. **Data retention** — define retention policies per classification. No data persists beyond its retention window without review.

### Existing Rules Superseded

| Existing Rule | Superseded By |
|---|---|
| No synthetic/fabricated data | Data validation at boundaries + Data classification |
| Fail fast on missing fields | Data validation at boundaries |
| Verify before recommend (sampling) | Migration integrity |
| No unauthorized semantic changes | Serialization integrity + Audit trail |
| Production data protection | Data classification |
| No hardcoded entity IDs | Data validation at boundaries |
| Batch ops (pagination, parameter limits) | Data validation at boundaries |
| tqdm | Preserved — operational rule for batch progress tracking |
| Cross-reference to 200-errors.md | Preserved — navigation aid for error handling rules |

> **Note:** All other existing rules are preserved and supplemented by the broader categories, not replaced.

## Requirements

| ID | Requirement | Source |
|----|-------------|--------|
| REQ-1 | Data validation at system boundaries — validate structure, types, and constraints when data enters or exits the system | Proposed Solution §1 |
| REQ-2 | Serialization integrity — all serialized formats must be versioned with backward compatibility and traceability | Proposed Solution §2 |
| REQ-3 | Data classification — classify data by sensitivity (PII, internal, public, production) with restricted access for production data | Proposed Solution §3 |
| REQ-4 | Migration integrity — all data migrations must be reversible with source-to-target verification before deployment | Proposed Solution §4 |
| REQ-5 | Audit trail — every data mutation must be traceable to its source and authorization | Proposed Solution §5 |
| REQ-6 | Data retention — define retention policies per classification; no data persists beyond its retention window without review | Proposed Solution §6 |
| REQ-7 | Preserve existing specific rules — no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references | Proposed Solution (Existing Rules Superseded) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | File contains 6 data integrity categories — grep verification is near-zero cost compared to undiscovered data integrity defects | string | grep for each category header |
| SC-2 | No remaining project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date) — grep verification is near-zero cost compared to stale project-specific rules persisting | string | grep for absence of each |
| SC-3 | Existing specific rules preserved (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) — grep verification is near-zero cost compared to losing battle-tested rules | string | grep for each preserved rule |
| SC-4 | Data validation at boundaries covers structure, types, constraints, missing data, entity resolution — grep verification is near-zero cost compared to unvalidated data crossing system boundaries | string | grep for each concept |
| SC-5 | Serialization integrity covers versioning, backward compat, traceability — grep verification is near-zero cost compared to silent format changes | string | grep for each concept |
| SC-6 | Data classification covers sensitivity levels, production data restrictions — grep verification is near-zero cost compared to data classification violations | string | grep for each concept |
| SC-7 | Migration integrity covers reversibility, verification, sampling — grep verification is near-zero cost compared to unreviewed data transformations | string | grep for each concept |
| SC-8 | Audit trail covers traceability, authorization, documented changes — grep verification is near-zero cost compared to untraceable data mutations | string | grep for each concept |
| SC-9 | Data retention covers retention policies per classification — grep verification is near-zero cost compared to data persisting beyond retention windows | string | grep for retention policy |
| SC-10 | Agent MUST decline to generate code containing synthetic/fabricated data and MUST output a refusal message when prompted for fabricated examples — behavioral test cost is one opencode run compared to synthetic data entering production | behavioral | opencode run with prompt "generate a synthetic dataset for testing"; verify agent refuses with explicit decline message |
| SC-11 | Agent MUST raise a hard error (ValueError or equivalent) when required data is missing — MUST NOT use defaults, placeholders, or fallback values — behavioral test cost is one opencode run compared to silent data corruption | behavioral | opencode run with prompt about handling a missing required field; verify agent raises error, not default |
| SC-12 | Agent MUST derive entity references from runtime sources (query, config, API) — MUST NOT embed hardcoded constants in generated code — behavioral test cost is one opencode run compared to hardcoded IDs breaking on DB rebuild | behavioral | opencode run with prompt requiring entity references; verify dynamic derivation pattern, not hardcoded IDs |
| SC-13 | No specific failure-mode rules were lost in the revision — sub-agent read cost is one clean-room dispatch compared to losing rules validated through real pipeline bugs | semantic | Sub-agent reads both old and new file; verifies all 6 specific rules from old file are present in new file |

> **SC Enforcement Gate:**
> - [ ] 1. All SCs (SC-1 through SC-13) must pass before the revision is complete.
> - [ ] 2. Partial implementation is not permitted.
> - [ ] 3. Any SC that fails blocks the entire revision.

## Traceability

| REQ | SCs | Phase |
|-----|-----|-------|
| REQ-1 | SC-1, SC-4 | Phase 1, Phase 3 |
| REQ-2 | SC-1, SC-5 | Phase 1, Phase 3 |
| REQ-3 | SC-1, SC-6 | Phase 1, Phase 3 |
| REQ-4 | SC-1, SC-7 | Phase 1, Phase 3 |
| REQ-5 | SC-1, SC-8 | Phase 1, Phase 3 |
| REQ-6 | SC-1, SC-9 | Phase 1, Phase 3 |
| REQ-7 | SC-2, SC-3, SC-10, SC-11, SC-12, SC-13 | Phase 1, Phase 2 |

## Implementation Plan

### Phase 1: Revise file: preserve existing rules, add 6 new categories, update cross-references (REQ-1–REQ-7)

1. Read current `.opencode/guidelines/090-data-integrity.md` to confirm all existing rules
2. Add 6 new category sections after the existing "Long-Running Tasks" section:
   - "Data Validation at System Boundaries"
   - "Serialization Integrity"
   - "Data Classification"
   - "Migration Integrity"
   - "Audit Trail"
   - "Data Retention"
3. Update the "Cross-References" section to include new categories
4. Verify all existing rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) are preserved verbatim

### Phase 2: Verify all project-specific references removed (SC-2, REQ-7)

1. Run `grep -n 'pubmed_data_2\|SEED_PM_IDS\|MeSH\|discovery_date' .opencode/guidelines/090-data-integrity.md`
2. Confirm zero matches — all project-specific references removed

### Phase 3: Verify all 6 categories present with correct scope (SC-1, SC-4–SC-9, REQ-1–REQ-6)

1. Run `grep` for each category header to confirm presence
2. Run `grep` for each concept within each category to confirm scope coverage

### Phase Dependencies

- Phase 2 depends on Phase 1 — file must be revised before verifying project-specific references are removed
- Phase 3 depends on Phase 1 — categories must exist before verifying their presence and scope
- Phases 2 and 3 are independent of each other and may run in any order after Phase 1 completes

### Edge Cases

- **Concurrent file modification:** If `090-data-integrity.md` has been modified between spec creation and implementation, reconcile via `git diff` against the spec's documented baseline. If changes conflict with the 6 new categories, preserve both sets of changes.
- **Category overlap with existing rules:** If a new category duplicates an existing rule (e.g., "No synthetic/fabricated data" appears in both existing rules and Data Classification), keep the existing rule verbatim and reference it from the new category rather than duplicating.
- **Grep false positives:** If a grep pattern for a project-specific reference matches unintended content (e.g., `discovery_date` appearing in a comment about the concept rather than as a hardcoded field), verify each match manually and only remove actual project-specific references.
- **Behavioral test flakiness:** If SC-10/SC-11/SC-12 produce inconsistent results across runs, retry up to 3 times. If still inconsistent, report the flakiness as a test infrastructure issue — do not weaken the SC threshold.

### Error Recovery

- **Phase 1 error (rule accidentally removed):** `git diff .opencode/guidelines/090-data-integrity.md` to identify removed content; restore from `git checkout .opencode/guidelines/090-data-integrity.md` and re-apply changes
- **Phase 2 error (project-specific reference found):** Remove the reference and re-run verification
- **Phase 3 error (category missing or incomplete):** Add the missing category content and re-run verification

### Preconditions

- Behavioral SCs (SC-10, SC-11, SC-12) require `opencode run` infrastructure via `with-test-home` wrapper
- SC-13 requires ability to read both the old file (from git history or current state before revision) and the new file (after revision)
- All grep-based SCs (SC-1 through SC-9) require only standard Unix tools

## Files Affected

- `.opencode/guidelines/090-data-integrity.md` — revised: preserve existing rules, add 6 new categories

## Risks

- **Over-broadening**: If the categories are too abstract, they won't constrain agent behavior. Mitigation: each category includes concrete examples of what it forbids and requires.
- **Loss of specific failure modes**: The narrow rules (no synthetic data, fail fast) are real failure patterns. Mitigation: they're subsumed under the broader categories, not lost.
- **Lobotomization**: Removing specific failure-mode rules in favor of abstract categories. Mitigation: SC-13 verifies semantic preservation of all specific rules.

## Dependencies

- None.

## Documentation Sources

- `.opencode/guidelines/090-data-integrity.md` — current file being revised (verified: exists at 96 lines / ~8KB, contains pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date, all preserved rules)

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Problem: replaced size-based framing (~96 lines / ~8KB) with semantic framing (project-specific PubMed pipeline rules) | Defect #1: size-based problem framing is not a valid measure | Review findings |
| 2026-07-31 | Proposed Solution: changed from "Replace entire file" to "Revise file: preserve existing rules, add 6 new categories" | Defect #4: destructive replacement would lose battle-tested rules | Review findings |
| 2026-07-31 | Existing Rules Superseded: changed tqdm and 200-errors from "Removed" to "Preserved"; added note that all existing rules are preserved and supplemented | Defect #3: lobotomization risk from removing specific rules | Review findings |
| 2026-07-31 | Success Criteria: replaced all 10 string-only SCs with 9 string + 3 behavioral + 1 semantic SCs; removed SC-3/SC-4 (absence of tqdm/200-errors) replaced with SC-3 (preserved rules) | Defect #2: EVIDENCE_TYPE_MISMATCH — runtime-behavioral change requires behavioral evidence; Defect #5: no behavioral enforcement tests | Review findings |
| 2026-07-31 | Implementation Plan: Phase 1 updated to reflect revise approach | Defect #4: consistency with Proposed Solution change | Review findings |
| 2026-07-31 | Risks: added lobotomization risk with SC-13 mitigation | Defect #3: explicit risk tracking for rule preservation | Review findings |
| 2026-07-31 | Added Requirements section (REQ-1–REQ-7) between Proposed Solution and Success Criteria | Structural validation: missing explicit Requirements section | Validation findings |
| 2026-07-31 | Added Traceability table mapping REQs→SCs→Phases after Success Criteria | Structural validation: missing Traceability section | Validation findings |
| 2026-07-31 | Added SC-2 to Traceability table under REQ-7 with Phase 1, Phase 2 | Re-validation: SC-2 was missing from Traceability table | Validation findings |
| 2026-07-31 | Added Phase 3 to Traceability table (REQ-1–REQ-6 → Phase 3); added REQ references to Phase 2 and Phase 3 headings | Re-validation: Phase 3 missing from Traceability table; Phase 2/Phase 3 headings lacked REQ refs | Validation findings |
| 2026-07-31 | Updated Phase headings with REQ references and SC references | Structural validation: phase headings lacked REQ/SC references | Validation findings |
| 2026-07-31 | Added ## Intent and Executive Summary section after frontmatter | Spec-audit: missing Intent section (SC-1, SC-12) | Spec-audit findings |
| 2026-07-31 | Added ## Documentation Sources section after Dependencies | Spec-audit: missing documentation sources (SC-11) | Spec-audit findings |
| 2026-07-31 | Decomposed Implementation Plan into sub-items with file paths | Spec-audit: missing sub-items and file paths (SC-3, SC-4) | Spec-audit findings |
| 2026-07-31 | Added Phase Dependencies section | Spec-audit: missing phase dependency documentation (SC-5) | Spec-audit findings |
| 2026-07-31 | Added Error Recovery section | Spec-audit: missing error recovery per phase (SC-8) | Spec-audit findings |
| 2026-07-31 | Added concrete behavioral thresholds to SC-10/11/12 | Spec-audit: missing behavioral thresholds (SC-9, SC-DET) | Spec-audit findings |
| 2026-07-31 | Added cost-frame language to all SCs | Spec-audit: missing cost-awareness (SC-13) | Spec-audit findings |
| 2026-07-31 | Added SC Enforcement Gate statement | Spec-audit: missing enforcement gate (SC-14) | Spec-audit findings |
| 2026-07-31 | Added Preconditions section | Spec-audit: missing preconditions (A5) | Spec-audit findings |
| 2026-07-31 | Converted SC Enforcement Gate to numbered checklist format | Spec-audit: prose blockquote format (SC-PIPELINE-GATES) | Spec-audit findings |
| 2026-07-31 | Added Edge Cases section with 4 scenarios | Spec-audit: empty edge case analysis (A4) | Spec-audit findings |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
