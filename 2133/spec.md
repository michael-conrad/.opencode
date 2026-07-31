---
remote_issue: 2133
remote_url: https://github.com/michael-conrad/.opencode/issues/2133
labels: [spec]
---

## Problem

`091-incremental-build.md` has three semantic defects that reduce clarity and maintainability:

1. **Duplicate cross-reference on line 9**: The same `000-critical-rules.md` cross-ref appears twice in the same line. The first instance is redundant — the second instance (after "Also covered by...") is the canonical one. The first instance adds no information and should be removed.

2. **Duplicated paragraph on line 47**: The paragraph "Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity." is already present in `020-go-prohibitions.md` §1.1 as a note. Having it in both files creates a maintenance burden — updates to the principle must be made in two places, and the two copies will inevitably drift. The canonical copy is in `020-go-prohibitions.md`; the copy in `091-incremental-build.md` should be removed.

3. **Dead reference on line 49**: The line "Symbolic rules below — the prose above this line replaces the previous ~200 lines of advisory text." references content that was already removed. This is a stale artifact from a prior compaction pass — it refers to text that no longer exists and serves no purpose. It should be removed.

## Proposed Solution

| Line | Content | Action |
|---|---|---|
| 9 | "Read [§Monolithic Implementation](000-critical-rules.md)" — repeated twice in same line | Remove first instance, keep one |
| 47 | "Implementation work is measured ONLY by whether tested verified correct code operations pass..." | Remove — already in 020 |
| 49 | "Symbolic rules below — the prose above this line replaces the previous ~200 lines" | Remove — dead reference |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Only one cross-ref to 000-critical-rules.md on line 9 | string | grep count of '000-critical-rules' on line 9 == 1 |
| SC-2 | Remove "Implementation work is measured" paragraph | string | grep for absence of 'tested verified correct code operations' |
| SC-3 | Remove "Symbolic rules below" line | string | grep for absence of 'Symbolic rules below' |

## Traceability

| SC ID | Phase |
|-------|-------|
| SC-1 | Phase 1 |
| SC-2 | Phase 2 |
| SC-3 | Phase 3 |

## Implementation Plan

### Phase 1: Deduplicate line 9 cross-ref (SC-1)
### Phase 2: Remove line 47 paragraph (SC-2)
### Phase 3: Remove line 49 (SC-3)

## Files Affected

- `.opencode/guidelines/091-incremental-build.md`

## Risks

- None. Self-contained cleanup.

## Dependencies

- None.

## Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-07-31 | Rewrote Problem section: replaced metric-based justification (line count, file size) with pure semantic analysis of each defect | Spec violated principle that word/line counts are not valid measures for compaction; justification must be semantic | spec-creation pipeline (revision task) |
| 2026-07-31 | Added Traceability section mapping SCs to Phases; added REQ references to Phase headings | Validation found 3 structural gaps: missing Traceability section, missing Traceability table, Phases lacked REQ references | spec-creation pipeline (revision task) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
