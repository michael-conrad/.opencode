---
title: '[SPEC] Create shared ref: discussion-mode-mandates.md'
remote_issue: 2358
remote_url: https://github.com/michael-conrad/.opencode/issues/2358
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2358/

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
| SC-1 | `.opencode/reference/discussion-mode-mandates.md` exists and its content is a content-preserving extraction of the §1.6 Discussion Mode Mandates source in `020-go-prohibitions.md` (the NEVER DO / ALWAYS DO bullets and the skill-routing table). | structural | `ls .opencode/reference/discussion-mode-mandates.md`; diff against the §1.6 source block to confirm no mandate was dropped or altered. | `.opencode/guidelines/020-go-prohibitions.md` (source) |
| SC-2 | `brainstorming/SKILL.md` contains a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative form; the link target resolves to the created file. | structural | grep `brainstorming/SKILL.md` for the imperative Read-link form; resolve the target path and assert it exists. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-3 | `approval-gate/SKILL.md` contains a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative form; the link target resolves to the created file. | structural | grep `approval-gate/SKILL.md` for the imperative Read-link form; resolve the target path and assert it exists. | `AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/reference/spec-structure-standards.md` |
| SC-4 | The §1.6 content appears exactly once in the deck — in the reference file, not duplicated into either skill card — and all Read-links resolve. | structural | grep the codebase to confirm the §1.6 content is not duplicated into `brainstorming/SKILL.md` or `approval-gate/SKILL.md`; run skildeck validation on both modified cards (if available). | `.opencode/reference/spec-structure-standards.md` |

## Requirements

- **R-1.** The reference file `.opencode/reference/discussion-mode-mandates.md` SHALL exist and SHALL contain the canonical content of §1.6 Discussion Mode Mandates from `020-go-prohibitions.md`.
- **R-2.** `brainstorming/SKILL.md` SHALL contain a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative Read [Text](path) form.
- **R-3.** `approval-gate/SKILL.md` SHALL contain a `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link using the imperative Read [Text](path) form.
- **R-4.** The §1.6 content SHALL appear only once in the deck — in the reference file — and SHALL NOT be re-inlined into either skill-card body.
- **R-5.** The reference file SHALL follow the `.opencode/reference/` format conventions and SHALL carry provenance per code standards where applicable.

## Items

### Item 1 (SC-1): Create the canonical shared reference file

- RED: `ls .opencode/reference/discussion-mode-mandates.md` fails (file does not exist).
- GREEN: Write `.opencode/reference/discussion-mode-mandates.md` with the extracted §1.6 content.
- verify: File exists, non-empty, and content matches the §1.6 source block.
- commit: The new reference file.

### Item 2 (SC-2): Add mandatory Read-link in brainstorming SKILL.md

- RED: grep `brainstorming/SKILL.md` finds no imperative Read-link to the reference.
- GREEN: Add the `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the Cross-References section.
- verify: grep confirms the imperative form; target path resolves.
- commit: `brainstorming/SKILL.md`.

### Item 3 (SC-3): Add mandatory Read-link in approval-gate SKILL.md

- RED: grep `approval-gate/SKILL.md` finds no imperative Read-link to the reference.
- GREEN: Add the `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the Cross-References section.
- verify: grep confirms the imperative form; target path resolves.
- commit: `approval-gate/SKILL.md`.

### Item 4 (SC-4): Verify single-source integrity

- RED: grep confirms §1.6 content is duplicated into a skill-card body or a Read-link is broken.
- GREEN: No implementation change; verification-only.
- verify: grep confirms content appears once; all Read-links resolve; skildeck validation passes.
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
| R-4 | SC-1, SC-4 | Item 1, Item 4 |
| R-5 | SC-1 | Item 1 |

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

- **SC-1:** Verifying the reference file exists and preserves §1.6 content costs one `ls` plus a diff against the source. Skipping means a missing or corrupted reference isn't caught until the condensation runs against a file that does not hold the mandates.
- **SC-2:** Verifying the brainstorming Read-link costs one grep of `brainstorming/SKILL.md` and a target-path resolution. Skipping means the brainstorming card silently loses its discussion-mode gate until a later spec is created without the mandates.
- **SC-3:** Verifying the approval-gate Read-link costs one grep of `approval-gate/SKILL.md` and a target-path resolution. Skipping means the approval-gate card silently loses its no-skill-routing-solicitation mandate.
- **SC-4:** Verifying single-source and link integrity costs a codebase grep and skildeck validation. Skipping means a duplicated or broken link ships, and the deck regresses to two copies that drift.

## Edge Cases

- **Input boundary — empty reference file:** If `discussion-mode-mandates.md` is written empty or truncated, the diff against the §1.6 source fails, so SC-1 catches it at creation.
- **Link form misuse:** If either card uses a "see" or symbol-only reference instead of the imperative `Read [Text](path)` form, SC-2/SC-3's grep asserts the imperative form, and the card is not accepted.
- **Link target missing:** If a Read-link is added before the reference file exists, SC-1/SC-2/SC-3 path resolution fails, so item ordering (reference before links) is enforced by the dependency DAG.
- **Duplicate content:** If §1.6 content is inlined into a skill card, SC-4's single-source grep flags the duplication.
- **Broken link after move:** If the reference file is later moved/renamed, SC-2/SC-3 path resolution re-fails, triggering repair.
- **Skill-card structural break:** If adding the Read-link breaks the skill card's frontmatter/dispatch-table structure, skildeck validation in SC-4 flags it; the link goes in the existing Cross-References section to avoid this.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
