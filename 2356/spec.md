---
remote_issue: 2356
remote_url: https://github.com/michael-conrad/.opencode/issues/2356
promoted_at: 2026-08-27T03:25:12Z
labels:
- spec
- needs-approval
number: 2356
state: OPEN
title: '[SPEC] Condense 130-authority-source.md — move drift protocol to engineering-approach'
---

> **Full spec and artifacts: [`.opencode/.issues/2356/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2356)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2356/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

Preloaded `.opencode/guidelines/130-authority-source.md` costs ~1.1k tokens and is loaded into orchestrator system context at every session start via the `opencode.jsonc` instructions array. ~40% of that content is procedural (the documentation-drift protocol in Rule 3 and dual-authority prose). The documentation-drift protocol is a how-to-respond procedure that is only needed during implementation when divergence is detected — it does not belong in the always-preloaded Tier 1 guideline. Relocating it to the engineering-approach skill's operating-protocol saves ~0.4k tokens from the preloaded orchestrator context while keeping the drift protocol reachable at implementation time.

## Root Cause / Motivation

The guideline bundles two distinct concerns that differ in when they are needed: (a) the dual-authority core — normative what-IS rules (spec-for-intent/code-for-state, spec-before-code, spec-revision-revokes-plan, suppression-of-reactive-remediation, verification-against-spec) that are safety-relevant and MUST remain preloaded per the #497 preloading mandate; and (b) the documentation-drift protocol — a procedural how-to-respond (update spec, admin sync, STOP and report) only needed during implementation when drift is detected. Because both live in the single preloaded file, the always-on orchestrator context pays for procedural content it rarely uses. The change is needed now because the #2135 precedent already relocated three superseded sections out of this guideline to skills; relocating the remaining drift-protocol prose completes that condensation pattern and continues the token savings.

## Approach Chosen

Relocate the documentation-drift protocol prose (Rule 3) from `.opencode/guidelines/130-authority-source.md` to `.opencode/skills/engineering-approach/tasks/operating-protocol.md`, which already governs the understand/design/verify procedural discipline and is loaded during implementation where drift detection applies. Condense the guideline to retain only the dual-authority core (Principle, Rules 1, 2, 4, 5, 6, and the `critical-rules-010` enforcement block). Keep the file path unchanged so all existing cross-references (065, 067, 075 guidelines, audit drift-detection tasks, issue-operations-core) remain valid. This is a prose/content change — no executable runtime behavior, routing, or branching logic changes; verification is semantic/structural.

## Alternatives Considered & Why Discarded

1. **Relocate the drift protocol to the audit skill's drift-detection chain.** Discarded: the audit skill already has a dedicated drift-detection role chain (investigator/evaluator/validator/arbiter). Placing the documentation-drift protocol there would duplicate that machinery. The issue scope explicitly names engineering-approach / verification as the target, and engineering-approach's operating-protocol already holds the design/verify procedural steps.

2. **Remove the drift protocol entirely (deletion, not relocation).** Discarded: this would cause content loss — the drift protocol's semantic meaning (update spec on divergence, admin sync, STOP and report) is a required procedural behavior. The issue scope is "relocate", not "remove".

3. **Keep the drift protocol in the guideline and only condense prose.** Discarded: this would not achieve the ~0.4k token savings from the preloaded context, because the procedural drift-protocol content would still be loaded at every session start. The intended benefit is removing procedural content from the preloaded guideline.

## Key Design Decisions

1. **130-authority-source.md remains in the opencode.jsonc instructions array.** The core is retained (REQ-5, #497 safety mandate), so the file is NOT removed — only its procedural prose is condensed. Tradeoff: the file stays preloaded, but at reduced token cost.
2. **The file path is unchanged.** All cross-references cite the path `130-authority-source.md`; keeping the path stable preserves those references. Tradeoff: no renaming benefit, but zero reference churn.
3. **The drift protocol lands in engineering-approach operating-protocol, not audit.** The relocation avoids duplicating audit's existing drift-detection chain and matches the issue scope. Tradeoff: agents must load the engineering-approach skill to reach the drift protocol at implementation time, which is when it is needed.
4. **Semantic preservation is a dedicated verification gate.** Because this is prose relocation, semantic equivalence (no content loss, no compaction-metric phrasing) is verified by AI read of both files — not grep (precedent #2135 SC-11a/b/c, SC-12). Tradeoff: semantic verification requires an AI read, but that is the correct evidence type for prose changes.

## User Intent / Original Prompt

The issue requests condensing `.opencode/guidelines/130-authority-source.md` (currently ~1.1k tokens, ~40% procedural) to save ~0.4k tokens by relocating the drift-protocol prose to engineering-approach / verification, while retaining the spec-for-intent/code-for-state core and the suppression-of-reactive-remediation rule.

## Not Included

- **Removing the authority-source core** (scope "Out"): the dual-authority core (Principle, Rules 1, 2, 4, 5, 6, critical-rules-010) stays preloaded.
- **Removing 130-authority-source.md from the opencode.jsonc instructions array** (REQ-N2): the file is retained.
- **Renaming the file path** `.opencode/guidelines/130-authority-source.md`: the path is unchanged.
- **Altering audit's drift-detection role chain**: the relocation targets engineering-approach, not audit.
- **Any executable code, routing, or behavioral change**: this is prose-only; no runtime-behavioral change.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | Rule 3 (Documentation Drift Protocol) procedural prose is removed from `.opencode/guidelines/130-authority-source.md`. | semantic | Clean-room AI read of the condensed `130-authority-source.md`; assert Rule 3 prose is absent and no content-free section header remains. | `.opencode/guidelines/130-authority-source.md` (source) |
| SC-2 | The documentation-drift protocol prose is present in `.opencode/skills/engineering-approach/tasks/operating-protocol.md`. | semantic | Clean-room AI read of `operating-protocol.md`; assert the drift-protocol prose (update spec, admin sync, STOP and report) is present. | `.opencode/skills/engineering-approach/tasks/operating-protocol.md` (source) |
| SC-3 | `130-authority-source.md` remains present in the `.opencode/opencode.jsonc` instructions array. | structural | Read the `opencode.jsonc` instructions array; assert `".opencode/guidelines/130-authority-source.md"` is still listed. | `.opencode/opencode.jsonc` (source) |
| SC-4 | The INDEX.md row for `130-authority-source.md` accurately reflects the condensed guideline's scope. | structural | Read the `130-authority-source.md` row in `.opencode/guidelines/INDEX.md`; assert the row exists and its load_when trigger is consistent with the retained core scope. | `.opencode/guidelines/INDEX.md` (source) |
| SC-5 | The retained core rules (Principle, Rules 1, 2, 4, 5, 6, and the `critical-rules-010` block) in the condensed guideline are semantically equivalent to the original. | semantic | Two-file semantic comparison of the retained core in the condensed `130-authority-source.md` against the original (git main); assert no semantic loss and no compaction-metric phrasing. | `.opencode/guidelines/130-authority-source.md`, git history (sources) |
| SC-6 | The relocated documentation-drift protocol in `operating-protocol.md` is semantically equivalent to the original Rule 3. | semantic | Two-file semantic comparison of the relocated drift protocol against the original Rule 3 (git main); assert semantic meaning preserved. | `.opencode/skills/engineering-approach/tasks/operating-protocol.md`, git history (sources) |

## Requirements

- **R-1.** `130-authority-source.md` SHALL remove the Rule 3 Documentation Drift Protocol procedural prose.
- **R-2.** `130-authority-source.md` SHALL retain the dual-authority core: Principle, Rules 1, 2, 4, 5, 6, and the `critical-rules-010` block.
- **R-3.** `engineering-approach/tasks/operating-protocol.md` SHALL contain the relocated documentation-drift protocol prose.
- **R-4.** `130-authority-source.md` SHALL remain listed in the `.opencode/opencode.jsonc` instructions array.
- **R-5.** The `130-authority-source.md` row in `.opencode/guidelines/INDEX.md` SHALL remain present and reflect the retained core scope.
- **R-6.** The file path `.opencode/guidelines/130-authority-source.md` SHALL remain unchanged.
- **R-7.** The retained core and relocated drift-protocol content SHALL preserve semantic meaning (no content loss, no compaction-metric phrasing).

## Items

### Item 1 (SC-1): Remove Rule 3 procedural prose from 130-authority-source.md

- RED: Clean-room read of `130-authority-source.md` — Rule 3 (Documentation Drift Protocol) prose is still present.
- GREEN: Remove the Rule 3 procedural prose; retain Principle, Rules 1, 2, 4, 5, 6, and the `critical-rules-010` block.
- verify: Clean-room AI read — Rule 3 absent; core retained; no empty section headers.
- commit: `.opencode/guidelines/130-authority-source.md`.

### Item 2 (SC-2): Relocate drift-protocol prose to engineering-approach operating-protocol

- RED: Clean-room read of `operating-protocol.md` — drift-protocol prose is absent.
- GREEN: Add the documentation-drift protocol prose (update spec, admin sync, STOP and report) to `operating-protocol.md`.
- verify: Clean-room AI read — drift-protocol prose present and semantically preserved; no duplication into audit.
- commit: `.opencode/skills/engineering-approach/tasks/operating-protocol.md`.

### Item 3 (SC-3): Confirm 130-authority-source.md retention in opencode.jsonc

- RED: Read `opencode.jsonc` instructions array — `130-authority-source.md` present (retention is the invariant; RED confirms the current state before any accidental removal).
- GREEN: No change required if the entry is present; if removed during condensation, restore it.
- verify: Read `opencode.jsonc` instructions array — `".opencode/guidelines/130-authority-source.md"` is listed.
- commit: `.opencode/opencode.jsonc` (only if a change was required).

### Item 4 (SC-4): Verify INDEX.md row accuracy

- RED: Read the `130-authority-source.md` row in `INDEX.md` — row present; verify its load_when wording reflects the current scope.
- GREEN: Adjust the load_when wording if it inaccurately reflects the condensed guideline's scope.
- verify: Read `INDEX.md` — the row is present and consistent with the retained core scope.
- commit: `.opencode/guidelines/INDEX.md` (only if a change was required).

### Item 5 (SC-5): Verify semantic preservation of the retained core

- RED: Compare condensed `130-authority-source.md` retained core against original (git main) — check for semantic loss or altered meaning.
- GREEN: Fix any semantic divergence in the condensed guideline.
- verify: Clean-room two-file semantic comparison — retained core semantically equivalent; no compaction-metric phrasing.
- commit: `.opencode/guidelines/130-authority-source.md` (if corrected).

### Item 6 (SC-6): Verify semantic preservation of the relocated drift protocol

- RED: Compare relocated drift protocol in `operating-protocol.md` against original Rule 3 (git main) — check for semantic loss.
- GREEN: Fix any semantic divergence in the relocated prose.
- verify: Clean-room two-file semantic comparison — relocated drift protocol semantically equivalent to original Rule 3.
- commit: `.opencode/skills/engineering-approach/tasks/operating-protocol.md` (if corrected).

## Dependencies

- **Reference:** `130-authority-source.md` (source guideline)
  - **Relationship:** Must be condensed in coordination with the relocation to avoid content loss (Item 1 and Item 2 are coupled — relocate before remove).
  - **Status:** Satisfied (source exists at `.opencode/guidelines/130-authority-source.md`).
- **Reference:** `engineering-approach/tasks/operating-protocol.md` (relocation target)
  - **Relationship:** Must receive the drift-protocol prose; depends on Items 1-2 being complete.
  - **Status:** Satisfied (source exists).
- **Reference:** `.opencode/opencode.jsonc` instructions array
  - **Relationship:** Must retain `130-authority-source.md` (REQ-5 / #497 preloading mandate).
  - **Status:** Satisfied (entry present at line 90).
- **Reference:** `.opencode/guidelines/INDEX.md`
  - **Relationship:** Row for `130-authority-source.md` must reflect the retained core scope.
  - **Status:** Satisfied (row present at line 32).
- **Reference:** Issue #2365 (engineering-approach skill update)
  - **Relationship:** #2365 makes engineering-approach the canonical home for the drift protocol; this issue's relocation depends on that context.
  - **Status:** Open (prerequisite).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1, SC-5 | Item 1, Item 5 |
| R-3 | SC-2, SC-6 | Item 2, Item 6 |
| R-4 | SC-3 | Item 3 |
| R-5 | SC-4 | Item 4 |
| R-6 | SC-1 | Item 1 |
| R-7 | SC-5, SC-6 | Item 5, Item 6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `130-authority-source.md` | guideline source | `.opencode/guidelines/130-authority-source.md` | read Rule 3 absence + core retention |
| `operating-protocol.md` | skill task source | `.opencode/skills/engineering-approach/tasks/operating-protocol.md` | read drift-protocol prose presence |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read instructions array retention |
| `INDEX.md` | guideline index | `.opencode/guidelines/INDEX.md` | read row presence + scope wording |
| git history | source of record | `git main` for `130-authority-source.md` and `operating-protocol.md` | two-file semantic comparison |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying Rule 3 removal costs one clean-room AI read of the condensed guideline. Skipping means the procedural drift protocol stays in the always-preloaded file, and every session pays the ~0.4k token cost with no benefit.
- **SC-2:** Verifying drift-protocol presence in `operating-protocol.md` costs one clean-room AI read. Skipping means the drift protocol is deleted rather than relocated — silent content loss that no future reader can recover.
- **SC-3:** Verifying `opencode.jsonc` retention costs one read of the instructions array. Skipping means the guideline could be dropped from preloading, violating the #497 safety mandate and breaking the orchestrator's authority-source guardrails.
- **SC-4:** Verifying the INDEX.md row costs one read. Skipping means the routing index misleads sub-agents about what the guideline governs, deferring the defect to the next routing decision.
- **SC-5:** Verifying retained-core semantic preservation costs one two-file comparison. Skipping means condensation could silently alter the safety-relevant dual-authority meaning, propagating wrong authority semantics to every preloaded session.
- **SC-6:** Verifying relocated-protocol semantic preservation costs one two-file comparison. Skipping means the relocated drift protocol could be semantically altered, so the how-to-respond guidance is wrong when an agent actually hits divergence during implementation.

## Edge Cases

- **Content-free section header:** If condensation leaves an empty header where Rule 3 stood, SC-1's semantic read flags it (precedent #2135 SC-12) and the change is not accepted.
- **Compaction-metric phrasing:** If the relocated or retained prose introduces compaction-metric phrases (e.g., "reduced tokens", "saved X tokens"), SC-5/SC-6 semantic reads flag it and the change is not accepted (precedent #2135 SC-12).
- **Cross-reference invalidation:** Because the file path `.opencode/guidelines/130-authority-source.md` is unchanged and the core is retained, the references in 065, 067, 075, audit drift-detection, and issue-operations-core stay valid; SC-1/SC-5 verify the core is present so those citations remain accurate.
- **Premature removal before relocation:** Items 1 and 2 are coupled — the drift protocol must be relocated (Item 2) before or alongside being removed (Item 1) to avoid content loss; the dependency ordering enforces this.
- **Concurrency:** This is a prose/content change with no shared state or transaction; no race condition or resource contention applies.
- **Recovery:** Because every SC is a prose-verification gate, a failed or partial change is repaired by re-running the corresponding item's GREEN edit; no state machine or rollback path is required.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
