# [SPEC] Update brainstorming skill — Read-link discussion-mode-mandates

> **Full spec and artifacts: [`2371/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2371/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `2371/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The brainstorming skill card does not consume the discussion-mode mandates via the canonical imperative Read-link form, so agents loading the skill do not reliably access the shared discussion-mode reference. |
| 2 | **Root Cause / Motivation** | The Read-Link Cross-Reference Rule requires the imperative `Read [Text](path)` form for agent-facing cross-references. The brainstorming card's Cross-References section lists Skills and Guidelines but contains no Read-link to a discussion-mode reference. The discussion-mode mandates are currently consumed only via the preloaded 020 guideline, not via a dedicated shared reference, which blocks the 020 condensation effort. |
| 3 | **Approach Chosen** | Add one imperative `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the brainstorming skill card's Cross-References section. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Inline the discussion-mode mandates into the brainstorming card — discarded because it duplicates content that belongs in the shared reference and defeats the 020 condensation effort. (b) Use a bare "see" citation — discarded because research shows "see" is treated as informational and does not trigger access. (c) Resolution-table + admonition pattern — discarded because it achieves only 42-58% access rate. |
| 5 | **Key Design Decisions** | Use the imperative Read-link form (verified 100% Tier 1 access rate) pointing to the shared reference file in `.opencode/reference/`. Tradeoff: the link depends on the reference file existing (deliverable of `.opencode#2358`). |
| 6 | **User Intent / Original Prompt** | Add a mandatory Read-link to discussion-mode-mandates.md in the brainstorming skill card. |

## 2. Not Included

- **Losing the discussion-mode mandates** — the mandates themselves are not removed or edited; this spec only adds the Read-link.
- **Modifying the approval-gate skill card's discussion-mode link** — that is the scope of `.opencode#2366`/`.opencode#2358`.
- **Modifying `020-go-prohibitions.md`** — separate 020 condensation scope.
- **Editing brainstorming task cards** (`tasks/*.md`) — unchanged.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The brainstorming skill card's Cross-References section SHALL contain an imperative `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the discussion-mode-mandates reference. | behavioral | `opencode run` via the `with-test-home` harness loading the brainstorming skill, asserting the agent reads `discussion-mode-mandates.md`; supplementary grep for the imperative form |
| SC-2 | The Read-link target `.opencode/reference/discussion-mode-mandates.md` SHALL resolve to an existing file. | behavioral | `opencode run` via the `with-test-home` harness; supplementary structural check that the target file exists |

## 4. Requirements

- R-1. The brainstorming skill card SHALL include an imperative `Read [Text](...)` link to the discussion-mode-mandates reference in its Cross-References section.
- R-2. The Read-link target SHALL resolve to the discussion-mode-mandates reference file.

## 5. Items

### Item 1 (SC-1): Add imperative Read-link to brainstorming skill card

- RED: Behavioral enforcement test asserting the agent does NOT currently read `discussion-mode-mandates.md` when loading the brainstorming skill.
- GREEN: Add the imperative `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the brainstorming skill card's Cross-References section.
- verify: Run the behavioral test; confirm the agent reads the reference file.
- commit: Commit the skill card change + test together as one working slice.

### Item 2 (SC-2): Verify link target resolution

- RED: Enforcement test asserting the target path resolves.
- GREEN: Ensure the dependency reference file exists (deliverable of `.opencode#2358`) or gate on dependency delivery.
- verify: Confirm `.opencode/reference/discussion-mode-mandates.md` exists and the link resolves.
- commit: Commit the verification as one working slice.

## 6. Dependencies

- **`.opencode#2358`** — Relationship: creates `.opencode/reference/discussion-mode-mandates.md`, the Read-link target. Status: pending (open, `needs-approval`).
- **Read-Link Cross-Reference Rule (AGENTS.md)** — Relationship: defines the imperative form. Status: satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 (Item 1) |
| R-2 | SC-2 | Phase 2 (Item 2) |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Read-Link Cross-Reference Rule | doc | AGENTS.md | read |
| cross-reference-form-comparison research card | doc | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read |
| discussion-mode-mandates reference | doc | `.opencode/reference/discussion-mode-mandates.md` | dependency (`.opencode#2358`) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral test costs minutes of execution time — a bounded delay that surfaces whether the agent actually reads the reference. Skipping means the Read-link is added but never consumed, and the defect (agents not accessing discussion-mode mandates) ships to production and costs 1000× more to fix.
- **SC-2:** Verifying the target resolves costs one behavioral run plus a structural existence check. Skipping means a broken link is not caught until the first agent fails to load the reference during a real session.

## 11. Edge Cases

- **Dependency missing (reference file does not exist):** Condition — `.opencode/reference/discussion-mode-mandates.md` not yet created. Expected behavior — SC-2 verification MUST NOT pass. Resolution — gate SC-2 on the dependency being delivered first (create the reference in the same change set or verify after `.opencode#2358` merges).
- **Link form regression (bare "see"):** Condition — a contributor uses a non-imperative citation. Expected behavior — SC-1 verification MUST fail. Resolution — enforce the imperative `Read [Text](path)` form.
- **Wrong target path:** Condition — the link points to a non-existent or incorrect path. Expected behavior — SC-2 verification MUST fail. Resolution — resolve the exact reference path.
