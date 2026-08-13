# Phase 2 — Absence verification gate

**Concern:** Verify that zero project-specific references remain in the revised file.

**Files:**
- `.opencode/guidelines/090-data-integrity.md`

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: file is in REVISED state (project-specific references removed)
- Phase 1 VbC passed

**Exit Conditions:**
- Zero matches for `pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date` in the affected file

## Code Path Coverage

| SC | Guideline section(s) checked |
|----|------------------------------|
| SC-2 | Absence of `pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date` |

## Cross-Cutting SCs

SC-2 spans content_revision (removal in Phase 1) and absence_verification (this phase).

## Interface Boundaries

No interface boundaries change in this verification-only phase. It reads the revised file and confirms absence of project-specific reference strings.

## State Transitions

```
REVISED --(Phase 2)--> ABSENCE_VERIFIED
```

| State | Description |
|-------|-------------|
| REVISED | File preserved existing rules, removed project-specific references, added 6 categories |
| ABSENCE_VERIFIED | Post-revision gate: zero project-specific reference matches remain |

---

**Cost frame:** Running the absence grep costs seconds of execution time. Skipping means stale project-specific rules can persist unrecognized, binding the general data integrity rules to one project's vocabulary and producing a false PASS at the next session.

## Step-by-step

- [ ] 56. **VbC (**clean-room**).** Grep the affected file for each project-specific reference (`pubmed_data_2`, `SEED_PM_IDS`, `MeSH`, `discovery_date`) and confirm zero matches. Verify each match manually if a pattern hits unintended content; only actual project-specific references are in scope for absence. Produce evidence artifact. **→ SC-2**

## Phase 2 VbC

- [ ] 57. **VbC (**clean-room**).** Verify zero project-specific reference matches remain in the affected file. **→ SC-2**

**Concern transition:** Leaving absence verification → entering presence and scope verification (Phase 3). Phase 3 is independent of Phase 2 (disjoint verification sets: absence vs presence), but both must run; Phase 3 depends on the same REVISED file state.
