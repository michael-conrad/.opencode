---
number: 1236
title: "[SPEC-FIX] Pipeline Dependency: Plan Creation Must Precede Pre-Work (Branch Creation)"
state: OPEN
---

## Executive Summary

The implementation pipeline allows parallel dispatch of "create plan" and "pre-work" (branch creation), but these have a dependency relationship: the plan must exist before the branch is created because the plan defines scope, file paths, and submodule requirements. Currently, no explicit dependency edge exists between these two steps, allowing orchestrators to run them in parallel — producing branches with no defined work scope.

## Problem

### Dependency Map (CURRENT — broken)

```
spec_approved
  ├── gap-fill cascade: auto_create_spec → auto_create_plan → auto_approve → auto_create_pr
  └── auto-dispatch:    pre-work → implementation-pipeline → verification → finishing → review-prep
                        ^ no cross-reference to plan creation above
```

The gap-fill cascade (in `010-approval-gate.md` and `gap-fill-cascade.md`) lists `auto_create_plan` as a gap-fill action. Pre-work (branch creation) is defined in a completely separate section (`auto-dispatch.md §6.1`) with no reference back to the gap-fill sequence. An orchestrator can dispatch both in parallel because no document tells them otherwise.

### Root Cause

**Zero explicit dependency edges exist between "plan_created" and "pre_work_complete" in any of these files:**

| Document | Section | Mentions Plan? | Mentions Pre-Work? | Dependency Edge? |
|---|---|---|---|---|
| `skills/approval-gate/SKILL.md` | Gap-fill cascade | Step 2 | No | None |
| `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` | GAP_FILL dict | `auto_create_plan` | No | None |
| `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` §6.1 | Pre-work mandate | No | `MANDATORY before any task()` | None — separate section |
| `skills/approval-gate/tasks/verify-authorization/auto-dispatch-table.md` | Dispatch Order | No | Step 1 after plan approval | Implicit ordering only (listed first) |
| `guidelines/010-approval-gate.md` | Authorization Scope Model | Yes | No | None |

## Solution

### Dependency Map (CORRECT)

```
spec_approved
  └── gap-fill cascade: auto_create_spec → auto_create_plan → PRE_WORK → auto_approve_plan → auto_create_pr
                                                              ^ explicit dependency: plan must exist before branch
```

### Changes Required

**File 1: `skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md`** (PRIMARY)

- Insert `pre_work` into the GAP_FILL dict between `auto_create_plan` and `auto_approve`
- Update `execute_gap_fill()` function to include branch creation step
- Add dependency comment: `# pre_work MUST run after auto_create_plan (plan defines scope for branch)`

**File 2: `skills/approval-gate/tasks/verify-authorization/auto-dispatch-table.md`** (SECONDARY)

- In the "Dispatch Order (Mandatory)" section, add a cross-reference to the gap-fill cascade
- Clarify: "pre-work runs AFTER plan creation, not in parallel. See gap-fill-cascade.md for the full dependency order."

**File 3: `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md`** (SECONDARY)

- In §6.1, add a note: "Pre-work (branch creation) depends on plan creation — the plan defines branch type and scope. Pre-work MUST NOT be dispatched before plan creation is complete."

**File 4: `skills/approval-gate/SKILL.md`** (SECONDARY)

- Update the Authorization Context Template section or Trigger Dispatch Table to note the dependency

## Constraints

| Constraint | Detail |
|---|---|
| No new tasks | The gap-fill sequence already includes the actions — just reorder and add dependency edge |
| Local plan artifact | Plans are local `.issues/{N}/plan.md` files that can be created on `dev` before branching |
| Pre-work remains mandatory | Pre-work is already mandatory; this fix adds the dependency guard without removing it |
| Existing behavior unchanged | No changes to implementation-pipeline, verification-before-completion, or finishing-a-development-branch |

## Affected Files

| File | Change |
|---|---|
| `.opencode/skills/approval-gate/tasks/verify-authorization/gap-fill-cascade.md` | Add `pre_work` to GAP_FILL dict between plan and approve; update `execute_gap_fill()` |
| `.opencode/skills/approval-gate/tasks/verify-authorization/auto-dispatch-table.md` | Add cross-reference to gap-fill cascade |
| `.opencode/skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` | Add dependency note in §6.1 |

## Success Criteria

| SC | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | Gap-fill cascade inserts `pre_work` between `auto_create_plan` and `auto_approve` | `string` | grep GAP_FILL dict for `pre_work` after `auto_create_plan` |
| SC-2 | `execute_gap_fill()` includes branch creation step in correct sequence | `string` | grep execute_gap_fill for pre_work implementation |
| SC-3 | `auto-dispatch.md` §6.1 references that pre-work depends on plan creation | `string` | grep for dependency cross-reference |
| SC-4 | `auto-dispatch-table.md` cross-references gap-fill cascade for order | `string` | grep for cross-reference text |

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| Breaking existing auto-dispatch behavior | Low | Medium | Only gap-fill sequence changes; pre-work was already mandatory |
| Orphaned branches without plans | Low | Medium | Pre-work blocked until plan exists — cannot create a branch without a defined scope |

## Edge Cases

| Edge Case | Handling |
|---|---|
| `for_spec` scope (no pre-work needed) | Gap-fill for `for_spec` does not include `pre_work` — only `for_plan`, `for_implementation`, `for_pr`, `for_pr_only` scopes create branches |
| `for_analysis` scope (observe/* branches) | `observe/*` branches are scratch branches created independently of plans; not affected by this dependency |
| Plan already exists (spec-to-plan cascade) | Existing plan = plan creation skipped → pre-work proceeds immediately after verification |

---

⚠️ **Fix Spec only — review, then approve for implementation.**

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
