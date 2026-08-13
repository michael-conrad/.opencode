# Phase 3 — Presence and scope verification gate

**Concern:** Verify that all 6 data integrity category headers and their required concepts are present with correct scope in the revised file.

**Files:**
- `.opencode/guidelines/090-data-integrity.md`

**SCs:** SC-1, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: file is in REVISED state (6 category sections added)
- Phase 1 VbC passed

**Exit Conditions:**
- All 6 category headers present
- Each category's required concepts present with correct scope

## Code Path Coverage

| SC | Guideline section(s) checked |
|----|------------------------------|
| SC-1 | 6 category section headers present |
| SC-4 | Boundary-validation concepts: structure, types, constraints, missing data, entity resolution |
| SC-5 | Serialization concepts: versioning, backward compat, traceability |
| SC-6 | Classification concepts: sensitivity levels, production data restrictions |
| SC-7 | Migration concepts: reversibility, verification, sampling |
| SC-8 | Audit concepts: traceability, authorization, documented changes |
| SC-9 | Retention policy per classification |

## Cross-Cutting SCs

Each of SC-1 and SC-4 through SC-9 spans content_revision (created in Phase 1) and presence_verification (this phase).

## Interface Boundaries

No interface boundaries change in this verification-only phase. It reads the revised file and confirms presence and scope of category headers and concepts.

## State Transitions

```
REVISED --(Phase 3)--> PRESENCE_VERIFIED
```

| State | Description |
|-------|-------------|
| REVISED | File preserved existing rules, removed project-specific references, added 6 categories |
| PRESENCE_VERIFIED | Post-revision gate: all 6 category headers and required concepts present |

---

**Cost frame:** Running each presence/scope grep costs seconds of execution time. Skipping means a structurally incomplete guideline passes review and the missing category ships — a defect discovered only when the next agent session loads the file and inherits the gap.

## Step-by-step

- [ ] 58. **VbC (**clean-room**).** Grep the affected file for each category header and confirm all 6 are present; then grep for each required concept within each category (boundary-validation: structure/types/constraints/missing-data/entity-resolution; serialization: versioning/backward-compat/traceability; classification: sensitivity-levels/production-data-restrictions; migration: reversibility/verification/sampling; audit: traceability/authorization/documented-changes; retention: retention-policy-per-classification) and confirm scope coverage. Produce evidence artifact. **→ SC-1, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9**

## Phase 3 VbC

- [ ] 59. **VbC (**clean-room**).** Verify all 6 category headers and required concepts present with correct scope in the affected file. **→ SC-1, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9**

## Post-implementation

- [ ] 60. **Structural checks (**inline**).** Run the finishing checklist (markdown lint and format check on `.opencode/guidelines/090-data-integrity.md`) per the build/lint/test commands in `.opencode/AGENTS.md`.
- [ ] 61. **Audit (**sub-agent**).** Dispatch the audit skill to adversarially audit the deliverable (spec fidelity, SC coverage, drift detection).
- [ ] 62. **Cross-validate (**sub-agent**).** Independently cross-validate the verification evidence produced in Phase 1 VbC, Phase 2, and Phase 3.
- [ ] 63. **Pre-PR gate (**sub-agent**).** Verify all SC verdicts (SC-1 through SC-13) are PASS; block if any SC is FAIL.
- [ ] 64. **Regression check (**sub-agent**).** Run the final regression check before PR.
- [ ] 65. **Review-prep (**sub-agent**).** Prepare PR review context via the git-workflow-pr skill.
- [ ] 66. **Create PR (**sub-agent**).** Create the pull request via the git-workflow-pr skill.
- [ ] 67. **Exec summary (**sub-agent**).** Generate the completion executive summary via the completion-core skill.

**Concern transition:** Content revision and both post-revision verification gates are complete. All 13 SCs verified; the plan proceeds to completion.
