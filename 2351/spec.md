---
remote_issue: 2351
remote_url: https://github.com/michael-conrad/.opencode/issues/2351
promoted_at: 2026-08-27T03:25:12.660366+00:00
promotion_type: retroactive_import
labels:
- spec
- needs-approval
number: 2351
state: OPEN
title: '[SPEC] Condense 067-context-completeness.md — move staleness detail to issue-review
  skill'
---

> **Full spec and artifacts: [`.opencode/.issues/2351/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2351/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2351/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

The preloaded `.opencode/guidelines/067-context-completeness.md` costs roughly 1.9k tokens of the agent's preloaded instruction budget, of which roughly 40% is procedural staleness detail — the Staleness Rule, the Significant Actions Requiring Re-Read list, the De Minimis Bound with its examples table, and the Single Exchange Window — that overlaps the issue-review and issue-operations skills. Because this procedural detail is carried in every agent session even when no comment-gathering occurs, it wastes preloaded token budget on content that belongs at the point of use.

## Root Cause / Motivation

The staleness procedural detail lives inline in a Tier 1 preloaded guideline instead of at the comment-gathering operation that actually consumes it. `issue-review/tasks/gather.md` Step 6.3 already owns a staleness-assessment hook ("Last audit timestamp — Used by `just-review` path to assess staleness"), so the re-read / de-minimis / single-exchange-window rules are duplicated as procedural prose in 067 when they are only exercised when a resource's comments are gathered. The condensation is needed now because the duplicated detail inflates the always-on preload without adding enforcement value — the read-all-comments core is what carries the safety-critical guarantee.

## Approach Chosen

Relocate the staleness procedural detail (Staleness Rule, Significant Actions Requiring Re-Read, De Minimis Bound + examples table, Single Exchange Window) out of the preloaded 067-context-completeness.md and inline it into the issue-review gather task card, which already owns the staleness-assessment hook at Step 6.3. The zero-tolerance read-all-comments-before-acting core of 067 (Zero Tolerance Rule, Scope of Resources, When This Applies, Evidence Requirement, FORBIDDEN, REQUIRED, Related Guidelines, critical-rules-012 blocks) is retained verbatim and remains preloaded. The 067 Single Exchange Window cross-reference to 065-verification-honesty.md is preserved in the relocated content.

## Alternatives Considered & Why Discarded

1. **Relocate the staleness detail to a shared reference file in `.opencode/reference/` loaded via a mandatory Read-link from the gather task.** Discarded: the staleness procedural detail has exactly one consumer (the issue-review gather task's comment gathering / staleness assessment). A separate reference file adds a file to navigate for content consumed at a single site, and the Read-Link form would force an extra indirection where inlining into the owning task card is sufficient. Inlining into the gather task card keeps the detail at the single point of use with no additional file to maintain.
2. **Re-inline the staleness detail into the other consuming skill cards (issue-operations, issue-operations-comments).** Discarded: this creates duplication across multiple skill cards and contradicts the single-canonical-home principle. The gather task card is the canonical home; the other skill cards route through issue-review when comment gathering is needed.

## Key Design Decisions

1. **The relocation form is INLINE into the issue-review gather task card**, not a separate reference file. Tradeoff: the detail lives directly at its single consumer (Step 6.3 staleness hook) with no extra indirection, at the cost of the gather task card carrying a bit more prose than before.
2. **The read-all-comments core remains preloaded and verbatim in 067.** Tradeoff: the safety-critical zero-tolerance guarantee stays in the always-on preload where it is always enforced, at the cost of 067 not shrinking to its absolute minimum.
3. **The staleness relocation is paired atomically with the removal from 067 (SC-2 before SC-1).** Tradeoff: guaranteed no content loss during relocation, at the cost of sequencing the relocation before the removal.

## User Intent / Original Prompt

The issue body requested: "Relocate staleness/deminimis/examples to issue-review skill; retain the zero-tolerance read-all-comments-before-acting core." The dispatch instruction additionally resolved the relocation form: "the staleness procedural detail relocates INLINE into the issue-review gather task card (which already owns the staleness-assessment hook at Step 6.3), NOT to a separate reference file."

## Not Included

- **The read-all-comments-before-acting core** — the Zero Tolerance Rule, Scope of Resources, When This Applies, Evidence Requirement, FORBIDDEN, REQUIRED, Related Guidelines, and critical-rules-012 blocks remain preloaded and are not modified.
- **Other skill cards (issue-operations, issue-operations-comments)** — the staleness detail is not re-inlined into these; it has one canonical home in the issue-review gather task card.
- **Parent-repo (opencode-config) files** — all changes are confined to the `.opencode` submodule.
- **The 067 read-all-comments enforcement semantics** — only the procedural staleness sections are relocated; the enforcement of reading all comments is unchanged.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The staleness procedural detail (Staleness Rule, Significant Actions Requiring Re-Read, De Minimis Bound + examples, Single Exchange Window) is removed from the preloaded `.opencode/guidelines/067-context-completeness.md`. | structural | Read 067-context-completeness.md and confirm the Staleness Rule section (the re-read / de-minimis / single-exchange-window content) is absent while the retained core sections (Zero Tolerance, Scope, When This Applies, Evidence, FORBIDDEN, REQUIRED) remain. | `.opencode/guidelines/067-context-completeness.md` (source) |
| SC-2 | The staleness/deminimis/single-exchange detail is relocated INLINE into the `issue-review` gather task card (`.opencode/skills/issue-review/tasks/gather.md`), reachable from the existing Step 6.3 staleness hook — NOT to a separate reference file. | structural | Read gather.md and confirm the relocated staleness detail (re-read before significant actions, de-minimis bound, single-exchange window, 065 cross-reference) is present inline in the task card, associated with the Step 6.3 staleness-assessment hook. | `.opencode/skills/issue-review/tasks/gather.md` (source) |
| SC-3 | The zero-tolerance read-all-comments-before-acting core (Zero Tolerance Rule, Scope of Resources, When This Applies, Evidence Requirement, FORBIDDEN, REQUIRED, Related Guidelines, critical-rules-012 blocks) is retained in 067-context-completeness.md. | behavioral | Run `opencode run` with a prompt triggering read-all-comments-before-acting; a clean-room sub-agent inspects the session stderr for evidence the agent reads ALL comments before acting on a resource (core retained and enforced). | `.opencode/guidelines/067-context-completeness.md` (source) |
| SC-4 | The preloaded token burden of 067-context-completeness.md is reduced (issue Impact target ~0.7k token savings). | structural | Measure the post-condensation byte/line count of 067-context-completeness.md and confirm a substantial reduction (the ~40% procedural staleness detail removed from the ~1.9k-token preload). | `.opencode/guidelines/067-context-completeness.md` (source) |
| SC-5 | The issue-review skill's staleness assessment (just-review path) remains functional after the relocation — the relocated detail is reachable from the gather task card, and the 065 Single Exchange Window cross-reference is preserved. | behavioral | Run `opencode run` invoking the issue-review gather task on a just-review candidate; a clean-room sub-agent inspects the session stderr for evidence the gather task assesses staleness using the relocated detail and preserves the 065 cross-reference. | `.opencode/skills/issue-review/tasks/gather.md` (source), `.opencode/guidelines/065-verification-honesty.md` (source) |

## Requirements

- **R-1.** 067-context-completeness.md SHALL retain the read-all-comments-before-acting core (Zero Tolerance Rule, Scope of Resources, When This Applies, Evidence Requirement, FORBIDDEN, REQUIRED, Related Guidelines, critical-rules-012 blocks) verbatim.
- **R-2.** 067-context-completeness.md SHALL NOT contain the staleness procedural detail (Staleness Rule, Significant Actions Requiring Re-Read, De Minimis Bound + examples, Single Exchange Window).
- **R-3.** The issue-review gather task card SHALL contain the relocated staleness procedural detail inline, reachable from the Step 6.3 staleness-assessment hook.
- **R-4.** The relocated staleness detail SHALL preserve the 065-verification-honesty.md Single Exchange Window cross-reference.
- **R-5.** The change SHALL be confined to `.opencode/` files (guideline 067 + issue-review skill); no parent-repo changes.
- **R-6.** 067-context-completeness.md SHALL remain in the `.opencode/opencode.jsonc` instructions array (preloaded); only its content shrinks.
- **R-7.** The staleness detail SHALL NOT be re-inlined into other skill cards (issue-operations, issue-operations-comments).

## Items

### Item 1 (SC-2): Relocate the staleness detail inline into the issue-review gather task card

- RED: Read `gather.md` — the Step 6.3 staleness hook does not yet carry the relocated staleness detail (re-read / de-minimis / single-exchange / 065 cross-reference).
- GREEN: Inline the staleness procedural detail into `gather.md` associated with the Step 6.3 staleness-assessment hook, preserving the 065 Single Exchange Window cross-reference.
- verify: Read `gather.md` and confirm the relocated detail is present inline at Step 6.3 with the 065 cross-reference intact.
- commit: `.opencode/skills/issue-review/tasks/gather.md`.

### Item 2 (SC-1): Remove the staleness detail from 067-context-completeness.md

- RED: Read 067-context-completeness.md — the Staleness Rule section (lines 35-70) is still present.
- GREEN: Remove the Staleness Rule, Significant Actions Requiring Re-Read, De Minimis Bound + examples, and Single Exchange Window sections, retaining the read-all-comments core.
- verify: Read 067-context-completeness.md and confirm the staleness sections are removed and the core sections remain.
- commit: `.opencode/guidelines/067-context-completeness.md`.

### Item 3 (SC-3): Verify the read-all-comments core is retained and enforced

- RED: Run the read-all-comments behavioral prompt against the pre-condensation 067; verify it passes before the change (baseline).
- GREEN: No code change — this item verifies the retained core after Items 1-2.
- verify: `opencode run` with the read-all-comments prompt; clean-room sub-agent inspects session stderr for evidence the agent reads ALL comments before acting.
- commit: no file change (verification item on 067).

### Item 4 (SC-4): Measure the post-condensation token burden of 067

- RED: Record the pre-condensation byte/line count of 067-context-completeness.md.
- GREEN: No code change — this item measures the post-condensation burden after Item 2.
- verify: Measure the post-condensation byte/line count and confirm a substantial reduction (~40% of the ~1.9k-token preload removed).
- commit: no file change (measurement item on 067).

### Item 5 (SC-5): Verify the issue-review staleness path is functional after relocation

- RED: Run the issue-review gather staleness behavioral prompt against the pre-relocation gather task; verify the baseline.
- GREEN: No code change — this item verifies the relocated gather task after Item 1.
- verify: `opencode run` invoking issue-review gather on a just-review candidate; clean-room sub-agent inspects session stderr for evidence the gather task assesses staleness using the relocated detail and preserves the 065 cross-reference.
- commit: no file change (verification item on gather.md).

## Dependencies

- **Reference:** `.opencode/guidelines/067-context-completeness.md`
  - **Relationship:** The primary target being condensed; its core is retained and its staleness detail is relocated.
  - **Status:** Satisfied (source exists, preloaded).
- **Reference:** `.opencode/skills/issue-review/tasks/gather.md` (Step 6.3 staleness hook)
  - **Relationship:** The canonical relocation target; already owns the staleness-assessment hook.
  - **Status:** Satisfied (source exists, line 89).
- **Reference:** `.opencode/guidelines/065-verification-honesty.md`
  - **Relationship:** Referenced by 067's Single Exchange Window; the cross-reference must be preserved in the relocated content.
  - **Status:** Satisfied (source exists).
- **Reference:** `.opencode/opencode.jsonc` instructions array
  - **Relationship:** 067 remains preloaded; only its content shrinks.
  - **Status:** Satisfied (no config change).
- **Reference:** research card `cross-reference-form-comparison.md`
  - **Relationship:** Governs the Read [Text](path) cross-reference form; applicable if any cross-reference appears in the relocated content.
  - **Status:** Satisfied (card present).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-3 | Item 3 |
| R-2 | SC-1 | Item 2 |
| R-3 | SC-2 | Item 1 |
| R-4 | SC-2, SC-5 | Item 1, Item 5 |
| R-5 | all SCs | all items |
| R-6 | SC-3 | Item 3 |
| R-7 | SC-2 | Item 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `067-context-completeness.md` | guideline | `.opencode/guidelines/067-context-completeness.md` | read section inventory (core retained, staleness removed) |
| `gather.md` | task card | `.opencode/skills/issue-review/tasks/gather.md` | read Step 6.3 + relocated staleness detail |
| `065-verification-honesty.md` | guideline | `.opencode/guidelines/065-verification-honesty.md` | read Single Exchange Window (cross-reference preserved) |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read instructions array (067 still preloaded) |
| `pre-spec-inspection.yaml` | analysis artifact | `.opencode/tmp/2351/artifacts/pre-spec-inspection.yaml` | read section inventory and relocation target |
| `pipeline-readiness.yaml` | analysis artifact | `.opencode/tmp/2351/artifacts/pipeline-readiness.yaml` | read BLOCKER-1/BLOCKER-2 resolution |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the staleness detail is removed from 067 costs one read of the guideline. Skipping means the duplicated procedural detail stays in the always-on preload, wasting ~0.7k tokens per session and deferring the condensation benefit indefinitely.
- **SC-2:** Verifying the staleness detail is relocated inline into the gather task card costs one read of gather.md. Skipping means the relocation orphaned the Step 6.3 staleness hook or the detail was lost entirely — a content-loss defect discovered only when the just-review path fails to assess staleness.
- **SC-3:** Running the behavioral read-all-comments test costs minutes of execution time. Skipping means the condensation could accidentally strip the safety-critical core, and the defect ships as a silent enforcement gap in every downstream agent session.
- **SC-4:** Measuring the post-condensation byte/line burden costs one measurement. Skipping means the claimed ~0.7k token savings is unverified, and the condensation may have delivered no real preload reduction.
- **SC-5:** Running the behavioral issue-review gather staleness test costs minutes of execution time. Skipping means the relocated staleness path could be broken and the 065 cross-reference lost, deferring discovery to a production issue-review failure.

## Edge Cases

- **Input boundary — empty relocated content:** If the staleness detail were relocated but contained nothing new (the Step 6.3 hook already assesses staleness), SC-2 requires the relocated re-read / de-minimis / single-exchange / 065-cross-reference content to be present inline, so an empty relocation fails.
- **State transition — relocation ordering:** SC-2 (relocation) MUST complete before SC-1 (removal from 067) to avoid content loss; the items are ordered accordingly, and the coupling is declared in the dependencies.
- **Failure mode — core accidentally removed:** If the condensation removes more than the staleness sections, SC-3's behavioral test flags the missing core and the change is rejected.
- **Failure mode — cross-reference lost:** If the relocated Single Exchange Window drops the 065 reference, SC-5 flags the loss and the change is rejected.
- **Concurrency:** This is a content relocation with no shared runtime state; no race condition or resource contention applies.
- **Recovery:** Because SC-1 and SC-2 are a paired relocation, a partial change is repaired by completing the missing half — either re-inlining the detail (SC-2) or removing it from 067 (SC-1) — with no state machine rollback required.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
