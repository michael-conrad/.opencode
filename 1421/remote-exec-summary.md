> **Full spec and artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/1421/

## Exec Summary

The gap-fill cascade is structured as a flat authorization list ("auto-create spec+plan+auto-approve+auto-PR") that agents interpret as a skip-list rather than a state-verification checklist. Replace it with a routing dispatcher that loads per-scope checklist files, each item verifying a state and reporting the next action if missing.

### Cards (dependency order)
1. **Per-scope checklist files** — Create `gap-fill-cascade/for-pr.md`, `for-implementation.md`, `for-plan.md` with verify/create pair format
2. **Cascade dispatcher rewrite** — Rewrite `gap-fill-cascade.md` as routing-only dispatcher that loads per-scope checklist and reports state
3. **Scope removal** — Remove `for_pr_only` and `for_review_only` from all scope-parsing, auto-dispatch, and template files (~29 files)
4. **Guideline updates** — Remove gap-fill column from `010-approval-gate.md` scope table; add YAML-only rule to `080-code-standards.md`

### Key Decisions
- **State-verification over action-list**: The cascade becomes a routing dispatcher that loops: dispatch cascade → if blocked, dispatch reported action → re-dispatch cascade → repeat until all states verified
- **Per-scope files over monolithic**: Each scope gets its own checklist file, loaded by the dispatcher based on `authorization_scope`
- **Scope removal**: `for_pr_only` and `for_review_only` removed — `for_pr` with existing artifacts behaves identically

### Risk Callouts
- **Bulk update scope**: ~29 task files need `pr_strategy` and scope enum updates — use grep enumeration and verify with post-change grep
- **Checklist drift**: Each checklist item routes to a skill's public entry point, never duplicating procedural logic — skill changes don't affect routing

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1421/`.
After creation, `local-issues sync` MUST be run and the result committed to create the local `.opencode/.issues/1421/` entry.
The implementation plan will be created in `.opencode/.issues/1421/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.
