## Problem

The gap-fill cascade is structured as an authorization list ("auto-create spec+plan+auto-approve+auto-PR") rather than a state-verification checklist. When an agent reads this, it interprets the gap-fill as "I have permission to skip to the end" rather than "I must verify each state sequentially and stop at the first gap."

This was demonstrated in session `ses_0ffeba217ffeyz4dmcrgle5cLK` (and previously in #1346): the agent received `for_pr` scope, read the gap-fill as a skip-list, bypassed plan creation, bypassed the implementation pipeline, and started reading files to modify directly. The agent never created a plan, never loaded `writing-plans` or `implementation-pipeline`, and never dispatched sub-agents for implementation work.

**Root cause:** The gap-fill is a flat action list that reads like "you may do X, Y, Z" — not "check if X is done; if not, do X; then check Y." The agent's training reward is progression, and the gap-fill provides a progression path that skips all quality gates.

## Scope

Replace the gap-fill cascade with a state-verification checklist model. The cascade becomes a routing-only dispatcher that loads per-scope checklist files. Each checklist item verifies a state and, if missing, returns a `BLOCKED` result with a `next_action` routing to the appropriate skill. The orchestrator loops: dispatch cascade → if BLOCKED, dispatch `next_action` → re-dispatch cascade → repeat until DONE.

## Files Affected

### New Files

| File | Purpose |
|------|---------|
| `skills/approval-gate/tasks/gap-fill-cascade/for-pr.md` | State-verification checklist for `for_pr` scope |
| `skills/approval-gate/tasks/gap-fill-cascade/for-implementation.md` | State-verification checklist for `for_implementation` scope |
| `skills/approval-gate/tasks/gap-fill-cascade/for-plan.md` | State-verification checklist for `for_plan` scope |

### Modified Files

| File | Change |
|------|--------|
| `skills/approval-gate/tasks/gap-fill-cascade.md` | Rewrite as routing dispatcher — reads scope from context, loads per-scope checklist, returns result contract |
| `guidelines/010-approval-gate.md` | Remove gap-fill column from scope table; simplify or remove scope enumeration table entirely |
| `skills/approval-gate/enforcement/scope-parsing.md` | Remove `for_pr_only` and `for_review_only` scope definitions |
| `skills/approval-gate/enforcement/auto-dispatch-table.md` | Remove `for_pr_only` and `for_review_only` entries |
| `skills/approval-gate/tasks/verify-authorization/scope-auto-resolve.md` | Remove `for_pr_only` and `for_review_only` from parsing table |
| `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` | Remove — replaced by `gap-fill-cascade/` directory |
| `guidelines/000-critical-rules.md` | Remove obsolete scope references |
| All skill task files with `authorization_scope` template blocks (~40+ files) | Remove `pr_strategy` from template; remove `for_pr_only` and `for_review_only` from enum |

## Design

### Orchestrator Loop

After `verify-authorization` returns `{authorization_scope, halt_at}`, the orchestrator enters a dispatch loop:

1. Dispatch `gap-fill-cascade` sub-agent with `{authorization_scope, issue_number}`
2. Receive result contract:
   - `{status: DONE}` → proceed to `halt_at` boundary
   - `{status: BLOCKED, next_action: "...", reason: "..."}` → dispatch `next_action`, then loop back to step 1
   - `{status: BLOCKED}` (no `next_action`) → HALT with blocker report

The orchestrator holds only routing metadata — it never decides what to do. The cascade file determines the next action.

### Gap-Fill Cascade Dispatcher (`gap-fill-cascade.md`)

Single task file that reads `authorization_scope` from context and loads the corresponding per-scope checklist:

```python
SCOPE_CHECKLIST = {
    "for_pr": "gap-fill-cascade/for-pr.md",
    "for_implementation": "gap-fill-cascade/for-implementation.md",
    "for_plan": "gap-fill-cascade/for-plan.md",
}
```

The sub-agent loads the checklist file, walks items sequentially, and returns the first BLOCKED result or DONE.

### Per-Scope Checklist Format

Each checklist item follows this structure:

```
- [ ] **State description**
      Verify: how to check this state (file exists, label present, etc.)
      If PASS: proceed to next item
      If FAIL: return `{status: BLOCKED, next_action: "<skill> --task <task>", reason: "<reason>"}`
```

Items are sequential — the sub-agent processes them in order and returns on the first FAIL.

### `for-pr.md` Checklist (Draft)

```
- [ ] **Spec exists and is approved**
      Verify: issue has `spec` label
      If PASS: proceed
      If FAIL: return `{next_action: "dispatch spec-creation --task create", reason: "spec_missing"}`

- [ ] **Plan exists and is faithful to spec**
      Verify: `*/.issues/{N}/plan.md` exists
      If PASS: proceed
      If FAIL: return `{next_action: "dispatch writing-plans --task create", reason: "plan_missing"}`

- [ ] **Plan is approved**
      Verify: issue has `approved-for-plan` label (or scope >= for_plan auto-approves)
      If PASS: proceed
      If FAIL: return `{next_action: "apply approved-for-plan label", reason: "plan_not_approved"}`

- [ ] **Implementation complete (all SCs verified PASS)**
      Verify: verification artifacts exist for all SCs in spec
      If PASS: proceed
      If FAIL: return `{next_action: "dispatch implementation-pipeline", reason: "implementation_incomplete"}`

- [ ] **PR exists**
      Verify: open PR for this branch exists
      If PASS: return `{status: DONE}`
      If FAIL: return `{next_action: "dispatch git-workflow --task pr-creation", reason: "pr_missing"}`
```

### `for-implementation.md` Checklist (Draft)

Same as `for-pr.md` but without the PR item — halts after implementation complete.

### `for-plan.md` Checklist (Draft)

```
- [ ] **Spec exists and is approved**
      Verify: issue has `spec` label
      If PASS: proceed
      If FAIL: return `{next_action: "dispatch spec-creation --task create", reason: "spec_missing"}`

- [ ] **Plan exists and is faithful to spec**
      Verify: `*/.issues/{N}/plan.md` exists
      If PASS: return `{status: DONE}`
      If FAIL: return `{next_action: "dispatch writing-plans --task create", reason: "plan_missing"}`
```

### Scope Removal

`for_pr_only` and `for_review_only` are removed. Their only purpose was "skip gap-fill" — but the state-verification checklist already skips itself when artifacts exist. `for_pr` with existing spec+plan+branch behaves identically to `for_pr_only`. The removed scopes were silent-failure traps when preconditions weren't met.

### `010-approval-gate.md` Simplification

The scope table is reduced to declarative properties only — no gap-fill column, no PR strategy column. The gap-fill routing is implicit: authorization always triggers `dispatch gap-fill-cascade`, which reads the scope and walks its checklist. The guideline states principles; enforcement files define mechanics.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `gap-fill-cascade.md` rewritten as routing dispatcher that loads per-scope checklist based on `authorization_scope` | `string` |
| SC-2 | `gap-fill-cascade/for-pr.md` exists with state-verification checklist (spec → plan → approval → implementation → PR) | `string` |
| SC-3 | `gap-fill-cascade/for-implementation.md` exists with state-verification checklist (spec → plan → approval → implementation) | `string` |
| SC-4 | `gap-fill-cascade/for-plan.md` exists with state-verification checklist (spec → plan) | `string` |
| SC-5 | Each checklist item follows verify/create pair format: verify state, if PASS proceed, if FAIL return `BLOCKED` with `next_action` | `string` |
| SC-6 | `for_pr_only` and `for_review_only` removed from all scope-parsing, auto-dispatch, and template files | `string` |
| SC-7 | `010-approval-gate.md` scope table has no gap-fill column | `string` |
| SC-8 | **BEHAVIORAL**: agent with `for_pr` scope and existing spec+plan dispatches `gap-fill-cascade`, routes through `implementation-pipeline` — does NOT skip to PR creation | `behavioral` |
| SC-9 | **BEHAVIORAL**: agent with `for_pr` scope and missing plan dispatches `writing-plans` via `next_action` routing | `behavioral` |
| SC-10 | `pr_strategy` removed from all `authorization_scope` template blocks across skill task files | `string` |

## Risk Analysis

| Risk | Mitigation |
|------|------------|
| Orchestrator loop creates infinite dispatch loop if cascade always returns BLOCKED | Cascade returns `{status: BLOCKED}` without `next_action` on unrecoverable state — orchestrator halts. Loop counter in orchestrator context (max 10 iterations) as safety net |
| Per-scope checklist files drift from skill task structure | Each checklist item routes to a skill's public entry point — it never duplicates procedural logic. Skill changes don't affect the routing reference |
| Removing `for_pr_only` breaks existing workflows that depend on it | `for_pr` with existing artifacts behaves identically. No behavioral change for any real use case |
| `010-approval-gate.md` loses too much information | The guideline states principles. Enforcement files (`scope-parsing.md`, `auto-dispatch-table.md`, `gap-fill-cascade/`) define mechanics. This is the correct separation — guidelines are for agents, enforcement files are for execution |

## Dependencies

- Supersedes gap-fill concerns in `.opencode#1007`
- `.opencode#1007` should be revised to depend on this spec

## Issue

https://github.com/michael-conrad/.opencode/issues/1418

## Changelog

- 2026-06-25: Initial draft

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
