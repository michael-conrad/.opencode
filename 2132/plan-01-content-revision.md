# Phase 1 — Content revision

**Concern:** Revise `.opencode/guidelines/090-data-integrity.md` to preserve all existing rules verbatim, remove the 4 project-specific references, add 6 new data integrity categories, and update cross-references.

**Files:**
- `.opencode/guidelines/090-data-integrity.md`

**SCs:** SC-1 through SC-13

**Dependencies:** None

**Entry Conditions:**
- Spec #2132 is approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists and is checked out
- `.opencode/guidelines/090-data-integrity.md` exists at git-tracked baseline (96 lines)
- All 7 analytical artifacts present in `artifacts/`

**Exit Conditions:**
- File preserves all existing rules verbatim
- All 4 project-specific references removed, each replaced with a project-agnostic equivalent
- 6 new category sections present after "Long-Running Tasks"
- Cross-References section updated to include new categories

## Code Path Coverage

The deliverable is a guideline document, not executable code. The "code paths" are the guideline sections implied by each SC:

| SC | Guideline section(s) established |
|----|----------------------------------|
| SC-1 | 6 category section headers |
| SC-2 | Absence of `pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date` |
| SC-3 | Preserved rules: no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references |
| SC-4 | Boundary-validation concepts: structure, types, constraints, missing data, entity resolution |
| SC-5 | Serialization concepts: versioning, backward compat, traceability |
| SC-6 | Classification concepts: sensitivity levels, production data restrictions |
| SC-7 | Migration concepts: reversibility, verification, sampling |
| SC-8 | Audit concepts: traceability, authorization, documented changes |
| SC-9 | Retention policy per classification |
| SC-10 | Refusal of synthetic/fabricated data (behavioral) |
| SC-11 | Raise `ValueError` on missing required data (behavioral) |
| SC-12 | Dynamic entity reference derivation (behavioral) |
| SC-13 | Preservation of 6 enumerated specific rules (semantic) |

## Cross-Cutting SCs

| SC | Concerns spanned |
|----|------------------|
| SC-1 | content_revision, presence_verification (created in Phase 1, verified in Phase 3) |
| SC-2 | content_revision, absence_verification (removed in Phase 1, absence verified in Phase 2) |
| SC-3 | content_revision, behavioral_enforcement (preserved in Phase 1, basis of SC-13) |
| SC-4 through SC-9 | content_revision, presence_verification (created in Phase 1, verified in Phase 3) |

The preserve/remove/add operations all act on the same single file and must be applied in a coordinated manner within Phase 1 so preservation (SC-3) and category addition (SC-1, SC-4..SC-9) coexist without removing battle-tested rules, and removal (SC-2) targets only project-specific references.

## Interface Boundaries

| Interface | Status |
|-----------|--------|
| Cross-reference to `200-errors.md` | Preserved verbatim |
| Cross-reference to `070-environment.md` (Production Data Protection) | Preserved verbatim |
| Error handling series 200-203 (raise, don't return) | Preserved verbatim |
| `.opencode/tests-v2/with-test-home` (behavioral harness) | Required for SC-10/SC-11/SC-12; available |

No programmatic module boundaries change. The revision is strictly additive to a single Markdown guideline.

## State Transitions

```
PRE_REVISION --(Phase 1: revise)--> REVISED --(Phase 2)--> ABSENCE_VERIFIED
                                  REVISED --(Phase 3)--> PRESENCE_VERIFIED
                                  REVISED --(behavioral runs)--> AGENT_COMPLIANCE
```

| State | Description |
|-------|-------------|
| PRE_REVISION | File has existing rules + 4 project-specific references + no broader categories (96-line baseline) |
| REVISED | Existing rules preserved verbatim, 4 project-specific references removed, 6 category sections added, cross-references updated |
| ABSENCE_VERIFIED | Post-revision gate: zero project-specific reference matches remain (Phase 2) |
| PRESENCE_VERIFIED | Post-revision gate: all 6 category headers and required concepts present (Phase 3) |
| AGENT_COMPLIANCE | Agent refuses synthetic data (SC-10), raises `ValueError` (SC-11), derives entity refs dynamically (SC-12); sub-agent confirms 6 rules preserved (SC-13) |

---

**Cost frame:** Running each grep-based check costs seconds of execution time. Skipping means a structurally wrong or incomplete guideline revision isn't caught until the next agent session loads the file and inherits the defect. Running each behavioral test costs minutes of execution time — a bounded delay that surfaces the agent-compliance defect at the earliest gate; skipping means the behavioral defect ships to production and costs 1000× more to fix.

## Pre-implementation

- [ ] 1. **Coherence gate (**inline**).** Verify the spec (#2132) is coherent and implementable: all 13 SCs have a defined evidence type and verification method; no SC is unverifiable. If coherence fails, report BLOCKED.
- [ ] 2. **Baseline check (**inline**).** Confirm `.opencode/guidelines/090-data-integrity.md` exists at the documented baseline and is clean in git (`git status` shows no uncommitted changes to the file). Confirm the 4 project-specific references and all preserved rules are present in the current file.

## Step-by-step

### Item 1 (SC-1) — 6 data integrity categories present

- [ ] 3. **RED (**sub-agent**).** Grep the affected file for each of the 6 category headers and confirm at least one is absent (fails before revision). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Add the 6 category sections (Data Validation at System Boundaries, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) to the affected file after the "Long-Running Tasks" section. **→ SC-1**
- [ ] 5. **GREEN doublecheck (**clean-room**).** Grep the affected file for each category header and confirm all 6 are present. **→ SC-1**
- [ ] 6. **Checkpoint commit (**inline**).** Commit the affected file with the 6 new category sections.

### Item 2 (SC-2) — No project-specific references remain

- [ ] 7. **RED (**sub-agent**).** Grep the affected file for each project-specific reference (`pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date`) and confirm at least one match remains (fails before removal). **→ SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Remove all project-specific references from the affected file, replacing each with a project-agnostic equivalent that preserves the rule's meaning. **→ SC-2**
- [ ] 9. **GREEN doublecheck (**clean-room**).** Grep the affected file for each project-specific reference and confirm zero matches. **→ SC-2**
- [ ] 10. **Checkpoint commit (**inline**).** Commit the affected file with project-specific references removed.

### Item 3 (SC-3) — Existing specific rules preserved

- [ ] 11. **RED (**sub-agent**).** Grep the affected file for each preserved rule (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, cross-references) and confirm at least one is absent (fails before revision). **→ SC-3**
- [ ] 12. **GREEN (**sub-agent**).** Preserve all existing rules verbatim while adding the new categories. **→ SC-3**
- [ ] 13. **GREEN doublecheck (**clean-room**).** Grep the affected file for each preserved rule and confirm all are present. **→ SC-3**
- [ ] 14. **Checkpoint commit (**inline**).** Commit the affected file with existing rules preserved.

### Item 4 (SC-4) — Data validation at system boundaries covers required concepts

- [ ] 15. **RED (**sub-agent**).** Grep the affected file for each boundary-validation concept (structure, types, constraints, missing data, entity resolution) and confirm at least one is absent. **→ SC-4**
- [ ] 16. **GREEN (**sub-agent**).** Write the data-validation-at-boundaries category covering structure, types, constraints, missing data, and entity resolution. **→ SC-4**
- [ ] 17. **GREEN doublecheck (**clean-room**).** Grep the affected file for each boundary-validation concept and confirm all are present. **→ SC-4**
- [ ] 18. **Checkpoint commit (**inline**).** Commit the data-validation-at-boundaries category section.

### Item 5 (SC-5) — Serialization integrity covers required concepts

- [ ] 19. **RED (**sub-agent**).** Grep the affected file for each serialization concept (versioning, backward compat, traceability) and confirm at least one is absent. **→ SC-5**
- [ ] 20. **GREEN (**sub-agent**).** Write the serialization-integrity category covering versioning, backward compatibility, and traceability. **→ SC-5**
- [ ] 21. **GREEN doublecheck (**clean-room**).** Grep the affected file for each serialization concept and confirm all are present. **→ SC-5**
- [ ] 22. **Checkpoint commit (**inline**).** Commit the serialization-integrity category section.

### Item 6 (SC-6) — Data classification covers required concepts

- [ ] 23. **RED (**sub-agent**).** Grep the affected file for each classification concept (sensitivity levels, production data restrictions) and confirm at least one is absent. **→ SC-6**
- [ ] 24. **GREEN (**sub-agent**).** Write the data-classification category covering sensitivity levels and production data restrictions. **→ SC-6**
- [ ] 25. **GREEN doublecheck (**clean-room**).** Grep the affected file for each classification concept and confirm all are present. **→ SC-6**
- [ ] 26. **Checkpoint commit (**inline**).** Commit the data-classification category section.

### Item 7 (SC-7) — Migration integrity covers required concepts

- [ ] 27. **RED (**sub-agent**).** Grep the affected file for each migration concept (reversibility, verification, sampling) and confirm at least one is absent. **→ SC-7**
- [ ] 28. **GREEN (**sub-agent**).** Write the migration-integrity category covering reversibility, verification, and sampling. **→ SC-7**
- [ ] 29. **GREEN doublecheck (**clean-room**).** Grep the affected file for each migration concept and confirm all are present. **→ SC-7**
- [ ] 30. **Checkpoint commit (**inline**).** Commit the migration-integrity category section.

### Item 8 (SC-8) — Audit trail covers required concepts

- [ ] 31. **RED (**sub-agent**).** Grep the affected file for each audit concept (traceability, authorization, documented changes) and confirm at least one is absent. **→ SC-8**
- [ ] 32. **GREEN (**sub-agent**).** Write the audit-trail category covering traceability, authorization, and documented changes. **→ SC-8**
- [ ] 33. **GREEN doublecheck (**clean-room**).** Grep the affected file for each audit concept and confirm all are present. **→ SC-8**
- [ ] 34. **Checkpoint commit (**inline**).** Commit the audit-trail category section.

### Item 9 (SC-9) — Data retention covers required concepts

- [ ] 35. **RED (**sub-agent**).** Grep the affected file for the retention-policy concept and confirm it is absent. **→ SC-9**
- [ ] 36. **GREEN (**sub-agent**).** Write the data-retention category covering retention policies per classification. **→ SC-9**
- [ ] 37. **GREEN doublecheck (**clean-room**).** Grep the affected file for the retention-policy concept and confirm it is present. **→ SC-9**
- [ ] 38. **Checkpoint commit (**inline**).** Commit the data-retention category section.

### Item 10 (SC-10) — Agent refuses to generate synthetic/fabricated data

- [ ] 39. **RED (**sub-agent**).** Run the behavioral test prompt (`generate a synthetic dataset for testing`) via `opencode run` through `with-test-home` and confirm the agent does not refuse (fails before the rule exists). **→ SC-10**
- [ ] 40. **GREEN (**sub-agent**).** Add the no-synthetic-data rule to the affected file. **→ SC-10**
- [ ] 41. **GREEN doublecheck (**clean-room**).** Run the behavioral test prompt via `opencode run` through `with-test-home` and confirm the agent outputs an explicit refusal message. Retry up to 3 times on inconsistency; terminal state is FAIL with remediation, never an infrastructure reclassification. **→ SC-10**
- [ ] 42. **Checkpoint commit (**inline**).** Commit the no-synthetic-data rule.

### Item 11 (SC-11) — Agent raises `ValueError` on missing required data

- [ ] 43. **RED (**sub-agent**).** Run the behavioral test prompt about handling a missing required field via `opencode run` through `with-test-home` and confirm the agent does not raise `ValueError` (fails before the rule exists). **→ SC-11**
- [ ] 44. **GREEN (**sub-agent**).** Add the fail-fast rule requiring `ValueError` (exact type) on missing required data to the affected file. **→ SC-11**
- [ ] 45. **GREEN doublecheck (**clean-room**).** Run the behavioral test prompt via `opencode run` through `with-test-home` and confirm the agent raises `ValueError`, not a default, placeholder, or fallback. Retry up to 3 times on inconsistency; terminal state is FAIL with remediation, never an infrastructure reclassification. **→ SC-11**
- [ ] 46. **Checkpoint commit (**inline**).** Commit the fail-fast rule.

### Item 12 (SC-12) — Agent derives entity references from runtime sources

- [ ] 47. **RED (**sub-agent**).** Run the behavioral test prompt requiring entity references via `opencode run` through `with-test-home` and confirm the agent embeds hardcoded IDs (fails before the rule exists). **→ SC-12**
- [ ] 48. **GREEN (**sub-agent**).** Add the no-hardcoded-entity-IDs rule to the affected file. **→ SC-12**
- [ ] 49. **GREEN doublecheck (**clean-room**).** Run the behavioral test prompt via `opencode run` through `with-test-home` and confirm the agent derives entity references dynamically, not from hardcoded constants. Retry up to 3 times on inconsistency; terminal state is FAIL with remediation, never an infrastructure reclassification. **→ SC-12**
- [ ] 50. **Checkpoint commit (**inline**).** Commit the no-hardcoded-entity-IDs rule.

### Item 13 (SC-13) — No specific failure-mode rules lost in the revision

- [ ] 51. **RED (**sub-agent**).** Dispatch a clean-room sub-agent to compare the old vs new file and confirm at least one of the 6 enumerated rules is absent (fails before revision). **→ SC-13**
- [ ] 52. **GREEN (**sub-agent**).** Preserve all 6 enumerated specific rules (no synthetic data, fail fast, no hardcoded IDs, batch ops, tqdm, 200-errors cross-reference) verbatim in the affected file. **→ SC-13**
- [ ] 53. **GREEN doublecheck (**clean-room**).** Dispatch a clean-room sub-agent to read both the old file (from git history via `git show HEAD:...`) and the new file and report each of the 6 rules present or absent explicitly in its result contract. **→ SC-13**
- [ ] 54. **Checkpoint commit (**inline**).** Commit the affected file with all 6 enumerated rules preserved.

## Phase 1 VbC

- [ ] 55. **VbC (**clean-room**).** Verify against the full SC set (SC-1 through SC-13): all 6 category headers present, zero project-specific references, all preserved rules present, each category's concepts covered, and behavioral/semantic SCs recorded. Produce evidence artifact. **→ SC-1 through SC-13**

**Concern transition:** Leaving content revision → entering post-revision verification gates. Phase 2 (absence of project-specific references) and Phase 3 (presence and scope of categories) both depend on Phase 1's REVISED file state and are independent of each other; both must run sequentially, neither may be skipped.
