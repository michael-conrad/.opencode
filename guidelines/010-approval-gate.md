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
| 9 | PR requires explicit instruction (except `for_pr` scope) | critical-rules-019 | `pr-creation-workflow` skill |
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
- **Release PR gate:** When `authorization_scope >= for_pr` and context is a release PR, agent MUST evaluate the skill deck before any action.

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

Defines where the pipeline halts after a given authorization scope and the PR strategy.

#### Key Scope Values

| Scope | HALT After | PR Strategy |
|-------|-----------|-------------|
| `for_review_prep` | review-prep | none |
| `for_spec` | spec_created | none |
| `for_plan` | plan_created | none |
| `for_implementation` | verification_complete | none |
| `for_pr` | pr_created | stacked |
| `for_release_pr` | pr_created | stacked |
| `for_analysis` | analysis_complete | none |


#### Scope-Dependent PR Strategy

- **stacked:** Feature PR targets the trunk. No PR for spec/plan-only scopes.
- **none:** No PR — only spec or plan creation.

### Authorization Scope Is Permission, Not a Pipeline Shortcut (CRITICAL)

**Authorization scope defines what the agent MAY do, not what it MUST do now.**

`for_pr` scope means: "you are authorized to proceed through the full pipeline (plan → implement → PR)." It does NOT mean "skip to implementation." The agent MUST still:
1. Create a plan from the spec (via `writing-plans`)
2. Present the plan
3. Execute the plan step-by-step
4. Create the PR

A question is NEVER authorization. A scope approval is NEVER a skip-the-pipeline directive. The pipeline sequence (spec → plan → implement → PR) is invariant — no authorization scope compresses it.

### Multi-Task Plan Authorization (CRITICAL)

When a parent issue has sub-issues with different `halt_at` values, authorization for the parent cascades to ALL sub-issues. The agent completes ALL phases in sequence without halting between them, reporting ONCE after all phases complete.

**Exception:** Developer explicitly names a phase (e.g., "approved: Phase 2 only") — complete that phase ONLY, then HALT.

### Authorization Set Carry-Forward

Authorization sets persist across scope transitions. If a developer approves `for_implementation` scope and later expands to `for_pr`, the existing authorization carries forward — no re-authorization needed for the expanded scope.

### Revision Revokes Approval (MANDATORY)

**Spec revision revokes all linked plan approvals.** If a spec is revised after a plan was approved (via cascade or direct), the linked plan approval is automatically revoked. The plan must be updated to match the revised spec and re-approved before any implementation proceeds.

#### Pipeline-Initiated Non-Substantive Revision Exception

Pipeline-initiated non-substantive spec revisions are exempt from the revocation rule. When a pipeline gate (e.g., SC-coherence gate) detects a spec defect and the orchestrator revises the spec to fix it, the linked plan approval is NOT revoked — the plan is auto-updated via `writing-plans --task update` and the pipeline continues without requiring re-authorization.

**Non-substantive** means: changes to evidence types, verification methods, artifact paths, or SC wording that do NOT alter the implementation intent, scope, or success criteria semantics. Substantive changes (new SCs, removed SCs, changed scope, changed implementation approach) still require re-authorization per `approval-gate-006`.

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
| Create investigation branch (`observe/*`) | No (must discard before HALT under `for_analysis`) |
| Write code, modify files | Yes |
| Create PR | Yes (except `for_pr` scope) |
| Merge PR | No — human-only |
| Close issues | Yes (after PR merge confirmed) |
| Delete branches | Yes |
| Modify git config | Yes (except exempt keys) |
| Run tests, verification | No |

### `for_analysis` Scope — Allowlist and Blocklist

The `for_analysis` scope is the default floor scope when no authorization is given. It is also the ONLY scope an agent may self-assign. Under `for_analysis`, the agent operates in read-only investigation mode.

#### ✅ Allowlist

- Read files, search code, browse issues
- Write to `{project_root}/tmp/` for investigation artifacts and throwaway scripts
- Create/update GitHub Issues (specs, plans, bug reports)
- Add labels and comments to GitHub Issues
- Run tests and verification commands
- Create `observe/<topic>` scratch branches (MUST be discarded before HALT)

#### 🚫 Blocklist

- Writing to `src/`, `test/`, or any permanent project directory
- Creating feature branches (`feature/*`, `spec/*`)
- Creating pull requests
- Committing to the trunk (`$DEFAULT_BRANCH`)
- Closing issues after PR merge
- Deleting branches (except discarding `observe/*` branches)
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
