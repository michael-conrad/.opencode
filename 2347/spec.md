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
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/020-go-prohibitions.md` guideline costs ~19.8k tokens — the single largest preloaded guideline (~30% of the preloaded burden). Roughly 60% of its content is procedural (orchestrator context discipline §1.1, discussion-mode mandates §1.6, iterative-feedback prose §2, project-local tool install rules §4) rather than safety-critical prohibition rules. |
| 2 | **Root Cause / Motivation** | 020-go-prohibitions.md (533 lines, 53,468 bytes) is preloaded unconditionally via the opencode.jsonc instructions array. Procedural context-management and discussion-mode content accumulated in it over time and duplicates content already present in skill cards (approval-gate, mcp-tool-usage, skill-creator, brainstorming). This duplication inflates the preloaded token burden without adding enforcement value. |
| 3 | **Approach Chosen** | Relocate the procedural sections (§1.1, §1.6, §2, §4) to named shared canonical references loaded via mandatory `Read [Text](path)` links, and retain the GO-prohibition core (§1) plus the anti-self-authorization critical-rules enforcement blocks verbatim in the preloaded 020. Consuming skill cards Read-link the shared references rather than re-inlining content. Each relocated concern maps to exactly one named reference file. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Leave 020 unchanged** — discarded because it preserves the ~19.8k token preloaded burden and the duplication across skill cards. (b) **Re-inline relocated content into each consuming skill card** — discarded because it replaces one duplication with another (per #2359 "Out: Re-inlining the content into each card (duplication avoided)"). (c) **Remove 020 from the preloaded instructions array** — discarded because the GO-prohibition core is safety-critical and must stay preloaded (opencode.jsonc instructions array unchanged). |
| 5 | **Key Design Decisions** | (a) Relocated rules use the canonical `Read [Text](path)` form (validated at 100% Tier 1 access by research card cross-reference-form-comparison.md, conf 0.95) — not "See" or resolution tables. (b) The GO-prohibition core and the procedural context-discipline content are distinct concerns: the core stays preloaded; the procedural content moves to shared references. (c) Each relocated concern maps to exactly one named canonical home, avoiding duplication: §1.1 → `reference/orchestrator-context-discipline.md` (#2359), §1.6 → `reference/discussion-mode-mandates.md` (#2358), §2 → `reference/plan-revision.md` (this issue or a companion), §4 → `guidelines/085-project-local-tools.md` (existing). (d) 020-go-prohibitions.md remains in the opencode.jsonc instructions array — only its content shrinks. |
| 6 | **User Intent / Original Prompt** | Condense the preloaded `020-go-prohibitions.md` guideline by moving context-discipline and discussion-mode mandates to shared references, retaining the GO-prohibition core. |

## 2. Not Included

- **Creating `reference/orchestrator-context-discipline.md`** — that is #2359's scope; this issue consumes it, it does not create it.
- **Creating `reference/discussion-mode-mandates.md`** — that is #2358's scope; this issue consumes it, it does not create it.
- **Parent-repo (opencode-config) AGENTS.md or config changes** — all changes are confined to `.opencode/` files (REQ-C3).
- **Removing any anti-self-authorization core** — the GO-prohibition core and anti-self-auth enforcement blocks are retained verbatim (REQ-N1, REQ-N4).
- **Re-inlining relocated content into consuming skill cards** — duplication is avoided (REQ-N2).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1a | §1.1 Orchestrator Context Discipline content is removed from the preloaded 020-go-prohibitions.md. | structural | read/grep confirms §1.1 prose is no longer present in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-1b | §1.1 Orchestrator Context Discipline content is present in reference/orchestrator-context-discipline.md. | structural | read confirms §1.1 content exists in the reference file. | `.opencode/reference/orchestrator-context-discipline.md` (created by #2359) |
| SC-1c | 020-go-prohibitions.md retains only a mandatory Read-link to reference/orchestrator-context-discipline.md for §1.1. | structural | read confirms 020 §1.1 is condensed to a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-2a | §1.6 Discussion Mode Mandates content is removed from 020-go-prohibitions.md. | structural | read/grep confirms §1.6 prose is no longer present in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-2b | §1.6 Discussion Mode Mandates content is present in reference/discussion-mode-mandates.md. | structural | read confirms §1.6 content exists in the reference file. | `.opencode/reference/discussion-mode-mandates.md` (created by #2358) |
| SC-2c | skills/brainstorming/SKILL.md has a mandatory Read-link to reference/discussion-mode-mandates.md. | structural | read confirms the brainstorming card's Cross-References section contains a mandatory `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link. | `.opencode/skills/brainstorming/SKILL.md` |
| SC-3a | §2 Iterative Feedback & Plan Revision prose is removed from 020-go-prohibitions.md. | structural | read/grep confirms §2 prose is no longer present in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-3b | §2 Iterative Feedback & Plan Revision prose is present in reference/plan-revision.md. | structural | read confirms §2 prose exists in the reference file. | `.opencode/reference/plan-revision.md` (created by this issue or a companion) |
| SC-3c | 020-go-prohibitions.md has a mandatory Read-link to reference/plan-revision.md for §2. | structural | read confirms 020 §2 is condensed to a mandatory `Read [Text](.opencode/reference/plan-revision.md)` link. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-4a-1 | §4 Project-Local Tool Installation content is removed from 020-go-prohibitions.md. | structural | read/grep confirms §4 prose is no longer present in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-4a-2 | 020-go-prohibitions.md has a mandatory Read-link to 085-project-local-tools.md for §4. | structural | read confirms 020 §4 is condensed to a mandatory `Read [Text](.opencode/guidelines/085-project-local-tools.md)` link. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-4b | The circular back-reference in 085-project-local-tools.md to 020 §4 is de-circularized. | structural | read confirms 085 no longer references 020 §4. | `.opencode/guidelines/085-project-local-tools.md` |
| SC-5 | The GO-prohibition core (no GO token, no solicitation, no offer-to-edit, no self-authorization, no question-as-authorization, no why-question modification) is retained verbatim in the preloaded 020-go-prohibitions.md. | behavioral | `opencode run` with a self-authorization solicitation prompt; clean-room sub-agent inspects session.yaml for evidence the agent does NOT self-authorize (core retained and enforced). | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-6 | The anti-self-authorization critical-rules enforcement blocks (028, 009, 027) are retained in 020-go-prohibitions.md. | structural | read confirms critical-rules-028/009/027 blocks remain in 020. | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-7 | The context-discipline critical-rules enforcement blocks (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) are relocated to reference/orchestrator-context-discipline.md — none are lost. | structural | read/grep confirms each context-discipline enforcement block is present in the reference file; no block is silently deleted. | `.opencode/reference/orchestrator-context-discipline.md` |
| SC-8 | The preloaded token burden of 020-go-prohibitions.md is reduced to a hard numeric threshold: post-condensation byte count < 26,734 bytes (< 50% of the original 53,468 bytes). | structural | byte count of 020-go-prohibitions.md after condensation is < 26,734 bytes — a binary PASS/FAIL against the hard threshold (no open-ended quality term). | `.opencode/guidelines/020-go-prohibitions.md` |
| SC-9a | skills/approval-gate/SKILL.md has a mandatory Read-link to reference/orchestrator-context-discipline.md. | structural | read/grep confirms the approval-gate card's Cross-References section contains a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link. | `.opencode/skills/approval-gate/SKILL.md` |
| SC-9b | skills/mcp-tool-usage/SKILL.md has a mandatory Read-link to reference/orchestrator-context-discipline.md. | structural | read/grep confirms the mcp-tool-usage card's Cross-References section contains a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link. | `.opencode/skills/mcp-tool-usage/SKILL.md` |
| SC-9c | skills/skill-creator/SKILL.md has a mandatory Read-link to reference/orchestrator-context-discipline.md. | structural | read/grep confirms the skill-creator card's Cross-References section contains a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link. | `.opencode/skills/skill-creator/SKILL.md` |
| SC-9d | skills/brainstorming/SKILL.md has a mandatory Read-link to reference/orchestrator-context-discipline.md. | structural | read/grep confirms the brainstorming card's Cross-References section contains a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link. | `.opencode/skills/brainstorming/SKILL.md` |

## 4. Requirements

- R-1. The system SHALL remove §1.1 Orchestrator Context Discipline content from 020-go-prohibitions.md and SHALL replace it with a mandatory `Read [Text](path)` link to `reference/orchestrator-context-discipline.md`.
- R-2. The system SHALL remove §1.6 Discussion Mode Mandates content from 020-go-prohibitions.md and SHALL relocate it to `reference/discussion-mode-mandates.md`, loaded via mandatory `Read [Text](path)` link from the brainstorming skill.
- R-3. The system SHALL remove §2 Iterative Feedback & Plan Revision prose from 020-go-prohibitions.md and SHALL relocate it to `reference/plan-revision.md`, loaded via mandatory `Read [Text](path)` link.
- R-4. The system SHALL condense §4 Project-Local Tool Installation content in 020-go-prohibitions.md to a mandatory `Read [Text](path)` link to 085-project-local-tools.md, and SHALL de-circularize the back-reference in 085-project-local-tools.md.
- R-5. The system SHALL retain the GO-prohibition core (§1) verbatim in the preloaded 020-go-prohibitions.md.
- R-6. The system SHALL retain the anti-self-authorization critical-rules enforcement blocks (028, 009, 027) in 020-go-prohibitions.md.
- R-7. The system SHALL relocate every context-discipline critical-rules enforcement block (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) to `reference/orchestrator-context-discipline.md` so that none is lost.
- R-8. The system SHALL reduce the preloaded token burden of 020-go-prohibitions.md to a post-condensation byte count below 26,734 bytes (i.e. < 50% of its original 53,468 bytes).
- R-9. The system SHALL add mandatory `Read [Text](path)` links to `reference/orchestrator-context-discipline.md` in the Cross-References section of each consuming skill card: approval-gate, mcp-tool-usage, skill-creator, and brainstorming.

## 5. Items

### Item 1 (SC-1a): Remove §1.1 Orchestrator Context Discipline content from 020

- RED: read confirms §1.1 Orchestrator Context Discipline prose is still present in 020.
- GREEN: Remove §1.1 Orchestrator Context Discipline prose from 020-go-prohibitions.md.
- verify: read confirms §1.1 prose is no longer present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 2 (SC-1b): Confirm §1.1 content present in orchestrator-context-discipline.md

- RED: read confirms §1.1 content is absent from reference/orchestrator-context-discipline.md.
- GREEN: Confirm §1.1 content is present in reference/orchestrator-context-discipline.md (created by #2359).
- verify: read confirms §1.1 content exists in the reference file.
- commit: `reference/orchestrator-context-discipline.md`

### Item 3 (SC-1c): Add mandatory Read-link in 020 to orchestrator-context-discipline.md

- RED: read confirms 020 lacks a mandatory Read-link to reference/orchestrator-context-discipline.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link to 020 for §1.1.
- verify: read confirms the Read-link is present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 4 (SC-2a): Remove §1.6 Discussion Mode Mandates content from 020

- RED: read confirms §1.6 Discussion Mode Mandates prose is still present in 020.
- GREEN: Remove §1.6 Discussion Mode Mandates prose from 020-go-prohibitions.md.
- verify: read confirms §1.6 prose is no longer present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 5 (SC-2b): Confirm §1.6 content present in discussion-mode-mandates.md

- RED: read confirms §1.6 content is absent from reference/discussion-mode-mandates.md.
- GREEN: Confirm §1.6 content is present in reference/discussion-mode-mandates.md (created by #2358).
- verify: read confirms §1.6 content exists in the reference file.
- commit: `reference/discussion-mode-mandates.md`

### Item 6 (SC-2c): Add mandatory Read-link in brainstorming to discussion-mode-mandates.md

- RED: read confirms brainstorming/SKILL.md lacks a mandatory Read-link to reference/discussion-mode-mandates.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/discussion-mode-mandates.md)` link to the brainstorming card's Cross-References section.
- verify: read confirms the Read-link is present in the brainstorming card.
- commit: `skills/brainstorming/SKILL.md`

### Item 7 (SC-3a): Remove §2 Iterative Feedback & Plan Revision prose from 020

- RED: read confirms §2 prose is still present in 020.
- GREEN: Remove §2 Iterative Feedback & Plan Revision prose from 020-go-prohibitions.md.
- verify: read confirms §2 prose is no longer present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 8 (SC-3b): Confirm §2 prose present in plan-revision.md

- RED: read confirms §2 prose is absent from reference/plan-revision.md.
- GREEN: Confirm §2 prose is present in reference/plan-revision.md (created by this issue or a companion).
- verify: read confirms §2 prose exists in the reference file.
- commit: `reference/plan-revision.md`

### Item 9 (SC-3c): Add mandatory Read-link in 020 to plan-revision.md

- RED: read confirms 020 lacks a mandatory Read-link to reference/plan-revision.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/plan-revision.md)` link to 020 for §2.
- verify: read confirms the Read-link is present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 10 (SC-4a-1): Remove §4 Project-Local Tool Installation content from 020

- RED: read confirms §4 Project-Local Tool Installation prose is still present in 020.
- GREEN: Remove §4 Project-Local Tool Installation prose from 020-go-prohibitions.md.
- verify: read confirms §4 prose is no longer present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 11 (SC-4a-2): Add mandatory Read-link in 020 to 085-project-local-tools.md

- RED: read confirms 020 lacks a mandatory Read-link to 085-project-local-tools.md.
- GREEN: Add a mandatory `Read [Text](.opencode/guidelines/085-project-local-tools.md)` link to 020 for §4.
- verify: read confirms the Read-link is present in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 12 (SC-4b): De-circularize the 085 back-reference to 020 §4

- RED: read confirms 085-project-local-tools.md still references 020 §4.
- GREEN: De-circularize the back-reference in 085-project-local-tools.md so it no longer points to 020 §4.
- verify: read confirms 085 no longer references 020 §4.
- commit: `guidelines/085-project-local-tools.md`

### Item 13 (SC-5): Verify GO-prohibition core retained verbatim

- RED: `opencode run` with a self-authorization solicitation prompt — assert the agent self-authorizes (core absent).
- GREEN: Confirm the GO-prohibition core (§1) remains verbatim in 020 after condensation.
- verify: `opencode run` behavioral test — assert the agent does NOT self-authorize (core retained and enforced).
- commit: `guidelines/020-go-prohibitions.md`

### Item 14 (SC-6): Verify anti-self-auth critical-rules blocks retained

- RED: read confirms critical-rules-028/009/027 blocks absent from 020.
- GREEN: Confirm critical-rules-028/009/027 blocks remain in 020-go-prohibitions.md.
- verify: read confirms the blocks remain in 020.
- commit: `guidelines/020-go-prohibitions.md`

### Item 15 (SC-7): Relocate context-discipline critical-rules blocks to orchestrator-context-discipline.md

- RED: read/grep confirms one or more context-discipline blocks (034, 035, 042, 048, 044, 043, 063, 065, 066, 071, 072, dispatch-gate-canonical) missing from reference/orchestrator-context-discipline.md.
- GREEN: Relocate each context-discipline enforcement block to reference/orchestrator-context-discipline.md.
- verify: read/grep confirms every block is present in the reference file; none silently deleted.
- commit: `guidelines/020-go-prohibitions.md`, `reference/orchestrator-context-discipline.md`

### Item 16 (SC-8): Measure post-condensation token burden

- RED: byte count of 020 after condensation is not < 26,734 bytes.
- GREEN: Confirm the post-condensation 020-go-prohibitions.md byte count is < 26,734 bytes (< 50% of the original 53,468 bytes).
- verify: byte count confirms 020 is < 26,734 bytes (binary PASS/FAIL against the hard threshold).
- commit: `guidelines/020-go-prohibitions.md`

### Item 17 (SC-9a): Add mandatory Read-link in approval-gate to orchestrator-context-discipline.md

- RED: read/grep confirms approval-gate/SKILL.md lacks a mandatory Read-link to reference/orchestrator-context-discipline.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link to the approval-gate card's Cross-References section.
- verify: read/grep confirms the Read-link is present in the approval-gate card.
- commit: `skills/approval-gate/SKILL.md`

### Item 18 (SC-9b): Add mandatory Read-link in mcp-tool-usage to orchestrator-context-discipline.md

- RED: read/grep confirms mcp-tool-usage/SKILL.md lacks a mandatory Read-link to reference/orchestrator-context-discipline.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link to the mcp-tool-usage card's Cross-References section.
- verify: read/grep confirms the Read-link is present in the mcp-tool-usage card.
- commit: `skills/mcp-tool-usage/SKILL.md`

### Item 19 (SC-9c): Add mandatory Read-link in skill-creator to orchestrator-context-discipline.md

- RED: read/grep confirms skill-creator/SKILL.md lacks a mandatory Read-link to reference/orchestrator-context-discipline.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link to the skill-creator card's Cross-References section.
- verify: read/grep confirms the Read-link is present in the skill-creator card.
- commit: `skills/skill-creator/SKILL.md`

### Item 20 (SC-9d): Add mandatory Read-link in brainstorming to orchestrator-context-discipline.md

- RED: read/grep confirms brainstorming/SKILL.md lacks a mandatory Read-link to reference/orchestrator-context-discipline.md.
- GREEN: Add a mandatory `Read [Text](.opencode/reference/orchestrator-context-discipline.md)` link to the brainstorming card's Cross-References section.
- verify: read/grep confirms the Read-link is present in the brainstorming card.
- commit: `skills/brainstorming/SKILL.md`

## 6. Dependencies

- **#2359** (orchestrator-context-discipline.md reference) — creates `reference/orchestrator-context-discipline.md`, the relocation target for §1.1 and the context-discipline blocks. Relationship: must be merged first — SC-1b, SC-1c, SC-7, SC-9a/9b/9c/9d must not land before it. Status: pending (open, [needs-approval, spec-draft]).
- **#2358** (discussion-mode-mandates reference) — creates `reference/discussion-mode-mandates.md`, the relocation target for §1.6. Relationship: must exist before SC-2b and SC-2c. Status: pending.
- **reference/plan-revision.md** — the relocation target for §2. Relationship: must exist before SC-3b and SC-3c. Status: pending — created by this issue or a companion issue (BLOCKER-3).
- **#2366** (approval-gate skill update) — related consuming-card update. Relationship: related to SC-9a. Status: pending.
- **#2364** (mcp-tool-usage skill update) — related consuming-card update. Relationship: related to SC-9b. Status: pending.
- **guidelines/085-project-local-tools.md** — the canonical project-local tool rules reference; relocation target for §4. Relationship: must be read before SC-4a-2 and SC-4b's de-circularization. Status: satisfied (exists).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a, SC-1b, SC-1c | Phase 1 |
| R-2 | SC-2a, SC-2b, SC-2c | Phase 2 |
| R-3 | SC-3a, SC-3b, SC-3c | Phase 3 |
| R-4 | SC-4a-1, SC-4a-2, SC-4b | Phase 3 |
| R-5 | SC-5 | Phase 4 |
| R-6 | SC-6 | Phase 4 |
| R-7 | SC-7 | Phase 1 |
| R-8 | SC-8 | Phase 4 |
| R-9 | SC-9a, SC-9b, SC-9c, SC-9d | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| 020-go-prohibitions.md | code | `.opencode/guidelines/020-go-prohibitions.md` | read (section inventory) |
| orchestrator-context-discipline.md | code | `.opencode/reference/orchestrator-context-discipline.md` | read (does not exist yet; created by #2359) |
| discussion-mode-mandates.md | code | `.opencode/reference/discussion-mode-mandates.md` | read (does not exist yet; created by #2358) |
| plan-revision.md | code | `.opencode/reference/plan-revision.md` | read (does not exist yet; created by this issue or a companion) |
| 085-project-local-tools.md | code | `.opencode/guidelines/085-project-local-tools.md` | read (back-reference to 020 §4) |
| approval-gate/SKILL.md | code | `.opencode/skills/approval-gate/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| mcp-tool-usage/SKILL.md | code | `.opencode/skills/mcp-tool-usage/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| skill-creator/SKILL.md | code | `.opencode/skills/skill-creator/SKILL.md` | read (DISPATCH_GATE, context-cost frame) |
| brainstorming/SKILL.md | code | `.opencode/skills/brainstorming/SKILL.md` | read (Cross-References section, DISPATCH_GATE) |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | read (instructions array) |
| cross-reference-form-comparison.md | doc | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read (conf 0.95 — Read-link 100% Tier 1 access) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a/SC-1b/SC-1c:** Verifying the §1.1 removal, presence in the reference, and the Read-link costs one read/grep each. Skipping means the context-discipline rules silently vanish from agent context and the condensation ships with §1.1 prose still preloaded — a token-burden defect that costs 1000× more to fix downstream.
- **SC-2a/SC-2b/SC-2c:** Verifying the §1.6 removal, presence in the reference, and the brainstorming Read-link costs one read/grep each. Skipping means the discussion-mode mandates are lost from the brainstorming workflow — a behavioral defect that ships to production and costs 1000× more to fix.
- **SC-3a/SC-3b/SC-3c:** Verifying the §2 removal, presence in the reference, and the Read-link costs one read/grep each. Skipping means the plan-revision prose is silently deleted rather than relocated — a content-loss defect caught only when an agent fails to follow plan-revision rules.
- **SC-4a-1/SC-4a-2:** Verifying the §4 removal and the Read-link costs one read each. Skipping means the project-local tool rules are lost — a structural defect that surfaces at the next tool-installation decision.
- **SC-4b:** Verifying the de-circularization costs one read. Skipping means a circular reference remains between 085 and 020 — a structural defect that surfaces at the next tool-installation decision.
- **SC-5:** Running the behavioral test costs minutes of execution time. Skipping means the GO-prohibition core is accidentally weakened and agents self-authorize — a safety-critical defect that costs 1000× more to fix.
- **SC-6:** Verifying the anti-self-auth blocks remain costs one read. Skipping means an anti-self-authorization enforcement block is silently lost — a structural defect that weakens the safety-critical core.
- **SC-7:** Verifying each context-discipline block is present in the reference costs one read/grep. Skipping means a context-discipline rule is silently deleted — a content-loss defect that compounds across every consuming card.
- **SC-8:** Measuring the post-condensation burden costs one byte count. Skipping means the condensation ships without confirming the hard threshold (post-condensation < 26,734 bytes, < 50% of the original 53,468 bytes) was met — a structural defect that defeats the issue's purpose.
- **SC-9a/SC-9b/SC-9c/SC-9d:** Verifying each consuming card's Read-link costs one read/grep each. Skipping means a consuming card omits the shared-reference Read-link and its context-discipline rules are lost from that card's context — a structural defect that compounds across the skill deck.

## 11. Edge Cases

- **Condition:** #2359 (orchestrator-context-discipline.md) has not merged when SC-1b/SC-1c/SC-7/SC-9 begin.
  - **Expected behavior:** Implementation MUST NOT land SC-1b/SC-1c/SC-7/SC-9 before the shared reference exists.
  - **Resolution:** Declared as an upstream dependency (BLOCKER-1); the pipeline waits for #2359 before Phase 1.
- **Condition:** The discussion-mandates shared reference (#2358) for §1.6 does not exist.
  - **Expected behavior:** SC-2b and SC-2c must not land without their canonical home.
  - **Resolution:** Declared as BLOCKER-2; the reference is created by #2358 before SC-2.
- **Condition:** The plan-revision shared reference (reference/plan-revision.md) for §2 does not exist.
  - **Expected behavior:** SC-3b and SC-3c must not land without their canonical home.
  - **Resolution:** Declared as BLOCKER-3; the reference is created by this issue or a companion before SC-3.
- **Condition:** A consuming skill card omits the mandatory Read-link.
  - **Expected behavior:** The context-discipline rules are lost from that card's context.
  - **Resolution:** SC-9a/9b/9c/9d verify every consuming card (approval-gate, mcp-tool-usage, skill-creator, brainstorming) has the Read-link; a missing link is a FAIL.
- **Condition:** The GO-prohibition core is accidentally modified during condensation.
  - **Expected behavior:** The core must remain verbatim.
  - **Resolution:** SC-5 (behavioral) and SC-6 (structural) verify retention; any modification is a FAIL.
- **Condition:** The 085 back-reference to 020 §4 is not de-circularized.
  - **Expected behavior:** A circular reference remains between 085 and 020.
  - **Resolution:** SC-4b verifies the back-reference is removed.
- **Condition:** A context-discipline critical-rules block is silently deleted during relocation.
  - **Expected behavior:** No rule is lost.
  - **Resolution:** SC-7 verifies every block is present in the reference; a missing block is a FAIL.

- **Condition:** The post-condensation 020-go-prohibitions.md byte count does not fall below the hard threshold (≥ 26,734 bytes, i.e. ≥ 50% of the original 53,468 bytes).
  - **Expected behavior:** The token-burden reduction target is not met.
  - **Resolution:** SC-8 verifies the byte count is < 26,734 bytes as a binary PASS/FAIL; a count at or above the threshold is a FAIL, regardless of how "substantially" the file appears reduced.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-28 | Removed exact line-range references from the Items section (Items 1-3, 6) and Documentation Sources, replacing them with stable section/heading references; decomposed SC-4 into SC-4a (condense §4) and SC-4b (de-circularize 085), each with its own item/RED-GREEN cycle; updated Traceability, Cost Frame, Edge Cases, Dependencies, and sc-summary.yaml to match. | Validation findings: (1) prescriptive content — exact line numbers are forbidden per spec-structure-standards §Prohibited Content Patterns; (2) SC-4 is a compound SC bundling two distinct deliverables/verification targets. | spec-creation revise pipeline |
| 2026-08-28 | Decomposed SC-1/SC-2/SC-3/SC-4a into atomic SCs (content-removed, content-present, Read-link-present) per the remove+relocate "and" compound defect; unified SC-2's §1.6 target to the named `reference/discussion-mode-mandates.md` from #2358 across criterion/dependency/item; named SC-3's §2 target as `reference/plan-revision.md` and declared its dependency (BLOCKER-3); pinned SC-7 to a single mechanism (relocate to `reference/orchestrator-context-discipline.md`) removing the disjunctive "or"; enumerated SC-9's consuming cards to the exact set (approval-gate, mcp-tool-usage, skill-creator, brainstorming) and split into single-deliverable SC-9a/9b/9c/9d; updated Items (1:1 item-SC mapping, 20 items), Traceability, Cost Frame, Edge Cases, Dependencies, sc-summary.yaml, and regenerated the analytical artifacts directory. | Validation findings: Aggregate FAIL on determinism, compound-SC, and decomposition — (1) unnamed SC-3 relocation target; (2) inconsistent SC-2 target naming; (3) SC-7 disjunctive escape hatch; (4) SC-9 open-ended escape hatch; (5) SC-1/2/3/4a compound remove+relocate; (6) SC-2/SC-9 span multiple deliverables. | spec-creation revise pipeline |
| 2026-08-28 | Pinned SC-8 to a hard numeric threshold: post-condensation byte count < 26,734 bytes (< 50% of the original 53,468 bytes). Replaced the open-ended quality term "substantially reduced" and soft threshold "target < ~50%" in the SC-8 criterion and verification method with the binary PASS/FAIL threshold; updated R-8, Item 16 (RED/GREEN/verify), Cost Frame, and added an SC-8 Edge Case; updated sc-summary.yaml SC-8 description. | Validation findings: Aggregate FAIL on determinism/binary-verifiability — SC-8 used "substantially reduced" (open-ended quality term) and "target < ~50%" (soft/approximate threshold), so the token-burden reduction SC could not be verified as a clean binary PASS/FAIL. | spec-creation revise pipeline |
