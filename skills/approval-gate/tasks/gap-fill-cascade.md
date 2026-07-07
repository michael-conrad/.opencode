<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: gap-fill-cascade

## Purpose

Routing dispatcher for the gap-fill state-verification checklist model. Reads `authorization_scope` from context, routes to the corresponding per-scope checklist file, walks items sequentially, and reports the first missing state or that all states are verified.

## Context Received

```yaml
authorization_scope: <scope_value>
issue_number: <N>
github.owner: <owner>
github.repo: <repo>
project_root: <path>
```

## Scope-to-Checklist Mapping

| Scope | Checklist File | Items | Behavior |
|-------|---------------|-------|----------|
| `for_pr` | `gap-fill-cascade/for-pr.md` | 5 items | Spec → Plan → Approval → Implementation → PR |
| `for_implementation` | `gap-fill-cascade/for-implementation.md` | 4 items | Spec → Plan → Approval → Implementation |
| `for_plan` | `gap-fill-cascade/for-plan.md` | 2 items | Spec → Plan |
| `for_spec` | None | — | Report `all_states_verified: true` (spec is the target scope) |
| `for_analysis` | None | — | Report `all_states_verified: true` (read-only investigation) |
| `for_review_prep` | None | — | Report `all_states_verified: true` (all artifacts must pre-exist) |

## Procedure

1. Read `authorization_scope` from context
2. If scope has a checklist file (for_pr, for_implementation, for_plan):
   a. Load the corresponding checklist file from `gap-fill-cascade/{scope-file}.md`
   b. Walk items sequentially — process each item's verify step
   c. On first FAIL: report `next_action` with reason, stop walking
   d. If all items PASS: report `all_states_verified: true`
3. If scope has no checklist (for_spec, for_analysis, for_review_prep):
   a. Report `all_states_verified: true` immediately

## Result Contract

```yaml
status: DONE|BLOCKED
all_states_verified: true|false
next_action: <skill-name>|null
reason: "<explanation if blocked or next_action set>"
checklist_progress:
  items_checked: <N>
  items_passed: <N>
  first_fail_item: <item-name>|null
```

## Orchestrator Loop Integration

After this task returns, the orchestrator:

- If `all_states_verified: true`: proceed to the halt boundary
- If `next_action` is set: dispatch that action, then re-dispatch this task
- If BLOCKED with no `next_action`: HALT with blocker report

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
