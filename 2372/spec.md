# [SPEC] Update verification skill — anchor verification-honesty & authority-source link

> **Full spec and artifacts: [`.issues/2372/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2372/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2372/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

The verification skill (`.opencode/skills/verification/`) is not yet the authoritative source for the verification-honesty evidence-requirement examples and session-scoped verification detail currently held in `065-verification-honesty.md`, and it lacks the mandatory `Read [Text](path)` link to the authority-source shared content. The verification skill must anchor this content so the 065 and 130 guidelines can be condensed without losing it.

### Root Cause / Motivation

Verification-honesty content (evidence examples, session-scoped detail) currently lives in the `065-verification-honesty.md` guideline, which is slated for condensation (`.opencode#2349`). The authority-source content in `130-authority-source.md` is slated for condensation (`.opencode#2356`). The verification skill is the natural canonical home for the evidence-requirement content because it is the runtime consumer of that content during claim verification. Without this anchoring, the condensation efforts would lose content that the verification skill and its downstream consumers (`verification-before-completion`, `verification-enforcement`) depend on at runtime.

### Approach Chosen

Make the verification skill the authoritative source for the 065 evidence-requirement examples and session-scoped verification detail by anchoring that content in the `verify`/`verify-single` task cards. Add a mandatory `Read [Text](path)` link to the authority-source shared content (the 130 condensation deliverable). Convert the existing defective "per 065-verification-honesty.md" citation in `verify.md` to the imperative Read-link form. Preserve the skill's routing metadata and the verification-honesty zero-tolerance core.

### Alternatives Considered & Why Discarded

- **Leave the content in `065-verification-honesty.md` and reference it from the skill via "see" citations.** Discarded: the research cards (confidence 0.95/0.85) demonstrate that "see" citations are treated as decorative text by agents and do not reliably trigger file access. The content must be anchored in the skill with the imperative `Read [Text](path)` form to be consumed at runtime.
- **Add the authority-source content inline into the verification skill.** Discarded: the authority-source content is shared across multiple skills and is the deliverable of the 130 condensation (`.opencode#2356`). Inlining it would duplicate content and conflict with the condensation effort. The correct pattern is a `Read [Text](path)` link to the shared reference.
- **Anchor the evidence content in a shared reference consumed via Read-link instead of the task cards.** Discarded: the evidence-requirement examples and session-scoped verification detail are verification-specific content, not shared across multiple skills. The shared-reference pattern is reserved for cross-skill content (the authority-source shared content). Anchoring in the `verify`/`verify-single` task cards makes the skill the single canonical home without an indirection layer.

### Key Design Decisions

- **Decision 1: Anchor evidence content in the verification skill's `verify`/`verify-single` task cards.** Tradeoff: consolidating content into the skill's task cards increases the skill surface but makes the skill the single canonical home, enabling the 065 condensation without content loss. The task cards are the runtime consumer of this content during claim verification; the shared-reference pattern is reserved for cross-skill content (the authority-source shared content, SC-3).
- **Decision 2: Use the imperative `Read [Text](path)` form for the authority-source link.** Tradeoff: the imperative form is the only pattern proven to trigger file access (100% Tier 1 access rate); it trades a compact citation for a load directive that reliably routes the agent to the shared content.
- **Decision 3: Preserve routing metadata unchanged.** Tradeoff: adding content without touching the Trigger Dispatch Table / Invocation avoids routing regression but requires careful additive-only edits.

### User Intent / Original Prompt

Update the verification skill to anchor verification-honesty (065) content, making the skill the canonical home and adding the mandatory authority-source (130) Read-link, as the companion to the 065/130 condensation specs (2349, 2356).

## 2. Not Included

- **`065-verification-honesty.md` modification** — the guideline's condensation is a separate scope (`.opencode#2349`). This spec only anchors content into the skill; it does not modify the guideline.
- **`075-docs-verification.md` modification** — separate condensation scope (`.opencode#2353`).
- **`130-authority-source.md` modification** — separate condensation scope (`.opencode#2356`). This spec only adds a Read-link to the authority-source shared content; it does not modify the guideline.
- **`opencode.jsonc` preload array modification** — separate config scope (`.opencode#2361`).
- **`verification-before-completion` / `verification-enforcement` skill modification** — downstream consumers are consistency-checked (their 065 references must continue to resolve) but not modified in this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The verification skill (`verify`/`verify-single` task cards) SHALL contain the consolidated evidence-requirement examples currently in `065-verification-honesty.md` (the "What COUNTS as Evidence" / "NOT Evidence" examples), establishing the skill as the authoritative source. | behavioral | `opencode run` via `with-test-home` dispatching the verification skill, asserting the agent reads the consolidated evidence-requirement examples; supplementary grep for the consolidated evidence block in `verify.md` |
| SC-2 | The verification skill (`verify`/`verify-single` task cards) SHALL contain the session-scoped verification detail currently in `065-verification-honesty.md` (the Session-Scoped Verification section), establishing the skill as the authoritative source. | behavioral | `opencode run` via `with-test-home` dispatching the verification skill, asserting the agent reads the session-scoped verification detail; supplementary grep for the session-scoped block in `verify.md` |
| SC-3 | The verification skill SHALL contain a mandatory `Read [Text](path)` link to the authority-source shared content, using the imperative form. | behavioral | `opencode run` via `with-test-home` asserting the agent reads the authority-source shared content; supplementary grep for `Read.*authority-source` in `SKILL.md` |
| SC-4 | The existing defective "per 065-verification-honesty.md" citation in `verify.md` SHALL be converted to the imperative Read-link form referencing the consolidated content anchored in the `verify`/`verify-single` task cards, so the skill consumes the consolidated content via the canonical pattern. | string | grep `verify.md` for the imperative `Read [Text](...)` form replacing the "per 065" citation |
| SC-5 | The verification skill's Trigger Dispatch Table, Invocation, and routing metadata SHALL remain unchanged (no routing regression). | structural | diff the Trigger Dispatch Table / Invocation before/after the edits |
| SC-6 | The verification-honesty zero-tolerance core (never-rely-on-memory + pre-response factual-claim gate) SHALL NOT be lost; this spec MUST NOT modify `065-verification-honesty.md`. | structural | confirm the 065 core (never-rely-on-memory + pre-response gate) is intact and 065 is not modified by this spec |

## 4. Requirements

- **R-1.** The verification skill SHALL become the authoritative source for the evidence-requirement examples currently in `065-verification-honesty.md` (the "What COUNTS as Evidence" / "NOT Evidence" examples).
- **R-2.** The verification skill SHALL become the authoritative source for the session-scoped verification detail currently in `065-verification-honesty.md` (the Session-Scoped Verification section).
- **R-3.** The verification skill SHALL add a mandatory `Read [Text](path)` link to the authority-source shared content (the dual-authority / code-as-authoritative-source content from `130-authority-source.md`, per the 130 condensation effort `.opencode#2356`).
- **R-4.** The evidence-requirement examples + session-scoped verification detail SHALL be anchored in the verification skill such that `065-verification-honesty.md` can be condensed (deliverable of `.opencode#2349`) without losing the content.
- **R-5.** The authority-source Read-link SHALL enable the `130-authority-source.md` condensation (`.opencode#2356`), with the authority-source shared content consumed by the verification skill via the mandatory Read-link.
- **R-6.** The link SHALL use the imperative `Read [Text](path)` form per the Read-Link Cross-Reference Rule and the cross-reference-form-comparison research card (confidence 0.95).
- **R-7.** The verification skill's existing defective "per 065-verification-honesty.md" citation in `verify.md` (line 65) SHALL be converted to the imperative Read-link form referencing the consolidated content anchored in the `verify`/`verify-single` task cards, so the skill consistently consumes the consolidated content via the canonical pattern.
- **R-8.** The change is additive to the verification skill surface; it MUST NOT break the verification skill's Trigger Dispatch Table, Invocation, or routing metadata.
- **R-9.** The verification-honesty zero-tolerance core (never-rely-on-memory + pre-response factual-claim gate) SHALL NOT be lost; it remains in `065-verification-honesty.md` (out-of-scope per the issue's "Out" clause).
- **R-10.** The verification skill's downstream consumers (`verification-before-completion`, `verification-enforcement`) MUST continue to resolve their verification-honesty references after the content relocation.
- **R-11.** This spec MUST NOT modify `065-verification-honesty.md`, `075-docs-verification.md`, or `130-authority-source.md` — those are separate condensation scopes (2349, 2353, 2356).

## 5. Items

### Item 1 (SC-1): Anchor evidence-requirement examples in verify/verify-single task cards

- **SC:** SC-1
- **Description:** Add the consolidated evidence-requirement examples (What COUNTS as Evidence / NOT Evidence) to the `verify`/`verify-single` task cards, establishing the skill as the authoritative source.
- **TDD cycle:**
  - RED: Behavioral test dispatching the verification skill asserting the agent does NOT currently have the consolidated evidence-requirement examples available in the skill (grep confirms no consolidated evidence block in verify/verify-single).
  - GREEN: Add the consolidated evidence-requirement examples to the `verify`/`verify-single` task cards.
  - verify: Behavioral run + grep confirm the consolidated evidence content is present and consumed.
  - commit: `.opencode/skills/verification/tasks/verify.md` (+ `verify-single.md`).

### Item 2 (SC-2): Anchor session-scoped verification detail in verify/verify-single task cards

- **SC:** SC-2
- **Description:** Add the session-scoped verification detail (Session-Scoped Verification section) to the `verify`/`verify-single` task cards, establishing the skill as the authoritative source.
- **TDD cycle:**
  - RED: Behavioral test dispatching the verification skill asserting the agent does NOT currently have the session-scoped verification detail available in the skill (grep confirms no session-scoped block in verify/verify-single).
  - GREEN: Add the session-scoped verification detail to the `verify`/`verify-single` task cards.
  - verify: Behavioral run + grep confirm the session-scoped detail is present and consumed.
  - commit: `.opencode/skills/verification/tasks/verify.md` (+ `verify-single.md`).

### Item 3 (SC-3): Add mandatory authority-source Read-link

- **SC:** SC-3
- **Description:** Add the mandatory `Read [Text](path)` link to the authority-source shared content (in the verification skill card Cross-References section and/or verify task).
- **TDD cycle:**
  - RED: grep confirms no `Read [Text](...)` link to authority-source content in the verification skill.
  - GREEN: Add the mandatory `Read [Text](path)` link to the authority-source shared content.
  - verify: grep confirms the imperative Read-link form is present (SC-3).
  - commit: `.opencode/skills/verification/SKILL.md` and/or `verify.md`.

### Item 4 (SC-4): Convert defective 065 citation to imperative Read-link form

- **SC:** SC-4
- **Description:** Convert the defective "per 065-verification-honesty.md" citation in `verify.md` (line 65) to the imperative Read-link form referencing the consolidated content anchored in the `verify`/`verify-single` task cards.
- **TDD cycle:**
  - RED: grep confirms the "per 065-verification-honesty.md" citation form still present in `verify.md` line 65.
  - GREEN: Convert the citation to the imperative `Read [Text](...)` form referencing the consolidated skill content.
  - verify: grep confirms the imperative form replaces the citation (SC-4).
  - commit: `.opencode/skills/verification/tasks/verify.md`.

### Item 5 (SC-5): Verify no routing regression

- **SC:** SC-5
- **Description:** Verify the verification skill's Trigger Dispatch Table, Invocation, and routing metadata are unchanged after the edits.
- **TDD cycle:**
  - RED: (verification only) capture the current Trigger Dispatch Table / Invocation.
  - GREEN: Confirm the routing metadata is unchanged after the edits.
  - verify: structural diff confirms Trigger Dispatch Table / Invocation unchanged (SC-5).
  - commit: (no separate commit — verification only).

### Item 6 (SC-6): Verify verification-honesty core preserved

- **SC:** SC-6
- **Description:** Verify the verification-honesty zero-tolerance core (never-rely-on-memory + pre-response gate) is not removed by this spec and that this spec does not modify 065.
- **TDD cycle:**
  - RED: (verification only) capture the current 065 core content (never-rely-on-memory + pre-response gate).
  - GREEN: Confirm the core is not removed by this spec (065 modification is out of scope).
  - verify: structural check confirms 065 core intact and this spec does not modify 065 (SC-6).
  - commit: (no separate commit — verification only).

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2349` (065-verification-honesty condensation) | SC-1/SC-2's content anchoring is gated on the 065 condensation not having already removed the content from 065 before this skill anchors it. This spec enables the condensation. | Pending |
| `.opencode#2356` (130-authority-source condensation) | SC-3's Read-link targets the authority-source shared content deliverable of this condensation. SC-3 verification is blocked until the shared reference exists, or the reference is created in the same change set. | Pending |
| `.opencode#2353` (075-docs-verification condensation) | Related change family; not directly modified by this spec. | Pending |
| Cross-reference-form-comparison research card (confidence 0.95) | Governs the imperative `Read [Text](path)` form required by SC-3/SC-4. | Satisfied |
| `065-verification-honesty.md` | Source of the evidence-requirement examples + session-scoped detail being consolidated into the skill. | Satisfied (source) |
| `130-authority-source.md` | Source of the authority-source shared content the Read-link targets. | Satisfied (source) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-1, SC-2 | Phase 1, Phase 2 |
| R-5 | SC-3 | Phase 3 |
| R-6 | SC-3 | Phase 3 |
| R-7 | SC-4 | Phase 4 |
| R-8 | SC-5 | Phase 5 |
| R-9 | SC-6 | Phase 6 |
| R-10 | SC-1, SC-2 | Phase 1, Phase 2 |
| R-11 | SC-6 | Phase 6 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `065-verification-honesty.md` | guideline | `.opencode/guidelines/065-verification-honesty.md` | read — confirms evidence-requirement examples + session-scoped detail present |
| `130-authority-source.md` | guideline | `.opencode/guidelines/130-authority-source.md` | read — confirms dual-authority / code-as-authoritative-source content |
| `verification/SKILL.md` | skill card | `.opencode/skills/verification/SKILL.md` | read — confirms no Cross-References section / authority-source Read-link exists |
| `verification/tasks/verify.md` | task card | `.opencode/skills/verification/tasks/verify.md` | read — confirms "per 065" citation at line 65, no consolidated evidence block |
| `verification/tasks/verify-single.md` | task card | `.opencode/skills/verification/tasks/verify-single.md` | read — confirms FAIL-never-downgraded invariant (line 62) |
| Cross-reference-form-comparison research card | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read — confidence 0.95, imperative Read-link form |
| Cross-reference-lobotomization research card | research | `.issues/research-cards/cross-reference-lobotomization.md` | read — confidence 0.85, "see" citations fail |
| Imperative-verb-forms-load-directives research card | research | `.issues/research-cards/imperative-verb-forms-load-directives.md` | read — confidence 0.85, imperative language improves adherence |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral test to confirm the consolidated evidence-requirement examples are anchored and consumed costs minutes of execution time — a bounded delay that surfaces a missing-content defect before the 065 condensation ships. Skipping it means the 065 condensation removes the evidence examples the verification skill and its downstream consumers depend on at runtime, and the defect is discovered only when a sub-agent executes the verification skill without the evidence examples — a death-spiral cost of rework across the skill, the condensation, and every downstream consumer.
- **SC-2:** Running the behavioral test to confirm the session-scoped verification detail is anchored and consumed costs minutes of execution time. Skipping it means the 065 condensation removes the session-scoped detail the verification skill depends on at runtime, and the defect is discovered only when a sub-agent executes the verification skill without the session-scoped detail — a death-spiral cost of rework across the skill and the condensation.
- **SC-3:** Running the behavioral test to confirm the authority-source Read-link is present and followed costs minutes of execution time. Skipping it means the imperative Read-link form is replaced by a defective "see" citation (42-58% access rate), the 130 condensation ships without a consumer of its shared content, and the authority-source content is never loaded at runtime — a death-spiral cost of rework across the skill and the condensation.
- **SC-4:** Running the string check to confirm the defective citation is converted costs one grep search. Skipping it means the "per 065" citation form persists, the agent treats the reference as decorative text, and the consolidated content is never loaded — a death-spiral cost of a broken cross-reference that silently fails at runtime.
- **SC-5:** Running the structural diff to confirm routing metadata is unchanged costs one diff. Skipping it means an accidental routing-metadata edit ships, breaking the verification skill's Trigger Dispatch Table / Invocation for every future dispatch — a death-spiral cost of a broken skill router.
- **SC-6:** Running the structural check to confirm the verification-honesty core is preserved costs one read. Skipping it means the zero-tolerance core (never-rely-on-memory + pre-response gate) is lost, and every agent that relies on it produces unverified claims — a death-spiral cost of unverifiable output across the entire pipeline.

## 11. Edge Cases

- **Condition:** Consolidated content added with a defective "see" citation instead of the imperative Read-link form (FM-1).
  **Expected behavior:** The skill MUST use the imperative `Read [Text](path)` form per the Read-Link Cross-Reference Rule.
  **Resolution:** Fails SC-4; the executor re-applies the imperative form.
- **Condition:** Authority-source Read-link target does not resolve (authority-source shared content not yet created by 2356) (FM-2).
  **Expected behavior:** The Read-link MUST resolve to existing content at runtime.
  **Resolution:** SC-3 is blocked until the 130 condensation delivers the shared reference, or the reference is created in the same change set. The executor either creates the authority-source shared reference in the same change set or gates SC-3 on the 130 condensation delivering it first.
- **Condition:** Routing metadata (Trigger Dispatch Table / Invocation) accidentally modified (FM-3).
  **Expected behavior:** The routing metadata MUST remain unchanged.
  **Resolution:** Fails SC-5; the executor reverts the routing-metadata change and re-applies the additive-only edits.
- **Condition:** Verification-honesty core content removed from 065 (FM-4).
  **Expected behavior:** The zero-tolerance core MUST NOT be removed.
  **Resolution:** Fails SC-6 (out-of-scope regression); the executor does not modify 065, which is owned by the 2349 condensation scope.
- **Condition:** Downstream consumers (`verification-before-completion`, `verification-enforcement`) left with dangling 065 references after content relocation (FM-5).
  **Expected behavior:** Downstream references MUST continue to resolve (REQ-10).
  **Resolution:** Consistency-checked, not modified, in this spec; the executor verifies the references resolve after the relocation.

## Invariants

- The verification skill's Trigger Dispatch Table, Invocation, and routing metadata are UNCHANGED (SC-5).
- The verification-honesty zero-tolerance core is NOT lost (SC-6).
- `065-verification-honesty.md`, `075-docs-verification.md`, and `130-authority-source.md` are NOT modified by this spec (separate condensation scopes 2349/2353/2356).
- The authority-source Read-link uses the imperative `Read [Text](path)` form.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-27 | Decomposed SC-1 into atomic SC-1 (evidence-requirement examples) and SC-2 (session-scoped verification detail); pinned the anchoring location to the `verify`/`verify-single` task cards (removed the "or a shared reference" open option); renumbered downstream SCs (SC-3 authority-source Read-link, SC-4 citation conversion, SC-5 routing metadata, SC-6 core preservation). Removed the "or otherwise resolved" escape hatch from the citation SC and pinned its resolution to the consolidated content anchored in the task cards. Defined the SC-6 zero-tolerance boundary in-spec (never-rely-on-memory + pre-response gate; this spec MUST NOT modify 065) instead of referencing external spec 2349. Updated Items, Traceability, Cost Frame, Edge Cases, and Invariants to match the revised atomic SC set. | Validation findings: Aggregate FAIL on determinism/escape-hatch/compound-SC grounds — (1) SC-1 anchoring location open + bundled content items; (2) SC-3 resolution open + second consumption target; (3) SC-5 external-authorization boundary not in-spec. | spec-creation validation gate (pipeline-initiated non-substantive revision) |
| 2026-08-27 | Removed the docs-verification (075) anchoring claim from the spec title and User Intent. The title and User Intent previously claimed the spec anchors 075 content, but no SC delivers 075 anchoring — SC-1/SC-2 anchor 065 content only, SC-3 adds the authority-source (130) Read-link, and 075 is explicitly out of scope (Not Included, R-11). The intent now accurately reflects what the SCs deliver: 065 anchoring + 130 authority-source link. | Validation findings: Aggregate FAIL on the Correctness dimension — preamble/intent-vs-SCs mismatch (075 anchoring claimed but not delivered by any SC). Resolved via option (a): remove the 075 claim from title and User Intent to match actual scope. | spec-creation validation gate (pipeline-initiated non-substantive revision) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
