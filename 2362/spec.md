---
remote_issue: 2362
remote_url: https://github.com/michael-conrad/.opencode/issues/2362
promoted_at: 2026-08-27T03:25:12.681174+00:00
labels:
- needs-approval
- spec-draft
number: 2362
state: OPEN
title: '[SPEC] Create shared ref: code-standards-shared.md'
---

> **Full spec and artifacts: [`.opencode/.issues/2362/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2362)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2362/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

`.opencode/guidelines/080-code-standards.md` is 663 lines and Tier 1 preloaded in the opencode.jsonc instructions array, costing approximately 14.2k tokens per session (per #2352). A subset of its procedural sections — Typing, Design Principles (project-specific conventions), Modern Python, Libraries & Packages, Dependency Injection, Dependency Injection (generic mandate), Print Statements & Output, Tool Selection by File Type, Numbering, Cross-Reference Standards, and YAML Standard for LLM-to-LLM Data Transfers — are consumed by four skill cards (programming-principles, skill-creator, test-driven-development, engineering-approach). These procedural sections are candidates for extraction into a shared canonical reference, so they can be loaded on demand via Read-link rather than paid for unconditionally at preload time.

## Root Cause / Motivation

The procedural code-standards content currently lives inline in a Tier 1 preloaded guideline, coupling on-demand skill-card consumers to an always-paid preload. Because 080 is preloaded unconditionally, every session pays the full token cost even when no skill card needs the procedural standards. The existing `.opencode/reference/*.md` pattern (plan-structure-standards, cost-model-standards, skill-card-description-standards, skill-card-schema, task-card-structure-standards, spec-structure-standards) establishes the canonical shared-reference pattern with SPDX/Provenance headers and Read-link consumption. Extracting the procedural sections into `code-standards-shared.md` and anchoring the four consuming skill cards to it via mandatory Read-links is the prerequisite for condensing 080 in #2352 (the parent effort, ~9.2k savings).

## Approach Chosen

Create `.opencode/reference/code-standards-shared.md` containing the eleven extracted procedural sections from 080, preserved verbatim and carrying the SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, and AI byline per the existing reference convention. Then add one mandatory `Read [Text](path)` link to `code-standards-shared.md` in each of the four consuming skill cards (programming-principles, skill-creator, test-driven-development, engineering-approach). This issue establishes the shared reference and its consumers; the actual condensation of 080 is handled separately by #2352. The enforcement core of 080 — the Enforcement Test Mandate, the critical-rules-XXX blocks (derivation provenance, evidence-type classification gate), and the critical-rules-009/042/test-integrity/BEH-EV blocks — is NOT extracted here and stays in 080.

## Alternatives Considered & Why Discarded

1. **Re-inline the procedural sections into each consuming skill card.** Discarded: the issue's Scope explicitly excludes re-inlining. Re-inlining would duplicate the content across four cards, creating four divergent copies that drift independently and defeating the single-canonical-source goal.
2. **Leave 080 as-is and only add Read-links to cards pointing at 080.** Discarded: 080 remains Tier 1 preloaded at full cost; the token savings (#2352) are not achieved, and the procedural content stays coupled to the preloaded guideline rather than becoming a reference document.
3. **Do nothing (defer).** Discarded: this shared reference is a Phase 1 foundational artifact required before #2352 can condense 080 and before the skill-update issues (#2367, #2368, #2369, #2365) can anchor their consuming cards.

## Key Design Decisions

1. **Single canonical source in `.opencode/reference/`, never re-inlined into skill cards.** Tradeoff: consumers pay a Read-link load cost when they route through the skill, in exchange for eliminating the unconditional preload token cost and eliminating content drift across copies.
2. **Mandatory `Read [Text](path)` form, not the forbidden "See ..." citation form.** Tradeoff: the Read-link form forces the agent to load the reference content into context, at the cost of requiring a real tool call rather than a passive citation (per the Read-Link Cross-Reference Rule).
3. **This issue creates the shared ref and anchors consumers; condensation of 080 is deferred to #2352.** Tradeoff: the token savings are realized only after the follow-up, at the benefit of keeping this change atomic and verifiable (reference-authoring + consumer-anchoring only, no content removal from 080).
4. **Reference header pattern (SPDX + Provenance + AI byline).** Tradeoff: matches the existing reference convention for consistency, at the cost of a small header block in each reference file.

## User Intent / Original Prompt

The user requested creating a shared reference file `code-standards-shared.md` for code-standards content, extracting the procedural sections from `.opencode/guidelines/080-code-standards.md` into a shared canonical reference that the consuming skill cards (programming-principles, skill-creator, test-driven-development, engineering-approach) Read-link to. This is part of the 080-condensation cluster (#2352 parent; #2365, #2367, #2368, #2369 consumers).

## Not Included

- **080 condensation / content removal** — `.opencode/guidelines/080-code-standards.md` is NOT modified by this issue; the condensation is #2352.
- **Re-inlining content into skill cards** — the shared ref is the single canonical source; cards reference it, never duplicate it (Scope Out).
- **Enforcement-core extraction** — the Enforcement Test Mandate, critical-rules-XXX blocks, and critical-rules-009/042/test-integrity/BEH-EV blocks stay in 080 (cross-cutting matrix).
- **`data-integrity-shared` or `attribution-provenance` shared refs** — referenced by sibling issues (#2365, #2368) but created separately, not by this issue.
- **Application source code** — no `.py` or test files are touched; this is a documentation/reference-only change in the `.opencode` submodule.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1a | `.opencode/reference/code-standards-shared.md` exists. | structural | `ls`/read the file; assert existence. | `.opencode/reference/code-standards-shared.md` (new) |
| SC-1b | `.opencode/reference/code-standards-shared.md` is non-empty (non-zero bytes). | structural | `ls -l`/`wc -c`; assert non-zero byte count. | `.opencode/reference/code-standards-shared.md` (new) |
| SC-1c | `.opencode/reference/code-standards-shared.md` contains all eleven extracted procedural section headers (Typing, Design Principles project-specific conventions, Modern Python, Libraries & Packages, Dependency Injection, Dependency Injection generic mandate, Print Statements & Output, Tool Selection by File Type, Numbering, Cross-Reference Standards, YAML Standard). | string | grep for each of the eleven required section headers; assert all present. | `.opencode/reference/code-standards-shared.md` (new), `.opencode/guidelines/080-code-standards.md` (source) |
| SC-1d | `.opencode/reference/code-standards-shared.md` carries the SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, and `Co-authored with AI` byline. | string | grep for SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, and `Co-authored with AI` byline; assert each present. | `.opencode/reference/code-standards-shared.md` (new) |
| SC-2a | `.opencode/skills/programming-principles/SKILL.md` contains a mandatory `Read [Text](path)` link to `code-standards-shared.md`. | string | Grep the SKILL.md for the `Read [` form referencing `code-standards-shared`; assert present. | `.opencode/skills/programming-principles/SKILL.md` |
| SC-2b | `.opencode/skills/programming-principles/SKILL.md` contains no forbidden "See ..." citation form referencing `code-standards-shared.md`. | string | Grep the SKILL.md for the `See ...` form referencing `code-standards-shared`; assert absent. | `.opencode/skills/programming-principles/SKILL.md` |
| SC-3a | `.opencode/skills/skill-creator/SKILL.md` contains a mandatory `Read [Text](path)` link to `code-standards-shared.md`. | string | Grep the SKILL.md for the `Read [` form referencing `code-standards-shared`; assert present. | `.opencode/skills/skill-creator/SKILL.md` |
| SC-3b | `.opencode/skills/skill-creator/SKILL.md` contains no forbidden "See ..." citation form referencing `code-standards-shared.md`. | string | Grep the SKILL.md for the `See ...` form referencing `code-standards-shared`; assert absent. | `.opencode/skills/skill-creator/SKILL.md` |
| SC-4a | `.opencode/skills/test-driven-development/SKILL.md` contains a mandatory `Read [Text](path)` link to `code-standards-shared.md`. | string | Grep the SKILL.md for the `Read [` form referencing `code-standards-shared`; assert present. | `.opencode/skills/test-driven-development/SKILL.md` |
| SC-4b | `.opencode/skills/test-driven-development/SKILL.md` contains no forbidden "See ..." citation form referencing `code-standards-shared.md`. | string | Grep the SKILL.md for the `See ...` form referencing `code-standards-shared`; assert absent. | `.opencode/skills/test-driven-development/SKILL.md` |
| SC-5a | `.opencode/skills/engineering-approach/SKILL.md` contains a mandatory `Read [Text](path)` link to `code-standards-shared.md`. | string | Grep the SKILL.md for the `Read [` form referencing `code-standards-shared`; assert present. | `.opencode/skills/engineering-approach/SKILL.md` |
| SC-5b | `.opencode/skills/engineering-approach/SKILL.md` contains no forbidden "See ..." citation form referencing `code-standards-shared.md`. | string | Grep the SKILL.md for the `See ...` form referencing `code-standards-shared`; assert absent. | `.opencode/skills/engineering-approach/SKILL.md` |

## Requirements

- **R-1.** `code-standards-shared.md` SHALL exist at `.opencode/reference/` and SHALL be non-empty.
- **R-2.** `code-standards-shared.md` SHALL contain all eleven extracted procedural sections from 080 preserved verbatim.
- **R-3.** `code-standards-shared.md` SHALL carry the SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, and AI byline per the existing reference convention.
- **R-4.** Each of the four consuming skill cards (programming-principles, skill-creator, test-driven-development, engineering-approach) SHALL contain a mandatory `Read [Text](path)` link to `code-standards-shared.md`.
- **R-5.** No consuming skill card SHALL use the forbidden "See ..." citation form to reference `code-standards-shared.md`.
- **R-6.** The enforcement core of 080 (Enforcement Test Mandate, critical-rules-XXX blocks, critical-rules-009/042/test-integrity/BEH-EV blocks) SHALL NOT be extracted into the shared reference.
- **R-7.** `080-code-standards.md` SHALL NOT be modified by this issue.
- **R-8.** The extracted content SHALL NOT be re-inlined into any skill card; the shared reference is the single canonical source.

## Items

### Item 1a (SC-1a): Verify code-standards-shared.md exists

- RED: `ls .opencode/reference/code-standards-shared.md` — file does not exist.
- GREEN: Create the file (with the eleven extracted procedural sections and the SPDX/Provenance/byline header block, per Items 1b/1c/1d).
- verify: `ls .opencode/reference/code-standards-shared.md` — assert existence.
- commit: `.opencode/reference/code-standards-shared.md`.

### Item 1b (SC-1b): Verify code-standards-shared.md is non-empty

- RED: `wc -c .opencode/reference/code-standards-shared.md` — zero bytes (or file absent).
- GREEN: Populate the file so it is non-zero bytes.
- verify: `wc -c .opencode/reference/code-standards-shared.md` — assert non-zero byte count.
- commit: `.opencode/reference/code-standards-shared.md`.

### Item 1c (SC-1c): Verify code-standards-shared.md contains all eleven sections

- RED: Grep `.opencode/reference/code-standards-shared.md` — some of the eleven required section headers absent.
- GREEN: Add each missing section (the eleven extracted procedural sections preserved verbatim from 080).
- verify: Grep for each of the eleven required section headers; assert all present.
- commit: `.opencode/reference/code-standards-shared.md`.

### Item 1d (SC-1d): Verify code-standards-shared.md carries SPDX/Provenance/byline headers

- RED: Grep `.opencode/reference/code-standards-shared.md` — SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, or `Co-authored with AI` byline absent.
- GREEN: Add the missing header lines.
- verify: Grep for SPDX-FileCopyrightText, SPDX-License-Identifier, Provenance header, and `Co-authored with AI` byline; assert each present.
- commit: `.opencode/reference/code-standards-shared.md`.

### Item 2a (SC-2a): Anchor programming-principles SKILL.md (Read-link)

- RED: Grep `.opencode/skills/programming-principles/SKILL.md` — no `Read [` link referencing `code-standards-shared`.
- GREEN: Add a mandatory `Read [Text](reference/code-standards-shared.md)` link.
- verify: Grep for `Read [` form referencing `code-standards-shared`; assert present.
- commit: `.opencode/skills/programming-principles/SKILL.md`.

### Item 2b (SC-2b): programming-principles SKILL.md has no "See" form

- RED: Grep `.opencode/skills/programming-principles/SKILL.md` — a `See ...` citation form referencing `code-standards-shared` exists.
- GREEN: Replace any `See ...` citation with the mandatory `Read [Text](path)` form.
- verify: Grep for `See ...` form referencing `code-standards-shared`; assert absent.
- commit: `.opencode/skills/programming-principles/SKILL.md`.

### Item 3a (SC-3a): Anchor skill-creator SKILL.md (Read-link)

- RED: Grep `.opencode/skills/skill-creator/SKILL.md` — no `Read [` link referencing `code-standards-shared`.
- GREEN: Add a mandatory `Read [Text](reference/code-standards-shared.md)` link.
- verify: Grep for `Read [` form referencing `code-standards-shared`; assert present.
- commit: `.opencode/skills/skill-creator/SKILL.md`.

### Item 3b (SC-3b): skill-creator SKILL.md has no "See" form

- RED: Grep `.opencode/skills/skill-creator/SKILL.md` — a `See ...` citation form referencing `code-standards-shared` exists.
- GREEN: Replace any `See ...` citation with the mandatory `Read [Text](path)` form.
- verify: Grep for `See ...` form referencing `code-standards-shared`; assert absent.
- commit: `.opencode/skills/skill-creator/SKILL.md`.

### Item 4a (SC-4a): Anchor test-driven-development SKILL.md (Read-link)

- RED: Grep `.opencode/skills/test-driven-development/SKILL.md` — no `Read [` link referencing `code-standards-shared`.
- GREEN: Add a mandatory `Read [Text](reference/code-standards-shared.md)` link.
- verify: Grep for `Read [` form referencing `code-standards-shared`; assert present.
- commit: `.opencode/skills/test-driven-development/SKILL.md`.

### Item 4b (SC-4b): test-driven-development SKILL.md has no "See" form

- RED: Grep `.opencode/skills/test-driven-development/SKILL.md` — a `See ...` citation form referencing `code-standards-shared` exists.
- GREEN: Replace any `See ...` citation with the mandatory `Read [Text](path)` form.
- verify: Grep for `See ...` form referencing `code-standards-shared`; assert absent.
- commit: `.opencode/skills/test-driven-development/SKILL.md`.

### Item 5a (SC-5a): Anchor engineering-approach SKILL.md (Read-link)

- RED: Grep `.opencode/skills/engineering-approach/SKILL.md` — no `Read [` link referencing `code-standards-shared`.
- GREEN: Add a mandatory `Read [Text](reference/code-standards-shared.md)` link.
- verify: Grep for `Read [` form referencing `code-standards-shared`; assert present.
- commit: `.opencode/skills/engineering-approach/SKILL.md`.

### Item 5b (SC-5b): engineering-approach SKILL.md has no "See" form

- RED: Grep `.opencode/skills/engineering-approach/SKILL.md` — a `See ...` citation form referencing `code-standards-shared` exists.
- GREEN: Replace any `See ...` citation with the mandatory `Read [Text](path)` form.
- verify: Grep for `See ...` form referencing `code-standards-shared`; assert absent.
- commit: `.opencode/skills/engineering-approach/SKILL.md`.

## Dependencies

- **Reference:** `.opencode/guidelines/080-code-standards.md`
  - **Relationship:** Source of the procedural sections extracted into the shared ref; must be read before the reference is authored.
  - **Status:** Satisfied (file exists, 663 lines, verified live).
- **Reference:** Existing `.opencode/reference/*.md` pattern (e.g., spec-structure-standards.md, cost-model-standards.md)
  - **Relationship:** Establishes the header and Read-link conventions this issue mirrors.
  - **Status:** Satisfied (files exist, verified live).
- **Reference:** Issue #2352 (parent 080-condensation effort)
  - **Relationship:** Consumes this shared ref after the four cards Read-link; the token savings are realized only after #2352 condenses 080.
  - **Status:** Pending (separate issue).
- **Reference:** Issues #2365, #2367, #2368, #2369 (sibling consumer updates)
  - **Relationship:** Read-link the shared ref (and data-integrity-shared / attribution-provenance) in their respective cards; may overlap with this issue's anchoring work.
  - **Status:** Pending (separate issues).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1a, SC-1b | Item 1a, Item 1b |
| R-2 | SC-1c | Item 1c |
| R-3 | SC-1d | Item 1d |
| R-4 | SC-2a, SC-3a, SC-4a, SC-5a | Item 2a, Item 3a, Item 4a, Item 5a |
| R-5 | SC-2b, SC-3b, SC-4b, SC-5b | Item 2b, Item 3b, Item 4b, Item 5b |
| R-6 | SC-1c | Item 1c |
| R-7 | SC-1c | Item 1c |
| R-8 | SC-2a, SC-3a, SC-4a, SC-5a | Item 2a, Item 3a, Item 4a, Item 5a |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `080-code-standards.md` | guideline source | `.opencode/guidelines/080-code-standards.md` | read for the eleven procedural sections (verified live, 663 lines) |
| `code-standards-shared.md` | reference (new) | `.opencode/reference/code-standards-shared.md` | ls + grep for sections and headers after creation |
| `programming-principles/SKILL.md` | skill card | `.opencode/skills/programming-principles/SKILL.md` | grep for Read-link present / "See" form absent |
| `skill-creator/SKILL.md` | skill card | `.opencode/skills/skill-creator/SKILL.md` | grep for Read-link present / "See" form absent |
| `test-driven-development/SKILL.md` | skill card | `.opencode/skills/test-driven-development/SKILL.md` | grep for Read-link present / "See" form absent |
| `engineering-approach/SKILL.md` | skill card | `.opencode/skills/engineering-approach/SKILL.md` | grep for Read-link present / "See" form absent |
| reference convention | reference files | `.opencode/reference/*.md` | read headers (SPDX/Provenance/byline) and Read-link usage (verified live) |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a/SC-1b:** Verifying the shared ref exists and is non-empty costs one `ls`/`wc -c`. Skipping means a missing or zero-byte reference is not caught until a consuming skill card fails to load it after 080 condenses in #2352 — deferring discovery to the condensation step.
- **SC-1c/SC-1d:** Verifying all eleven sections and the header block costs a grep pass. Skipping means an incomplete reference (missing section or missing SPDX/Provenance/byline header) is not caught until a consuming skill card fails to load the content it needs after 080 condenses.
- **SC-2a/SC-3a/SC-4a/SC-5a:** Verifying each card's Read-link costs one grep per card. Skipping means a card that lacks the Read-link silently loses the procedural standards when 080 condenses — content loss that is only discovered when an agent routing through that card fails to find the standards it needs.
- **SC-2b/SC-3b/SC-4b/SC-5b:** Verifying the absence of the forbidden "See ..." citation form costs one grep per card. Skipping means a card that uses the citation form would not force the agent to load the reference, defeating the Read-link convention without detection.

## Edge Cases

- **Input boundary — empty reference file:** SC-1b requires the file be non-empty; a zero-byte or header-only file fails the non-emptiness (SC-1b) and section-header (SC-1c) checks.
- **State transition — shared ref absent → present:** Phase 1 (Items 1a-1d) establishes the file; Phase 2 (Items 2-5) anchors consumers. A card cannot Read-link a non-existent file, so the phases are dependency-ordered (Phase 1 precedes Phase 2).
- **Failure mode — a consuming card lacks the Read-link:** When 080 condenses in #2352, that card loses the procedural standards. SC-2a/SC-3a/SC-4a/SC-5a each grep the specific card to flag any missing link before condensation proceeds.
- **Failure mode — forbidden "See ..." citation used:** A card using the citation form would not force the agent to load the reference, defeating the Read-link convention. SC-2b/SC-3b/SC-4b/SC-5b each assert the "See ..." form is absent.
- **Concurrency:** This is a documentation/reference-only change with no shared state or transaction; no race condition or resource contention applies. Sibling issues #2365/#2367/#2368/#2369 may touch overlapping cards, so implementation should coordinate Read-link additions to avoid edit conflicts.
- **Recovery:** Because each SC is a single file edit, a failed or partial change is repaired by re-running the corresponding item's GREEN edit; no state machine or rollback path is required.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-27 | Decomposed all 5 compound SCs into 12 atomic SCs (SC-1a..SC-1d, SC-2a/SC-2b, SC-3a/SC-3b, SC-4a/SC-4b, SC-5a/SC-5b); each atomic SC bundles a single independently verifiable claim. | Validation finding: Compound-SC decomposition — each original SC bundled multiple independently verifiable claims joined by "and". | Validation findings (orchestrator) |
| 2026-08-27 | Changed SC-1 evidence type from "structural + string" to single canonical types (SC-1a/SC-1b/SC-1c = structural; SC-1d = string). | Validation finding: EVIDENCE_TYPE_MISMATCH — "structural + string" is not one of the four valid canonical evidence types. | Validation findings (orchestrator) |
| 2026-08-27 | Updated Items (1:1 item-SC mapping: Items 1a-1d, 2a/2b, 3a/3b, 4a/4b, 5a/5b), Traceability table, Cost Frame, and Edge Cases to match the decomposed atomic SC set. | Consequence of SC decomposition — downstream sections must reference the atomic SC set. | Validation findings (orchestrator) |
| 2026-08-27 | Changed SC-1c evidence type from "structural" to "string" to match its grep verification method (grep for the eleven section headers). Updated sc-summary.yaml SC-1c evidence_type accordingly. | Validation finding: EVIDENCE_TYPE_MISMATCH — SC-1c declared "structural" but its verification method is grep, which is "string" per the canonical taxonomy. | Validation findings (orchestrator) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
