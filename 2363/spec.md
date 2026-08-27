> **Full spec and artifacts: [`.opencode/.issues/2363/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2363)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2363/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC: Create shared reference data-integrity-shared.md

## 1. Intent and Executive Summary

1. **Problem Statement** — The seven procedural data-integrity sections of `.opencode/guidelines/090-data-integrity.md` (Batch Operations, Long-Running Tasks, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) are needed on demand by the `engineering-approach` and `programming-principles` consuming skill cards. Today this procedural content is only reachable via the preloaded 090 guideline, which cannot be condensed until the procedural sections have a standalone canonical home that consumers can Read-link to.

2. **Root Cause / Motivation** — 090-data-integrity.md bundles non-procedural mandates (Global Absolute Prohibition, Fail-Fast, Verify Before Recommend, No Unauthorized Semantic Changes, Production Data Protection, No Hardcoded Entity IDs, Data Validation at System Boundaries) together with seven procedural sections that are candidates for condensation (~2.7k token savings). The procedural content cannot be extracted and 090 condensed until the consumers (engineering-approach, programming-principles) explicitly Read-link to a shared reference that holds the extracted sections. This spec creates that reference and the consumer Read-links, preparing the ground for the separate downstream 090 condensation issue.

3. **Approach Chosen** — Create `.opencode/reference/data-integrity-shared.md` holding the seven procedural sections verbatim from 090-data-integrity.md, and add mandatory `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` links to the consuming skill cards/task files (engineering-approach, programming-principles). This follows the established `reference/*.md` convention and the AGENTS.md Read-Link Cross-Reference Rule (inline `Read [Text](path)` form, not `See §section` citations).

4. **Alternatives Considered & Why Discarded** —
   - *Re-inlining the procedural content into each consuming card* — discarded: duplicates content across cards, defeats the purpose of a single canonical source, and violates the Scope Out (no re-inlining). The shared-reference approach preserves DRY.
   - *Removing the procedural sections from 090 in this same spec* — discarded: 090 condensation is a separate dependent downstream issue with its own risk profile (the #497 preload safety regression). This spec only prepares for condensation; it does not perform it.

5. **Key Design Decisions** —
   - The shared reference is a **read-only canonical reference** consumed via inline `Read [Text](path)` links, not added to the opencode.jsonc preload array. Reference files are read on demand (verified convention).
   - The seven sections are copied **verbatim** — no semantic drift, no rewording, no restructuring. This honors 090's own no-unauthorized-semantic-changes rule and `130-authority-source.md`.
   - 090-data-integrity.md is **not modified** by this spec; it remains the preloaded Tier 1 guideline. This avoids scope creep into the condensation concern.
   - All changed files live under `.opencode/` and are routed to the `.opencode` repository (owner `michael-conrad`, repo `.opencode`), not the root repo.

6. **User Intent / Original Prompt** — The request is to create a shared reference file `data-integrity-shared.md` holding the procedural data-integrity sections and to add mandatory Read-links to the consuming skill cards, so that 090 can later be condensed without losing access to the procedural content.

## 2. Not Included

- **090-data-integrity.md condensation** — Removing or condensing the non-procedural sections of 090 is a separate dependent downstream issue. This spec only adds Read-links and the shared reference; it does not modify 090.
- **Re-inlining procedural content into consuming cards** — The procedural sections are moved to the shared reference only; they are NOT duplicated inline into engineering-approach or programming-principles.
- **Preload array changes** — opencode.jsonc (12 Tier 1 guidelines) is not modified; the shared reference is not added to preload.
- **Behavioral validation of Read-link efficacy** — Proving agents actually follow the Read-link belongs to the downstream 090 condensation issue, not this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/reference/data-integrity-shared.md` exists and contains the seven procedural sections (Batch Operations, Long-Running Tasks, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) verbatim from 090-data-integrity.md | structural | `ls` for existence; grep for all seven section headers; diff each section body against the corresponding 090-data-integrity.md section |
| SC-2 | `engineering-approach` skill card/task files contain a mandatory `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` link | structural | grep engineering-approach/SKILL.md and task files for the canonical Read-link form |
| SC-3 | `programming-principles` skill card/task files contain a mandatory `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` link | structural | grep programming-principles/SKILL.md and task files for the canonical Read-link form |
| SC-4 | No procedural content is re-inlined into the consuming cards (Scope Out respected) | structural | grep engineering-approach and programming-principles files for distinctive procedural phrases (e.g., "POSTGRESQL PARAMETER LIMIT", "tqdm", "VERSION ALL SERIALIZED FORMATS"); verify none are duplicated inline |
| SC-5 | `.opencode/guidelines/090-data-integrity.md` is not modified by this spec | structural | `git diff` shows no changes to 090-data-integrity.md in this branch's changeset |

## 4. Requirements

- **R-1.** The system SHALL create `.opencode/reference/data-integrity-shared.md` as a new canonical reference file.
- **R-2.** The shared reference SHALL contain the seven procedural sections (Batch Operations, Long-Running Tasks, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) preserved verbatim from 090-data-integrity.md.
- **R-3.** The `engineering-approach` skill card/task files SHALL contain a `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` inline link.
- **R-4.** The `programming-principles` skill card/task files SHALL contain a `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` inline link.
- **R-5.** All Read-links SHALL use the canonical `Read [Text](path)` inline form — not `See §section` citations or resolution tables.
- **R-6.** The procedural content SHALL NOT be re-inlined into the consuming cards.
- **R-7.** The system SHALL NOT modify `.opencode/guidelines/090-data-integrity.md` in this spec.
- **R-8.** The system SHALL NOT modify the opencode.jsonc instructions array (12 Tier 1 guidelines remain preloaded).
- **R-9.** The shared reference SHALL be a read-only canonical reference consumed on demand — it SHALL NOT be added to the preload array.
- **R-10.** All changed files SHALL be routed to the `.opencode` repository (owner `michael-conrad`, repo `.opencode`).

## 5. Items

### Item 1 (SC-1): Create data-integrity-shared.md with seven procedural sections verbatim

- RED: `ls .opencode/reference/data-integrity-shared.md` fails (file does not exist)
- GREEN: Create `.opencode/reference/data-integrity-shared.md` containing the seven procedural sections copied verbatim from 090-data-integrity.md
- verify: `ls` confirms existence; grep confirms all seven section headers; diff each section body against 090 source
- commit: new file `.opencode/reference/data-integrity-shared.md`

### Item 2 (SC-2): Add mandatory Read-link to engineering-approach skill card/task files

- RED: grep engineering-approach files for `Read [data-integrity-shared.md]` returns no match
- GREEN: Add `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` link to engineering-approach/SKILL.md (and task files as needed)
- verify: grep confirms the canonical Read-link form present
- commit: modified engineering-approach skill card/task files

### Item 3 (SC-3): Add mandatory Read-link to programming-principles skill card/task files

- RED: grep programming-principles files for `Read [data-integrity-shared.md]` returns no match
- GREEN: Add `Read [data-integrity-shared.md](reference/data-integrity-shared.md)` link to programming-principles/SKILL.md (and task files as needed)
- verify: grep confirms the canonical Read-link form present
- commit: modified programming-principles skill card/task files

### Item 4 (SC-4): Verify no re-inlining of procedural content into consuming cards

- RED: grep consuming cards for distinctive procedural phrases (e.g., "POSTGRESQL PARAMETER LIMIT", "tqdm", "VERSION ALL SERIALIZED FORMATS") — placeholder guard
- GREEN: Confirm no duplicated procedural content present in engineering-approach / programming-principles files
- verify: grep returns no inline procedural phrase matches in consuming cards
- commit: (verification only — no file change)

### Item 5 (SC-5): Verify 090-data-integrity.md unchanged

- RED: `git diff` against baseline shows a change to 090-data-integrity.md (placeholder guard)
- GREEN: Confirm `git diff` shows no changes to `.opencode/guidelines/090-data-integrity.md`
- verify: `git diff` shows 090-data-integrity.md untouched in this changeset
- commit: (verification only — no file change)

## 6. Dependencies

- **Reference:** `.opencode/guidelines/090-data-integrity.md` — **Relationship:** source content; the seven procedural sections are copied verbatim from it. **Status:** satisfied (file exists, preloaded).
- **Reference:** AGENTS.md Read-Link Cross-Reference Rule — **Relationship:** mandates the `Read [Text](path)` inline form. **Status:** satisfied.
- **Reference:** `.opencode/.issues/research-cards/cross-reference-form-comparison.md` — **Relationship:** confirms inline markdown links are the reliable cross-reference form (confidence 0.95). **Status:** satisfied.
- **Reference:** `.opencode/reference/*.md` convention — **Relationship:** the new reference file follows this convention (read on demand, not preloaded). **Status:** satisfied.
- **Reference:** 090-data-integrity condensation (downstream dependent issue) — **Relationship:** this spec PREPARES for condensation; the condensation itself is a separate downstream issue that must not be performed here. **Status:** pending (downstream, not part of this spec).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | 1 |
| R-2 | SC-1 | 1 |
| R-3 | SC-2 | 2 |
| R-4 | SC-3 | 3 |
| R-5 | SC-2, SC-3 | 2, 3 |
| R-6 | SC-4 | 4 |
| R-7 | SC-5 | 5 |
| R-8 | SC-5 | 5 |
| R-9 | SC-1 | 1 |
| R-10 | SC-1, SC-2, SC-3 | 1, 2, 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 090-data-integrity.md | code (guideline) | `.opencode/guidelines/090-data-integrity.md` | read — section headers and bodies confirmed |
| AGENTS.md Read-Link Cross-Reference Rule | doc | `.opencode/AGENTS.md` | read — mandates inline Read [Text](path) form |
| cross-reference-form-comparison research card | doc | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read — confidence 0.95, inline links reliable |
| spec-structure-standards.md | doc | `.opencode/reference/spec-structure-standards.md` | read — required spec sections |
| cost-model-standards.md | doc | `.opencode/reference/cost-model-standards.md` | read — dark-prose-007 cost-frame format |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the shared reference exists and matches 090 verbatim costs a file read and per-section diff. Skipping means a missing or drift-ridden reference ships, and every downstream consumer (and the future 090 condensation) inherits the defect — a structurally wrong canonical source that propagates for weeks.
- **SC-2:** Verifying the engineering-approach Read-link costs one grep. Skipping means the consumer never loads the shared reference after 090 condenses — the procedural content silently vanishes from the engineering-approach context and is only rediscovered as a production defect.
- **SC-3:** Verifying the programming-principles Read-link costs one grep. Skipping means the same silent content loss for programming-principles consumers.
- **SC-4:** Verifying no re-inlining costs one grep. Skipping means duplicated procedural content creeps into cards, defeating the shared-reference purpose and guaranteeing future inconsistency.
- **SC-5:** Verifying 090 is unchanged costs one git diff. Skipping means scope creep into the condensation concern — a change that should be a separate, reviewed issue ships as a side effect.

## 11. Edge Cases

- **Input boundaries:** The shared reference file is empty or missing → SC-1 verification (file existence + seven section headers) FAILs. Resolution: create/repair the reference with all seven sections verbatim before proceeding.
- **State transitions:** Phase 1 (reference create) must complete before Phases 2-3 (Read-links), because a Read-link to a nonexistent reference is a dangling reference. The guards (Phases 4-5) are independent and may run at any point.
- **Failure modes:** A consuming card already contains a conflicting/`See §section` reference to the procedural content → the new Read-link must replace or supplement it; the Phase 4 guard catches any residual inline content. If the `.opencode/reference/` directory does not exist, it is created as part of SC-1.
- **Concurrency:** Not applicable — a single writer creates the reference and adds links; no concurrent readers depend on intermediate state within this spec's execution.
- **Recovery:** If 090 is accidentally modified during implementation, `git diff` (SC-5) detects it and the change is reverted before completion; the downstream condensation issue remains the sole authorized path for 090 changes.
