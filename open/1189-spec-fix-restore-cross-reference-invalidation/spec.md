---
remote_issue: 1189
remote_url: "https://github.com/michael-conrad/.opencode/issues/1189"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

## Summary

screen-issue-gate2.md weakened cross-reference invalidation from hard INVALIDATE to soft DOWNGRADE or flag-for-review.

## Phase 1: Restore Hard Invalidation

Change line 72 from DOWNGRADE or flag-for-review to INVALIDATE with downgrade to partially-implemented.

## Phase 2: Update Failure Triggers Table

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | screen-issue-gate2.md uses INVALIDATE | string |
| SC-2 | Failure triggers table uses INVALIDATE | string |
| SC-3 | Behavioral test: agent hard-blocks on open cross-refs | behavioral |