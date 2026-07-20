> **Full spec and artifacts: `.opencode/.issues/580/`**

## Exec Summary

Before any PR is created, the enforcement gate independently verifies the branch is not behind the target base. This is a belt-and-suspenders check — the review-prep step already rebases, but the target may have advanced between stages. The enforcement gate performs its own live staleness check rather than relying on prior-step evidence artifacts.

### Cards (dependency order)
1. **Add Step 1.3 to `enforcement-gate.md`** — staleness check and auto-rebase (fetch, rev-list, auto-rebase, conflict routing)
2. **Add item 9 to `pre-pr-checklist.md`** — staleness check as mandatory pre-PR step
3. **Create behavioral test** (`staleness-gate.sh`)

### Key Decisions
- **Dynamic target resolution** — target is the PR's base branch, NOT hardcoded to `origin/dev`
- **No intermediate evidence artifacts** — git state IS the evidence

### Risk Callouts
- **Double-rebase risk** — review-prep may have already rebased; enforcement gate rebase should be idempotent
- **Target branch advancement** — if target moves between review-prep and enforcement gate, the stale check catches it

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/580/`.
After creation, `local-issues sync 580` MUST be run and the result committed to create the local `.issues/580/` entry.
The implementation plan will be created in `.issues/580/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/580/`*