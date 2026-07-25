---
remote_issue: 2133
remote_url: https://github.com/michael-conrad/.opencode/issues/2133
labels: [spec]
---

## Problem

`091-incremental-build.md` is ~49 lines / ~2.8KB — already compacted. Three minor issues remain:

1. Line 9 cross-refs 000-critical-rules.md (preloaded, already in context)
2. Line 47 restates "Implementation work is measured ONLY by..." — already in 020-go-prohibitions.md §1.1
3. Line 49 says "Symbolic rules below — the prose above this line replaces the previous ~200 lines" — dead reference to already-removed content

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

## Implementation Plan

### Phase 1: Deduplicate line 9 cross-ref
### Phase 2: Remove line 47 paragraph
### Phase 3: Remove line 49

## Files Affected

- `.opencode/guidelines/091-incremental-build.md`

## Risks

- None. Self-contained cleanup.

## Dependencies

- None.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
