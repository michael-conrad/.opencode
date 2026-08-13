---
plan_schema_version: 1
issue: 2132
title: "Broaden 090-data-integrity.md with a 6-category general data integrity framework"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2132 — Broaden 090-data-integrity.md with a general data integrity framework

**Issue URL:** https://github.com/michael-conrad/.opencode/issues/2132

**Goal:** Revise `.opencode/guidelines/090-data-integrity.md` in place to preserve all existing battle-tested rules verbatim, remove the 4 project-specific PubMed-pipeline references, and add 6 new broader data integrity categories so the guideline applies across projects.

**Architecture:** Additive revision of a single Markdown guideline. Preserve all existing rules verbatim (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references). Remove the 4 project-specific references (`pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date`), replacing each with a project-agnostic equivalent. Append 6 new category sections (Data Validation at System Boundaries, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) after the existing "Long-Running Tasks" section, and update the "Cross-References" section. Three phases: Phase 1 performs the content revision; Phases 2 and 3 are independent post-revision verification gates.

**Files:**
- `.opencode/guidelines/090-data-integrity.md` — revised: preserve existing rules, remove project-specific references, add 6 new categories

**Dispatch:** test-driven-development, verification-before-completion

## Blast Radius

| File | Revision | Impact Zone |
|------|----------|-------------|
| `.opencode/guidelines/090-data-integrity.md` | revised in place | Single guideline consumed by AI agents at session load (`tier: 1`, `load_when: sub-agent`) |

No application module or executable code path is affected. The deliverable is a Markdown guideline; the relevant "code path" is the set of guideline sections and concepts the revision establishes.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete. SC-1 through SC-9 are string checks; SC-10 through SC-12 are behavioral; SC-13 is semantic. A behavioral test that cannot execute or remains inconsistent after up to 3 retries is FAIL with remediation — never reclassified as an infrastructure issue.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Steps | Dispatch |
|-------|------|---------|-----|------------|-------|----------|
| 1 | Content revision | Preserve existing rules, remove project-specific references, add 6 new categories | SC-1 through SC-13 | — | 5–56 | `test-driven-development` (red, green), `verification-before-completion` (verify), orchestrator (commit) |
| 2 | Absence verification gate | Verify zero project-specific reference matches remain | SC-2 | 1 | 57 | `verification-before-completion` (verify) |
| 3 | Presence and scope verification gate | Verify all 6 category headers and required concepts present | SC-1, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 | 1 | 58 | `verification-before-completion` (verify) |

## Phase Details

### Phase 1 — Content revision

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | `.opencode/guidelines/090-data-integrity.md` |
| SCs | SC-1 through SC-13 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/guidelines/090-data-integrity.md
preserve_verbatim_rules:
  - no synthetic/imaginary/fabricated data
  - fail fast (raise contextual errors, no false/default/invalid defaults, hard fail on missing required data)
  - no hardcoded entity IDs (dynamic runtime derivation)
  - batch operations (pagination, parameter limits, validation)
  - tqdm requirement for long-running tasks
  - cross-reference to 200-errors.md
remove_project_specific_references:
  - pubmed_data_2
  - SEED_PM_IDS
  - MeSH
  - discovery_date
add_categories_after: Long-Running Tasks
categories:
  - Data Validation at System Boundaries
  - Serialization Integrity
  - Data Classification
  - Migration Integrity
  - Audit Trail
  - Data Retention
```

### Phase 2 — Absence verification gate

| Field | Value |
|-------|-------|
| Skill | `verification-before-completion` |
| Task | `verify` |
| Target | `.opencode/guidelines/090-data-integrity.md` |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
verification: absence of pubmed_data_2, SEED_PM_IDS, MeSH, discovery_date (zero matches)
```

### Phase 3 — Presence and scope verification gate

| Field | Value |
|-------|-------|
| Skill | `verification-before-completion` |
| Task | `verify` |
| Target | `.opencode/guidelines/090-data-integrity.md` |
| SCs | SC-1, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 |
| Depends On | 1 |

**Context:**
```yaml
verification:
  - 6 category headers present
  - boundary-validation concepts: structure, types, constraints, missing data, entity resolution
  - serialization concepts: versioning, backward compat, traceability
  - classification concepts: sensitivity levels, production data restrictions
  - migration concepts: reversibility, verification, sampling
  - audit concepts: traceability, authorization, documented changes
  - retention: retention policy per classification
```

## Exit Criteria

- [ ] C1. `.opencode/guidelines/090-data-integrity.md` contains all 6 new data integrity category sections (SC-1)
- [ ] C2. No project-specific references remain (`pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date`) (SC-2)
- [ ] C3. All existing specific rules preserved verbatim (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) (SC-3)
- [ ] C4. Data validation at system boundaries covers structure, types, constraints, missing data, entity resolution (SC-4)
- [ ] C5. Serialization integrity covers versioning, backward compat, traceability (SC-5)
- [ ] C6. Data classification covers sensitivity levels, production data restrictions (SC-6)
- [ ] C7. Migration integrity covers reversibility, verification, sampling (SC-7)
- [ ] C8. Audit trail covers traceability, authorization, documented changes (SC-8)
- [ ] C9. Data retention covers retention policies per classification (SC-9)
- [ ] C10. Behavioral test confirms agent refuses to generate synthetic/fabricated data with explicit decline message (SC-10)
- [ ] C11. Behavioral test confirms agent raises `ValueError` (exact type) on missing required data, not a default/placeholder/fallback (SC-11)
- [ ] C12. Behavioral test confirms agent derives entity references from runtime sources, not hardcoded constants (SC-12)
- [ ] C13. Clean-room sub-agent confirms all 6 enumerated specific rules present in the new file, each reported present/absent (SC-13)
