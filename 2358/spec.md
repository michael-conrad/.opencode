---
title: '[SPEC] Create shared ref: discussion-mode-mandates.md'
remote_issue: 2358
remote_url: https://github.com/michael-conrad/.opencode/issues/2358
---

> **Full spec and artifacts: [`.opencode/.issues/2358/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2358)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2358/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

`.opencode/guidelines/020-go-prohibitions.md` §1.6 Discussion Mode Mandates is procedural content (the NEVER DO / ALWAYS DO bullets plus the skill-routing prohibition table) that is consumed by the brainstorming and approval-gate skill cards yet currently lives inline in a Tier 1 guideline that is preloaded on every session via the `.opencode/opencode.jsonc` instructions array. The discussion-mode mandates govern conversational behavior for both cards, but each card reaches them only through the preloaded 020 guideline rather than through its own load path.

## Root Cause / Motivation

§1.6 is procedural guidance whose consumers are the brainstorming and approval-gate skill cards, but it is physically located in `020-go-prohibitions.md`, a Tier 1 guideline preloaded on every session. This placement inflates the preloaded token burden for a section that is not universally relevant, and it couples skill-card conversational behavior to a guideline that every session must carry regardless of whether discussion-mode context is active. The `.opencode/reference/` directory already exists as the canonical home for shared reference documents consumed via `Read [Text](path)` links (for example `cost-model-standards.md`, `skill-card-description-standards.md`). The change is needed now because the preload budget is consumed by content that belongs in a lazily-loaded shared reference, and the 020 condensation effort depends on this reference existing first.

## Approach Chosen

Extract the §1.6 Discussion Mode Mandates content from `020-go-prohibitions.md` into a new canonical shared reference file `.opencode/reference/discussion-mode-mandates.md`. Add a mandatory `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the brainstorming and approval-gate skill cards so each card loads the shared reference through the canonical Read-link form. The reference file becomes the single source of truth for discussion-mode mandates; the skill cards consume it by reference and do not duplicate its content. This spec does not itself rewrite `020-go-prohibitions.md` — removing §1.6 from the preloaded 020 guideline is the separate dependent 020 condensation scope.

## Alternatives Considered & Why Discarded

1. **Re-inline the §1.6 content into each skill card body.** Discarded: duplicating the mandates into both brainstorming and approval-gate cards creates two copies that drift independently; the whole point of a shared reference is a single source of truth, and the out-of-scope list explicitly forbids re-inlining.
2. **Leave §1.6 inline in 020 and add a `see` citation in each card.** Discarded — the AGENTS.md Read-Link Cross-Reference Rule and the cross-reference-form-comparison research card (confidence 0.95) show that a bare "see" reference is treated as informational by agents and achieves only 42-58% access; only the imperative `Read [Text](path)` form reaches 100% Tier 1 access.

## Key Design Decisions

1. **The reference file is the sole canonical owner of the §1.6 content; skill cards are consumers only.** Tradeoff: content moves out of the preloaded 020 into a lazily-loaded reference, at the cost of requiring each consuming card to carry a Read-link.
2. **Mandatory Read-links use the imperative `Read [Text](path)` form, not "see" or symbol-only refs.** Tradeoff: reliable 100% access per the research card, at the cost of requiring the exact imperative form in both cards.
3. **The new reference file follows the `.opencode/reference/` format conventions (title + prose) with provenance per code standards.** Tradeoff: consistency with the other reference docs, at the cost of a small SPDX/provenance header.

## User Intent / Original Prompt

The motivating request: extract §1.1 Discussion Mode Mandates from the preloaded 020-go-prohibitions guideline into a shared canonical reference that the brainstorming and approval-gate skill cards load via mandatory Read-links, establishing the single-source reference the 020 condensation depends on.

## Not Included

- **Re-inlining §1.6 content into either skill card** — the whole point is a single shared source; duplication is explicitly out of scope.
- **Rewriting `020-go-prohibitions.md`** — removing §1.6 from the preloaded 020 file is the separate dependent 020 condensation scope, not this spec.
- **Changing the substantive rules of §1.6** — extraction is content-preserving; no mandate is added, removed, or reworded.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1a | `.opencode/reference/discussion-mode-mandates.md` exists. | structural | `ls .opencode/reference/discussion-mode-mandates.md` succeeds. | `.opencode/guidelines/020-go-prohibitions.md` (source) |
| SC-1b | The reference file's content is a content-preserving extraction of the §1.6 Discussion Mode Mandates source in `020-go-prohibitions.md` (the NEVER DO / ALWAYS DO bullets and the skill-routing table). | string | diff the reference file against the §1.6 source block to confirm no mandate was dropped or altered. | `.opencode/guidelines/020-go-prohibitions.md` (source) |
| SC-2a | `brainstorming/SKILL.md` contains a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative form. | string | grep `brainstorming/SKILL.md` for the imperative Read-link form. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-2b | The `brainstorming/SKILL.md` Read-link target resolves to the created file. | structural | resolve the target path from the `brainstorming/SKILL.md` Read-link and assert it exists. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-3a | `approval-gate/SKILL.md` contains a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative form. | string | grep `approval-gate/SKILL.md` for the imperative Read-link form. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-3b | The `approval-gate/SKILL.md` Read-link target resolves to the created file. | structural | resolve the target path from the `approval-gate/SKILL.md` Read-link and assert it exists. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-4a | The §1.6 content appears exactly once in the deck — in the reference file, not duplicated into either skill card. | string | grep the codebase to confirm the §1.6 content is not duplicated into `brainstorming/SKILL.md` or `approval-gate/SKILL.md`. | `.opencode/reference/spec-structure-standards.md` |
| SC-4b | Every `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link across the entire deck resolves to the created file — a deck-wide link-integrity check that is not limited to the two modified cards. | string | scan the whole deck (all skill cards, guidelines, and references) for any Read-link to the reference file and assert each target resolves; run skildeck validation on all modified cards (if available). | `.opencode/reference/spec-structure-standards.md` |

## Requirements

- **R-1.** The reference file `.opencode/reference/discussion-mode-mandates.md` SHALL exist and SHALL contain the canonical content of §1.6 Discussion Mode Mandates from `020-go-prohibitions.md`.
- **R-2.** `brainstorming/SKILL.md` SHALL contain a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative Read [Text](path) form.
- **R-3.** `approval-gate/SKILL.md` SHALL contain a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative Read [Text](path) form.
- **R-4.** The §1.6 content SHALL appear only once in the deck — in the reference file — and SHALL NOT be re-inlined into either skill-card body.
- **R-5.** The reference file SHALL follow the `.opencode/reference/` format conventions and SHALL carry provenance per code standards where applicable.
- **R-6.** All `Read [Text](.opencode/reference/discussion-mode-mandates.md)` links in the deck SHALL resolve to the created reference file.

## Items

### Item 1 (SC-1a, SC-1b): Create the canonical shared reference file

- RED: `ls .opencode/reference/discussion-mode-mandates.md` fails (file does not exist).
- GREEN: Write `.opencode/reference/discussion-mode-mandates.md` with the extracted §1.6 content.
- verify: File exists (SC-1a), non-empty, and content matches the §1.6 source block (SC-1b).
- commit: The new reference file.

### Item 2 (SC-2a, SC-2b): Add mandatory Read-link in brainstorming SKILL.md

- RED: grep `brainstorming/SKILL.md` finds no imperative Read-link to the reference.
- GREEN: Add the `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the Cross-References section.
- verify: grep confirms the imperative form (SC-2a); target path resolves (SC-2b).
- commit: `brainstorming/SKILL.md`.

### Item 3 (SC-3a, SC-3b): Add mandatory Read-link in approval-gate SKILL.md

- RED: grep `approval-gate/SKILL.md` finds no imperative Read-link to the reference.
- GREEN: Add the `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the Cross-References section.
- verify: grep confirms the imperative form (SC-3a); target path resolves (SC-3b).
- commit: `approval-gate/SKILL.md`.

### Item 4 (SC-4a): Verify single-source integrity

- RED: grep confirms §1.6 content is duplicated into a skill-card body.
- GREEN: No implementation change; verification-only.
- verify: grep confirms content appears once.
- commit: No code change.

### Item 5 (SC-4b): Verify deck-wide Read-link resolution

- RED: a Read-link to the reference file anywhere in the deck is broken (target does not resolve).
- GREEN: No implementation change; verification-only.
- verify: all Read-links across the deck resolve; skildeck validation passes on all modified cards.
- commit: No code change.

## Dependencies

- **Reference:** `.opencode/guidelines/020-go-prohibitions.md` §1.6 (source of the extracted content)
  - **Relationship:** Must be read before Item 1 to extract the exact mandate text.
  - **Status:** Satisfied (source exists).
- **Reference:** `AGENTS.md` Read-Link Cross-Reference Rule
  - **Relationship:** Must be followed for the imperative Read-link form in Items 2-3.
  - **Status:** Satisfied.
- **Reference:** 020 condensation (dependent issue)
  - **Relationship:** This spec creates the shared reference that the dependent condensation consumes; the condensation removes §1.6 from 020.
  - **Status:** Pending (dependent; not part of this spec's scope).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-1a, SC-1b, SC-4a | Item 1, Item 4 |
| R-5 | SC-1a, SC-1b | Item 1 |
| R-6 | SC-4b | Item 5 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `020-go-prohibitions.md` §1.6 | guideline source | `.opencode/guidelines/020-go-prohibitions.md` | read to extract canonical content |
| Read-Link Cross-Reference Rule | guideline | `AGENTS.md` | read rule, apply imperative form |
| Spec Structure Standards | reference | `.opencode/reference/spec-structure-standards.md` | read standards |
| Cost Model Standards | reference | `.opencode/reference/cost-model-standards.md` | read cost-frame pattern |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a/SC-1b:** Verifying the reference file exists and preserves §1.6 content costs one `ls` plus a diff against the source. Skipping means a missing or corrupted reference isn't caught until the condensation runs against a file that does not hold the mandates.
- **SC-2a/SC-2b:** Verifying the brainstorming Read-link costs one grep of `brainstorming/SKILL.md` and a target-path resolution. Skipping means the brainstorming card silently loses its discussion-mode gate until a later spec is created without the mandates.
- **SC-3a/SC-3b:** Verifying the approval-gate Read-link costs one grep of `approval-gate/SKILL.md` and a target-path resolution. Skipping means the approval-gate card silently loses its no-skill-routing-solicitation mandate.
- **SC-4a:** Verifying single-source integrity costs a codebase grep. Skipping means a duplicated copy ships, and the deck regresses to two copies that drift.
- **SC-4b:** Verifying deck-wide Read-link resolution costs a deck-wide scan plus skildeck validation. Skipping means a broken link ships anywhere in the deck and a card silently loses its discussion-mode gate.

## Edge Cases

- **Input boundary — empty reference file:** If `discussion-mode-mandates.md` is written empty or truncated, the diff against the §1.6 source fails, so SC-1b catches it at creation.
- **Link form misuse:** If either card uses a "see" or symbol-only reference instead of the imperative `Read [Text](path)` form, SC-2a/SC-3a's grep asserts the imperative form, and the card is not accepted.
- **Link target missing:** If a Read-link is added before the reference file exists, SC-1a/SC-2b/SC-3b path resolution fails, so item ordering (reference before links) is enforced by the dependency DAG.
- **Duplicate content:** If §1.6 content is inlined into a skill card, SC-4a's single-source grep flags the duplication.
- **Broken link after move:** If the reference file is later moved/renamed, SC-4b's deck-wide path resolution re-fails, triggering repair.
- **Skill-card structural break:** If adding the Read-link breaks the skill card's frontmatter/dispatch-table structure, skildeck validation in SC-4b flags it; the link goes in the existing Cross-References section to avoid this.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-27 | Corrected evidence types for SC-1b, SC-2a, SC-3a, SC-4a from `structural` to `string` to match their grep/diff verification methods. Decomposed SC-4b from a per-card link-resolution check (redundant with SC-2b ∪ SC-3b) into a deck-wide link-integrity invariant covering all Read-links across the deck. Updated Item 5, Cost Frame, and Edge Cases accordingly. | Validation finding: EVIDENCE_TYPE_MISMATCH (SC-1b/SC-2a/SC-3a/SC-4a declared `structural` but verified by string-grade methods); SC-4b redundant with SC-2b ∪ SC-3b (fails Ceremony and Coverage decomposition criteria). | Validation pipeline |
| 2026-08-27 | Decomposed SC-4 into SC-4a (content-appears-once) and SC-4b (links-resolve); updated Items 4-5, Traceability, Cost Frame, and Edge Cases accordingly. | Validation finding: SC-4 was a compound, verification-only SC bundling two independently verifiable targets (non-duplication + global Read-link resolution), failing Atomicity, Single Deliverable, and PR-Gate Viability. | Validation pipeline |
| 2026-08-27 | Decomposed SC-1 into SC-1a (file exists) and SC-1b (content-preserving extraction); SC-2 into SC-2a (imperative link present) and SC-2b (link target resolves); SC-3 into SC-3a (imperative link present) and SC-3b (link target resolves). Added R-6 (all Read-links SHALL resolve) tracing to SC-4b. Updated Items 1-3, Traceability, Cost Frame, and Edge Cases accordingly. | Validation finding: SC-1/SC-2/SC-3 were compound SCs bundling two independently verifiable targets each, failing Atomicity; SC-4b was an orphan SC with no tracing requirement. | Validation pipeline |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
