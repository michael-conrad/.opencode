number: 2599
title: "[BUG] skildeck validate flags MISSING_DISPATCH_TABLE on all 35 skill cards — deck-wide pre-existing finding"
state: OPEN
labels: [bug]
---

# [BUG] skildeck validate flags MISSING_DISPATCH_TABLE on all 35 skill cards — deck-wide pre-existing finding

Disposition vehicle for a pre-existing red structural check encountered during .opencode#2551 PR prep.

**Finding:** `skildeck validate` reports MISSING_DISPATCH_TABLE for every SKILL.md in the deck (35/35), including cards merged through recent review (work, gh-cli, git-workflow-pr, …). The deck's cards are prose-numbered items, not dispatch tables — the validator's expectation and the deck's current card standard disagree, deck-wide.

**Evidence (2026-10-13):**
- Working tree (feature/2551-consumable-effort-bound @ 192b0987): 35 MISSING_DISPATCH_TABLE findings; lint clean (0 findings).
- Trunk baseline (05eba9bb, shallow worktree validated via dispatcher): identical 35 findings — pre-existing, not introduced by #2551.

**Disposition:** #2551's PR prep passes through this finding only via this filed fix issue per the suite-green rule. The open question for the fix: either cards adopt the dispatch-table structure the validator enforces, or the validator's card-shape expectation is updated to match the deck standard.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
