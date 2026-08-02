---
trigger_on: approved, go, authorization, approve, approval-gate, spec-before-code
tier: 1
load_when: sub-agent
---

# Approval Gate

**Enforced by `hooks/pre-commit` Gate 2b (authorization_scope + halt_at check).** Read [approval-gate skill](skills/approval-gate/SKILL.md) for complete procedural workflow.

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
| 8 | Search before halt (no spec found) | — | Read [Silent Halt](000-critical-rules.md) |
| 9 | PR requires explicit instruction (except `for_pr` scope) | critical-rules-019 | `git-workflow-pr` skill |
| 10 | Close issues only after PR merge confirmed (verified by check-pr Phase 2) | critical-rules-013 | `git-workflow cleanup` |
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

Pipeline-initiated non-substantive spec revisions are exempt from the revocation rule. When a pipeline gate (e.g., SC-coherence gate) detects a spec defect and the orchestrator revises the spec to fix it, the linked plan approval is NOT revoked — the plan is auto-updated via `task("execute revise from writing-plans")` and the pipeline continues without requiring re-authorization.

**Non-substantive** means: changes to evidence types, verification methods, artifact paths, or SC wording that do NOT alter the implementation intent, scope, or success criteria semantics. Substantive changes (new SCs, removed SCs, changed scope, changed implementation approach) still require re-authorization per `approval-gate-006`.





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

### [critical-rules-010] Implementation Without Spec — expanding the definition
Modifying behavior, config, or enforcement without an approved spec is what amateurs do when they want their changes to break the build and waste everyone's review time. Professional engineers produce a spec first — then implement against it. Read [010-approval-gate.md](guidelines/010-approval-gate.md).


### [critical-rules-010] Spec Without Investigation
Professional engineers inspect the codebase before writing a spec — live verification prevents assumptions. Amateurs spec from memory and training data — then wonder why the implementation doesn't fit the actual code.


### [critical-rules-010] Plan Creation Without Analytical Artifacts — bypassing the artifact gate
Professional engineers verify all 7 analytical artifacts exist before plan creation (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). Amateurs skip artifact verification and produce plans disconnected from codebase reality — then wonder why every phase encounters a dependency or constraint the artifacts would have caught. The artifact gate is enforced at the writing-plans TDT entry, Entry Criteria, pre-plan-readiness task, and spec-to-plan handoff manifest. Skipping any of these gates means the plan was never structurally validated against the spec.

**Artifact generation:** The 7 analytical artifacts are generated by `writing-plans/tasks/backfill.md` (dispatched with `mode: retroactive` context for retroactive generation of pre-existing artifacts). Artifacts are stored at `{project_root}/{path}/.issues/{N}/artifacts/{name}.yaml`. **Artifact validation:** `writing-plans/tasks/create.md` Step 4a validates artifact existence before plan creation. Missing artifacts produce BLOCKED with `MISSING_SPEC_ARTIFACT`, with auto-generation fallback via retroactive mode.


### [critical-rules-011] Bug Discovery Does NOT Authorize Bug Fixing
Finding a bug during implementation does NOT mean you have permission to fix it. Professional engineers stop, report the bug as a spec issue, and wait for authorization — amateurs assume discovery is a license to act.


### [critical-rules-011] Symptom-Only Fix-Specs — patches without root cause analysis
Writing a fix spec that only addresses symptoms means you are leaving the root cause in place for the next person to find. Professional engineers always identify root cause in fix specs — amateurs patch symptoms and call it done.


### [critical-rules-009] Conflating Issue References with Authorization Cascade
Only formal `github_sub_issue_write` links trigger cascade. Professional engineers only cascade authorization through formal `github_sub_issue_write` links — amateurs read implied permission into every cross-reference.


### [critical-rules-016] Skipping Interdependency Analysis for Batch Approvals
Approving batches without understanding interdependencies means approving work that silently conflicts with other work. Professional engineers analyze interdependencies before every batch approval — amateurs batch first and find conflicts in CI.


### [critical-rules-018] Pipeline-Scoped Authorization with Hard HALT at Scope Boundary
Read [approval-gate skill](skills/approval-gate/SKILL.md) → Authorization Scope Model.


### [critical-rules-018] Stopping After Single Phase in Multi-Task Plan
Complete ALL phases, report ONCE, HALT ONCE. Read [approval-gate skill](skills/approval-gate/SKILL.md).


### [critical-rules-013] Assuming Closed Issues Are Verified
Read [approval-gate --task verify-closed-issue](skills/approval-gate/SKILL.md) and [--task reconcile-issue-graph](skills/approval-gate/SKILL.md).


### [critical-rules-019] Creating PRs Without Explicit Instruction
Exception: `for_pr` scope authorizes PR creation.


### [critical-rules-018] Ignoring Spec-to-Plan Approval Cascade
Spec approved + faithful plan exists = plan auto-approved.


### [critical-rules-037] Structural Decision Solicitation Under for_pr Scope
No `question` tool for structural decisions when `halt_at >= pr_created`.


