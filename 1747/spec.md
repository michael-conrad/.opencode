> **Full spec and artifacts: `.opencode/.issues/492/`**

## Exec Summary

Feature branches can be forked from a stale `dev` checkout and accumulate commits while `dev` moves ahead. When the developer pushes the branch and creates a PR, the diff is against an outdated base — the PR may conflict, duplicate work already done on `dev`, or miss required changes. This wastes review cycles and creates avoidable rebase work.

### Cards (dependency order)
1. **Add staleness-check + auto-rebase step to `review-prep/push-and-cleanup.md`** before existing Step 1.5 rebase
2. **Detection method**: `git rev-list --count --left-right origin/dev...HEAD` — if `behind > 0`, the branch is stale
3. **On staleness**: auto-rebase onto `origin/dev`. On Tier 1-2 conflict: auto-resolve. On Tier 3 conflict: HALT and escalate.
4. **On clean** (behind == 0): proceed normally to push and PR creation

### Key Decisions
- **Auto-rebase, not halt** — agent performs rebase autonomously; only escalate on Tier 3 (intent) conflicts
- **Trigger via `git-workflow --task review-prep`** — the pre-PR gate. Not a webhook, not scheduled.

### Risk Callouts
- **Rebase conflicts** — Tier 3 intent conflicts require developer intervention and may block PR creation
- **Not post-merge drift** — this is pre-PR staleness detection only; spec-vs-code drift is a separate concern

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/492/`.
After creation, `local-issues sync 492` MUST be run and the result committed to create the local `.issues/492/` entry.
The implementation plan will be created in `.issues/492/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/492/`*