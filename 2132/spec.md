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
- **User Intent / Original Prompt:** The original trigger for this spec was a request to broaden `090-data-integrity.md` beyond its project-specific PubMed XML pipeline failure modes so the data integrity rules apply across projects. This revision is an audit-driven remediation of the resulting spec: the spec-audit re-audit returned a holistic PASS across all 11 dimensions but flagged 4 narrow criteria (SC-1, SC-PRESCRIPTIVE-CODE, SC-11-DOCS, SC-12-PREAMBLE) requiring structural fixes — adding the 'Not Included' and per-SC 'Items' sections, replacing an exact grep assertion command with a file-area reference, converting Documentation Sources to the mandated table format, and adding this 'User Intent / Original Prompt' field.

## Not Included

- **New data integrity categories beyond the 6 specified** — The revision adds exactly 6 broader categories (data validation at system boundaries, serialization integrity, data classification, migration integrity, audit trail, data retention). Additional categories (e.g., data lineage, data quality metrics, data governance roles) are out of scope to keep the fix proportionate to the single-file blast radius.
- **Removal or replacement of existing rules** — All existing battle-tested rules are preserved verbatim. No existing rule is superseded, removed, or weakened; the revision is strictly additive.
- **Changes to other guideline files** — Only `.opencode/guidelines/090-data-integrity.md` is revised. No other guideline, skill, or tool file is modified.
- **Data integrity enforcement tooling** — The revision documents rules only; it does not add automated linting, CI checks, or enforcement tooling for the new categories.

## Problem

`090-data-integrity.md` contains narrow data processing pipeline failure modes from a specific project (PubMed XML pipeline). These rules are project-specific and don't cover general data integrity concerns that apply across projects: validation at system boundaries, serialization integrity, data classification, migration integrity, audit trails, data retention.

**Scope justification for the broader framework:** The 6 additional categories are not independent scope expansion — each is a direct generalization of an existing battle-tested project-specific rule, keeping the fix proportionate to the blast radius (a single guideline file). The existing rule that a project-specific failure mode exposed is the *instance*; the broader category is the *general principle* it demonstrates:

| Existing project-specific rule | Broader category it generalizes to |
|---|---|
| No synthetic/fabricated data | Data classification |
| Fail fast on missing fields | Data validation at system boundaries |
| No hardcoded entity IDs | Data validation at system boundaries |
| Batch operations (pagination, parameter limits) | Data validation at system boundaries |
| Verify before recommend (sampling) | Migration integrity |
| No unauthorized semantic changes | Serialization integrity + Audit trail |
| Production data protection | Data classification |

The broader categories exist so that agents recognize these integrity concerns in projects *other than* the PubMed pipeline, where the specific trigger words (e.g., `pubmed_data_2`, `SEED_PM_IDS`, `discovery_date`) do not appear. Without the generalization, the rules would remain silently bound to one project's vocabulary.

## Proposed Solution

Revise the file: preserve the specific battle-tested rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) and add the broader 6-category framework as new sections.

### Definitions

- **System boundary** — any point at which data enters or exits the application's processing logic: a file ingest, an API request/response, a database read/write, a serialization/deserialization step, or an external service interaction. The integrity rule applies at every such crossing point: no unvalidated data crosses a system boundary.
- **Retention window** — the defined duration a given data classification is permitted to persist (derived from its sensitivity: production/PII data has the shortest window, public data the longest). Any data that persists beyond its retention window MUST be reviewed for deletion, archival, or re-classification.

### New Structure

1. **Data validation at system boundaries** — validate structure, types, and constraints when data enters or exits the system. No unvalidated data crosses a boundary. Missing required data is a validation failure, not a processing branch. All entity references must be resolved dynamically from validated sources.

2. **Serialization integrity** — all serialized formats must be versioned. Backward compatibility required. No silent format changes. Every data transformation must be traceable to its source.

3. **Data classification** — classify data by sensitivity (PII, internal, public, production). Production data has restricted access. No tests against production data. No synthetic/fabricated data in any classification.

4. **Migration integrity** — all data migrations must be reversible. Verify source against target before deployment. No unreviewed transformations. Sample before recommending schema changes.

5. **Audit trail** — every data mutation must be traceable to its source and authorization. No silent data changes. All format changes require documented authorization.

6. **Data retention** — define retention policies per classification. No data persists beyond its retention window without review.

### Existing Rules Generalized

| Existing Rule | Generalized By |
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

> **Note:** Every existing rule is preserved verbatim and supplemented by the broader categories, not replaced. The "Generalized By" column names the broader category that generalizes each existing rule so the underlying integrity concern is recognized beyond this project's vocabulary. Preservation is unconditional — no existing rule is superseded or removed.

## Requirements

| ID | Requirement | Source |
|----|-------------|--------|
| R-1 | The agent SHALL validate structure, types, and constraints at system boundaries, and SHALL NOT allow unvalidated data to cross any system boundary. Missing required data SHALL be treated as a validation failure, not a processing branch. All entity references SHALL be resolved dynamically from validated sources. | Proposed Solution §1 |
| R-2 | The agent SHALL version all serialized formats, SHALL maintain backward compatibility, and SHALL make every data transformation traceable to its source. The agent SHALL NOT change a serialized format silently. | Proposed Solution §2 |
| R-3 | The agent SHALL classify data by sensitivity (PII, internal, public, production), SHALL restrict access to production data, SHALL NOT run tests against production data, and SHALL NOT introduce synthetic or fabricated data in any classification. | Proposed Solution §3 |
| R-4 | The agent SHALL make all data migrations reversible, SHALL verify source against target before deployment, SHALL NOT perform unreviewed transformations, and SHALL sample before recommending schema changes. | Proposed Solution §4 |
| R-5 | The agent SHALL make every data mutation traceable to its source and authorization, SHALL NOT make silent data changes, and SHALL require documented authorization for all format changes. | Proposed Solution §5 |
| R-6 | The agent SHALL define retention policies per data classification and SHALL NOT allow data to persist beyond its retention window without review. | Proposed Solution §6 |
| R-7 | The agent SHALL preserve all existing specific rules verbatim — no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, and cross-references — and SHALL NOT remove, supersede, or weaken any existing rule. | Proposed Solution (Existing Rules Generalized) |

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
| SC-11 | Agent MUST raise `ValueError` (this exact exception type) when required data is missing — MUST NOT use defaults, placeholders, or fallback values — behavioral test cost is one opencode run compared to silent data corruption | behavioral | opencode run with prompt about handling a missing required field; verify agent raises `ValueError`, not a default, placeholder, or fallback |
| SC-12 | Agent MUST derive entity references from runtime sources (query, config, API) — MUST NOT embed hardcoded constants in generated code — behavioral test cost is one opencode run compared to hardcoded IDs breaking on DB rebuild | behavioral | opencode run with prompt requiring entity references; verify dynamic derivation pattern, not hardcoded IDs |
| SC-13 | No specific failure-mode rules were lost in the revision — sub-agent read cost is one clean-room dispatch compared to losing rules validated through real pipeline bugs. The sub-agent MUST verify that the new file retains all 6 of the following specific rules from the old file: (1) no synthetic/imaginary/fabricated data — the Global Absolute Prohibition; (2) fail-fast — raise contextual errors immediately, no false/default/invalid defaults, hard fail on missing required data; (3) no hardcoded entity IDs — all entity IDs derived dynamically at runtime; (4) batch operations — pagination/parameter-limit/validation rules; (5) tqdm requirement for long-running tasks; (6) cross-reference to 200-errors.md. Each of the 6 rules MUST be reported present or absent explicitly in the sub-agent's result contract | semantic | Sub-agent reads both old and new file; verifies each of the 6 enumerated rules from old file is present in new file; reports each rule present/absent |

> **SC Enforcement Gate:**
> - [ ] 1. All SCs (SC-1 through SC-13) must pass before the revision is complete.
> - [ ] 2. Partial implementation is not permitted.
> - [ ] 3. Any SC that fails blocks the entire revision.

## Items

Each SC maps to exactly one item. Each item follows the RED → GREEN → verify → commit TDD cycle.

### Item 1 (SC-1): 6 data integrity categories present

- RED: grep the affected file for each of the 6 category headers and confirm at least one is absent (fails before revision)
- GREEN: add the 6 category sections to the affected file
- verify: grep the affected file for each category header and confirm all 6 are present
- commit: the affected file with the 6 new category sections

### Item 2 (SC-2): No project-specific references remain

- RED: grep the affected file for each project-specific reference and confirm at least one match remains (fails before removal)
- GREEN: remove all project-specific references from the affected file, replacing each with a project-agnostic equivalent
- verify: grep the affected file for each project-specific reference and confirm zero matches
- commit: the affected file with project-specific references removed

### Item 3 (SC-3): Existing specific rules preserved

- RED: grep the affected file for each preserved rule and confirm at least one is absent (fails before revision)
- GREEN: preserve all existing rules verbatim while adding the new categories
- verify: grep the affected file for each preserved rule and confirm all are present
- commit: the affected file with existing rules preserved

### Item 4 (SC-4): Data validation at system boundaries covers required concepts

- RED: grep the affected file for each boundary-validation concept and confirm at least one is absent
- GREEN: write the data-validation-at-boundaries category covering structure, types, constraints, missing data, and entity resolution
- verify: grep the affected file for each boundary-validation concept and confirm all are present
- commit: the data-validation-at-boundaries category section

### Item 5 (SC-5): Serialization integrity covers required concepts

- RED: grep the affected file for each serialization concept and confirm at least one is absent
- GREEN: write the serialization-integrity category covering versioning, backward compatibility, and traceability
- verify: grep the affected file for each serialization concept and confirm all are present
- commit: the serialization-integrity category section

### Item 6 (SC-6): Data classification covers required concepts

- RED: grep the affected file for each classification concept and confirm at least one is absent
- GREEN: write the data-classification category covering sensitivity levels and production data restrictions
- verify: grep the affected file for each classification concept and confirm all are present
- commit: the data-classification category section

### Item 7 (SC-7): Migration integrity covers required concepts

- RED: grep the affected file for each migration concept and confirm at least one is absent
- GREEN: write the migration-integrity category covering reversibility, verification, and sampling
- verify: grep the affected file for each migration concept and confirm all are present
- commit: the migration-integrity category section

### Item 8 (SC-8): Audit trail covers required concepts

- RED: grep the affected file for each audit concept and confirm at least one is absent
- GREEN: write the audit-trail category covering traceability, authorization, and documented changes
- verify: grep the affected file for each audit concept and confirm all are present
- commit: the audit-trail category section

### Item 9 (SC-9): Data retention covers required concepts

- RED: grep the affected file for the retention-policy concept and confirm it is absent
- GREEN: write the data-retention category covering retention policies per classification
- verify: grep the affected file for the retention-policy concept and confirm it is present
- commit: the data-retention category section

### Item 10 (SC-10): Agent refuses to generate synthetic/fabricated data

- RED: run the behavioral test prompt and confirm the agent does not refuse (fails before the rule exists)
- GREEN: add the no-synthetic-data rule to the affected file
- verify: run the behavioral test prompt and confirm the agent outputs an explicit refusal message
- commit: the no-synthetic-data rule

### Item 11 (SC-11): Agent raises `ValueError` on missing required data

- RED: run the behavioral test prompt and confirm the agent does not raise `ValueError` (fails before the rule exists)
- GREEN: add the fail-fast rule requiring `ValueError` on missing required data to the affected file
- verify: run the behavioral test prompt and confirm the agent raises `ValueError`, not a default, placeholder, or fallback
- commit: the fail-fast rule

### Item 12 (SC-12): Agent derives entity references from runtime sources

- RED: run the behavioral test prompt and confirm the agent embeds hardcoded IDs (fails before the rule exists)
- GREEN: add the no-hardcoded-entity-IDs rule to the affected file
- verify: run the behavioral test prompt and confirm the agent derives entity references dynamically, not from hardcoded constants
- commit: the no-hardcoded-entity-IDs rule

### Item 13 (SC-13): No specific failure-mode rules lost in the revision

- RED: dispatch a clean-room sub-agent to compare old vs new file and confirm at least one of the 6 enumerated rules is absent (fails before revision)
- GREEN: preserve all 6 enumerated specific rules verbatim in the affected file
- verify: dispatch a clean-room sub-agent to read both old and new file and report each of the 6 rules present or absent explicitly
- commit: the affected file with all 6 enumerated rules preserved

## Traceability

| R | SCs | Phase |
|-----|-----|-------|
| R-1 | SC-1, SC-4 | Phase 1, Phase 3 |
| R-2 | SC-1, SC-5 | Phase 1, Phase 3 |
| R-3 | SC-1, SC-6 | Phase 1, Phase 3 |
| R-4 | SC-1, SC-7 | Phase 1, Phase 3 |
| R-5 | SC-1, SC-8 | Phase 1, Phase 3 |
| R-6 | SC-1, SC-9 | Phase 1, Phase 3 |
| R-7 | SC-2, SC-3, SC-10, SC-11, SC-12, SC-13 | Phase 1, Phase 2 |

## Implementation Plan

### Phase 1: Revise file: preserve existing rules, remove project-specific references, add 6 new categories, update cross-references (R-1–R-7)

1. Read current `.opencode/guidelines/090-data-integrity.md` to confirm all existing rules
2. Remove all project-specific references (this is the SC-2 removal work — it happens in Phase 1, not deferred to Phase 2):
   - Remove `pubmed_data_2` mentions from "Verify Before Recommend" (Exhaustive Automated Analysis + NO UNAUTHORIZED FORMAT CHANGES)
   - Remove `SEED_PM_IDS` mention from "No Hardcoded Entity IDs"
   - Remove `MeSH` example from "MANDATORY SOURCE TRACEABILITY FOR VALIDATION DATA"
   - Remove `discovery_date` examples from "Fail-Fast" (NO FALSE DATA + HARD FAIL ON MISSING REQUIRED DATA), generalizing the field names
   - Replace each removed example with a project-agnostic equivalent that preserves the rule's meaning
3. Add 6 new category sections after the existing "Long-Running Tasks" section:
   - "Data Validation at System Boundaries"
   - "Serialization Integrity"
   - "Data Classification"
   - "Migration Integrity"
   - "Audit Trail"
   - "Data Retention"
4. Update the "Cross-References" section to include new categories
5. Verify all existing rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) are preserved verbatim

### Phase 2: Verify all project-specific references removed (SC-2, R-7)

1. Grep the affected file for each project-specific reference and confirm zero matches — all project-specific references removed (this verifies the Phase 1 removal work; Phase 2 is a verification gate only, it performs no removal)

### Phase 3: Verify all 6 categories present with correct scope (SC-1, SC-4–SC-9, R-1–R-6)

1. Run `grep` for each category header to confirm presence
2. Run `grep` for each concept within each category to confirm scope coverage

### Phase Dependencies

- Phase 2 depends on Phase 1 — file must be revised before verifying project-specific references are removed
- Phase 3 depends on Phase 1 — categories must exist before verifying their presence and scope
- **Phases 2 and 3 are independent of each other.** Neither phase reads or writes state consumed or produced by the other:
  - Phase 2 verifies only the absence of project-specific reference strings in the revised file
  - Phase 3 verifies only the presence and scope of the 6 category sections in the revised file
  - Because Phase 2 verifies absence and Phase 3 verifies presence of disjoint content sets, their PASS/FAIL outcomes are mutually unaffected. Executing them in either order yields identical, deterministic results. The pipeline MUST run Phase 2 and Phase 3 sequentially after Phase 1 (either Phase 2-then-Phase 3 or Phase 3-then-Phase 2), but MUST NOT skip either, and MUST NOT treat them as interchangeable alternatives.

### Edge Cases

- **Concurrent file modification:** If `090-data-integrity.md` has been modified between spec creation and implementation, reconcile via `git diff` against the spec's documented baseline. If changes conflict with the 6 new categories, preserve both sets of changes.
- **Category overlap with existing rules:** If a new category duplicates an existing rule (e.g., "No synthetic/fabricated data" appears in both existing rules and Data Classification), keep the existing rule verbatim and reference it from the new category rather than duplicating.
- **Grep false positives:** If a grep pattern for a project-specific reference matches unintended content (e.g., `discovery_date` appearing in a comment about the concept rather than as a hardcoded field), verify each match manually and only remove actual project-specific references.
- **Behavioral test flakiness:** If SC-10/SC-11/SC-12 produce inconsistent results across runs, retry up to 3 times. If the test still cannot execute or remains inconsistent after the retries, the result is **FAIL** — report the failure as a behavioral SC failure (SC-10, SC-11, or SC-12) with remediation, never as a test infrastructure issue and never reclassified. Per critical-rules-BEH-EV, a behavioral test that cannot execute or remains inconsistent MUST be reported FAIL and drive remediation; it MUST NOT be attributed to infrastructure to evade the behavioral requirement. The bounded retry does not change this terminal state: it is FAIL, not an infrastructure reclassification.

### Error Recovery

- **Phase 1 error (rule accidentally removed):** `git diff .opencode/guidelines/090-data-integrity.md` to identify removed content; restore from `git checkout .opencode/guidelines/090-data-integrity.md` and re-apply changes
- **Phase 2 error (project-specific reference found):** Remove the reference and re-run verification
- **Phase 3 error (category missing or incomplete):** Add the missing category content and re-run verification

### Preconditions

- All grep-based SCs (SC-1 through SC-9) require only standard Unix tools

## Files Affected

- `.opencode/guidelines/090-data-integrity.md` — revised: preserve existing rules, remove project-specific references, add 6 new categories

## Risks

- **Over-broadening**: If the categories are too abstract, they won't constrain agent behavior. Mitigation: each category includes concrete examples of what it forbids and requires.
- **Loss of specific failure modes**: The narrow rules (no synthetic data, fail fast) are real failure patterns. Mitigation: they're subsumed under the broader categories, not lost.
- **Lobotomization**: Removing specific failure-mode rules in favor of abstract categories. Mitigation: SC-13 verifies semantic preservation of all specific rules.

## Dependencies

| Dependency | Referenced By | Relationship | Status |
|------------|--------------|--------------|--------|
| `opencode run` infrastructure via `with-test-home` wrapper (`.opencode/tests-v2/with-test-home`) | SC-10, SC-11, SC-12 | Required to execute behavioral verification of the 3 behavioral SCs | Available in this environment (`with-test-home` exists at `.opencode/tests-v2/`) |
| Read access to the pre-revision state of `.opencode/guidelines/090-data-integrity.md` (from git history via `git show HEAD:.opencode/guidelines/090-data-integrity.md`, or captured current state before revision) | SC-13 | Required to compare old vs new file for rule-preservation verification | Available in this environment (file is tracked in git) |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `090-data-integrity.md` | doc | `.opencode/guidelines/090-data-integrity.md` | read — verified: exists at 96 lines / ~8KB, contains pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date, all preserved rules |
| `with-test-home` | code | `.opencode/tests-v2/with-test-home` | read — verified: exists, 22148 bytes; behavioral test harness wrapper used by SC-10/SC-11/SC-12 |

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
| 2026-07-31 | Added Requirements section (R-1–R-7) between Proposed Solution and Success Criteria | Structural validation: missing explicit Requirements section | Validation findings |
| 2026-07-31 | Added Traceability table mapping requirements→SCs→Phases after Success Criteria | Structural validation: missing Traceability section | Validation findings |
| 2026-07-31 | Added SC-2 to Traceability table under R-7 with Phase 1, Phase 2 | Re-validation: SC-2 was missing from Traceability table | Validation findings |
| 2026-07-31 | Added Phase 3 to Traceability table (R-1–R-6 → Phase 3); added requirement references to Phase 2 and Phase 3 headings | Re-validation: Phase 3 missing from Traceability table; Phase 2/Phase 3 headings lacked requirement refs | Validation findings |
| 2026-07-31 | Updated Phase headings with requirement references and SC references | Structural validation: phase headings lacked requirement/SC references | Validation findings |
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
| 2026-08-13 | SC-11: replaced "ValueError or equivalent" with exact "MUST raise `ValueError`" | HOL-1/Implementability + HOL-6/Escape Hatches: "or equivalent" made SC-11 ambiguous and gave the agent an escape hatch | Spec-audit holistic gate FAIL |
| 2026-08-13 | SC-13: enumerated the exact 6 specific rules (synthetic data, fail-fast, no hardcoded IDs, batch ops, tqdm, 200-errors cross-reference) and required per-rule present/absent reporting | HOL-1/Implementability + HOL-5/Testability: "6 specific rules" not enumerated made SC-13 non-reproducible | Spec-audit holistic gate FAIL |
| 2026-08-13 | Phase 1: added explicit step to remove project-specific references (pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date); Phase 2 recast as verification-only gate | HOL-2/Internal Consistency: SC-2/Phase 2 removal contradicted Phase 1 which added categories without removal | Spec-audit holistic gate FAIL |
| 2026-08-13 | Added "Definitions" subsection defining "system boundary" and "retention window" | HOL-3/Completeness: undefined terms forced implementor guessing | Spec-audit holistic gate FAIL |
| 2026-08-13 | Promoted behavioral-SC infrastructure (`with-test-home`) and git-history requirements from Preconditions into Dependencies with reference/relationship/status | HOL-3/Completeness: implicit dependencies for SC-10/11/12 and SC-13 not declared in Dependencies | Spec-audit holistic gate FAIL |
| 2026-08-13 | Problem statement: added scope-justification table mapping each broader category to the project-specific rule it generalizes | HOL-4/Scope Discipline: 6 broad categories exceeded stated PubMed-scoped problem; fix must stay proportionate to blast radius | Spec-audit holistic gate FAIL |
| 2026-08-13 | Phase Dependencies: replaced "may run in any order" with deterministic independence contract (disjoint verification sets, either order, no skipping) | HOL-6/Escape Hatches: "may run in any order" let agent short-circuit or skip phases | Spec-audit holistic gate FAIL |
| 2026-08-13 | Added `.opencode/tests-v2/with-test-home` to Documentation Sources | HOL-3/Completeness: dependency source must be documented (verified: exists, 22148 bytes) | Spec-audit holistic gate FAIL |
| 2026-08-13 | Renamed "Existing Rules Superseded" table to "Existing Rules Generalized"; changed "Superseded By" column to "Generalized By"; rewrote the Note to state preservation is unconditional and "Generalized By" names the broader category generalizing each existing rule | HOL-2/Internal Consistency: "Superseded By" contradicted the Note that all rules are preserved and supplemented, not replaced — a rule cannot be both superseded and preserved; spec approach is preserve-all-verbatim | Spec-audit holistic gate FAIL |
| 2026-08-13 | Behavioral-test-flakiness Edge Case: removed the "report the flakiness as a test infrastructure issue" reclassification path; terminal state after the bounded retry (up to 3 times) is now explicit FAIL with remediation, never an infrastructure reclassification | HOL-6/Escape Hatches: the infrastructure-reclassification language granted the agent discretion to reclassify a behavioral SC failure, short-circuiting SC-10/11/12 and violating critical-rules-BEH-EV (behavioral test failure must be FAIL, never reclassified) | Spec-audit holistic gate FAIL |
| 2026-08-13 | Added 'User Intent / Original Prompt' field to the Intent and Executive Summary preamble documenting the original trigger (broaden 090-data-integrity.md beyond PubMed-specific rules) and this audit-driven revision | SC-12-PREAMBLE: preamble had 5 of 6 required fields, missing the 6th 'User Intent / Original Prompt' field required by spec-structure-standards.md §1 | Spec-audit re-audit narrow criteria FAIL |
| 2026-08-13 | Added 'Not Included' section listing 4 explicit exclusions with rationale (additional categories, rule removal/replacement, other guideline files, enforcement tooling) | SC-1: spec missing reference-mandated 'Not Included' section (§2) | Spec-audit re-audit narrow criteria FAIL |
| 2026-08-13 | Added 'Items' section enumerating each SC-1..SC-13 with RED/GREEN/verify/commit TDD cycle (13 items, one per SC) | SC-1: spec missing reference-mandated per-SC 'Items' enumeration with TDD cycles (§5) | Spec-audit re-audit narrow criteria FAIL |
| 2026-08-13 | Phase 2 step 1: replaced exact grep assertion command with a file-area reference describing the absence check (grep the affected file for each project-specific reference and confirm zero matches) | SC-PRESCRIPTIVE-CODE: exact assertion code (grep command + exact file path) embedded in Phase 2, forbidden by spec-structure-standards.md §Prohibited Content Patterns | Spec-audit re-audit narrow criteria FAIL |
| 2026-08-13 | Documentation Sources: converted from bullet list to mandated table format (Source | Type | Location | Verification) for the two documented sources (090-data-integrity.md, with-test-home) | SC-11-DOCS: Documentation Sources used a bullet list, not the required table format (spec-structure-standards.md §8) | Spec-audit re-audit narrow criteria FAIL |
| 2026-08-13 | Requirements: converted `REQ-1`–`REQ-7` identifiers to `R-1`–`R-7` with RFC 2119 normative keywords (SHALL / SHALL NOT); rewrote each requirement as a normative requirement statement. Updated all downstream references (Traceability table, Phase 1/2/3 headings, Change Control historical entries) to keep traceability intact: REQ-1→R-1, REQ-2→R-2, ... REQ-7→R-7. Number of requirements (7) and their meaning unchanged; all 13 SCs intact. | SC-1: Requirements section deviated from spec-structure-standards.md §4, which mandates RFC 2119 SHALL/SHOULD/MAY normative language and `R-N` numbering; the spec used `REQ-*` identifiers with descriptive language | Spec-audit re-audit narrow criteria FAIL (SC-1) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
