---
remote_issue: 2347
remote_url: https://github.com/michael-conrad/.opencode/issues/2347
promoted_at: 2026-08-27T03:25:12.652239+00:00
labels:
- needs-approval
- spec-draft
number: 2347
state: OPEN
title: '[SPEC] Condense 020-go-prohibitions.md — move context-discipline & discussion mandates'
---

> **Full spec and artifacts: [`.opencode/.issues/2347/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2347)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2347/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Condense 020-go-prohibitions.md — move context-discipline & discussion mandates

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/020-go-prohibitions.md` guideline costs ~19.8k tokens — the single largest preloaded guideline (~30% of the preloaded burden). Roughly 60% of its content is procedural (orchestrator context discipline §1.1, discussion-mode mandates §1.6, iterative-feedback prose, project-local tool install rules) rather than safety-critical prohibition rules. |
| 2 | **Root Cause / Motivation** | 020-go-prohibitions.md (533 lines, 53,468 bytes) is preloaded unconditionally via the opencode.jsonc instructions array (line 81). Procedural context-management and discussion-mode content accumulated in it over time and duplicates content already present in skill cards (approval-gate, mcp-tool-usage, skill-creator, brainstorming, writing-plans, executing-plans, git-workflow). This duplication inflates the preloaded token burden without adding enforcement value. |
| 3 | **Approach Chosen** | Relocate the procedural sections (§1.1, §1.6, §2, §4) to shared canonical references loaded via mandatory `Read [Text](path)` links, and retain the GO-prohibition core (§1) plus the anti-self-authorization critical-rules enforcement blocks verbatim in the preloaded 020. Consuming skill cards Read-link the shared references rather than re-inlining content. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Leave 020 unchanged** — discarded because it preserves the ~19.8k token preloaded burden and the duplication across skill cards. (b) **Re-inline relocated content into each consuming skill card** — discarded because it replaces one duplication with another (per #2359 "Out: Re-inlining the content into each card (duplication avoided)"). (c) **Remove 020 from the preloaded instructions array** — discarded because the GO-prohibition core is safety-critical and must stay preloaded (opencode.jsonc line 81 unchanged). |
| 5 | **Key Design Decisions** | (a) Relocated rules use the canonical `Read [Text](path)` form (validated at 100% Tier 1 access by research card cross-reference-form-comparison.md, conf 0.95) — not "See" or resolution tables. (b) The GO-prohibition core and the procedural context-discipline content are distinct concerns: the core stays preloaded; the procedural content moves to shared references. (c) Each relocated concern maps to exactly one canonical home, avoiding duplication. (d) 020-go-prohibitions.md remains in the opencode.jsonc instructions array (line 81) — only its content shrinks. |
| 6 | **User Intent / Original Prompt** | Condense the preloaded `020-go-prohibitions.md` guideline by moving context-discipline and discussion-mode mandates to shared references, retaining the GO-prohibition core. |

## 2. Not Included

- **Creating `reference/orchestrator-context-discipline.md`** — that is #2359's scope; this issue consumes it, it does not create it.
- **Parent-repo (opencode-config) AGENTS.md or config changes** — all changes are confined to `.opencode/` files (REQ-C3).
- **Removing any anti-self-authorization core** — the GO-prohibition core and anti-self-auth enforcement blocks are retained verbatim (REQ-N1, REQ-N4).
- **Re-inlining relocated content into consuming skill cards** — duplication is avoided (REQ-N2).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | §1.1 Orchestrator Context Discipline content is removed from the preloaded 020-go-prohibitions.md and relocated to the shared reference orchestrator-context-discipline.md, with 020 retaining only a mandatory Read-link. | behavioral | `opencode run` with a context-discipline routing prompt; clean-room sub-agent inspects session.yaml for evidence the agent loads the shared reference via Read-link and does not find §1.1 prose in 020. | `.opencode/guidelines/020-go-prohibitions.md`; `.opencode/reference/orchestrator-context-discipline.md` (created by #2359) |
| SC-2 | §1.6 Discussion Mode Mandates content is removed from 020-go-prohibitions.md and relocated to a shared reference loaded via mandatory Read-link from the brainstorming skill. | behavioral | `opencode run` with a discussion-mode prompt; clean-room sub-agent inspects session.yaml for evidence the brainstorming skill loads the discussion-mandates reference and 020 no longer contains §1.6 prose. | `.opencode/guidelines/020-go-prohibitions.md`; `.opencode/skills/brainstorming/SKILL.md` |
| SC-3 | §2 Iterative Feedback & Plan Revision prose is removed from 020-go-prohibitions.md and relocated to a shared reference. | structural | read/grep confirms §2 content removed from 020 and present in the shared reference. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-4 | §4 Project-Local Tool Installation content is removed from 020-go-prohibitions.md and replaced with a mandatory Read-link to 085-project-local-tools.md; the circular back-reference in 085 is de-circularized. | structural | read confirms 020 §4 condensed to a Read-link and 085 no longer references 020 §4. | `.opencode/guidelines/020-go-prohibitions.md`; `.opencode/guidelines/085-project-local-tools.md` |
| SC-5 | The GO-prohibition core (no GO token, no solicitation, no offer-to-edit, no self-authorization, no question-as-authorization, no why-question modification) is retained verbatim in the preloaded 020-go-prohibitions.md. | behavioral | `opencode run` with a self-authorization solicitation prompt; clean-room sub-agent inspects session.yaml for evidence the agent does NOT self-authorize (core retained and enforced). | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-6 | The anti-self-authorization critical-rules enforcement blocks (028, 009, 027) are retained in 020-go-prohibitions.md. | structural | read confirms critical-rules-028/009/027 blocks remain in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-7 | The context-discipline critical-rules enforcement blocks (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) are relocated to the shared reference or converted to Read-links — none are lost. | structural | read/grep confirms each context-discipline enforcement block is either in the shared reference or a Read-link in 020; no block is silently deleted. | `.opencode/guidelines/020-go-prohibitions.md`; `.opencode/reference/orchestrator-context-discipline.md` |
| SC-8 | The preloaded token burden of 020-go-prohibitions.md is reduced (issue Impact target ~11.9k token savings). | structural | byte/line count of 020-go-prohibitions.md after condensation is substantially reduced (target < ~50% of original 53,468 bytes). | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-9 | Consuming skill cards (approval-gate, mcp-tool-usage, skill-creator, and any other card referencing §1.1) load the shared context-discipline reference via mandatory Read-link. | structural | read/grep confirms each consuming card's Cross-References section has a mandatory Read-link to orchestrator-context-discipline.md. | `.opencode/skills/approval-gate/SKILL.md`; `.opencode/skills/mcp-tool-usage/SKILL.md`; `.opencode/skills/skill-creator/SKILL.md` |

## 4. Requirements

- R-1. The system SHALL remove §1.1 Orchestrator Context Discipline content from 020-go-prohibitions.md and SHALL replace it with a mandatory `Read [Text](path)` link to `reference/orchestrator-context-discipline.md`.
- R-2. The system SHALL remove §1.6 Discussion Mode Mandates content from 020-go-prohibitions.md and SHALL relocate it to a shared reference loaded via mandatory `Read [Text](path)` link from the brainstorming skill.
- R-3. The system SHALL remove §2 Iterative Feedback & Plan Revision prose from 020-go-prohibitions.md and SHALL relocate it to a shared plan-revision reference.
- R-4. The system SHALL condense §4 Project-Local Tool Installation content in 020-go-prohibitions.md to a mandatory `Read [Text](path)` link to 085-project-local-tools.md, and SHALL de-circularize the back-reference in 085-project-local-tools.md.
- R-5. The system SHALL retain the GO-prohibition core (§1) verbatim in the preloaded 020-go-prohibitions.md.
- R-6. The system SHALL retain the anti-self-authorization critical-rules enforcement blocks (028, 009, 027) in 020-go-prohibitions.md.
- R-7. The system SHALL relocate or Read-link every context-discipline critical-rules enforcement block (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) so that none is lost.
- R-8. The system SHALL reduce the preloaded token burden of 020-go-prohibitions.md to substantially below its original 53,468 bytes.
- R-9. The system SHALL add mandatory `Read [Text](path)` links to `reference/orchestrator-context-discipline.md` in the Cross-References section of each consuming skill card (approval-gate, mcp-tool-usage, skill-creator, and any other card referencing §1.1).

## 5. Items

### Item 1 (SC-1): Remove §1.1 Orchestrator Context Discipline from 020, replace with Read-link

- RED: `opencode run` with a context-discipline routing prompt — assert the agent does NOT load orchestrator-context-discipline.md via Read-link and §1.1 prose is still present in 020.
- GREEN: Remove §1.1 prose (lines 84-250) from 020-go-prohibitions.md and replace with a mandatory Read-link to reference/orchestrator-context-discipline.md.
- verify: `opencode run` behavioral test — assert the agent loads the shared reference via Read-link and 020 no longer contains §1.1 prose.
- commit: `guidelines/020-go-prohibitions.md`

### Item 2 (SC-2): Remove §1.6 Discussion Mode Mandates from 020, relocate to shared reference

- RED: `opencode run` with a discussion-mode prompt — assert the brainstorming skill does NOT load the discussion-mandates reference and §1.6 prose is still in 020.
- GREEN: Remove §1.6 prose (lines 252-278) from 020-go-prohibitions.md and add a mandatory Read-link to the discussion-mandates reference in the brainstorming skill's Cross-References section.
- verify: `opencode run` behavioral test — assert the brainstorming skill loads the discussion-mandates reference and 020 no longer contains §1.6 prose.
- commit: `guidelines/020-go-prohibitions.md`, `skills/brainstorming/SKILL.md`

### Item 3 (SC-3): Remove §2 Iterative Feedback & Plan Revision prose from 020, relocate to shared reference

- RED: read confirms §2 prose still present in 020.
- GREEN: Remove §2 prose (lines 280-286) from 020-go-prohibitions.md and relocate to the shared plan-revision reference.
- verify: read/grep confirms §2 removed from 020 and present in the shared reference.
- commit: `guidelines/020-go-prohibitions.md`

### Item 4 (SC-4): Condense §4 Project-Local Tool Installation to Read-link, de-circularize 085

- RED: read confirms §4 prose still present in 020 and 085 still references 020 §4.
- GREEN: Condense §4 (lines 290-303) to a mandatory Read-link to 085-project-local-tools.md; de-circularize the back-reference in 085.
- verify: read confirms 020 §4 condensed to a Read-link and 085 no longer references 020 §4.
- commit: `guidelines/020-go-prohibitions.md`, `guidelines/085-project-local-tools.md`

### Item 5 (SC-5): Verify GO-prohibition core retained verbatim

- RED: `opencode run` with a self-authorization solicitation prompt — assert the agent self-authorizes (core absent).
- GREEN: Confirm the GO-prohibition core (§1, lines 9-79) remains verbatim in 020 after condensation.
- verify: `opencode run` behavioral test — assert the agent does NOT self-authorize (core retained and enforced).
- commit: `guidelines/020-go-prohibitions.md`

### Item 6 (SC-6): Verify anti-self-auth critical-rules blocks retained

- RED: read confirms critical-rules-028/009/027 blocks absent from 020.
- GREEN: Confirm critical-rules-028/009/027 blocks remain in 020-go-prohibitions.md.
- verify: read confirms the blocks remain in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 7 (SC-7): Relocate or Read-link context-discipline critical-rules blocks

- RED: read/grep confirms one or more context-discipline blocks (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) missing from both 020 and the shared reference.
- GREEN: Relocate each context-discipline enforcement block to the shared reference or convert to a Read-link in 020.
- verify: read/grep confirms every block is either in the shared reference or a Read-link in 020; none silently deleted.
- commit: `guidelines/020-go-prohibitions.md`, `reference/orchestrator-context-discipline.md`

### Item 8 (SC-8): Measure post-condensation token burden

- RED: byte/line count of 020 after condensation is not substantially reduced.
- GREEN: Confirm the post-condensation 020-go-prohibitions.md is substantially reduced (target < ~50% of original 53,468 bytes).
- verify: byte/line count confirms substantial reduction.
- commit: `guidelines/020-go-prohibitions.md`

### Item 9 (SC-9): Add mandatory Read-links in consuming skill cards

- RED: read/grep confirms a consuming card's Cross-References section lacks a Read-link to orchestrator-context-discipline.md.
- GREEN: Add mandatory Read-links to orchestrator-context-discipline.md in the Cross-References section of approval-gate, mcp-tool-usage, skill-creator, and any other card referencing §1.1.
- verify: read/grep confirms each consuming card has a mandatory Read-link to orchestrator-context-discipline.md.
- commit: `skills/approval-gate/SKILL.md`, `skills/mcp-tool-usage/SKILL.md`, `skills/skill-creator/SKILL.md`

## 6. Dependencies

- **#2359** (orchestrator-context-discipline.md reference) — creates `reference/orchestrator-context-discipline.md`, the relocation target for §1.1. Relationship: must be merged first — SC-1, SC-7, SC-9 must not land before it. Status: pending (open, [needs-approval, spec-draft]).
- **#2358** (discussion-mode-mandates reference) — provides the shared reference for §1.6. Relationship: must exist before SC-2. Status: pending.
- **#2366** (approval-gate skill update) — related consuming-card update. Relationship: related to SC-9. Status: pending.
- **#2364** (mcp-tool-usage skill update) — related consuming-card update. Relationship: related to SC-9. Status: pending.
- **guidelines/085-project-local-tools.md** — the canonical project-local tool rules reference; relocation target for §4. Relationship: must be read before SC-4's de-circularization. Status: satisfied (exists).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 3 |
| R-5 | SC-5 | Phase 4 |
| R-6 | SC-6 | Phase 4 |
| R-7 | SC-7 | Phase 1 |
| R-8 | SC-8 | Phase 4 |
| R-9 | SC-9 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 020-go-prohibitions.md | code | `.opencode/guidelines/020-go-prohibitions.md` | read (section inventory, lines 9-303, 307-531) |
| orchestrator-context-discipline.md | code | `.opencode/reference/orchestrator-context-discipline.md` | read (does not exist yet; created by #2359) |
| 085-project-local-tools.md | code | `.opencode/guidelines/085-project-local-tools.md` | read (back-reference to 020 §4 at lines 14, 50) |
| approval-gate/SKILL.md | code | `.opencode/skills/approval-gate/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| mcp-tool-usage/SKILL.md | code | `.opencode/skills/mcp-tool-usage/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| skill-creator/SKILL.md | code | `.opencode/skills/skill-creator/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| brainstorming/SKILL.md | code | `.opencode/skills/brainstorming/SKILL.md` | read (Cross-References section) |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | read (instructions array line 81) |
| cross-reference-form-comparison.md | doc | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read (conf 0.95 — Read-link 100% Tier 1 access) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the behavioral test costs minutes of execution time. Skipping means the context-discipline rules silently vanish from agent context and the condensation ships with §1.1 prose still preloaded — a token-burden defect that costs 1000× more to fix downstream.
- **SC-2:** Running the behavioral test costs minutes of execution time. Skipping means the discussion-mode mandates are lost from the brainstorming workflow — a behavioral defect that ships to production and costs 1000× more to fix.
- **SC-3:** Verifying the §2 relocation costs one read/grep. Skipping means the plan-revision prose is silently deleted rather than relocated — a content-loss defect caught only when an agent fails to follow plan-revision rules.
- **SC-4:** Verifying the §4 condensation and de-circularization costs one read. Skipping means the project-local tool rules are lost or a circular reference remains — a structural defect that surfaces at the next tool-installation decision.
- **SC-5:** Running the behavioral test costs minutes of execution time. Skipping means the GO-prohibition core is accidentally weakened and agents self-authorize — a safety-critical defect that costs 1000× more to fix.
- **SC-6:** Verifying the anti-self-auth blocks remain costs one read. Skipping means an anti-self-authorization enforcement block is silently lost — a structural defect that weakens the safety-critical core.
- **SC-7:** Verifying each context-discipline block is relocated or Read-linked costs one read/grep. Skipping means a context-discipline rule is silently deleted — a content-loss defect that compounds across every consuming card.
- **SC-8:** Measuring the post-condensation burden costs one byte/line count. Skipping means the condensation ships without confirming the token-burden reduction target was met — a structural defect that defeats the issue's purpose.
- **SC-9:** Verifying each consuming card's Read-link costs one read/grep. Skipping means a consuming card omits the shared-reference Read-link and its context-discipline rules are lost from that card's context — a structural defect that compounds across the skill deck.

## 11. Edge Cases

- **Condition:** #2359 (orchestrator-context-discipline.md) has not merged when SC-1/SC-7/SC-9 begin.
  - **Expected behavior:** Implementation MUST NOT land SC-1/SC-7/SC-9 before the shared reference exists.
  - **Resolution:** Declared as an upstream dependency (BLOCKER-1); the pipeline waits for #2359 before Phase 1.
- **Condition:** The discussion-mandates shared reference (for §1.6) does not exist.
  - **Expected behavior:** SC-2 must not land without its canonical home.
  - **Resolution:** Declared as BLOCKER-2; the reference is created by this issue or a companion before SC-2.
- **Condition:** A consuming skill card omits the mandatory Read-link.
  - **Expected behavior:** The context-discipline rules are lost from that card's context.
  - **Resolution:** SC-9 verifies every consuming card has the Read-link; a missing link is a FAIL.
- **Condition:** The GO-prohibition core is accidentally modified during condensation.
  - **Expected behavior:** The core must remain verbatim.
  - **Resolution:** SC-5 (behavioral) and SC-6 (structural) verify retention; any modification is a FAIL.
- **Condition:** The 085 back-reference to 020 §4 is not de-circularized.
  - **Expected behavior:** A circular reference remains between 085 and 020.
  - **Resolution:** SC-4 verifies the back-reference is removed.
- **Condition:** A context-discipline critical-rules block is silently deleted during relocation.
  - **Expected behavior:** No rule is lost.
  - **Resolution:** SC-7 verifies every block is relocated or Read-linked; a missing block is a FAIL.
