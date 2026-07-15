---
name: approval-gate-scope
description: "Dispatch when the agent needs to verify authorization scope, apply approval labels, handle spec revision revocation, or execute bug discovery protocol. Also dispatch when the agent needs to check approval state, enforce pipeline halt boundaries, or manage spec-to-plan cascade. Triggers when: agent determines authorization verification is needed, agent needs to apply or remove approved-for-* labels, agent detects a spec revision that revokes plan approval, agent discovers a bug during implementation."
license: MIT
provenance: AI-generated
---

# Skill: approval-gate-scope

## Overview

Authorization scope sub-skill of the approval-gate. Handles scope verification, label management, spec-to-plan cascade, revision revocation, and bug discovery protocol. This skill is a pure dispatcher — it routes to task files and does not perform inline work. All authorization verification is delegated to clean-room sub-agents that independently read issue state and comments.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "verify authorization" / "check approval" | `verify-authorization` | `sub-task` | {issue_number, authorization_scope} |
| "screen issue" / "triage" | `screen-issue` | `sub-task` | {issue_number} |
| "pre-implementation analysis" | `pre-implementation-analysis` | `sub-task` | {issue_numbers} |
| "verify blockers" | `verify-blockers` | `sub-task` | {issue_number} |
| "verify closed issue" | `verify-closed-issue` | `sub-task` | {issue_number} |
| "spec-to-plan cascade" | `spec-to-plan-cascade` | `sub-task` | {spec_issue, plan_issue} |
| "item decomposition check" | `item-decomposition-check` | `sub-task` | {plan_issue} |
| "auto-dispatch" | `auto-dispatch` | `sub-task` | {authorization_scope} |
| "verify already implemented" | `verify-already-implemented` | `sub-task` | {issue_number} |
| "approval cascade" / "cascade authorization" | `approval-cascade` | `sub-task` | {parent_issue, sub_issues} |
| "pipeline halt boundary" / "check halt_at" | `check-halt-boundary` | `sub-task` | {authorization_scope, halt_at, pipeline_phase} |
| "apply label" / "set approval label" | `apply-label` | `sub-task` | {issue_number, authorization_scope} |
| "revision revocation" / "spec revised" | `revision-revocation` | `sub-task` | {spec_issue, plan_issue} |
| "bug discovery" / "bug found during implementation" | `bug-discovery-protocol` | `sub-task` | {issue_number, bug_description} |
| "verify plan pipeline" / "check pipeline completeness" | `verify-plan-pipeline` | `sub-task` | {issue_number} |
| "verify fix spec" / "check fix spec" | `verify-fix-spec` | `sub-task` | {issue_number} |
| "verify open questions" | `verify-open-questions` | `sub-task` | {issue_number} |
| "verify QA mode" / "Q/A mode" | `verify-qa-mode` | `sub-task` | {issue_number} |
| "verify sub-issues" | `verify-sub-issues` | `sub-task` | {plan_issue} |
| "reconcile issue graph" | `reconcile-issue-graph` | `sub-task` | {issue_number} |
| "gap-fill cascade" | `gap-fill-cascade` | `sub-task` | {authorization_scope, issue_number} |
| "authorization context" | `authorization-context` | `sub-task` | {authorization_scope, halt_at, pipeline_phase} |
| "column validation" | `column-validation` | `sub-task` | {issue_number, authorization_scope} |
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |
| "release PR" / "release authorization" | `verify-authorization` | `sub-task` | {issue_number, authorization_scope, is_release: true} |

## Persona

Authorization scope gatekeeper. Verifies scope, cascade, and halt boundaries by dispatching to sub-agents that independently read issue state and comments. An orchestrator that checks authorization inline instead of dispatching to a verification sub-agent has produced a self-certification, not an independent gate — every authorization claim carries the orchestrator's cached context, and the separation between the agent seeking approval and the agent verifying it is collapsed. Professional gatekeepers dispatch to independent verifiers. Inlining means the gate was never independent.

## Sub-Agent Routing

All tasks run via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. Read [audit SKILL.md §DISPATCH_GATE](skills/audit/SKILL.md). `screen-issue` receives issue body + authorization context + pipeline_phase. `pre-implementation-analysis` receives all issue numbers + authorization context + pipeline_phase. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }` with zero file paths. No inline work — all tasks use sub-agents. If a sub-agent returns empty, re-task with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas. `DONE_WITH_CONCERNS` is coerced to FAIL per the bright-line coercion rule in the implementation-pipeline SKILL.md Trigger Dispatch Table.

### Authorization Context Template

Read [the authorization context template and routing rules](skills/approval-gate-scope/tasks/authorization-context.md).

### Column Validation Rules

Read [the pre-approval gate column validation rules](skills/approval-gate-scope/tasks/column-validation.md).

### Enforcement Modules

| Module | Purpose |
|--------|---------|
| `enforcement/auto-dispatch-table.md` | Auto-dispatch routing based on authorization scope and issue state |
| `enforcement/scope-parsing.md` | Verb-prefix parsing table for authorization scope resolution |
| `enforcement/adversarial-verification.md` | Evidence artifact format and finding classification for verification checkpoints |
| `enforcement/closed-issue-verification.md` | Closed state verification procedure and state reason classification |
| `enforcement/sub-issue-graph-traversal.md` | Sub-issue graph traversal algorithm with depth limits and edge types |
| `enforcement/work-state-schema.md` | Work state file schema for chain-of-responsibility orchestration |

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read verify-authorization/scope-auto-resolve.md then execute step 1" | "execute verify-authorization from approval-gate-scope" |
| Preloaded step sequences | "Step 1: parse scope. Step 2: check authorization." | "execute verify-authorization from approval-gate-scope" |
| Preloaded expected outcomes | "Return { authorized, scope }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The user just said approved so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute verify-authorization from approval-gate-scope" without task file path | "execute verify-authorization from approval-gate-scope. Read `approval-gate-scope/tasks/verify-authorization.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from approval-gate-scope. Read `approval-gate-scope/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

### Dispatch Context Contract

Every `task()` call MUST include only:

- `worktree.path`
- `github.owner`
- `github.repo`
- `authorization_scope`
- `halt_at`
- `pipeline_phase`

Plus skill-specific fields per the `## Sub-Agent Routing` section above.

Exclusions (MUST NOT be in prompt):
- `orchestrator_reasoning`
- `expected_outcomes`
- `inline_file_paths`
- `agent_memory`
- `cached_verification_results`

### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- The orchestrator MUST NOT read task file content — it only receives result contracts from sub-agents
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References

Parent skill: `approval-gate`. Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `implementation-pipeline`, `writing-plans`, `executing-plans`, `pre-analysis`, `audit`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`, `020-go-prohibitions.md`.
