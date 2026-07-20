> **Full spec and artifacts: `.opencode/.issues/4/`**

## Exec Summary

The gap-fill cascade in `approval-gate` is a flat action list that agents interpret as a skip-list, bypassing all quality gates (plan creation, implementation pipeline, sub-agent dispatch). This replaces it with a routing dispatcher that loads per-scope state-verification checklist files — each item verifies a state and, if missing, reports which action to dispatch next.

### Cards (dependency order)
1. **Rewrite `gap-fill-cascade.md`** — Convert from flat action list to routing dispatcher
2. **Create per-scope checklist files** — `for-pr.md`, `for-implementation.md`, `for-plan.md`
3. **Remove dead scopes** — Delete `for_pr_only` and `for_review_only` from scope-parsing, auto-dispatch, and templates
4. **Update approval-gate scope table** — Remove gap-fill column from `010-approval-gate.md`
5. **Add YAML-only rule** — LLM-to-LLM data transfers in `080-code-standards.md`

### Key Decisions
- **Per-scope files over monolithic**: Each scope has different verification items; monolithic file harder to maintain (DEC-1)
- **Remove `for_pr_only`/`for_review_only`**: State-verification checklist already skips itself when artifacts exist; removed scopes were silent-failure traps (DEC-2)

### Risk Callouts
- **Checklist drift from skill structure**: Mitigated by routing to skill public entry points, never duplicating procedural logic (RISK-1)
- **Removing `for_pr_only` breaks workflows**: Low risk — `for_pr` with existing artifacts behaves identically (RISK-2)

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/4/`.
After creation, `local-issues sync 4` MUST be run and the result committed to create the local `.issues/4/` entry.
The implementation plan will be created in `.issues/4/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/4/`*