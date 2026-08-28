> **Full spec and artifacts: [`.issues/2369/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2369)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/2369/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Update programming-principles skill — Read-link code-standards-shared

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The `programming-principles` skill card (`.opencode/skills/programming-principles/SKILL.md`) is a declared consumer of both `code-standards-shared.md` and `data-integrity-shared.md` (listed in sibling specs #2362 and #2363), yet it has no Read [Text](path) links to either shared reference. Sub-agents dispatched to its tasks currently rely solely on 080/090 preload in the opencode.jsonc instructions array. |
| 2 | **Root Cause / Motivation** | The Read-Link Cross-Reference Rule in AGENTS.md mandates the `Read [Text](path)` pattern as the only reliable cross-reference form (100% Tier 1 access rate vs 42-58% for resolution-table forms, per `cross-reference-form-comparison` research card, confidence 0.95). Without the mandatory Read-links, sub-agents treat the shared references as informational and do not load them, losing access to the procedural content that moved to the shared references. |
| 3 | **Approach Chosen** | Add a `## Cross-References` section to the `programming-principles` SKILL.md containing two mandatory `Read [Text](path)` links — one to `reference/code-standards-shared.md` and one to `reference/data-integrity-shared.md` — replicating the canonical link text and structure already present in `engineering-approach/SKILL.md` `## Cross-References`. |
| 4 | **Alternatives Considered & Why Discarded** | **Resolution-table cross-reference** — discarded because the `cross-reference-form-comparison` research card proves the inline `Read [Text](path)` form is the only viable cross-reference pattern (100% Tier 1 access rate vs 42-58% for resolution-table forms). **Bare `§Name` citation** — discarded because the Read-Link Cross-Reference Rule explicitly forbids the "See ..." citation form; agents treat it as informational and ignore it. |
| 5 | **Key Design Decisions** | **Replicate engineering-approach link text** — the `## Cross-References` section in `engineering-approach/SKILL.md` (lines 123-129) provides the exact canonical link text and structure to replicate, ensuring consistency across consuming cards. **Reference, never re-inline** — the SKILL.md references the shared references; re-inlining their content is explicitly out of scope. **No guideline modification** — 080-code-standards.md and 090-data-integrity.md are NOT modified by this spec; guideline condensation is sibling work (#2352 for 080, #2363 for 090). |
| 6 | **User Intent / Original Prompt** | Update the `programming-principles` skill card to add mandatory Read-links to `code-standards-shared.md` and `data-integrity-shared.md` so that sub-agents gain on-demand access to the shared procedural content that moved out of the 080/090 guidelines. |

## 2. Not Included

- **[Guideline condensation]** — The condensation of `080-code-standards.md` and `090-data-integrity.md` is sibling work (#2352 for 080, #2363 for 090) and is not addressed here.
- **[Shared reference creation]** — The shared reference files `code-standards-shared.md` and `data-integrity-shared.md` are created by sibling specs #2362 and #2363 respectively; this spec only adds the consuming Read-links.
- **[Content re-inlining]** — Duplicating the shared reference content into the SKILL.md is explicitly out of scope; the card references the shared references rather than duplicating them.
- **[Other skill cards]** — Only the `programming-principles` SKILL.md is modified; no other skill cards are touched.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `programming-principles` SKILL.md SHALL contain a `Read [Text](path)` link to `reference/code-standards-shared.md` using the `Read [code-standards-shared reference](reference/code-standards-shared.md)` form. | structural | Grep `.opencode/skills/programming-principles/SKILL.md` for the link `Read [code-standards-shared reference](reference/code-standards-shared.md)`. |
| SC-2 | The `programming-principles` SKILL.md SHALL contain a `Read [Text](path)` link to `reference/data-integrity-shared.md` using the `Read [data-integrity-shared reference](reference/data-integrity-shared.md)` form. | structural | Grep `.opencode/skills/programming-principles/SKILL.md` for the link `Read [data-integrity-shared reference](reference/data-integrity-shared.md)`. |
| SC-3 | The guidelines `080-code-standards.md` and `090-data-integrity.md` SHALL remain unmodified by this change. | structural | `git diff` against the pre-change commit for `.opencode/guidelines/080-code-standards.md` and `.opencode/guidelines/090-data-integrity.md` shows no changes. |

## 4. Requirements

- R-1. The `programming-principles` SKILL.md SHALL contain a `Read [Text](path)` link to `reference/code-standards-shared.md`.
- R-2. The `programming-principles` SKILL.md SHALL contain a `Read [Text](path)` link to `reference/data-integrity-shared.md`.
- R-3. Both Read-links SHALL use the `Read [Text](path)` form and SHALL NOT use the forbidden "See ..." citation form.
- R-4. The `programming-principles` SKILL.md SHALL reference the shared references and SHALL NOT re-inline their content.
- R-5. The guidelines `080-code-standards.md` and `090-data-integrity.md` SHALL NOT be modified by this change.

## 5. Items

### Item 1 (SC-1): Add Read-link to code-standards-shared.md

- RED: Grep the `programming-principles` SKILL.md for `Read [code-standards-shared reference](reference/code-standards-shared.md)` — assert absent (fails).
- GREEN: Add the `## Cross-References` section with the `Read [code-standards-shared reference](reference/code-standards-shared.md)` link to the SKILL.md.
- verify: Grep the SKILL.md for the link — assert present.
- commit: Commit the SKILL.md change.

### Item 2 (SC-2): Add Read-link to data-integrity-shared.md

- RED: Grep the `programming-principles` SKILL.md for `Read [data-integrity-shared reference](reference/data-integrity-shared.md)` — assert absent (fails).
- GREEN: Add the `Read [data-integrity-shared reference](reference/data-integrity-shared.md)` link to the `## Cross-References` section.
- verify: Grep the SKILL.md for the link — assert present.
- commit: Commit the SKILL.md change.

### Item 3 (SC-3): Verify concern boundary

- RED: Assert that `080-code-standards.md` and `090-data-integrity.md` are unmodified (they are, at RED — no failing test needed; this is a verification item).
- GREEN: No code change — the boundary is verified by confirming the diff contains no guideline changes.
- verify: `git diff` against the pre-change commit for the two guideline files — assert no changes.
- commit: Commit the verification evidence.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| #2362 (code-standards-shared.md) | Creates the `reference/code-standards-shared.md` target; the Read-link is a forward reference until this merges | Pending |
| #2363 (data-integrity-shared.md) | Creates the `reference/data-integrity-shared.md` target; the Read-link is a forward reference until this merges | Pending |
| `engineering-approach/SKILL.md` `## Cross-References` | Reference pattern for the canonical link text and structure | Satisfied |
| `cross-reference-form-comparison` research card | Proves the inline `Read [Text](path)` form is the only viable cross-reference pattern | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-1, SC-2 | Phase 1 |
| R-4 | SC-1, SC-2 | Phase 1 |
| R-5 | SC-3 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `engineering-approach/SKILL.md` `## Cross-References` | code | `.opencode/skills/engineering-approach/SKILL.md` | Read — verified the canonical link text and structure |
| `programming-principles/SKILL.md` | code | `.opencode/skills/programming-principles/SKILL.md` | Read — verified the target card has no Read-links |
| Read-Link Cross-Reference Rule | doc | `AGENTS.md` | Read — verified the `Read [Text](path)` mandate |
| `cross-reference-form-comparison` research card | doc | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | Read — verified the inline-link form is the only viable pattern |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the code-standards-shared Read-link exists costs one grep search. Skipping means the consuming card loses access to the code-standards procedural content, and the defect is only discovered when a sub-agent fails to load the shared reference during implementation.
- SC-2: Verifying the data-integrity-shared Read-link exists costs one grep search. Skipping means the consuming card loses access to the data-integrity procedural content, and the defect is only discovered when a sub-agent fails to load the shared reference during implementation.
- SC-3: Verifying the 080/090 guidelines are unmodified costs one `git diff`. Skipping means a scope-creep change to the guidelines ships unnoticed, and the defect is only discovered at review time when the condensation specs conflict.

## 11. Edge Cases

- **Condition:** A Read-link is missing from the SKILL.md.
  - **Expected behavior:** The consuming card loses access to the shared reference content.
  - **Resolution:** SC-1/SC-2 grep verification catches the missing link; the implementer adds it.
- **Condition:** A Read-link uses the forbidden "See ..." form.
  - **Expected behavior:** The sub-agent treats the reference as informational and does not load it.
  - **Resolution:** R-3 forbids the form; verification asserts the `Read [Text](path)` form is used.
- **Condition:** The shared reference files do not yet exist (created by #2362/#2363).
  - **Expected behavior:** The Read-links are dangling references until the sibling specs merge.
  - **Resolution:** Known accepted limitation (per pipeline-readiness); the links resolve after #2362/#2363 merge. No action required by this spec.
- **Condition:** A guideline file (080 or 090) is accidentally modified during implementation.
  - **Expected behavior:** Scope creep beyond the spec.
  - **Resolution:** SC-3 git-diff verification catches the change; the implementer reverts it.
- **Concurrency:** No concurrency concerns — single-file additive change to a skill card.
- **Recovery:** No runtime recovery required — the change is a static documentation reference addition.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
