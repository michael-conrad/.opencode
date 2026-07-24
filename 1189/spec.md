---
number: 1189
title: "[SPEC-FIX] Restore cross-reference invalidation in screen-issue-gate2 — hard block not soft flag"
state: OPEN
---

## Summary

The pre-image of `screen-issue.md` (before commit `a92978eb` Phase 3 decomposition) had a hard invalidation rule: cross-reference inconsistencies **invalidate** the "already-implemented" classification. The post-image's `screen-issue-gate2.md` weakened this to "DOWNGRADE or flag-for-review" (line 72), which is a soft flag. The key principle at line 87 still says "invalidate" but the code at line 72 doesn't match.

## Root Cause

Commit `a92978eb` decomposed `screen-issue.md` (497 lines) into `screen-issue-gate1.md` and `screen-issue-gate2.md`. The pre-image's cross-reference invalidation logic (lines 223-247) was carried forward but weakened from a hard `INVALIDATE` to a soft `DOWNGRADE or flag-for-review`.

## Affected Files

| File | Change |
|------|--------|
| `skills/approval-gate/tasks/screen/screen-issue-gate2.md` | Restore hard invalidation at line 72 |

## Phase 1: Restore Hard Invalidation

**Line 72** — Change from:

```
if ref_issue["state"] == "open" and candidate is classified as "already-implemented":
  DOWNGRADE to "partially-implemented" or flag-for-review
```

To:

```
if ref_issue["state"] == "open" and candidate is classified as "already-implemented":
  INVALIDATE "already-implemented" classification — cross-reference inconsistency
  DOWNGRADE to "partially-implemented"
```

**Line 87** — The key principle already says:

> Even if Gate 1 and Gate 2 pass, cross-reference inconsistencies invalidate the "already-implemented" classification. The full issue graph must be consistent.

No change needed to line 87 — the principle is correct. The code just needs to match it.

## Phase 2: Add Cross-Reference Invalidation to Failure Triggers Table

Update the failure triggers table at lines 81-85:

| Failure Condition | Classification | Action |
|-----------------|----------------|--------|
| Referenced issue is open | CONFLICTING | **INVALIDATE** "already-implemented" — downgrade to partially-implemented |
| Referenced issue closed without merged PR | VERIFICATION-GAP | Flag for review — may be premature closure |
| Cross-reference 404 | MISSING-TRACEABILITY | Flag for developer — referenced issue doesn't exist |

Change the first row's Action from "DOWNGRADE or flag-for-review" to "INVALIDATE 'already-implemented' — downgrade to partially-implemented".

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `screen-issue-gate2.md` line 72 uses `INVALIDATE` (hard block) instead of `DOWNGRADE or flag-for-review` (soft flag) | `string` |
| SC-2 | Failure triggers table at line 81-85 uses `INVALIDATE` for the CONFLICTING row | `string` |
| SC-3 | Behavioral test: screening an already-implemented issue with open cross-references → agent hard-blocks, does not soft-flag | `behavioral` |

## Non-Goals

- Not modifying `screen-issue-gate1.md` — Gate 1 sub-issue enumeration is correct
- Not modifying the Gate Evidence Audit table or GA-2/GA-3/GA-4 procedures
- Not modifying the screening result contract format

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/screen-issue-invalidation`
