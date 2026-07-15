<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: Gap-Fill Cascade — Routing Dispatcher

## Purpose

Routing dispatcher for the gap-fill cascade. Reads `authorization_scope` from context, loads the corresponding per-scope state-verification checklist file, walks items sequentially, and reports the first missing state or that all states are verified. The dispatcher loads the checklist file based on the authorization scope.

## Context Received

```yaml
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_pr|for_review_prep>
issue_number: <N>
github.owner: <owner>
github.repo: <repo>
```

## Procedure

### Step 1: Read authorization_scope from context

Extract `authorization_scope` from the task context. If missing, return `BLOCKED` with reason "No authorization_scope in context".

### Step 2: Route to per-scope checklist or immediate all_states_verified

| Scope | Action |
|-------|--------|
| `for_pr` | Load `gap-fill-cascade/for-pr.md`, walk items sequentially |
| `for_implementation` | Load `gap-fill-cascade/for-implementation.md`, walk items sequentially |
| `for_plan` | Load `gap-fill-cascade/for-plan.md`, walk items sequentially |
| `for_spec` | Report `all_states_verified: true` — no gap-fill needed |
| `for_analysis` | Report `all_states_verified: true` — no gap-fill needed |
| `for_review_prep` | Report `all_states_verified: true` — no gap-fill needed |

### Step 3: Walk checklist items

For scopes with a checklist file (`for_pr`, `for_implementation`, `for_plan`):

1. Load the checklist file from `gap-fill-cascade/<scope>.md`
2. Walk items sequentially in order
3. For each item:
   - Verify the state using the item's verification method
   - If PASS: proceed to the next item
   - If FAIL: report `next_action: <action>` with reason
4. If all items PASS: report `all_states_verified: true`

### Step 4: Report result

Return a structured result contract:

```yaml
status: DONE|BLOCKED
task: gap-fill-cascade
authorization_scope: <scope>
all_states_verified: true|false
next_action: <action_name|null>
next_action_reason: "<reason|null>"
blocker_reason: "<reason|null>"
```

## Result Contract Examples

### All states verified (for_pr with all artifacts present)

```yaml
status: DONE
task: gap-fill-cascade
authorization_scope: for_pr
all_states_verified: true
next_action: null
next_action_reason: null
blocker_reason: null
```

### Missing plan (for_pr without plan)

```yaml
status: DONE
task: gap-fill-cascade
authorization_scope: for_pr
all_states_verified: false
next_action: writing-plans
next_action_reason: "No plan found for issue {issue_number}"
blocker_reason: null
```

### Missing spec (for_plan without spec)

```yaml
status: DONE
task: gap-fill-cascade
authorization_scope: for_plan
all_states_verified: false
next_action: spec-creation
next_action_reason: "No approved spec found for issue {issue_number}"
blocker_reason: null
```

---

Co-authored with AI: OpenCode (deepseek-v4-flash)
