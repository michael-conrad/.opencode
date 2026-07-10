---
name: approval-gate
description: "Use when checking or enforcing authorization scope, approval cascade, pipeline halt boundaries, label application, spec-to-plan cascade, revision revocation, and bug discovery protocol. Also use when verifying authorization state, applying approved-for-* labels, or handling re-implementation after spec revision. Invoke for: authorization check, scope verification, cascade enforcement, halt boundary check, label application, spec-to-plan cascade, revision revocation, bug discovery protocol. All conditions are MANDATORY — no implementation without authorization. Trigger phrases: check authorization, verify scope, enforce cascade, apply label, approve, go, authorized, revision revokes approval, bug discovery protocol."
license: MIT
compatibility: opencode
---

## Persona

Authorization gatekeeper. Verifies scope, cascade, and halt boundaries by dispatching to sub-agents that independently read issue state and comments. An orchestrator that checks authorization inline instead of dispatching to a verification sub-agent has produced a self-certification, not an independent gate — every authorization claim carries the orchestrator's cached context, and the separation between the agent seeking approval and the agent verifying it is collapsed. Professional gatekeepers dispatch to independent verifiers. Inlining means the gate was never independent.

## Worktree Mode

This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.

## Mandatory Task Discipline

- [ ] 1. Every task and sub-task in this skill is mandatory
- [ ] 2. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables that must be discarded
- [ ] 3. Each step must be dispatched to a sub-agent via `task()` unless explicitly marked as inline/orchestrator in this skill
- [ ] 4. Return only routing-significant data: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

Sub-Agent Task Context Audit

All tasks run via `task(subagent_type="general")`. Standard context: `{ issue_number, worktree.path, github.owner, github.repo, authorization_scope, halt_at, pipeline_phase }`. Auditor tasks use subagent_type from resolve-models result contract (auditor_1/auditor_2) — NOT `general`. Include audit_phase in task context when routing auditors. See audit SKILL.md §DISPATCH_GATE. `screen-issue` receives issue body + authorization context + pipeline_phase. `pre-implementation-analysis` receives all issue numbers + authorization context + pipeline_phase. `pre-analysis` receives only `{ issue_number, task_description, pipeline_phase, authorization_scope, halt_at, github.owner, github.repo }` with zero file paths. No inline work — all tasks use sub-agents. If a sub-agent returns empty, re-task with original scoped context only (max 2 retries). Result contracts return `status` (DONE/BLOCKED/OVERFLOW) + task-specific fields per `enforcement/` result contract schemas. `DONE_WITH_CONCERNS` is coerced to FAIL per the bright-line coercion rule in the implementation-pipeline SKILL.md Trigger Dispatch Table.

### Authorization Context Template

See `approval-gate/tasks/authorization-context.md` for the authorization context template and routing rules.

### Column Validation Rules

See `approval-gate/tasks/column-validation.md` for the pre-approval gate column validation rules.

### DISPATCH_GATE — Orchestrator task() Prompt Protocol

> **Context cost frame:** These are internal operational bookkeeping notes describing how context flows through the pipeline — they are NOT implementation complexity measures. Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS.
> This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output.

The orchestrator MUST NOT preload execution context into `task()` prompts.
Every sub-agent MUST independently discover scope and produce its own result contract.

#### Forbidden in task() Prompts

| Violation | Forbidden Pattern | Correct Pattern |
|-----------|-------------------|-----------------|
| Preloaded file paths | "Read cleanup/branch-cleanup.md then execute step 1" | "execute cleanup task from git-workflow" |
| Preloaded step sequences | "Step 1: sync $DEFAULT_BRANCH. Step 2: delete branch." | "execute cleanup task from git-workflow" |
| Preloaded expected outcomes | "Return { cleanup_status, branch_deleted }" | Let sub-agent define its own result contract |
| Preloaded orchestrator reasoning | "The merge was just completed so we need to..." | Pure objective, no narrative |
| Missing task file discovery directive | "execute verify-authorization from approval-gate" without task file path | "execute verify-authorization from approval-gate. Read `approval-gate/tasks/verify-authorization.md` first" |

## Required: Sub-agent Task File Discovery Directive

Every `task()` prompt that dispatches a named task MUST include a discovery directive in the format:

```
execute <task> from <skill>. Read `<skill>/tasks/<task>.md` first
```

This directive tells the sub-agent which task file to load independently — it is NOT preloading the file content. The sub-agent opens and reads the task file in its own clean-room context, discovers the procedure, and executes autonomously. Without this directive, the sub-agent must search for the correct task file, which is wasted context and routing ambiguity.

This is NOT a violation of the preloading prohibition. The task file path is routing metadata (which file to load), not execution context (what the file contains). The sub-agent still reads the file independently and discovers scope on its own.

#### Dispatch Context Contract

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

#### Sub-Agent Entry Criteria

A sub-agent receiving a `task()` prompt MUST reject it if the prompt contains:
- Inline file paths to task files
- Inline step or procedure definitions
- Expected outcome structures or schema constraints
- Pre-loaded evidence or orchestrator-derived conclusions

Return `status: BLOCKED` with `reason: PRELOADED_CONTEXT_REJECTED`.

#### Orchestrator Entry Criteria

After loading this skill and reading the Trigger Dispatch Table, the orchestrator MUST:
- Use the exact `task(..., prompt: "...")` string from the table
- NOT write a custom prompt with preloaded context
- NOT add orchestrator reasoning, file paths, step sequences, or expected outcomes
- The orchestrator MUST NOT read task file content — it only receives result contracts from sub-agents
- If the canonical dispatch produces an empty result: re-task clean-room with the same canonical string (max 2 retries)

## Cross-References


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
| completion / workflow end | `completion` | `sub-task` | {workflow_state} |
| "release PR" / "release authorization" | `verify-authorization` | `sub-task` | {issue_number, authorization_scope, is_release: true} |

Skills: `git-workflow`, `pr-creation-workflow`, `issue-review`, `implementation-pipeline`, `writing-plans`, `executing-plans`, `pre-analysis`. Guidelines: `010-approval-gate.md`, `000-critical-rules.md`, `065-verification-honesty.md`.


