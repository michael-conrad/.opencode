---
remote_issue: 2133
remote_url: https://github.com/michael-conrad/.opencode/issues/2133
labels: [spec]
---

## Intent and Executive Summary

### Problem Statement

`091-incremental-build.md` has three semantic defects that reduce clarity and maintainability.

### Root Cause/Motivation

Each defect was introduced during prior editing passes without corresponding cleanup:
1. A cross-reference was duplicated when an "Also covered by" note was appended without removing the original reference.
2. A paragraph was copied from `020-go-prohibitions.md` during a consistency pass without deduplication.
3. A compaction note was left in place after the text it described was removed.

### Approach Chosen

Remove the three defective lines. No restructuring, no rewording, no scope expansion.

### Alternatives Considered & Why Discarded

- **Full rewrite of 091-incremental-build.md**: Discarded — the file's structure is sound; only three lines are defective.
- **Restructuring the cross-reference section**: Discarded — the simplest fix (remove one instance) is the most maintainable.

### Key Design Decisions

- Remove only the defective content; do not reflow or reword surrounding text.
- The canonical copy of the "tested verified correct code operations" paragraph lives in `020-go-prohibitions.md`; removing it from `091-incremental-build.md` eliminates the drift risk.

## Proposed Solution

| Location | Content | Action |
|----------|---------|--------|
| First cross-ref line in the opening paragraph | "Read [§Monolithic Implementation](000-critical-rules.md)" — repeated twice in same line | Remove first instance, keep one |
| Paragraph after Anti-Patterns list | "Implementation work is measured ONLY by whether tested verified correct code operations pass..." | Remove — already in 020 |
| Symbolic rules below line | "Symbolic rules below — the prose above this line replaces the previous ~200 lines" | Remove — dead reference |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Only one cross-ref to 000-critical-rules.md in the first cross-ref line | string | grep count of '000-critical-rules' on the first cross-ref line == 1 — no runtime execution cost |
| SC-2 | Remove "Implementation work is measured" paragraph | string | grep for absence of 'tested verified correct code operations' — no runtime execution cost |
| SC-3 | Remove "Symbolic rules below" line | string | grep for absence of 'Symbolic rules below' — no runtime execution cost |

All SCs must PASS for the spec to be considered complete. Partial implementation is not permitted.

## Traceability

| SC ID | Phase |
|-------|-------|
| SC-1 | Phase 1 |
| SC-2 | Phase 2 |
| SC-3 | Phase 3 |

## Implementation Plan

### Phase 1: Deduplicate first cross-ref line (SC-1)
### Phase 2: Remove paragraph after Anti-Patterns list (SC-2)
### Phase 3: Remove symbolic rules below line (SC-3)

## Edge Cases

### Content Shifts

If line content has moved between spec creation and implementation (e.g., due to concurrent edits), the implementor MUST verify the actual content at the target location before removing it. The spec identifies content by semantic description, not line number — the implementor should grep for the actual text rather than relying on positional assumptions.

### Concurrent Modifications

If another change modified the same lines before this spec is implemented, the implementor MUST re-evaluate whether the removal is still correct. The defect may have been partially or fully resolved by the concurrent change.

### Already-Removed Content

If one of the defects was already fixed (e.g., the duplicated cross-ref was already deduplicated), the implementor MUST skip that phase and report it as already-complete. Do not re-remove content that was already removed.

## Files Affected

- `.opencode/guidelines/091-incremental-build.md`

## Analytical Findings

- **Blast radius**: Single file (`.opencode/guidelines/091-incremental-build.md`), no downstream impact. No other files reference the removed content.
- **Systemic implication**: This spec is scoped to `091-incremental-build.md` only. A systemic scan of other guidelines for similar defects (duplicate cross-refs, duplicated paragraphs, dead references) is out of scope for this cleanup.

## Risks

- None. Self-contained cleanup.

## Dependencies

- None.

## Documentation Sources

The following live sources were verified during spec creation:

- `.opencode/guidelines/091-incremental-build.md` — verified the three defects described in Problem Statement
- `.opencode/guidelines/020-go-prohibitions.md` §1.1 — verified the "tested verified correct code operations" paragraph exists as canonical copy

## Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-07-31 | Rewrote Problem section: replaced metric-based justification (line count, file size) with pure semantic analysis of each defect | Spec violated principle that word/line counts are not valid measures for compaction; justification must be semantic | spec-creation pipeline (revision task) |
| 2026-07-31 | Added Traceability section mapping SCs to Phases; added REQ references to Phase headings | Validation found 3 structural gaps: missing Traceability section, missing Traceability table, Phases lacked REQ references | spec-creation pipeline (revision task) |
| 2026-07-31 | Replaced `## Problem` with `## Intent and Executive Summary` containing all 5 fields | SC-1/SC-12: Preamble format requirement | spec-audit findings |
| 2026-07-31 | Added Edge Cases section after Implementation Plan | SC-8: Edge cases requirement | spec-audit findings |
| 2026-07-31 | Added Documentation Sources section | SC-11: Documentation sources requirement | spec-audit findings |
| 2026-07-31 | Added cost-frame reformation language to each SC verification method | SC-13: Cost-frame language requirement | spec-audit findings |
| 2026-07-31 | Added enforcement gate statement after SC table | SC-14: Enforcement gate requirement | spec-audit findings |
| 2026-07-31 | Replaced line number references with stable anchors in Proposed Solution table | SC-PRESCRIPTIVE-CODE: Line number references requirement | spec-audit findings |
| 2026-07-31 | Added Analytical Findings section with blast radius and systemic implication | Analytical findings requirement | spec-audit findings |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
