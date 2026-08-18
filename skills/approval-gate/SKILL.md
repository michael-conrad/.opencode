---
name: approval-gate
description: "Authorization gatekeeper that verifies authorization scope, applies approval labels, and routes to downstream skills. Load via skill() when the agent needs to verify authorization scope, apply approval labels, handle spec revision revocation, or execute bug discovery protocol. Also load when checking approval state, enforcing pipeline halt boundaries, or managing spec-to-plan cascade. Authorization verification is REQUIRED before any implementation. User phrases: verify authorization, check approval, apply label, approved, go, authorization, spec revision, bug discovery"
license: MIT
compatibility: opencode
provenance: AI-generated
---

# Skill: approval-gate

## Overview

Authorization gatekeeper that handles scope verification, label management, spec-to-plan cascade, revision revocation, and bug discovery protocol. This skill is a pure dispatcher — it routes to task files and does not perform inline work. All authorization verification is delegated to clean-room sub-agents that independently read issue state.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "verify authorization" / "check approval" / "approved" / "go" | `resolve-scope` | `sub-task` | {issue_number, authorization_scope} |
| "apply label" / "set approval label" | `apply-label` | `sub-task` | {issue_number, authorization_scope} |
| "route" / "auto-dispatch" / "next step" | `route` | `sub-task` | {authorization_scope, halt_at, pipeline_phase} |
| "spec revision" / "spec revised" | `resolve-scope` | `sub-task` | {issue_number, authorization_scope, is_revision: true} |
| "bug discovery" / "bug found during implementation" | `resolve-scope` | `sub-task` | {issue_number, bug_description} |
| "release PR" / "release authorization" | `resolve-scope` | `sub-task` | {issue_number, authorization_scope, is_release: true} |

## Invocation

`skill({name: "approval-gate"})` — call the skill, then dispatch to the task:

| Task | Canonical Dispatch String |
|------|--------------------------|
| `resolve-scope` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [resolve authorization scope from chat](.opencode/skills/approval-gate/tasks/resolve-scope.md). issue_number: ", issue_number, ", authorization_scope: ", authorization_scope))` |
| `apply-label` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [apply approved-for label](.opencode/skills/approval-gate/tasks/apply-label.md). issue_number: ", issue_number, ", authorization_scope: ", authorization_scope))` |
| `route` | `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [route to next pipeline step](.opencode/skills/approval-gate/tasks/route.md). authorization_scope: ", authorization_scope, ", halt_at: ", halt_at, ", pipeline_phase: ", pipeline_phase))` |

## Persona

Authorization scope gatekeeper. Verifies scope, cascade, and halt boundaries by dispatching to sub-agents that independently read issue state. An orchestrator that checks authorization inline instead of dispatching to a verification sub-agent has produced a self-certification, not an independent gate — every authorization claim carries the orchestrator's cached context, and the separation between the agent seeking approval and the agent verifying it is collapsed. Professional gatekeepers dispatch to independent verifiers. Inlining means the gate was never independent.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. No inline work — all tasks use sub-agents. If a sub-agent returns empty, re-task with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/OVERFLOW) + task-specific fields.

## Workflows

### Verify authorization (3-step path)

- [ ] 1. **Resolve scope** — Parses authorization text and resolves scope/halt_at
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [resolve authorization scope from chat](.opencode/skills/approval-gate/tasks/resolve-scope.md). issue_number: ", issue_number))`
  - **Context passed:** `{issue_number, issues_prefix, project_root}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

- [ ] 2. **Apply label** — Writes authorization-scope label
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [apply approved-for label](.opencode/skills/approval-gate/tasks/apply-label.md). issue_number: ", issue_number))`
  - **Context passed:** `{issue_number, issues_prefix, project_root}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

- [ ] 3. **Route** — Scope-aware auto-route to next skill
  - **Prompt:** `task(subagent_type="general", prompt: concat("You are a sub-agent. Follow the instructions in [route to next pipeline step](.opencode/skills/approval-gate/tasks/route.md). issue_number: ", issue_number, ", authorization_scope: ", authorization_scope, ", halt_at: ", halt_at, ", pipeline_phase: ", pipeline_phase))`
  - **Context passed:** `{issue_number, issues_prefix, project_root}`
  - **Returns:** `{status, finding_summary, artifact_path, blocker_reason}`
  - **Execution mode:** sub-agent dispatch

## Authorization Scope Model

### Scope Values

| Scope | HALT After | PR Strategy |
|-------|-----------|-------------|
| `for_review_prep` | review-prep | none |
| `for_spec` | spec_created | none |
| `for_plan` | plan_created | none |
| `for_implementation` | verification_complete | none |
| `for_pr` | pr_created | stacked |
| `for_release_pr` | pr_created | stacked |
| `for_analysis` | analysis_complete | none |

### Verb-Prefix Parsing Table

| Phrase | Scope |
|--------|-------|
| "approved #N" (no qualifier) | `for_analysis` |
| "approved #N for spec" | `for_spec` |
| "approved #N for plan" | `for_plan` |
| "approved #N for implementation" | `for_implementation` |
| "approved #N to PR" / "approved #N for PR" | `for_pr` |
| "approved #N for release PR" | `for_release_pr` |
| "approved #N for review" | `for_review_prep` |

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

### Bug Discovery Protocol (CRITICAL)

**Discovering a bug during implementation does NOT authorize the agent to fix it.** The agent MUST:

1. Report the bug as a spec issue (see [Bug Report Response](skills/issue-operations/SKILL.md))
2. HALT the current implementation
3. Wait for developer decision — continue with current scope or switch to bug fix

## DISPATCH_GATE — Orchestrator task() Prompt Protocol

The orchestrator MUST NOT preload execution context into `task()` prompts. Every sub-agent MUST independently discover scope and produce its own result contract.

### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read the task file then execute step 1" | "execute resolve-scope from approval-gate" |
| Preloaded step sequences | "Step 1: check scope. Step 2: apply label." | "execute resolve-scope from approval-gate" |
| Preloaded expected outcomes | "Return { authorization_status }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The spec was just revised so we need to..." | Pure objective, no narrative |

### Dispatch Context Contract

Every `task()` call MUST include only:
- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the Sub-Agent Routing section above.

### Orchestrator Entry Criteria

Reading the Trigger Dispatch Table and Invocation section in the orchestrator's own context is small, necessary, routing-relevant work assigned to the orchestrator by allocation-by-context-cost: the skill card is routing metadata the orchestrator must hold, and sub-agents cannot call `skill()` or load skills. The no-preloaded-context substance below is unchanged.

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- The orchestrator MUST NOT read task file content — it only receives result contracts from sub-agents
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Skills: `git-workflow`, `git-workflow-pr`, `issue-review`, `writing-plans`, `pre-analysis`, `audit`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`, `020-go-prohibitions.md`.
