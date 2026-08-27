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
| SC-1 | `.opencode/reference/orchestrator-context-discipline.md` exists and contains the extracted §1.1 content (orchestrator-context-lean, sub-agent-context-generosity, result-contract-frugality, allocation-by-context-cost), preserving the standardized vocabulary. | string | `grep` for the four mandate names and standardized vocabulary terms in the reference file |
| SC-2 | Each of the 5 consuming skill cards (approval-gate, spec-creation, writing-plans, executing-plans, git-workflow) contains a `Read [Text](path)` link to `orchestrator-context-discipline.md` in its Cross-References section, using the imperative inline-link form. | string | `grep` each consuming card's Cross-References section for the `Read [Text](path)` link to the reference |
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

### Item 1 (SC-1): Create orchestrator-context-discipline.md reference file

- RED: Enforcement test that asserts the reference file does not yet exist at `.opencode/reference/orchestrator-context-discipline.md`.
- GREEN: Create `.opencode/reference/orchestrator-context-discipline.md` with the extracted §1.1 content, preserving the standardized vocabulary and following reference file conventions.
- verify: `grep` the reference file for the four mandate names and standardized vocabulary terms.
- commit: The new reference file.

### Item 2 (SC-2): Add mandatory Read [Text](path) links to consuming skill cards

- RED: Enforcement test that asserts none of the 5 consuming skill cards contains a `Read [Text](path)` link to the reference.
- GREEN: Add a `Read [Text](path)` link to `orchestrator-context-discipline.md` in the Cross-References section of each of the 5 consuming skill cards.
- verify: `grep` each consuming card's Cross-References section for the imperative inline-link form.
- commit: The 5 modified skill cards.

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
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-2 | Phase 2 |
| R-5 | SC-2 | Phase 2 |
| R-6 | SC-3 | Phase 3 |
| R-7 | SC-1 | Phase 1 |
| R-8 | SC-1, SC-2 | Phases 1-2 |

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

- **SC-1:** Verifying the reference file exists and preserves the standardized vocabulary costs one grep search. Skipping means a structurally wrong or vocabulary-regressed reference isn't caught until the first spec created from it fails audit — a death-spiral start.
- **SC-2:** Verifying each of the 5 consuming cards carries the imperative Read-link costs five grep searches. Skipping means a card misses the link, content loss propagates, and orchestrators never load the reference — the exact defect this spec exists to prevent.
- **SC-3:** Verifying the AGENTS.md index row costs one grep search. Skipping means the reference is undiscoverable, reducing adoption and leaving the content stranded in the preloaded guideline.

## 11. Edge Cases

- **Input boundaries:** The reference file must be created even if some consuming cards already contain partial content — the Read-link is additive, never destructive.
- **State transitions:** ABSENT → CREATED (Phase 1) → LINKED (Phase 2) → INDEXED (Phase 3). Each transition is triggered by its phase and is independently verifiable.
- **Failure modes:** If a consuming card already uses a non-imperative citation form, the Read-link is added alongside it — existing content is not removed. If the reference file already exists, it is verified for content completeness rather than recreated.
- **Concurrency:** No runtime concurrency — this is a documentation-only change. File writes are sequential per phase.
- **Recovery:** If a Read-link is missing from a card, the card is re-verified and the link added. If the reference content is incomplete, it is revised to include all four mandates.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
