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
| 9 | PR requires explicit instruction (except `for_pr`/`for_pr_only`) | critical-rules-019 | `pr-creation-workflow` skill |
| 10 | Close issues only after PR merge confirmed | critical-rules-013 | `git-workflow cleanup` |
| 11 | Spec-to-Plan cascade (auto-approve faithful plan) | approval-gate-001a-cascade | `approval-gate` skill |
| 12 | Pipeline-scoped authorization with hard HALT at boundary | approval-gate-010/011 | `approval-gate` skill |
| 13 | Issue creation = reporting, NOT implementation (no auth required) | — | `issue-operations` skill |
| 14 | Bug discovery ≠ bug fixing authorization | critical-rules-011 | `approval-gate` skill |

### Mandatory Requirements

- **Spec before code:** Every code change requires an approved spec
- **Plan before implementation:** Every implementation requires an approved plan
- **Branch first:** Create feature branch before any file modification
- **Explicit authorization:** "approved" or "go" — implicit, rhetorical, or complaint-based authorization is invalid
- **Label application:** Apply `approved-for-*` label on authorization
- **Human-only merge:** Agent never merges PRs

### Issue Creation Is Reporting, Not Implementation (CRITICAL)

Creating a GitHub Issue is a reporting action, not an implementation action — it does NOT require authorization. This rule prevents the approval-gate from blocking bug reports, feature requests, spec drafts, or any other non-implementation issue.

- ✅ Issue creation (any type: bug, feature, spec, plan, question) does NOT require authorization
- ✅ Spec creation does NOT require authorization — spec content IS the authorization request
- ✅ Adding labels, comments, or assigning issues does NOT require authorization
- 🚫 Creating a branch, writing code, or modifying files still requires authorization (separate step)
- 🚫 Issue creation is NOT a backdoor to implementation — creating a spec issue does not authorize implementing it

### Spec-to-Plan Approval Cascade (Critical)

An approved spec auto-approves a faithful plan. This prevents redundant authorization requests when the plan faithfully reflects the spec.

**Cascade rule:** When a faithful plan exists for the approved spec, `approval-gate-001a-cascade` auto-approves the plan without requiring separate developer input. The agent proceeds directly to implementation.

**Revocation:** If the spec is revised after auto-approval, the linked plan approval is revoked per `approval-gate-006`.

#### Edge Cases

| Case | Rule |
|------|------|
| Spec approved, no plan written yet | Must create plan (call `writing-plans`), NO authorization needed for plan creation |
| Faithful plan approved via cascade, then spec revised | Cascade approval revoked — must update plan and get new approval |
| Unfaithful plan submitted | Must revise plan to match spec; cascade does NOT apply to unfaithful plans |
| Spec approved with `for_spec` scope | No cascade — scope explicitly limits to spec only; plan creation requires scope expansion |

### Mandate Tiering Interaction (Critical)

| Mandate Level | Example | Overridable By |
|--------------|---------|----------------|
| Tier 1 (Safety-Critical) | No direct pushes to main, human-only merge | Never — safety-critical |
| Tier 2 (Process-Integrity) | Approval gate, branch naming | Explicit developer authorization |
| Tier 3 (Workflow-Standard) | Numbering conventions, tool selection | Flag only — no halt |
| Developer override | User says "approved" or "go" | Only applies to Tier 2 |

#### Decision Table: Authorization + File Modifications

| Has Authorization? | Spec/Plan Exists? | Action |
|--------------------|-------------------|--------|
| Yes | Yes | Proceed with implementation |
| Yes | No | Create spec (authorization cascades to spec creation) |
| No | Yes | HALT — authorization required before implementation |
| No | No | HALT — spec and authorization both required |

### Explicit Authorization Priority (Critical)

| Phrase | Means | Authorization? |
|--------|-------|---------------|
| "approved" or "go" | Explicit authorization | Yes |
| "what would happen if X" | Rhetorical question | No |
| "can you explain Y" | Information request | No |
| "Z is broken" | Bug report | Creates issue, not authorization |
| "the deadline is Friday" | Context/narrative | No |
| "confirmed" or "looks good" | Confirmation of understanding | No — confirmation ≠ authorization |
| "fix the spacing" or "add validation" | Feedback on approach | No — feedback ≠ authorization |

### Authorization Scope

Authorization scope determines what the agent is authorized to do between approvals. The scope is set by the authorization message and constrains all subsequent work.

| Scope Source | How Determined |
|-------------|----------------|
| `authorization_scope` in developer message | Explicit scope keyword in authorization |
| `approved-for-*` label on issue | Implicit scope from issue labels |
| `halt_at` from previous scope | Continuation scope when resuming |
| Default (no scope) | `for_analysis` — HALT after analysis_complete |

### Authorization Scope Model (CRITICAL)

Defines where the pipeline halts after a given authorization scope, what gap-fill actions to auto-perform, and the PR strategy.

#### Key Scope Values

| Scope | HALT After | Gap-Fill | PR Strategy |
|-------|-----------|----------|-------------|
| `for_review_prep` | review-prep | None | individual |
| `for_spec` | spec_created | None | none |
| `for_plan` | plan_created | auto-create spec | none |
| `for_implementation` | implementation_complete | auto-create spec+plan+auto-approve | individual |
| `for_pr` | pr_created | auto-create spec+plan+auto-approve+auto-PR | stacked |
| `for_pr_only` | pr_created | None | stacked |
| `for_review_only` | code_review_ready | None | individual |
| `for_analysis` | analysis_complete | None | none |

#### Unified Pipeline Path (Work-of-1)

**Work-of-1 requires unified pipeline task() — NOT per-task authorization.** Authorization for a phase (e.g., "implement") means authorizing ALL sub-issues under that phase within a single sequential pipeline, each tasked via `task(subagent_type="general")`. The agent does NOT treat each sub-issue as requiring separate developer authorization.

#### Scope-Dependent PR Strategy

- **stacked:** Feature PR targets dev. No PR for spec/plan-only scopes.
- **individual:** Single PR per issue. Standard workflow.
- **none:** No PR — only spec or plan creation.

#### Gap-Fill Cascade

When scope includes gap-fill, the agent auto-creates missing artifacts:

1. `for_plan` scope: auto-create spec before plan
2. `for_implementation` scope: auto-create spec → auto-create plan → auto-approve
3. `for_pr` scope: auto-create spec → auto-create plan → auto-approve → auto-create PR

### Multi-Task Plan Authorization (CRITICAL)

When a parent issue has sub-issues with different `halt_at` values, authorization for the parent cascades to ALL sub-issues. The agent completes ALL phases in sequence without halting between them, reporting ONCE after all phases complete.

**Exception:** Developer explicitly names a phase (e.g., "approved: Phase 2 only") — complete that phase ONLY, then HALT.

### Authorization Set Carry-Forward

Authorization sets persist across scope transitions. If a developer approves `for_implementation` scope and later expands to `for_pr`, the existing authorization carries forward — no re-authorization needed for the expanded scope.

### Revision Revokes Approval (MANDATORY)

**Spec revision revokes all linked plan approvals.** If a spec is revised after a plan was approved (via cascade or direct), the linked plan approval is automatically revoked. The plan must be updated to match the revised spec and re-approved before any implementation proceeds.

### Re-implementation Workflow

When `approval-gate-006` fires (spec revision revokes plan approval):

1. Clear the revoked approval markers
2. Update plan to match revised spec (call `writing-plans`)
3. Present updated plan for developer approval
4. On approval, re-enter the implementation pipeline

### Label Handling

- **Apply label:** On authorization, apply `approved-for-<scope>` label to the issue
- **Remove label:** On completion/closure, remove `approved-for-*` label
- **No label = no approval:** Absence of `approved-for-*` label means the issue has NOT been authorized for that scope
- **Multiple labels:** An issue may have multiple `approved-for-*` labels for different scopes (e.g., `approved-for-spec` and `approved-for-implementation`)

### Bug Report Response

When a bug is reported via GitHub Issue or developer message:

1. The bug IS a spec — create a spec issue from the bug report
2. The agent does NOT propose implementing any fix — creating the spec is sufficient
3. Do NOT ask "do you want me to fix this" — the spec IS the response
4. The bug spec goes through standard spec→plan→implementation pipeline

### Audit Auto-Fix Exemption

Non-substantive GitHub Issue body formatting fixes found during deliberately-invoked audits are exempt from authorization per `approval-gate-008`. Conditional fixes still require separate authorization per `approval-gate-009`.

### Bug Discovery Protocol (CRITICAL)

**Discovering a bug during implementation does NOT authorize the agent to fix it.** The agent MUST:

1. Report the bug as a spec issue (see Bug Report Response above)
2. HALT the current implementation
3. Wait for developer decision — continue with current scope or switch to bug fix

### Action Authorization Classification

| Action | Authorization Required? |
|--------|------------------------|
| Read files, search code, browse issues | No |
| Create spec/plan issues | No |
| Create feature branch (`feature/*`, `spec/*`) | Yes (requires `for_implementation` or above) |
| Create investigation branch (`investigate/*`) | No (must discard before HALT under `for_analysis`) |
| Write code, modify files | Yes |
| Create PR | Yes (except `for_pr`/`for_pr_only` scope) |
| Merge PR | No — human-only |
| Close issues | Yes (after PR merge confirmed) |
| Delete branches | Yes |
| Modify git config | Yes (except exempt keys) |
| Run tests, verification | No |

### `for_analysis` Scope — Allowlist and Blocklist

The `for_analysis` scope is the default floor scope when no authorization is given. It is also the ONLY scope an agent may self-assign. Under `for_analysis`, the agent operates in read-only investigation mode.

#### ✅ Allowlist

- Read files, search code, browse issues
- Write to `./tmp/` for investigation artifacts and throwaway scripts
- Create/update GitHub Issues (specs, plans, bug reports)
- Add labels and comments to GitHub Issues
- Run tests and verification commands
- Create `investigate/<topic>` scratch branches (MUST be discarded before HALT)

#### 🚫 Blocklist

- Writing to `src/`, `test/`, or any permanent project directory
- Creating feature branches (`feature/*`, `spec/*`)
- Creating pull requests
- Committing to `dev` or `main`
- Closing issues after PR merge
- Deleting branches (except discarding `investigate/*` branches)
- Fixing bugs (requires `for_implementation` or above)
- Any code modification to production files

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
schema_version: "3.0"
last_updated: "2026-05-17T00:00:00Z"
rules:
  - id: approval-gate-001
    tier: 2
    title: "No implementation without authorization"
    conditions:
      all:
        - "has_approved_plan == false"
    actions:
      - HALT
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-001a
    tier: 2
    title: "Spec approval authorizes plan creation, not implementation"
    conditions:
      all:
        - "has_approved_spec == true"
        - "has_approved_plan == false"
        - "has_existing_plan == false"
    actions:
      - HALT
      - CALL(writing-plans)
    requires: [approval-gate-001]
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-001a-cascade
    tier: 2
    title: "Spec approval cascades to existing faithful plan"
    conditions:
      all:
        - "has_approved_spec == true"
        - "has_existing_plan == true"
        - "plan_is_faithful == true"
    actions:
      - HALT
      - AUTO_APPROVE(plan)
      - PROCEED_TO(implementation)
    requires: [approval-gate-001]
    source: "010-approval-gate.md §Spec-to-Plan Approval Cascade"

  - id: approval-gate-001b
    tier: 2
    title: "Plan approval authorizes implementation"
    conditions:
      all:
        - "has_approved_plan == true"
    actions:
      - HALT
      - CALL(executing-plans)
    source: "010-approval-gate.md §Tier0"

  - id: approval-gate-002
    tier: 2
    title: "Explicit authorization applies approved-for-* label"
    conditions:
      any:
        - "user_says == 'approved'"
        - "user_says == 'go'"
    actions:
      - HALT
      - PROCEED
    source: "010-approval-gate.md §Explicit Authorization Priority"

  - id: approval-gate-003
    tier: 2
    title: "No authorization without user input"
    conditions:
      all:
        - "has_authorization == false"
        - "needs_approval_label == true"
    actions:
      - HALT
    source: "010-approval-gate.md §Explicit Authorization Priority"

  - id: approval-gate-004
    tier: 3
    title: "Branch first before any file modification"
    conditions:
      all:
        - "has_feature_branch == false"
    actions:
      - FLAG
    source: "010-approval-gate.md §Mandatory Requirements"

  - id: approval-gate-005
    tier: 1
    title: "CRITICAL VIOLATION — Agents must never merge PRs"
    conditions:
      all:
        - "is_agent == true"
    actions:
      - HALT
    source: "010-approval-gate.md §Mandatory Requirements"

  - id: approval-gate-006
    tier: 2
    title: "Spec revision revokes linked plan approvals"
    conditions:
      all:
        - "spec_revised == true"
        - "has_linked_plan == true"
    actions:
      - HALT
      - REVOKE(plan_approval)
      - RUN(re-implementation-workflow)
    source: "010-approval-gate.md §Revision Revokes Approval"

  - id: approval-gate-008
    tier: 2
    title: "Audit auto-fix exempt from authorization when conditions met"
    conditions:
      all:
        - "audit_deliberately_invoked == true"
        - "finding_classification == 'auto-fix'"
        - "fix_target == 'github-issue-body'"
        - "fix_non_substantive == true"
    actions:
      - HALT
      - PROCEED
    source: "010-approval-gate.md §Audit Auto-Fix Exemption"

  - id: approval-gate-009
    tier: 2
    title: "Conditional audit fixes require authorization"
    conditions:
      all:
        - "audit_deliberately_invoked == true"
        - "finding_classification == 'conditional'"
    actions:
      - HALT
    source: "010-approval-gate.md §Audit Auto-Fix Exemption"

  - id: approval-gate-010
    tier: 2
    title: "Pipeline-scoped authorization extends to scope horizon"
    conditions:
      all:
        - "authorization_scope != 'for_analysis'"
    actions:
      - HALT
      - GAP_FILL(scope)
      - PROCEED_TO(halt_at)
      - HALT_AT(halt_at)
    source: "010-approval-gate.md §Authorization Scope Model"

  - id: approval-gate-011
    tier: 2
    title: "Hard HALT at scope boundary without re-authorization"
    conditions:
      all:
        - "pipeline_stage > halt_at"
    actions:
      - HALT
    source: "010-approval-gate.md §Authorization Scope Model"

  - id: approval-gate-012
    tier: 2
    title: "Unified pipeline path — no single-task exemption"
    conditions:
      all:
        - "has_approved_plan == true"
    actions:
      - HALT
      - CALL(divide-and-conquer)
    source: "010-approval-gate.md §Unified Dispatch Path"

  - id: approval-gate-014
    tier: 2
    title: "for_pr scope auto gap-fill — no halt for structural decisions"
    conditions:
      all:
        - "authorization_scope == 'for_pr'"
        - "agent_halted_for_structural_decision == true"
    actions:
      - HALT
      - PROCEED_WITH_GAP_FILL
    source: "010-approval-gate.md §Authorization Scope Model"
```
