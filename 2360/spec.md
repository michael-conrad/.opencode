---
number: 2360
title: '[SPEC] Create shared ref: attribution-provenance.md'
status: open
labels: [needs-approval, spec-draft]
---

> **Full spec and artifacts: [`.opencode/.issues/2360/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2360)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2360/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Create shared reference attribution-provenance.md

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The AI Co-Authored Attribution and Provenance Headers sections of `.opencode/guidelines/080-code-standards.md` are consumed by three skill cards (skill-creator, spec-creation, issue-operations-comments) that currently rely on 080 being preloaded in the opencode.jsonc instructions array. This couples attribution/provenance standards to a single preloaded guideline and prevents 080 condensation. |
| 2 | **Root Cause / Motivation** | Attribution and provenance standards are duplicated across the consuming cards' reliance on 080 preload rather than being a single canonical reference. Extracting them into a shared reference enables 080 condensation and gives consuming cards a direct, explicit dependency. |
| 3 | **Approach Chosen** | Create `.opencode/reference/attribution-provenance.md` as a shared canonical reference containing the extracted AI Co-Authored Attribution and Provenance Headers content from 080-code-standards.md. Add mandatory Read-links to the three consuming skill cards. Condense 080 by replacing the extracted sections with a Read-link to the shared reference. |
| 4 | **Alternatives Considered & Why Discarded** | **Re-inline attribution/provenance content into each consuming card** — discarded because it duplicates content across three cards, creating drift risk and violating the Read [Text](path) dynamic-loading pattern mandated by task-card-structure-standards.md §7. |
| 5 | **Key Design Decisions** | (1) The shared reference follows the existing `.opencode/reference/` file format (SPDX + Provenance headers, Co-authored with AI byline). (2) All consumers use the Read [Text](path) pattern — no inline copies. (3) The co-author attribution requirement is preserved verbatim in the reference. |
| 6 | **User Intent / Original Prompt** | Create a shared reference document `attribution-provenance.md` consolidating the attribution/byline and provenance-header sections currently in 080-code-standards.md, enabling 080 condensation. |

## 2. Not Included

- **[Re-inlining attribution/provenance into consuming cards]** — Explicitly out of scope. Consuming cards reference the shared reference via Read-link, never inline copies.
- **[Modifying opencode.jsonc]** — The preload of 080 (line 86) is not changed by this spec; the condensed 080 still loads, but attribution content now lives in the reference.
- **[Modifying skill-creator task files or validate_skill_cards.py]** — Related paths (validate.md, operating-protocol.md, validate_skill_cards.py) are noted as consumers but not modified by this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/reference/attribution-provenance.md` exists and contains the extracted AI Co-Authored Attribution and Provenance Headers content from 080-code-standards.md, following the reference file format (SPDX + Provenance headers, Co-authored with AI byline) | structural | File existence + content inspection against 080-code-standards.md source sections |
| SC-2 | `skill-creator/SKILL.md` contains a `Read [Text](.opencode/reference/attribution-provenance.md)` link in its Cross-References section | structural | Grep skill-creator/SKILL.md for the Read-link |
| SC-3 | `spec-creation/SKILL.md` contains a `Read [Text](.opencode/reference/attribution-provenance.md)` link in its Cross-References section | structural | Grep spec-creation/SKILL.md for the Read-link |
| SC-4 | `issue-operations-comments/SKILL.md` contains a `Read [Text](.opencode/reference/attribution-provenance.md)` link in its Cross-References section | structural | Grep issue-operations-comments/SKILL.md for the Read-link |
| SC-5 | `080-code-standards.md` has the AI Co-Authored Attribution and Provenance Headers sections replaced with a Read-link to attribution-provenance.md, with no content loss | structural | Inspect 080-code-standards.md for the Read-link and confirm extracted content is preserved in the reference |

## 4. Requirements

- R-1. The system SHALL create `.opencode/reference/attribution-provenance.md` as a shared canonical reference.
- R-2. The system SHALL extract the AI Co-Authored Attribution and Provenance Headers sections from 080-code-standards.md into the shared reference.
- R-3. The system SHALL add mandatory Read-links to the consuming skill cards (skill-creator, spec-creation, issue-operations-comments).
- R-4. The system SHALL NOT re-inline the attribution/provenance content into each consuming card.
- R-5. The system SHALL preserve the co-author attribution requirement in the shared reference.
- R-6. The system SHALL enable 080-code-standards.md condensation by replacing the extracted sections with a Read-link.
- R-7. The shared reference SHALL follow the existing `.opencode/reference/` file format conventions (SPDX + Provenance headers, Co-authored with AI byline).
- R-8. The shared reference SHALL be consumed via the Read [Text](path) pattern per task-card-structure-standards.md §7 Dynamic Loading.

## 5. Items

### Item 1 (SC-1): Create attribution-provenance.md reference

- RED: Assert `.opencode/reference/attribution-provenance.md` does not exist
- GREEN: Create the reference with extracted attribution/provenance content following the reference file format
- verify: File exists + content inspection against 080 source sections
- commit: `.opencode/reference/attribution-provenance.md`

### Item 2 (SC-2): Add Read-link to skill-creator/SKILL.md

- RED: Assert skill-creator/SKILL.md lacks the Read-link
- GREEN: Add `Read [Text](.opencode/reference/attribution-provenance.md)` to Cross-References
- verify: Grep skill-creator/SKILL.md for the Read-link
- commit: `.opencode/skills/skill-creator/SKILL.md`

### Item 3 (SC-3): Add Read-link to spec-creation/SKILL.md

- RED: Assert spec-creation/SKILL.md lacks the Read-link
- GREEN: Add `Read [Text](.opencode/reference/attribution-provenance.md)` to Cross-References
- verify: Grep spec-creation/SKILL.md for the Read-link
- commit: `.opencode/skills/spec-creation/SKILL.md`

### Item 4 (SC-4): Add Read-link to issue-operations-comments/SKILL.md

- RED: Assert issue-operations-comments/SKILL.md lacks the Read-link
- GREEN: Add `Read [Text](.opencode/reference/attribution-provenance.md)` to Cross-References
- verify: Grep issue-operations-comments/SKILL.md for the Read-link
- commit: `.opencode/skills/issue-operations-comments/SKILL.md`

### Item 5 (SC-5): Condense 080-code-standards.md

- RED: Assert 080-code-standards.md still contains the inline attribution/provenance sections
- GREEN: Replace the AI Co-Authored Attribution and Provenance Headers sections with a Read-link to attribution-provenance.md
- verify: Inspect 080-code-standards.md for the Read-link and confirm extracted content is preserved in the reference
- commit: `.opencode/guidelines/080-code-standards.md`

## 6. Dependencies

- **Reference:** `.opencode/reference/` file format conventions (SPDX + Provenance headers, Co-authored with AI byline)
  - **Relationship:** The new reference must follow the established format of the 7 existing reference documents
  - **Status:** Satisfied
- **Reference:** task-card-structure-standards.md §7 Dynamic Loading
  - **Relationship:** Mandates the Read [Text](path) pattern for reference-dependent criteria
  - **Status:** Satisfied
- **Reference:** 080-code-standards.md condensation
  - **Relationship:** The shared reference extraction enables 080 condensation (SC-5 depends on SC-1)
  - **Status:** Pending — this spec implements it

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-2, SC-3, SC-4 | Phase 2 |
| R-4 | SC-2, SC-3, SC-4, SC-5 | Phase 2, Phase 3 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-5 | Phase 3 |
| R-7 | SC-1 | Phase 1 |
| R-8 | SC-2, SC-3, SC-4, SC-5 | Phase 2, Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| 080-code-standards.md AI Co-Authored Attribution section | code | `.opencode/guidelines/080-code-standards.md` lines 164-349 | read — source content to extract |
| 080-code-standards.md Provenance Headers section | code | `.opencode/guidelines/080-code-standards.md` lines 351-437 | read — source content to extract |
| skill-creator/SKILL.md | code | `.opencode/skills/skill-creator/SKILL.md` | read — consuming card |
| spec-creation/SKILL.md | code | `.opencode/skills/spec-creation/SKILL.md` | read — consuming card |
| issue-operations-comments/SKILL.md | code | `.opencode/skills/issue-operations-comments/SKILL.md` | read — consuming card |
| task-card-structure-standards.md §7 Dynamic Loading | doc | `.opencode/reference/task-card-structure-standards.md` | read — Read [Text](path) pattern mandate |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the reference file exists and contains the extracted content costs one read call. Skipping means a structurally wrong or incomplete reference isn't caught until the first consuming card fails to load attribution rules.
- SC-2: Verifying the skill-creator Read-link costs one grep search. Skipping means skill-creator loses the co-author attribution requirement, and the risk identified in the spec materializes.
- SC-3: Verifying the spec-creation Read-link costs one grep search. Skipping means spec bodies lose their AI byline requirement.
- SC-4: Verifying the issue-operations-comments Read-link costs one grep search. Skipping means posted content loses byline verification.
- SC-5: Verifying the 080 condensation costs one read of 080-code-standards.md. Skipping means 080 retains duplicated inline content and the condensation goal is not met.

## 11. Edge Cases

- **Input boundaries:** The reference file must contain the full extracted content — no partial extraction. Empty or null content is a failure.
- **State transitions:** Phase 1 (reference created) must complete before Phase 2 (Read-links) and Phase 3 (080 condensation). No transition may occur before the reference exists.
- **Failure modes:** If the co-author attribution requirement is lost during extraction, the reference is defective. If a consuming card does not Read-link the reference, it loses attribution enforcement.
- **Concurrency:** The three consuming-card Read-links (SC-2/3/4) are independent and may be done in any order after SC-1. No shared mutable state.
- **Recovery:** If a Read-link is missing or points to the wrong path, re-add the correct `Read [Text](.opencode/reference/attribution-provenance.md)` link. If 080 condensation loses content, restore the extracted content in the reference and re-verify.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
