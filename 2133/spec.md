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

### User Intent / Original Prompt

Clean up the three semantic defects in `091-incremental-build.md` (duplicated cross-reference, duplicated paragraph, dead compaction note) without restructuring, rewording, or expanding scope.

## Not Included

- **Systemic scan of other guidelines** — A scan of other guideline files for similar defects (duplicate cross-refs, duplicated paragraphs, dead references) is out of scope; this spec is scoped to `091-incremental-build.md` only.
- **Restructuring or rewording of `091-incremental-build.md`** — Only the three defective lines are removed; the file's structure and surrounding text are preserved.
- **Any change to `020-go-prohibitions.md`** — The canonical "tested verified correct code operations" paragraph remains in `020-go-prohibitions.md`; this spec only removes the duplicate from `091-incremental-build.md`.

## Proposed Solution

| Location | Content | Action |
|----------|---------|--------|
| First cross-ref line in the opening paragraph | "Read [§Monolithic Implementation](000-critical-rules.md)" — repeated twice in same line | Remove first instance, keep one |
| Paragraph after Anti-Patterns list | "Implementation work is measured ONLY by whether tested verified correct code operations pass..." | Remove — already in 020 |
| Symbolic rules below line | "Symbolic rules below — the prose above this line replaces the previous ~200 lines" | Remove — dead reference |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | Only one cross-ref to 000-critical-rules.md in the first cross-ref line | string | grep count of '000-critical-rules' on the first cross-ref line == 1 | `.opencode/guidelines/091-incremental-build.md` |
| SC-2 | Remove "Implementation work is measured" paragraph | string | grep for absence of 'tested verified correct code operations' | `.opencode/guidelines/091-incremental-build.md`, `.opencode/guidelines/020-go-prohibitions.md` §1.1 |
| SC-3 | Remove "Symbolic rules below" line | string | grep for absence of 'Symbolic rules below' | `.opencode/guidelines/091-incremental-build.md` |

All SCs must PASS for the spec to be considered complete. Partial implementation is not permitted.

## Requirements

- R-1. The first cross-reference line in the opening paragraph of `091-incremental-build.md` SHALL contain exactly one reference to `000-critical-rules.md`.
- R-2. The paragraph beginning "Implementation work is measured ONLY by whether tested verified correct code operations pass..." SHALL be absent from `091-incremental-build.md`.
- R-3. The line "Symbolic rules below — the prose above this line replaces the previous ~200 lines" SHALL be absent from `091-incremental-build.md`.

## Items

### Item 1 (SC-1): Deduplicate first cross-ref line

- RED: grep count of '000-critical-rules' on the first cross-ref line returns 2 (duplicate present)
- GREEN: Remove the first instance of the cross-ref, keeping one
- verify: grep count of '000-critical-rules' on the first cross-ref line == 1
- commit: The single-line deduplication change

### Item 2 (SC-2): Remove paragraph after Anti-Patterns list

- RED: grep for 'tested verified correct code operations' in `091-incremental-build.md` returns a match (duplicate present)
- GREEN: Remove the paragraph from `091-incremental-build.md`
- verify: grep for absence of 'tested verified correct code operations' in `091-incremental-build.md`
- commit: The paragraph removal change

### Item 3 (SC-3): Remove symbolic rules below line

- RED: grep for 'Symbolic rules below' in `091-incremental-build.md` returns a match (dead reference present)
- GREEN: Remove the "Symbolic rules below" line
- verify: grep for absence of 'Symbolic rules below' in `091-incremental-build.md`
- commit: The dead-reference removal change

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the cross-ref count costs one grep search. Skipping means the duplicated cross-ref ships and the next reader follows a redundant reference.
- SC-2: Verifying the paragraph's absence costs one grep search. Skipping means the duplicated paragraph ships and the drift risk between `091-incremental-build.md` and `020-go-prohibitions.md` persists.
- SC-3: Verifying the dead reference's absence costs one grep search. Skipping means the dead reference ships and the next reader follows a stale pointer.

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |

## Implementation Plan

### Phase 1: Deduplicate first cross-ref line (SC-1)
### Phase 2: Remove paragraph after Anti-Patterns list (SC-2)
### Phase 3: Remove symbolic rules below line (SC-3)

## Edge Cases

### Content Shifts

The spec identifies content by semantic description, not line number. The implementor MUST locate each target by its exact semantic text (the grep pattern defined in the corresponding SC verification method) and remove it. Positional assumptions are never used. If the target text is present, it MUST be removed. If the target text is absent, the removal is a no-op and the SC verification (grep for absence) MUST still be executed and MUST pass. Content shifts do not alter the removal obligation.

### Concurrent Modifications

The removal requirement is unconditional and independent of any concurrent change. Regardless of whether another change modified the same lines, the implementor MUST still execute each phase's removal and verification. The SCs are absolute: the target content MUST be absent after implementation. If a concurrent change already removed the content, the SC verification (grep for absence) confirms it and MUST pass. If a concurrent change did not remove it, the implementor MUST remove it. Concurrent modifications do not grant the implementor discretion to re-decide whether a removal is still required.

### Already-Removed Content

The removal requirement is unconditional and idempotent. No phase is ever skipped. If the target content is already absent, the implementor MUST still execute the phase's verification step (grep for absence per the SC verification method) and the SC MUST pass. The implementor MUST NOT re-add content that is absent, and MUST NOT skip the verification. The absence of the target content MUST be verified by the SC verification step, not by skipping the phase.

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

### Recency Verification (commit history review)

The claims about the current code state were verified against the live file and its commit history during spec creation:

- `git status --short guidelines/091-incremental-build.md` returned no output — the file has no uncommitted changes, so the working-tree state matches the committed state.
- `git log --oneline -5 -- guidelines/091-incremental-build.md` shows the file's most recent commit is `908f5894 checkpoint(#2121): step-14 complete`; no later commit has modified the file.
- Live grep of `.opencode/guidelines/091-incremental-build.md` confirms all three defects are present in the current committed state: the duplicated `000-critical-rules` cross-reference on the first cross-ref line, the "tested verified correct code operations" paragraph, and the "Symbolic rules below" line.

This confirms the three defects described in the Problem Statement exist in the current state of the file and have not been fixed or superseded by a later commit.

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
| 2026-08-13 | Rewrote Edge Cases subsections (Content Shifts, Concurrent Modifications, Already-Removed Content) with deterministic, non-discretionary handling | Spec-audit HOL-6 (Escape Hatches) FAIL: discretionary language let the implementor skip or re-decide removals | spec-creation pipeline (revision task) |
| 2026-08-13 | Added Documentation Sources column to SC table; removed "no runtime execution cost" cost claims from SC verification methods and added a Cost Frame section with per-SC cost-frame statements | Validation FAIL: (1) dark-prose-007 cost-frame conformance — verification methods stated a cost claim, not a cost frame; (2) SC table lacked Documentation Sources column | spec-creation pipeline (revision task) |
| 2026-08-13 | Added User Intent / Original Prompt field to Intent section; added Not Included, Requirements (R-1..R-3), and Items (Item 1..3) sections; updated Traceability to Requirements → SCs → Phases | Validation FAIL on completeness: spec missing §1 preamble field 6, §2 Not Included, §4 Requirements, §5 Items | spec-creation pipeline (revision task) |
| 2026-08-13 | Rewrote Already-Removed Content edge case: replaced "confirmed by verification" (prohibited tracking/status marker) with forward-looking "MUST be verified by the SC verification step" language | Re-audit SC-TRACKING-LANG FAIL: 'confirmed' used as a prohibited tracking/status marker | spec-creation pipeline (revision task) |
| 2026-08-13 | Added Recency Verification subsection under Documentation Sources recording commit history review evidence (git status clean, latest commit 908f5894, live grep confirming the three defects) | Re-audit A4-recency-check FAIL: spec claimed current code state without recorded commit history review evidence | spec-creation pipeline (revision task) |
| 2026-08-13 | Removed line-number citations (line 9, 47, 49) from the Recency Verification subsection, keeping only the semantic descriptions of the three defects | Re-audit HOL-2 (Internal Consistency) FAIL: line-number citations contradicted the Content Shifts edge case assertion that positional assumptions are never used; content is identified by semantic description | spec-creation pipeline (revision task) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
