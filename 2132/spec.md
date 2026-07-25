---
remote_issue: 2132
remote_url: https://github.com/michael-conrad/.opencode/issues/2132
labels: [spec]
---

## Problem

`090-data-integrity.md` is ~96 lines / ~8KB. Its rules are narrow data processing pipeline failure modes from a specific project (no synthetic data, fail fast on missing fields, verify before recommend, tqdm for batch jobs). These don't cover general data integrity concerns that apply across projects: validation at system boundaries, serialization integrity, data classification, migration integrity, audit trails, data retention.

## Proposed Solution

Replace the entire file with a broadened data integrity framework covering 6 categories. The existing narrow rules are subsumed by the broader principles.

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
| tqdm | Removed — tool-specific, not a data integrity principle |
| Cross-reference to 200-errors.md | Removed — not preloaded |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | File contains 6 data integrity categories | string | grep for each category header |
| SC-2 | No remaining project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date) | string | grep for absence of each |
| SC-3 | No remaining cross-reference to 200-errors.md | string | grep for absence of '200-errors' |
| SC-4 | No remaining tqdm requirement | string | grep for absence of 'tqdm' |
| SC-5 | Data validation at boundaries covers structure, types, constraints, missing data, entity resolution | string | grep for each concept |
| SC-6 | Serialization integrity covers versioning, backward compat, traceability | string | grep for each concept |
| SC-7 | Data classification covers sensitivity levels, production data restrictions | string | grep for each concept |
| SC-8 | Migration integrity covers reversibility, verification, sampling | string | grep for each concept |
| SC-9 | Audit trail covers traceability, authorization, documented changes | string | grep for each concept |
| SC-10 | Data retention covers retention policies per classification | string | grep for retention policy |

## Implementation Plan

### Phase 1: Replace entire file content with new 6-category framework
### Phase 2: Verify all project-specific references removed
### Phase 3: Verify all 6 categories present with correct scope

## Files Affected

- `.opencode/guidelines/090-data-integrity.md` — replaced entirely

## Risks

- **Over-broadening**: If the categories are too abstract, they won't constrain agent behavior. Mitigation: each category includes concrete examples of what it forbids and requires.
- **Loss of specific failure modes**: The narrow rules (no synthetic data, fail fast) are real failure patterns. Mitigation: they're subsumed under the broader categories, not lost.

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
