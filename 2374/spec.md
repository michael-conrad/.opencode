---
title: "[SPEC] Update issue-review skill — anchor context-completeness staleness detail"
number: 2374
repo: .opencode
created: 2026-08-27
status: open
labels: [needs-approval, spec-draft]
---

> **Full spec and artifacts: [`.opencode/.issues/2374/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2374)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2374/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Update issue-review skill — anchor context-completeness staleness detail

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The context-completeness staleness rule, de-minimis bound, and single-exchange window currently live only in the `067-context-completeness.md` guideline (lines 35-70), which is slated for condensation in issue #2351. Without an authoritative home in the `issue-review` skill, the detail would be lost when 067 is condensed, and the `issue-review` gather/operating-protocol decision points would resolve re-read decisions against no canonical source. |
| 2 | **Root Cause / Motivation** | The staleness detail is operational context for the `issue-review` skill's decision points (gather Step 2, operating-protocol Step 1), but it is authored in a generic guideline that is being condensed. Anchoring it into the `issue-review` skill card makes it the authoritative source so #2351 can remove it from 067 without content loss. The change must land now because #2351's condensation depends on this anchor being in place. |
| 3 | **Approach Chosen** | Consolidate the staleness rule, de-minimis bound, and single-exchange window into the `issue-review` SKILL.md as an authoritative section (under Operating Protocol). Add mandatory `Read [Text](path)` cross-references for all shared content between `issue-review` and 067 per the AGENTS.md Read-Link Cross-Reference Rule. Preserve the read-all-comments core in 067 unchanged. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: leave the detail in 067 and skip the anchor.** Discarded because #2351 condensation would remove the detail from 067, leaving no authoritative source and causing content loss. **Alternative: duplicate the detail in both 067 and issue-review.** Discarded because duplication defeats the condensation savings and violates single-source-of-truth discipline. |
| 5 | **Key Design Decisions** | (a) The `issue-review` SKILL.md becomes the single authoritative home for the staleness detail — a tradeoff of moving operational content into a skill card to enable 067 condensation. (b) Cross-references use the `Read [Text](path)` inline-link form exclusively — a tradeoff of following the research-card-verified 100% Tier 1 access pattern over resolution tables (42-58%). (c) The read-all-comments core stays in 067 — a tradeoff of keeping the zero-tolerance rule in the preloaded Tier 1 guideline rather than relocating it. |
| 6 | **User Intent / Original Prompt** | Issue #2374: "Update issue-review skill — anchor context-completeness staleness detail." The requirement is to make issue-review the canonical home for the staleness/de-minimis/single-exchange-window detail, enabling the 067 condensation in #2351. |

## 2. Not Included

- **[067 condensation (removal of staleness detail + preload change)]** — The actual removal of the staleness detail from `067-context-complements.md` and the `opencode.jsonc` preload change are issue #2351's scope. This issue only anchors the content into issue-review and adds cross-reference links.
- **[`opencode.jsonc` preload array modification]** — The config change is #2351's concern ("Depends on issue-review update + config").
- **[`issue-operations-core/tasks/read-comments.md` rewrite]** — It references the unchanged 067 read-all-comments core; no change required.
- **[`issue-review` dispatch behavior / description semantic router]** — The skill's Trigger Dispatch Table, Invocation, and description are not modified; only additive staleness content is added.
- **[`analyze-and-spec.md` / `audit.md` task changes]** — These reference the unchanged 067 read-all-comments core; no change required.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|--------------|---------------------|----------------------|
| SC-1 | The `issue-review` SKILL.md SHALL be the authoritative source for the staleness rule, the de-minimis bound, and the single-exchange window (consolidated from `067-context-completeness.md` lines 35-70), and the detail SHALL be absent from `issue-review` task files (single-source). | behavioral | Dispatch the `issue-review` gather task via `opencode run` and assert (stderr) the agent consults the `issue-review` authoritative staleness source when deciding whether to re-read comments before a significant action; assert the agent applies the de-minimis bound and single-exchange window. Structural: assert the staleness/de-minimis/single-exchange text is present in `issue-review/SKILL.md` and absent from `issue-review` task files. | `.opencode/skills/issue-review/SKILL.md`; `.opencode/guidelines/067-context-completeness.md`; `.opencode/reference/skill-card-schema.md` |
| SC-2 | Any content shared between `issue-review` and 067 (the staleness detail and the read-all-comments core) SHALL be cross-referenced using the mandatory `Read [Text](path)` form per the AGENTS.md Read-Link Cross-Reference Rule, with no `See file §section` or bare-symbol cross-reference forms introduced. | structural | Grep `issue-review/SKILL.md` and `067-context-completeness.md` for `Read [Text](path)` links on shared content; assert no `See file §section` or bare-symbol patterns. Behavioral: `opencode run` prompt asserting the agent follows the `Read [Text](path)` link to access the referenced file. | `.opencode/AGENTS.md` Read-Link Cross-Reference Rule; `.opencode/.issues/research-cards/cross-reference-form-comparison.md` |
| SC-3 | The zero-tolerance read-all-comments-before-acting core SHALL remain intact in `067-context-completeness.md` (Zero Tolerance Rule, Scope of Resources, When This Applies, Evidence Requirement, FORBIDDEN, REQUIRED), and the `issue-review` SKILL.md description SHALL still assert "All comments MUST be read before acting on any issue". | behavioral | Dispatch the `issue-review` gather task via `opencode run` and assert (stderr) the agent reads ALL comments before any triage decision. Structural: assert the read-all-comments core text remains in `067-context-completeness.md` and the SKILL.md description still asserts all comments must be read. | `.opencode/guidelines/067-context-completeness.md`; `.opencode/skills/issue-review/SKILL.md` |

## 4. Requirements

R-1. The `issue-review` SKILL.md SHALL be the authoritative source for the staleness rule, the de-minimis bound, and the single-exchange window.

R-2. The consolidated staleness detail SHALL be relocated (not duplicated) from `067-context-completeness.md` into `issue-review/SKILL.md`, with no copy remaining in `issue-review` task files.

R-3. The `issue-review` SKILL.md frontmatter (name, description, license) SHALL remain binary-valid per `skill-card-schema.md`.

R-4. The Pre-Flight Guard section in `issue-review/SKILL.md` SHALL be preserved verbatim.

R-5. Any content shared between `issue-review` and 067 SHALL be cross-referenced using the `Read [Text](path)` form per the AGENTS.md Read-Link Cross-Reference Rule.

R-6. The `067-context-completeness.md` SHALL add a `Read [Text](path)` link to `issue-review` as the authoritative source for the staleness detail.

R-7. The `issue-review/SKILL.md` SHALL add a `Read [Text](path)` link to the `067-context-completeness.md` read-all-comments core for shared content.

R-8. The zero-tolerance read-all-comments-before-acting core SHALL remain intact and unchanged in `067-context-completeness.md`.

R-9. The `issue-review` gather task and operating protocol SHOULD route re-read decisions to the consolidated authoritative staleness source via `Read [Text](path)` links.

R-10. The change SHOULD coordinate with issue #2351 so the staleness detail is neither lost nor duplicated across the two issues.

## 5. Items

### Item 1 (SC-1): Anchor staleness/de-minimis/single-exchange detail in issue-review skill card

- RED: Behavioral enforcement test dispatches the `issue-review` gather task and asserts (stderr) the agent does NOT yet consult the `issue-review` authoritative staleness source (detail absent from SKILL.md).
- GREEN: Add the consolidated staleness rule, de-minimis bound, and single-exchange window to `issue-review/SKILL.md` (e.g., a "Context-Completeness Staleness" section under Operating Protocol).
- verify: Behavioral `opencode run` assertion that the agent consults the authoritative source; structural assertion that the detail is present in SKILL.md and absent from task files; frontmmatter binary-validity check.
- commit: `issue-review/SKILL.md` staleness section.

### Item 2 (SC-2): Add mandatory Read [Text](path) cross-references for shared content

- RED: Grep asserts no `Read [Text](path)` link on shared content exists yet in `issue-review/SKILL.md` and `067-context-completeness.md`.
- GREEN: Add `Read [Text](path)` links: 067 → issue-review (staleness authoritative source) and issue-review → 067 (read-all-comments core).
- verify: Structural grep for `Read [Text](path)` links and absence of `See file §section`/bare-symbol forms; behavioral `opencode run` assertion the agent follows the link to access the referenced file.
- commit: Cross-reference links in `issue-review/SKILL.md` and `067-context-completeness.md`.

### Item 3 (SC-3): Preserve the read-all-comments core

- RED: Behavioral enforcement test dispatches the `issue-review` gather task and asserts (stderr) the read-all-comments-before-triage behavior is present (core intact).
- GREEN: No content change — this is a verification guardrail; confirm the core remains in 067 and the SKILL.md description still asserts all comments must be read.
- verify: Behavioral `opencode run` assertion the agent reads ALL comments before any triage decision; structural assertion the core text remains in 067 and the description is unchanged.
- commit: No content change; verification evidence only.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Issue #2351 (067 condensation) | #2374 anchors the staleness detail into issue-review so #2351 can remove it from 067 without loss; the two MUST land coordinated. | Pending (coupled) |
| `skill-card-schema.md` binary constraints | `issue-review/SKILL.md` frontmatter must remain valid per the schema. | Satisfied |
| `AGENTS.md` Read-Link Cross-Reference Rule | Mandates the `Read [Text](path)` cross-reference form. | Satisfied |
| Research card `cross-reference-form-comparison.md` (confidence 0.95) | Confirms inline `Read [Text](path)` form is the only viable pattern at 100% Tier 1 access. | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-2 | Phase 2 |
| R-6 | SC-2 | Phase 2 |
| R-7 | SC-2 | Phase 2 |
| R-8 | SC-3 | Phase 3 |
| R-9 | SC-1, SC-2 | Phase 1, Phase 2 |
| R-10 | SC-2 | Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `issue-review/SKILL.md` | code | `.opencode/skills/issue-review/SKILL.md` | read |
| `067-context-completeness.md` | code | `.opencode/guidelines/067-context-completeness.md` | read |
| `skill-card-schema.md` | code | `.opencode/reference/skill-card-schema.md` | read |
| AGENTS.md Read-Link Cross-Reference Rule | code | `.opencode/AGENTS.md` | read |
| Research card `cross-reference-form-comparison.md` | code | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral `opencode run` gather-task assertion costs minutes of execution time — a bounded delay that surfaces a missing authoritative source before the detail is lost. Skipping it means the staleness detail is not anchored, the #2351 condensation removes it from 067, and the detail is silently lost — a defect that ships and costs 1000× more to rediscover.
- SC-2: Running the structural grep for `Read [Text](path)` links costs seconds. Skipping it means a `See file §section` or bare-symbol reference is introduced, the agent never accesses the referenced file (42-58% access), and the shared content is lost during #2351 condensation — a death-spiral defect.
- SC-3: Running the behavioral `opencode run` read-all-comments assertion costs minutes of execution time. Skipping it means the zero-tolerance read-all-comments core is weakened or removed during consolidation, and agents act on partial context — a behavioral defect that ships and costs 1000× more to fix.

## 11. Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|------------------|------------|
| **Input boundary: empty staleness detail source** | If the staleness detail source text in 067 (lines 35-70) is missing or malformed at implementation time, the anchor cannot proceed. | HALT and report — the source content must be present before consolidation. |
| **State transition: ownership of staleness detail** | The detail transitions from sole ownership in 067 to authoritative ownership in issue-review. | Ensure single authoritative owner; 067 links via `Read [Text](path)`, does not re-state. |
| **Failure mode: frontmatter invalidated** | If adding the staleness section invalidates the `issue-review/SKILL.md` frontmatter (name/description/license), the skill becomes invisible. | Validate frontmatter against `skill-card-schema.md` before commit; fail-fast on invalid. |
| **Failure mode: content duplicated across task files** | If the detail is duplicated into `gather.md`/`operating-protocol.md` instead of single-sourced in SKILL.md. | Enforce single-source; task files reference via `Read [Text](path)` only. |
| **Failure mode: #2351 lands before #2374** | If the 067 condensation (removal) lands before the issue-review anchor, the detail is lost. | Coordinate at PR/merge time; #2374 must land before or with #2351. |
| **Concurrency: parallel edits to issue-review/SKILL.md** | Concurrent edits to the skill card could conflict. | Rebase-always hygiene; resolve conflicts per `conflict-resolution` skill. |
| **Recovery: read-all-comments core weakened** | If the consolidation weakens the zero-tolerance core. | SC-3 verification guardrail detects and blocks the regression; revert to the intact core. |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
