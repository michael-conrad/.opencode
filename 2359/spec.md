---
number: 2359
title: '[SPEC] Create shared ref: orchestrator-context-discipline.md'
status: open
labels: [needs-approval, spec-draft]
---

> **Full spec and artifacts: [`.opencode/.issues/2359/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2359)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2359/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Create shared reference orchestrator-context-discipline.md

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | `.opencode/guidelines/020-go-prohibitions.md` §1.1 Orchestrator Context Discipline (lines 84-139) is procedural content that must be removed from the preloaded guideline but is referenced by multiple skill cards (approval-gate, spec-creation, writing-plans, executing-plans, git-workflow). |
| 2 | **Root Cause / Motivation** | The orchestrator-context-lean, sub-agent-context-generosity, and result-contract-frugality mandates are referenced by multiple skill cards. Keeping this procedural content inline in the preloaded guideline forces every agent to load it, and risks duplication if each consuming card re-inlines it. A single canonical reference file, consumed via mandatory Read-links, is the correct home. |
| 3 | **Approach Chosen** | Create `.opencode/reference/orchestrator-context-discipline.md` as the single canonical home for the orchestrator context discipline content, extracted from `020-go-prohibitions.md` §1.1. Add mandatory `Read [Text](path)` links to the 5 consuming skill cards' Cross-References sections, and index the reference in the AGENTS.md Reference Documents table. |
| 4 | **Alternatives Considered & Why Discarded** | Re-inlining the content into each consuming card was considered and discarded — it duplicates content across 5+ files, creating drift risk and violating the single-source-of-truth principle. A resolution table or bare `§Name` citation was discarded per the cross-reference-form-comparison research card (only 42-58% access rate vs. 100% for the imperative inline-link form). |
| 5 | **Key Design Decisions** | (1) The reference is a standards/reference document, NOT a task card — it is read by orchestrators, never dispatched to sub-agents. (2) Consuming cards MUST use the imperative `Read [Text](path)` inline-link form per the Read-Link Cross-Reference Rule. (3) The standardized vocabulary ('orchestrator context', 'sub-agent context', 'orchestrator context discipline') MUST be preserved — no regression to 'context budget'/'context cost'/'context awareness'. |
| 6 | **User Intent / Original Prompt** | Create a shared reference `orchestrator-context-discipline.md` to serve as the canonical home for orchestrator context discipline content, enabling the 020-go-prohibitions condensation. |

## 2. Not Included

- **020-go-prohibitions.md condensation** — The condensation of §1.1 out of the guideline is a separate downstream dependency, not this spec's scope. This spec only creates the reference file and wires the Read-links.
- **Re-inlining content into each consuming card** — Duplication is the anti-pattern being avoided; content lives only in the reference.
- **New skill card or task card creation** — Only a reference file and Read-links in existing cards are created.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1a | `.opencode/reference/orchestrator-context-discipline.md` exists as a file. | string | `grep` for the file existence / `file-exists` check on `.opencode/reference/orchestrator-context-discipline.md` |
| SC-1b | The reference file contains the extracted §1.1 **orchestrator-context-lean** mandate. | string | `grep` for `orchestrator-context-lean` in the reference file |
| SC-1c | The reference file contains the extracted §1.1 **sub-agent-context-generosity** mandate. | string | `grep` for `sub-agent-context-generosity` in the reference file |
| SC-1d | The reference file contains the extracted §1.1 **result-contract-frugality** mandate. | string | `grep` for `result-contract-frugality` in the reference file |
| SC-1e | The reference file contains the extracted §1.1 **allocation-by-context-cost** model. | string | `grep` for `allocation-by-context-cost` in the reference file |
| SC-1f | The reference file preserves the standardized vocabulary ('orchestrator context', 'sub-agent context', 'orchestrator context discipline'). | string | `grep` the reference file for the standardized vocabulary terms |
| SC-1g | The reference file does not regress to 'context budget'/'context cost'/'context awareness'. | string | `grep` the reference file confirms absence of the regression terms |
| SC-2a | The **approval-gate** skill card contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` approval-gate's Cross-References section for the `Read [Text](path)` link to the reference |
| SC-2b | The **spec-creation** skill card contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` spec-creation's Cross-References section for the `Read [Text](path)` link to the reference |
| SC-2c | The **writing-plans** skill card contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` writing-plans's Cross-References section for the `Read [Text](path)` link to the reference |
| SC-2d | The **executing-plans** skill card contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` executing-plans's Cross-References section for the `Read [Text](path)` link to the reference |
| SC-2e | The **git-workflow** skill card contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` git-workflow's Cross-References section for the `Read [Text](path)` link to the reference |
| SC-3 | The AGENTS.md Reference Documents table contains a row for `orchestrator-context-discipline.md` with a Purpose entry. | string | `grep` the AGENTS.md Reference Documents table for the reference filename |

## 4. Requirements

- R-1. The system SHALL create `.opencode/reference/orchestrator-context-discipline.md` as the single canonical home for orchestrator-context-lean, sub-agent-context-generosity, result-contract-frugality, and the allocation-by-context-cost model.
- R-2. The reference file SHALL preserve the standardized vocabulary ('orchestrator context', 'sub-agent context', 'orchestrator context discipline') and SHALL NOT regress to 'context budget'/'context cost'/'context awareness'.
- R-3. The reference file SHALL follow the existing `.opencode/reference/` file conventions (SPDX header, Co-authored with AI byline, `## Overview` section).
- R-4. The 5 consuming skill cards (approval-gate, spec-creation, writing-plans, executing-plans, git-workflow) SHALL each contain a mandatory `Read [Text](path)` link to the reference in their Cross-References sections.
- R-5. The `Read [Text](path)` links SHALL use the imperative inline-link form per the Read-Link Cross-Reference Rule.
- R-6. The reference SHALL be indexed in the AGENTS.md Reference Documents table with a Purpose entry.
- R-7. The reference SHALL be a standards/reference document, NOT a task card — it is read by orchestrators, not dispatched to sub-agents.
- R-8. The reference content SHALL NOT be re-inlined into each consuming card (duplication avoided).

## 5. Items

### Item 1 (SC-1a, SC-1b, SC-1c, SC-1d, SC-1e, SC-1f, SC-1g): Create orchestrator-context-discipline.md reference file

- RED (SC-1a): Enforcement test that asserts the reference file does not yet exist at `.opencode/reference/orchestrator-context-discipline.md`.
- GREEN (SC-1a): Create `.opencode/reference/orchestrator-context-discipline.md` with the extracted §1.1 content, preserving the standardized vocabulary and following reference file conventions.
- verify (SC-1a): Confirm the reference file exists.
- commit (SC-1a): The new reference file.

- RED (SC-1b): Enforcement test that asserts the reference file does not contain the orchestrator-context-lean mandate.
- GREEN (SC-1b): Ensure the reference file contains the orchestrator-context-lean mandate content.
- verify (SC-1b): `grep` the reference file for `orchestrator-context-lean`.
- commit (SC-1b): The reference file.

- RED (SC-1c): Enforcement test that asserts the reference file does not contain the sub-agent-context-generosity mandate.
- GREEN (SC-1c): Ensure the reference file contains the sub-agent-context-generosity mandate content.
- verify (SC-1c): `grep` the reference file for `sub-agent-context-generosity`.
- commit (SC-1c): The reference file.

- RED (SC-1d): Enforcement test that asserts the reference file does not contain the result-contract-frugality mandate.
- GREEN (SC-1d): Ensure the reference file contains the result-contract-frugality mandate content.
- verify (SC-1d): `grep` the reference file for `result-contract-frugality`.
- commit (SC-1d): The reference file.

- RED (SC-1e): Enforcement test that asserts the reference file does not contain the allocation-by-context-cost model.
- GREEN (SC-1e): Ensure the reference file contains the allocation-by-context-cost model content.
- verify (SC-1e): `grep` the reference file for `allocation-by-context-cost`.
- commit (SC-1e): The reference file.

- RED (SC-1f): Enforcement test that asserts the standardized vocabulary terms are absent.
- GREEN (SC-1f): Ensure the reference file preserves 'orchestrator context'/'sub-agent context'/'orchestrator context discipline'.
- verify (SC-1f): `grep` the reference file for the standardized vocabulary terms.
- commit (SC-1f): The reference file.

- RED (SC-1g): Enforcement test that asserts the regression terms ('context budget'/'context cost'/'context awareness') are present.
- GREEN (SC-1g): Ensure the reference file does not use the regression terms.
- verify (SC-1g): `grep` the reference file confirms absence of the regression terms.
- commit (SC-1g): The reference file.

### Item 2 (SC-2a, SC-2b, SC-2c, SC-2d, SC-2e): Add mandatory Read [Text](path) links to consuming skill cards

- RED (SC-2a): Enforcement test that asserts the approval-gate skill card does not contain a `Read [Text](path)` link to the reference.
- GREEN (SC-2a): Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of the approval-gate skill card.
- verify (SC-2a): `grep` approval-gate's Cross-References section for the imperative inline-link form.
- commit (SC-2a): The approval-gate skill card.

- RED (SC-2b): Enforcement test that asserts the spec-creation skill card does not contain a `Read [Text](path)` link to the reference.
- GREEN (SC-2b): Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of the spec-creation skill card.
- verify (SC-2b): `grep` spec-creation's Cross-References section for the imperative inline-link form.
- commit (SC-2b): The spec-creation skill card.

- RED (SC-2c): Enforcement test that asserts the writing-plans skill card does not contain a `Read [Text](path)` link to the reference.
- GREEN (SC-2c): Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of the writing-plans skill card.
- verify (SC-2c): `grep` writing-plans's Cross-References section for the imperative inline-link form.
- commit (SC-2c): The writing-plans skill card.

- RED (SC-2d): Enforcement test that asserts the executing-plans skill card does not contain a `Read [Text](path)` link to the reference.
- GREEN (SC-2d): Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of the executing-plans skill card.
- verify (SC-2d): `grep` executing-plans's Cross-References section for the imperative inline-link form.
- commit (SC-2d): The executing-plans skill card.

- RED (SC-2e): Enforcement test that asserts the git-workflow skill card does not contain a `Read [Text](path)` link to the reference.
- GREEN (SC-2e): Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of the git-workflow skill card.
- verify (SC-2e): `grep` git-workflow's Cross-References section for the imperative inline-link form.
- commit (SC-2e): The git-workflow skill card.

### Item 3 (SC-3): Index the reference in AGENTS.md Reference Documents table

- RED: Enforcement test that asserts the AGENTS.md Reference Documents table does not yet contain a row for the reference.
- GREEN: Add a row for `orchestrator-context-discipline.md` with a Purpose entry to the AGENTS.md Reference Documents table.
- verify: `grep` the AGENTS.md Reference Documents table for the reference filename.
- commit: The modified AGENTS.md.

## 6. Dependencies

- **Reference:** `020-go-prohibitions.md` §1.1 (lines 84-139)
  - **Relationship:** The extraction source for the reference content. Must be read before implementation.
  - **Status:** Satisfied — content present in the guideline.
- **Reference:** AGENTS.md Read-Link Cross-Reference Rule
  - **Relationship:** Mandates the `Read [Text](path)` imperative inline-link form. Must be followed during implementation.
  - **Status:** Satisfied — rule is active.
- **Reference:** 020-go-prohibitions condensation
  - **Relationship:** Downstream dependency — this spec enables the condensation but does not perform it.
  - **Status:** Pending — separate concern.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a, SC-1b, SC-1c, SC-1d, SC-1e | Phase 1 |
| R-2 | SC-1f, SC-1g | Phase 1 |
| R-3 | SC-1a | Phase 1 |
| R-4 | SC-2a, SC-2b, SC-2c, SC-2d, SC-2e | Phase 2 |
| R-5 | SC-2a, SC-2b, SC-2c, SC-2d, SC-2e | Phase 2 |
| R-6 | SC-3 | Phase 3 |
| R-7 | SC-1a | Phase 1 |
| R-8 | SC-1a, SC-1b, SC-1c, SC-1d, SC-1e, SC-2a, SC-2b, SC-2c, SC-2d, SC-2e | Phases 1-2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 020-go-prohibitions.md §1.1 | guideline | `.opencode/guidelines/020-go-prohibitions.md` | read — content present at lines 84-139 |
| Read-Link Cross-Reference Rule | guideline | `.opencode/AGENTS.md` | read — rule mandates `Read [Text](path)` |
| cross-reference-form-comparison research card | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read — inline-link form achieves 100% Tier 1 access |
| cross-reference-lobotomization research card | research | `.issues/research-cards/cross-reference-lobotomization.md` | read — 'See' citations fail as load directives |
| spec-writing-ai-agents-opencode-skill-architecture research card | research | `.opencode/.issues/research-cards/spec-writing-ai-agents-opencode-skill-architecture.md` | read — reference files consumed via Read-links |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a:** Verifying the reference file exists costs one file-existence check. Skipping means the reference is never created, leaving the content stranded in the preloaded guideline.
- **SC-1b, SC-1c, SC-1d, SC-1e:** Verifying each of the four mandates is present in the reference costs one grep search each (four total). Skipping means a missing mandate isn't caught until the first spec created from it fails audit — a death-spiral start.
- **SC-1f:** Verifying the standardized vocabulary is preserved costs one grep search. Skipping means a vocabulary-regressed reference isn't caught until downstream agents misroute content.
- **SC-1g:** Verifying the regression terms are absent costs one grep search. Skipping means a vocabulary-regressed reference isn't caught until downstream agents misroute content.
- **SC-2a, SC-2b, SC-2c, SC-2d, SC-2e:** Verifying each of the 5 consuming cards carries the imperative Read-link costs one grep search per card (five total). Skipping means a card misses the link, content loss propagates, and orchestrators never load the reference — the exact defect this spec exists to prevent.
- **SC-3:** Verifying the AGENTS.md index row costs one grep search. Skipping means the reference is undiscoverable, reducing adoption and leaving the content stranded in the preloaded guideline.

## 11. Edge Cases

- **Input boundaries:** The reference file must be created even if some consuming cards already contain partial content — the Read-link is additive, never destructive.
- **State transitions:** ABSENT → CREATED (Phase 1, SC-1a) → MANDATE-PRESENT (Phase 1, SC-1b..SC-1e) → VOCAB-PRESERVED (Phase 1, SC-1f) → REGRESSION-ABSENT (Phase 1, SC-1g) → LINKED (Phase 2, SC-2a..SC-2e) → INDEXED (Phase 3, SC-3). Each transition is triggered by its SC and is independently verifiable.
- **Failure modes:** If a consuming card already uses a non-imperative citation form, the Read-link is added alongside it — existing content is not removed. If the reference file already exists, each of SC-1b..SC-1g is verified for the individual mandate/vocabulary/regression presence rather than the file being recreated.
- **Concurrency:** No runtime concurrency — this is a documentation-only change. File writes are sequential per phase.
- **Recovery:** If a Read-link is missing from a card, the corresponding SC-2x is re-verified and the link added. If a specific mandate is missing from the reference, the corresponding SC-1x is re-verified and the mandate added. If the reference content is incomplete, it is revised to include all four mandates (SC-1b..SC-1e), the preserved vocabulary (SC-1f), and absence of regression terms (SC-1g).

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-27 | Decomposed compound SCs into atomic SCs: SC-1 split into SC-1a (file exists), SC-1b..SC-1e (four mandates), SC-1f (vocabulary preservation); SC-2 split into SC-2a..SC-2e (one per consuming skill card). Updated sc-summary.yaml, Items, Traceability, Cost Frame, and Edge Cases to match the decomposed SC set. | Validation finding: Aggregate FAIL due to compound SCs bundling multiple verification targets via "and"/comma-list phrasing. | Validation pipeline (sub-agent revision) |
| 2026-08-27 | Split compound SC-1f into two atomic SCs: SC-1f (standardized vocabulary preserved) and SC-1g (regression terms absent). Updated sc-summary.yaml (sc_count 12→13), Items, Traceability, Cost Frame, and Edge Cases to match. | Validation finding: Aggregate FAIL — SC-1f bundled two distinct verification targets (vocabulary present + regression terms absent) via "and", violating the atomic-SC rule. | Validation pipeline (sub-agent revision) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
