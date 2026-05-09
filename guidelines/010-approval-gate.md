---
trigger_on: approved, go, authorization, approve, approval-gate, spec-before-code
tier: 1
load_when: sub-agent
---

# Approval Gate

**Enforced by `hooks/pre-commit` Gate 2b (authorization_scope + halt_at check).** See `approval-gate` skill for complete procedural workflow.

## Tier 0: Zero Tolerance Rules

| # | Requirement | Symbolic Rule | Enforced By |
|---|-------------|-------------|-------------|
| 1 | Spec before code | approval-gate-001 | `approval-gate` skill |
| 2 | Plan before implementation | approval-gate-001a | `writing-plans` skill |
| 3 | Explicit authorization required | approval-gate-002 | `approval-gate` skill |
| 4 | Apply `approved-for-*` label | approval-gate-002 | `approval-gate` skill |
| 5 | Branch before any file modification | approval-gate-004 | `git-workflow` / `pre-commit` Gate 1 |
| 6 | Human-only merge | approval-gate-005 | GitHub branch protection |
| 7 | Silent halt — no prompts | — | `000-critical-rules.md` |
| 8 | Search before halt (no spec found) | — | `000-critical-rules.md` §Silent Halt |
| 9 | PR requires explicit instruction (except `for_pr`/`pr_only`) | critical-rules-019 | `pr-creation-workflow` skill |
| 10 | Close issues only after PR merge confirmed | critical-rules-013 | `git-workflow cleanup` |
| 11 | Spec-to-Plan cascade (auto-approve faithful plan) | approval-gate-001a-cascade | `approval-gate` skill |
| 12 | Pipeline-scoped authorization with hard HALT at boundary | approval-gate-010/011 | `approval-gate` skill |
| 13 | Issue creation = reporting, NOT implementation (no auth required) | — | `issue-operations` skill |
| 14 | Bug discovery ≠ bug fixing authorization | critical-rules-011 | `approval-gate` skill |

### Authorization Scope Model

| Scope | HALT After | Gap-Fill | PR Strategy |
|-------|-----------|----------|-------------|
| `standard` | review-prep | None | individual |
| `for_spec` | spec_created | None | none |
| `for_plan` | plan_created | auto-create spec | none |
| `for_implementation` | implementation_complete | auto-create spec+plan+auto-approve | individual |
| `for_code_review` | code_review_ready | auto-create spec+plan+auto-approve | individual |
| `for_pr` | pr_created | auto-create spec+plan+auto-approve+auto-PR | stacked |
| `pr_only` | pr_created | None | stacked |
| `review_only` | code_review_ready | None | individual |

### Key Edge Cases

| Case | Rule |
|------|------|
| Spec revised → revokes linked plan approvals | approval-gate-006 |
| Plan not faithful to spec → must revise and re-approve | `plan-fidelity` audit |
| Confirmation ≠ authorization | critical-rules-027 |
| Feedback ≠ authorization | critical-rules-027 |
| Question/ complaint ≠ authorization | critical-rules-question-auth-001 |
| for_pr scope → no halt for structural decisions | approval-gate-014, critical-rules-037 |
| Multi-task plan → authorization cascades to ALL sub-issues | critical-rules-018 |
| No `approved-for-*` label → awaiting approval | approval-gate-003 |
| Audit auto-fix (non-substantive GitHub Issue body only) → exempt | approval-gate-008 |
| Conditional audit fix → requires separate authorization | approval-gate-009 |

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: approval-gate-001
    title: "No implementation without authorization"
    conditions:
      all:
        - "has_approved_plan == false"
    actions:
      - HALT
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-001a
    title: "Spec approval authorizes plan creation, not implementation"
    conditions:
      all:
        - "has_approved_spec == true"
        - "has_approved_plan == false"
        - "has_existing_plan == false"
    actions:
      - INVOKE(writing-plans)
    requires: [approval-gate-001]
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-001a-cascade
    title: "Spec approval cascades to existing faithful plan"
    conditions:
      all:
        - "has_approved_spec == true"
        - "has_existing_plan == true"
        - "plan_is_faithful == true"
    actions:
      - AUTO_APPROVE(plan)
      - PROCEED_TO(implementation)
    requires: [approval-gate-001]
    source: "010-approval-gate.md §Spec-to-Plan Approval Cascade"

  - id: approval-gate-001b
    title: "Plan approval authorizes implementation"
    conditions:
      all:
        - "has_approved_plan == true"
    actions:
      - INVOKE(executing-plans)
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-002
    title: "Explicit authorization applies approved-for-* label"
    conditions:
      any:
        - "user_says == 'approved'"
        - "user_says == 'go'"
    actions:
      - PROCEED
    source: "010-approval-gate.md §Explicit Authorization Priority"

  - id: approval-gate-003
    title: "No authorization without user input"
    conditions:
      all:
        - "has_authorization == false"
        - "needs_approval_label == true"
    actions:
      - HALT
    source: "010-approval-gate.md §Explicit Authorization Priority"

  - id: approval-gate-004
    title: "Branch first before any file modification"
    conditions:
      all:
        - "has_feature_branch == false"
    actions:
      - HALT
    source: "010-approval-gate.md §Mandatory Requirements"

  - id: approval-gate-005
    title: "Agents must never merge PRs"
    conditions:
      all:
        - "is_agent == true"
    actions:
      - HALT
    source: "010-approval-gate.md §Mandatory Requirements"

  - id: approval-gate-006
    title: "Spec revision revokes linked plan approvals"
    conditions:
      all:
        - "spec_revised == true"
        - "has_linked_plan == true"
    actions:
      - REVOKE(plan_approval)
      - INVOKE(re-implementation-workflow)
    source: "010-approval-gate.md §Revision Revokes Approval"

  - id: approval-gate-008
    title: "Audit auto-fix exempt from authorization when conditions met"
    conditions:
      all:
        - "audit_deliberately_invoked == true"
        - "finding_classification == 'auto-fix'"
        - "fix_target == 'github-issue-body'"
        - "fix_non_substantive == true"
    actions:
      - PROCEED
    source: "010-approval-gate.md §Audit Auto-Fix Exemption"

  - id: approval-gate-009
    title: "Conditional audit fixes require authorization"
    conditions:
      all:
        - "audit_deliberately_invoked == true"
        - "finding_classification == 'conditional'"
    actions:
      - HALT
    source: "010-approval-gate.md §Audit Auto-Fix Exemption"

  - id: approval-gate-010
    title: "Pipeline-scoped authorization extends to scope horizon"
    conditions:
      all:
        - "authorization_scope != 'standard'"
    actions:
      - GAP_FILL(scope)
      - PROCEED_TO(halt_at)
      - HALT_AT(halt_at)
    source: "010-approval-gate.md §Authorization Scope Model"

  - id: approval-gate-011
    title: "Hard HALT at scope boundary without re-authorization"
    conditions:
      all:
        - "pipeline_stage > halt_at"
    actions:
      - HALT
    source: "010-approval-gate.md §Authorization Scope Model"

  - id: approval-gate-012
    title: "Unified dispatch path — no single-task exemption"
    conditions:
      all:
        - "has_approved_plan == true"
    actions:
      - INVOKE(divide-and-conquer)
    source: "010-approval-gate.md §Unified Dispatch Path"

  - id: approval-gate-014
    title: "for_pr scope auto gap-fill — no halt for structural decisions"
    conditions:
      all:
        - "authorization_scope == 'for_pr'"
        - "agent_halted_for_structural_decision == true"
    actions:
      - PROCEED_WITH_GAP_FILL
    source: "010-approval-gate.md §Authorization Scope Model"
```
